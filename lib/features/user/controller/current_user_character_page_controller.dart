import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/user/assets/model/user_character_snapshot_query.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_repository.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';

part 'current_user_character_page_controller_refresh.dart';

/// 当前用户角色二级页面控制器
class CurrentUserCharacterPageController extends TinygrailPagedListController<
    UserCharacterApiItem, UserCharacterApiItem> {
  /// 创建当前用户角色二级页面控制器
  ///
  /// [snapshotRepository] 用户资产快照仓库
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [onAutomaticRefreshSucceeded] 后台刷新成功回调
  /// [onAutomaticRefreshFailed] 后台刷新失败回调
  /// [readVisibleCharacterIndex] 读取当前可视角色在窗口中的下标
  /// [onBeforeCharacterDataReplaced] 角色分页替换前的滚动位置校正回调
  /// [pageSize] 每页角色数量
  CurrentUserCharacterPageController({
    required UserAssetSnapshotRepository snapshotRepository,
    required String username,
    required String nickname,
    required VoidCallback onAutomaticRefreshSucceeded,
    required VoidCallback onAutomaticRefreshFailed,
    required int? Function() readVisibleCharacterIndex,
    required void Function(
      int previousItemIndex,
      int replacementItemIndex,
      List<UserCharacterApiItem> items,
    ) onBeforeCharacterDataReplaced,
    super.pageSize = defaultPageSize,
  })  : _snapshotRepository = snapshotRepository,
        _username = username.trim(),
        _nickname = nickname.trim(),
        _onAutomaticRefreshSucceeded = onAutomaticRefreshSucceeded,
        _onAutomaticRefreshFailed = onAutomaticRefreshFailed,
        _readVisibleCharacterIndex = readVisibleCharacterIndex,
        _onBeforeCharacterDataReplaced = onBeforeCharacterDataReplaced;

  /// 当前用户角色本地分页数量
  static const int defaultPageSize = 100;

  final UserAssetSnapshotRepository _snapshotRepository;
  final String _username;
  final String _nickname;
  final VoidCallback _onAutomaticRefreshSucceeded;
  final VoidCallback _onAutomaticRefreshFailed;
  final int? Function() _readVisibleCharacterIndex;
  final void Function(
    int previousItemIndex,
    int replacementItemIndex,
    List<UserCharacterApiItem> items,
  ) _onBeforeCharacterDataReplaced;

  bool _isDisposed = false;
  bool _isPageBlockingRefresh = false;
  bool _isChangingSort = false;
  bool _initialPageRequested = false;
  bool _shouldLoadNextPageAfterBlockingRefresh = false;
  bool _suppressAutomaticRefreshFailure = false;
  Future<TinygrailPage<UserCharacterApiItem>>? _initialPageOperation;
  Future<bool>? _characterRefreshOperation;
  Future<bool>? _automaticRefreshOperation;
  Future<bool>? _sortChangeOperation;
  Future<int>? _prependPageOperation;
  UserCharacterSnapshotSort _sort = UserCharacterSnapshotSort.holdings;
  UserCharacterSnapshotSortDirection _direction =
      UserCharacterSnapshotSortDirection.descending;
  UserCharacterSnapshotSort _committedSort = UserCharacterSnapshotSort.holdings;
  UserCharacterSnapshotSortDirection _committedDirection =
      UserCharacterSnapshotSortDirection.descending;
  List<UserCharacterLevelPosition> _levelPositions = const [];
  List<UserCharacterLevelPosition> _committedLevelPositions = const [];
  int _windowFirstPage = 1;
  int _queryGeneration = 0;

  /// 当前排序字段
  UserCharacterSnapshotSort get sort => _sort;

  /// 当前排序方向
  UserCharacterSnapshotSortDirection get direction => _direction;

  /// 等级快速跳转位置
  List<UserCharacterLevelPosition> get levelPositions => _levelPositions;

  /// 是否可以向前加载相邻页
  bool get canLoadPreviousPage =>
      !_isChangingSort && !_isPageBlockingRefresh && _windowFirstPage > 1;

  /// 首屏或主动刷新期间暂停下一页请求
  @override
  bool get isNextPageLoadPaused => _isPageBlockingRefresh || _isChangingSort;

  /// 首屏或主动刷新期间显示底部分页加载状态
  @override
  bool get showPausedLoadMoreIndicator => _isPageBlockingRefresh;

  /// 切换排序时显示原有首屏骨架
  @override
  bool get forceInitialLoading => _isChangingSort;

  /// 校验当前用户角色分页请求
  @override
  Object? validatePageRequest() {
    if (_username.isEmpty) {
      return StateError('用户名不能为空');
    }
    return null;
  }

  /// 读取当前用户角色本地分页
  ///
  /// [page] 页码
  /// [pageSize] 每页角色数量
  @override
  Future<TinygrailPage<UserCharacterApiItem>> requestPage({
    required int page,
    required int pageSize,
  }) {
    if (page == 1 && !_initialPageRequested) {
      _initialPageRequested = true;
      late final Future<TinygrailPage<UserCharacterApiItem>> operation;
      operation = _loadInitialPage(pageSize).whenComplete(() {
        if (identical(_initialPageOperation, operation)) {
          _initialPageOperation = null;
        }
      });
      _initialPageOperation = operation;
      return operation;
    }
    return _readRequiredPage(page: page, pageSize: pageSize);
  }

  /// 切换当前用户角色排序
  ///
  /// [nextSort] 目标排序字段
  Future<bool> selectSort(UserCharacterSnapshotSort nextSort) {
    final nextDirection = nextSort == _sort
        ? (_direction == UserCharacterSnapshotSortDirection.descending
            ? UserCharacterSnapshotSortDirection.ascending
            : UserCharacterSnapshotSortDirection.descending)
        : UserCharacterSnapshotSortDirection.descending;
    _sort = nextSort;
    _direction = nextDirection;
    _levelPositions = const [];
    final generation = ++_queryGeneration;
    _setChangingSort(true);
    final previousSortOperation = _sortChangeOperation;
    late final Future<bool> operation;
    operation = _applySortChange(
      generation,
      previousSortOperation,
    ).then((success) {
      if (!success && generation == _queryGeneration && !_isDisposed) {
        _sort = _committedSort;
        _direction = _committedDirection;
        _levelPositions = _committedLevelPositions;
        notifyListeners();
      } else if (success && generation == _queryGeneration && !_isDisposed) {
        _committedSort = _sort;
        _committedDirection = _direction;
        _committedLevelPositions = _levelPositions;
      }
      return success;
    }).whenComplete(() {
      if (identical(_sortChangeOperation, operation)) {
        _sortChangeOperation = null;
      }
    });
    _sortChangeOperation = operation;
    return operation;
  }

  /// 跳转到指定角色等级
  ///
  /// [level] 目标角色等级
  /// [beforeItemsReplaced] 目标分页窗口提交前的滚动位置校正回调
  Future<bool> jumpToLevel(
    int level, {
    required void Function(
      int itemIndex,
      List<UserCharacterApiItem> items,
    ) beforeItemsReplaced,
  }) async {
    if (_sort != UserCharacterSnapshotSort.level || _isDisposed) {
      return false;
    }
    final position =
        _levelPositions.where((item) => item.level == level).firstOrNull;
    if (position == null) {
      return false;
    }
    final generation = ++_queryGeneration;
    await _waitForInitialLoadAndBlockingRefresh();
    await waitForPagingIdle();
    if (_isDisposed || generation != _queryGeneration) {
      return false;
    }
    final targetPage = position.absoluteIndex ~/ pageSize + 1;
    final itemIndex = position.absoluteIndex % pageSize;
    // 一次提交目标页和后续页，避免两次分页状态更新造成抖动
    final success = await replaceFromPage(
      targetPage,
      followingPageCount: 1,
      shouldCommit: () => !_isDisposed && generation == _queryGeneration,
      beforeCommit: (items) => beforeItemsReplaced(itemIndex, items),
    );
    if (!success || _isDisposed || generation != _queryGeneration) {
      return false;
    }
    _windowFirstPage = targetPage;
    notifyListeners();
    return true;
  }

  /// 向当前窗口前方加载相邻页
  Future<int> loadPreviousPage() {
    final existing = _prependPageOperation;
    if (existing != null) {
      return existing;
    }
    if (!canLoadPreviousPage) {
      return Future.value(0);
    }
    final targetPage = _windowFirstPage - 1;
    late final Future<int> operation;
    operation = prependPage(targetPage).then((count) {
      if (count > 0 && !_isDisposed) {
        _windowFirstPage = targetPage;
      }
      return count;
    }).whenComplete(() {
      if (identical(_prependPageOperation, operation)) {
        _prependPageOperation = null;
      }
    });
    _prependPageOperation = operation;
    return operation;
  }

  /// 刷新当前用户角色并替换当前分页窗口
  @override
  Future<bool> refresh() async {
    final initialOperation = _initialPageOperation;
    if (initialOperation != null) {
      try {
        // 首屏请求已完成时直接复用结果，避免下拉刷新重复写入快照
        await initialOperation;
        return !_isDisposed;
      } catch (_) {
        // 首屏失败后继续执行手动刷新作为重试
      }
    }
    if (_isDisposed) {
      return false;
    }
    final automaticOperation = _automaticRefreshOperation;
    if (automaticOperation != null) {
      _suppressAutomaticRefreshFailure = true;
      return automaticOperation;
    }
    return _startOrJoinCharacterRefresh(blockPageLoading: true);
  }

  /// 记录阻塞刷新期间触发的预加载位置
  ///
  /// [index] 当前构建的展示条目下标
  @override
  void handleItemBuilt(int index) {
    if (!_isPageBlockingRefresh) {
      super.handleItemBuilt(index);
      return;
    }
    final itemCount = items.length;
    if (itemCount == 0) {
      return;
    }
    final maxIndex = itemCount - 1;
    final triggerIndex =
        (maxIndex - itemPreloadThreshold).clamp(0, maxIndex).toInt();
    if (index >= triggerIndex) {
      _shouldLoadNextPageAfterBlockingRefresh = true;
    }
  }

  /// 等待当前页面持有的数据库任务结束
  Future<void> waitForPendingOperations() async {
    final initialOperation = _initialPageOperation;
    if (initialOperation != null) {
      try {
        await initialOperation;
      } catch (_) {
        // 首屏异常由分页页面展示，销毁阶段只等待任务结束
      }
    }
    final refreshOperation = _characterRefreshOperation;
    if (refreshOperation != null) {
      try {
        await refreshOperation;
      } catch (_) {
        // 刷新异常由页面状态或后台提示处理
      }
    }
    final sortChangeOperation = _sortChangeOperation;
    if (sortChangeOperation != null) {
      try {
        await sortChangeOperation;
      } catch (_) {
        // 排序异常由调用方处理
      }
    }
    final prependPageOperation = _prependPageOperation;
    if (prependPageOperation != null) {
      try {
        await prependPageOperation;
      } catch (_) {
        // 前置分页异常由页面提示处理
      }
    }
  }

  /// 释放当前用户角色控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 加载当前用户角色第一页
  ///
  /// [pageSize] 每页角色数量
  Future<TinygrailPage<UserCharacterApiItem>> _loadInitialPage(
    int pageSize,
  ) async {
    final cached = await _snapshotRepository.readCharacterPage(
      username: _username,
      page: 1,
      pageSize: pageSize,
      sort: _sort,
      direction: _direction,
    );
    if (cached != null) {
      _scheduleAutomaticRefresh();
      return cached;
    }

    _setPageBlockingRefresh(true);
    try {
      await _snapshotRepository.refreshCharacters(
        username: _username,
        nickname: _nickname,
      );
    } finally {
      _setPageBlockingRefresh(false);
    }
    return _readRequiredPage(page: 1, pageSize: pageSize);
  }

  /// 读取必须存在的当前用户角色分页
  ///
  /// [page] 页码
  /// [pageSize] 每页角色数量
  Future<TinygrailPage<UserCharacterApiItem>> _readRequiredPage({
    required int page,
    required int pageSize,
  }) async {
    final result = await _snapshotRepository.readCharacterPage(
      username: _username,
      page: page,
      pageSize: pageSize,
      sort: _sort,
      direction: _direction,
    );
    if (result == null) {
      throw StateError('用户角色本地数据不可用');
    }
    return result;
  }

  /// 使用最新排序替换当前可视分页窗口
  Future<bool> _replaceWithLatestCharacterWindow() async {
    while (!_isDisposed) {
      await waitForPagingIdle();
      final prependPageOperation = _prependPageOperation;
      if (prependPageOperation != null) {
        await prependPageOperation;
      }
      if (_isDisposed) {
        return false;
      }
      final generation = _queryGeneration;
      final replacementSort = _sort;
      final replacementDirection = _direction;
      final replacementCountPage = await _readRequiredPage(
        page: 1,
        pageSize: 1,
      );
      final replacementLevelPositions = replacementSort ==
              UserCharacterSnapshotSort.level
          ? await _snapshotRepository.readCharacterLevelPositions(
              username: _username,
              direction: replacementDirection,
            )
          : const <UserCharacterLevelPosition>[];
      await waitForPagingIdle();
      final latestPrependPageOperation = _prependPageOperation;
      if (latestPrependPageOperation != null) {
        await latestPrependPageOperation;
      }
      if (_isDisposed) {
        return false;
      }
      if (generation != _queryGeneration ||
          replacementSort != _sort ||
          replacementDirection != _direction) {
        // 交互查询变化后重新读取窗口，避免保留刷新前的等级跳转目录
        continue;
      }
      final anchorItemIndex = _readVisibleCharacterIndex();
      final visibleAbsoluteIndex = anchorItemIndex == null
          ? (_windowFirstPage - 1) * pageSize
          : (_windowFirstPage - 1) * pageSize + anchorItemIndex;
      final anchorAbsoluteIndex = replacementCountPage.totalItems <= 0
          ? 0
          : visibleAbsoluteIndex
              .clamp(0, replacementCountPage.totalItems - 1)
              .toInt();
      final anchorPage = anchorAbsoluteIndex ~/ pageSize + 1;
      final firstPage = (anchorPage - _refreshAdjacentPageCount)
          .clamp(1, anchorPage)
          .toInt();
      final lastPage = anchorPage + _refreshAdjacentPageCount;
      final followingPageCount = lastPage - firstPage;
      final success = await replaceFromPage(
        firstPage,
        followingPageCount: followingPageCount,
        shouldCommit: () =>
            !_isDisposed &&
            generation == _queryGeneration &&
            replacementSort == _sort &&
            replacementDirection == _direction,
        beforeCommit: anchorItemIndex == null
            ? null
            : (replacementItems) => _onBeforeCharacterDataReplaced(
                  anchorItemIndex,
                  anchorAbsoluteIndex - (firstPage - 1) * pageSize,
                  replacementItems,
                ),
      );
      if (_isDisposed) {
        return false;
      }
      if (!success) {
        final queryChanged = generation != _queryGeneration ||
            replacementSort != _sort ||
            replacementDirection != _direction;
        if (queryChanged) {
          continue;
        }
        return false;
      }
      _levelPositions = replacementLevelPositions;
      _windowFirstPage = firstPage;
      _committedSort = _sort;
      _committedDirection = _direction;
      _committedLevelPositions = _levelPositions;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// 更新页面阻塞刷新状态
  ///
  /// [value] 是否暂停页面分页交互
  void _setPageBlockingRefresh(bool value) {
    if (_isDisposed || _isPageBlockingRefresh == value) {
      return;
    }
    _isPageBlockingRefresh = value;
    notifyListeners();
  }

  /// 恢复刷新期间暂缓的下一页加载
  void _resumeDeferredNextPageLoad() {
    if (_isDisposed || !_shouldLoadNextPageAfterBlockingRefresh) {
      return;
    }
    _shouldLoadNextPageAfterBlockingRefresh = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        unawaited(loadNextPage());
      }
    });
  }

  /// 应用最新排序并从第一页重新加载
  ///
  /// [generation] 排序请求代次
  Future<bool> _applySortChange(
    int generation,
    Future<bool>? previousSortOperation,
  ) async {
    try {
      if (previousSortOperation != null) {
        try {
          await previousSortOperation;
        } catch (_) {
          // 前一次排序失败不阻止最新排序继续读取本地数据
        }
      }
      await _waitForInitialLoadAndBlockingRefresh();
      await waitForPagingIdle();
      if (_isDisposed || generation != _queryGeneration) {
        return false;
      }
      await _refreshLevelPositions();
      await waitForPagingIdle();
      if (_isDisposed || generation != _queryGeneration) {
        return false;
      }
      final success = await replaceFromPage(
        1,
        shouldCommit: () => !_isDisposed && generation == _queryGeneration,
      );
      if (_isDisposed || generation != _queryGeneration) {
        return false;
      }
      if (success) {
        _windowFirstPage = 1;
      }
      return success;
    } catch (_) {
      return false;
    } finally {
      if (generation == _queryGeneration) {
        _setChangingSort(false);
      }
    }
  }

  /// 更新排序切换加载状态
  ///
  /// [value] 是否正在切换排序
  void _setChangingSort(bool value) {
    if (_isDisposed || _isChangingSort == value) {
      return;
    }
    _isChangingSort = value;
    notifyListeners();
  }

  /// 转换当前用户角色展示条目
  ///
  /// [items] 本地角色条目
  @override
  List<UserCharacterApiItem> convertPageItems(
    List<UserCharacterApiItem> items,
  ) {
    return items;
  }
}
