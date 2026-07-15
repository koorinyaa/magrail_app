import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/user/assets/model/user_temple_snapshot_query.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_repository.dart';

part 'current_user_temple_page_controller_refresh.dart';

/// 当前用户圣殿二级页面控制器
class CurrentUserTemplePageController extends TinygrailPagedListController<
    UserTempleSnapshotEntry, UserTempleSnapshotEntry> {
  /// 创建当前用户圣殿二级页面控制器
  ///
  /// [snapshotRepository] 用户资产快照仓库
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [onAutomaticRefreshSucceeded] 后台刷新成功回调
  /// [onAutomaticRefreshFailed] 后台刷新失败回调
  /// [readVisibleTempleIndex] 读取当前可视圣殿在窗口中的下标
  /// [waitForScrollIdle] 等待列表滚动结束
  /// [onBeforeTempleDataReplaced] 圣殿分页替换前的滚动位置校正回调
  /// [pageSize] 每页圣殿数量
  CurrentUserTemplePageController({
    required UserAssetSnapshotRepository snapshotRepository,
    required String username,
    required String nickname,
    required VoidCallback onAutomaticRefreshSucceeded,
    required VoidCallback onAutomaticRefreshFailed,
    required int? Function() readVisibleTempleIndex,
    required Future<void> Function() waitForScrollIdle,
    required void Function(
      int previousItemIndex,
      int replacementItemIndex,
      List<UserTempleSnapshotEntry> items,
    ) onBeforeTempleDataReplaced,
    super.pageSize = defaultPageSize,
  })  : _snapshotRepository = snapshotRepository,
        _username = username.trim(),
        _nickname = nickname.trim(),
        _onAutomaticRefreshSucceeded = onAutomaticRefreshSucceeded,
        _onAutomaticRefreshFailed = onAutomaticRefreshFailed,
        _readVisibleTempleIndex = readVisibleTempleIndex,
        _waitForScrollIdle = waitForScrollIdle,
        _onBeforeTempleDataReplaced = onBeforeTempleDataReplaced;

  /// 当前用户圣殿本地分页数量
  static const int defaultPageSize = 50;

  final UserAssetSnapshotRepository _snapshotRepository;
  final String _username;
  final String _nickname;
  final VoidCallback _onAutomaticRefreshSucceeded;
  final VoidCallback _onAutomaticRefreshFailed;
  final int? Function() _readVisibleTempleIndex;
  final Future<void> Function() _waitForScrollIdle;
  final void Function(
    int previousItemIndex,
    int replacementItemIndex,
    List<UserTempleSnapshotEntry> items,
  ) _onBeforeTempleDataReplaced;

  bool _isDisposed = false;
  bool _isPageBlockingRefresh = false;
  // 新快照写入后暂停普通分页，直到页面窗口提交同一版本
  bool _isRefreshSnapshotPending = false;
  bool _isChangingQuery = false;
  bool _initialPageRequested = false;
  bool _shouldLoadNextPageAfterRefreshPause = false;
  bool _suppressAutomaticRefreshFailure = false;
  Future<TinygrailPage<UserTempleSnapshotEntry>>? _initialPageOperation;
  Future<bool>? _templeRefreshOperation;
  Future<bool>? _automaticRefreshOperation;
  Future<bool>? _queryChangeOperation;
  Future<int>? _prependPageOperation;
  UserTempleSnapshotSort _sort = UserTempleSnapshotSort.assets;
  UserTempleSnapshotSortDirection _direction =
      UserTempleSnapshotSortDirection.descending;
  UserTempleSnapshotSort _committedSort = UserTempleSnapshotSort.assets;
  UserTempleSnapshotSortDirection _committedDirection =
      UserTempleSnapshotSortDirection.descending;
  String _searchKeyword = '';
  String _committedSearchKeyword = '';
  List<UserTempleLevelPosition> _levelPositions = const [];
  List<UserTempleLevelPosition> _committedLevelPositions = const [];
  // 等级目录版本用于确保快速跳转下标与目标分页来自同一快照
  int? _levelIndexRevision;
  int? _committedLevelIndexRevision;
  // 可视分页版本用于判断哈希一致时页面是否仍需同步
  int? _windowRevision;
  int _windowFirstPage = 1;
  int _queryGeneration = 0;

  /// 当前排序字段
  UserTempleSnapshotSort get sort => _sort;

  /// 当前排序方向
  UserTempleSnapshotSortDirection get direction => _direction;

  /// 当前角色 ID 或名称筛选词
  String get searchKeyword => _searchKeyword;

  /// 当前角色等级快速跳转位置
  List<UserTempleLevelPosition> get levelPositions => _levelPositions;

  /// 当前页面使用的圣殿快照版本
  int? get templeSnapshotRevision => _windowRevision;

  /// 是否可以向前加载相邻页
  bool get canLoadPreviousPage =>
      !_isChangingQuery &&
      !_isPageBlockingRefresh &&
      !_isRefreshSnapshotPending &&
      _windowFirstPage > 1;

  /// 首屏无可用数据或新快照待提交时暂停下一页请求
  @override
  bool get isNextPageLoadPaused =>
      _isPageBlockingRefresh || _isRefreshSnapshotPending || _isChangingQuery;

  /// 首屏无可用数据时显示底部分页加载状态
  @override
  bool get showPausedLoadMoreIndicator => _isPageBlockingRefresh;

  /// 切换排序或筛选时显示原有首屏骨架
  @override
  bool get forceInitialLoading => _isChangingQuery;

  /// 校验当前用户圣殿分页请求
  @override
  Object? validatePageRequest() {
    if (_username.isEmpty) {
      return StateError('用户名不能为空');
    }
    return null;
  }

  /// 读取当前用户圣殿本地分页
  ///
  /// [page] 页码
  /// [pageSize] 每页圣殿数量
  @override
  Future<TinygrailPage<UserTempleSnapshotEntry>> requestPage({
    required int page,
    required int pageSize,
  }) {
    if (page == 1 && !_initialPageRequested) {
      _initialPageRequested = true;
      late final Future<TinygrailPage<UserTempleSnapshotEntry>> operation;
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

  /// 切换当前用户圣殿排序
  ///
  /// [nextSort] 目标排序字段
  Future<bool> selectSort(UserTempleSnapshotSort nextSort) {
    final nextDirection = nextSort == _sort
        ? (_direction == UserTempleSnapshotSortDirection.descending
            ? UserTempleSnapshotSortDirection.ascending
            : UserTempleSnapshotSortDirection.descending)
        : UserTempleSnapshotSortDirection.descending;
    _sort = nextSort;
    _direction = nextDirection;
    _levelPositions = const [];
    _levelIndexRevision = null;
    return _startQueryChange();
  }

  /// 应用角色 ID 或名称筛选
  ///
  /// [keyword] 角色 ID 或名称筛选词
  Future<bool> applySearchFilter(String keyword) {
    final resolvedKeyword = keyword.trim();
    if (resolvedKeyword == _searchKeyword) {
      return _queryChangeOperation ?? Future<bool>.value(true);
    }
    _searchKeyword = resolvedKeyword;
    _levelPositions = const [];
    _levelIndexRevision = null;
    return _startQueryChange();
  }

  /// 跳转到指定角色等级
  ///
  /// [level] 目标角色等级
  /// [beforeItemsReplaced] 目标分页窗口提交前的滚动位置校正回调
  Future<bool> jumpToLevel(
    int level, {
    required void Function(
      int itemIndex,
      List<UserTempleSnapshotEntry> items,
    ) beforeItemsReplaced,
  }) async {
    if (_sort != UserTempleSnapshotSort.characterLevel || _isDisposed) {
      return false;
    }
    final generation = ++_queryGeneration;
    var committedGeneration = generation;
    await _waitForInitialLoadAndBlockingRefresh();
    while (!_isDisposed && generation == _queryGeneration) {
      await waitForPagingIdle();
      if (_isDisposed || generation != _queryGeneration) {
        return false;
      }
      final snapshotRevision = _levelIndexRevision;
      final position =
          _levelPositions.where((item) => item.level == level).firstOrNull;
      if (snapshotRevision == null || position == null) {
        return false;
      }
      final targetPage = position.absoluteIndex ~/ pageSize + 1;
      final firstPage = (targetPage - 1).clamp(1, targetPage).toInt();
      final itemIndex = position.absoluteIndex % pageSize +
          (targetPage - firstPage) * pageSize;
      final success = await replaceFromPage(
        firstPage,
        // 以目标页为中心读取前后相邻页，首尾页按实际可用页数加载
        followingPageCount: 2,
        shouldCommit: () => !_isDisposed && generation == _queryGeneration,
        beforeCommit: (items) {
          beforeItemsReplaced(itemIndex, items);
          // 使已捕获旧可视锚点的刷新重新按跳转后窗口计算
          committedGeneration = ++_queryGeneration;
        },
        pageLoader: ({required page, required pageSize}) => _readRequiredPage(
          page: page,
          pageSize: pageSize,
          expectedRevision: snapshotRevision,
        ),
      );
      if (_isDisposed || committedGeneration != _queryGeneration) {
        return false;
      }
      if (success) {
        _windowFirstPage = firstPage;
        _windowRevision = snapshotRevision;
        _resumePagingAfterIndependentWindowCommit();
        notifyListeners();
        return true;
      }
      final sourceState = await _snapshotRepository.readSourceState(_username);
      if (_isDisposed || generation != _queryGeneration) {
        return false;
      }
      if (sourceState?.revisions.temples == snapshotRevision) {
        return false;
      }
      // 刷新事务切换快照后重读等级目录，避免旧下标命中新分页
      await _refreshLevelPositions();
    }
    return false;
  }

  /// 向当前窗口前方加载相邻页
  ///
  /// [beforeItemsPrepended] 相邻页提交前的滚动位置校正回调
  Future<int> loadPreviousPage({
    void Function(List<UserTempleSnapshotEntry> items)? beforeItemsPrepended,
  }) {
    final existing = _prependPageOperation;
    if (existing != null) {
      return existing;
    }
    if (!canLoadPreviousPage) {
      return Future.value(0);
    }
    final targetPage = _windowFirstPage - 1;
    late final Future<int> operation;
    operation = prependPage(
      targetPage,
      beforeCommit: beforeItemsPrepended,
    ).then((count) {
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

  /// 刷新当前用户圣殿并替换当前分页窗口
  @override
  Future<bool> refresh() async {
    final initialOperation = _initialPageOperation;
    if (initialOperation != null) {
      try {
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
    return _startOrJoinTempleRefresh(blockPageLoading: items.isEmpty);
  }

  /// 记录刷新暂停期间触发的预加载位置
  ///
  /// [index] 当前构建的展示条目下标
  @override
  void handleItemBuilt(int index) {
    if (!_isPageBlockingRefresh && !_isRefreshSnapshotPending) {
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
      _shouldLoadNextPageAfterRefreshPause = true;
    }
  }

  /// 释放当前用户圣殿控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 使用最新查询替换当前可视分页窗口
  ///
  /// [expectedRevision] 刷新完成时确认的圣殿快照版本
  Future<bool> _replaceWithLatestTempleWindow({
    required int expectedRevision,
  }) async {
    var replacementRevision = expectedRevision;
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
      final replacementSearchKeyword = _searchKeyword;
      final targetRevision = replacementRevision;
      late final TinygrailPage<UserTempleSnapshotEntry> replacementCountPage;
      try {
        replacementCountPage = await _readRequiredPage(
          page: 1,
          pageSize: 1,
          expectedRevision: targetRevision,
        );
      } on StateError {
        final latestRevision =
            (await _snapshotRepository.readSourceState(_username))
                ?.revisions
                .temples;
        if (latestRevision != null && latestRevision != targetRevision) {
          replacementRevision = latestRevision;
          continue;
        }
        rethrow;
      }
      final replacementLevelIndex =
          replacementSort == UserTempleSnapshotSort.characterLevel
              ? await _snapshotRepository.readTempleLevelIndex(
                  username: _username,
                  direction: replacementDirection,
                  searchKeyword: replacementSearchKeyword,
                )
              : null;
      if (replacementLevelIndex != null &&
          replacementLevelIndex.revision != targetRevision) {
        replacementRevision = replacementLevelIndex.revision;
        continue;
      }
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
          replacementDirection != _direction ||
          replacementSearchKeyword != _searchKeyword) {
        continue;
      }
      await _waitForScrollIdle();
      if (_isDisposed) {
        return false;
      }
      if (generation != _queryGeneration ||
          replacementSort != _sort ||
          replacementDirection != _direction ||
          replacementSearchKeyword != _searchKeyword) {
        continue;
      }
      final anchorItemIndex = _readVisibleTempleIndex();
      final visibleAbsoluteIndex = anchorItemIndex == null
          ? (_windowFirstPage - 1) * pageSize
          : (_windowFirstPage - 1) * pageSize + anchorItemIndex;
      final anchorAbsoluteIndex = replacementCountPage.totalItems <= 0
          ? 0
          : visibleAbsoluteIndex
              .clamp(0, replacementCountPage.totalItems - 1)
              .toInt();
      final anchorPage = anchorAbsoluteIndex ~/ pageSize + 1;
      final firstPage =
          (anchorPage - _refreshAdjacentPageCount).clamp(1, anchorPage).toInt();
      final lastPage = anchorPage + _refreshAdjacentPageCount;
      final followingPageCount = lastPage - firstPage;
      final success = await replaceFromPage(
        firstPage,
        followingPageCount: followingPageCount,
        shouldCommit: () =>
            !_isDisposed &&
            generation == _queryGeneration &&
            replacementSort == _sort &&
            replacementDirection == _direction &&
            replacementSearchKeyword == _searchKeyword,
        beforeCommit: anchorItemIndex == null
            ? null
            : (replacementItems) => _onBeforeTempleDataReplaced(
                  anchorItemIndex,
                  anchorAbsoluteIndex - (firstPage - 1) * pageSize,
                  replacementItems,
                ),
        pageLoader: ({required page, required pageSize}) => _readRequiredPage(
          page: page,
          pageSize: pageSize,
          expectedRevision: targetRevision,
        ),
      );
      if (_isDisposed) {
        return false;
      }
      if (!success) {
        final queryChanged = generation != _queryGeneration ||
            replacementSort != _sort ||
            replacementDirection != _direction ||
            replacementSearchKeyword != _searchKeyword;
        if (queryChanged) {
          continue;
        }
        final latestRevision =
            (await _snapshotRepository.readSourceState(_username))
                ?.revisions
                .temples;
        if (latestRevision != null && latestRevision != targetRevision) {
          replacementRevision = latestRevision;
          continue;
        }
        return false;
      }
      _levelPositions =
          replacementLevelIndex?.positions ?? const <UserTempleLevelPosition>[];
      _levelIndexRevision = replacementLevelIndex?.revision;
      _windowFirstPage = firstPage;
      _windowRevision = targetRevision;
      _committedSort = _sort;
      _committedDirection = _direction;
      _committedSearchKeyword = _searchKeyword;
      _committedLevelPositions = _levelPositions;
      _committedLevelIndexRevision = _levelIndexRevision;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// 应用最新排序与筛选并从第一页重新加载
  ///
  /// [generation] 查询请求代次
  /// [previousQueryOperation] 前一次查询任务
  Future<bool> _applyQueryChange(
    int generation,
    Future<bool>? previousQueryOperation,
  ) async {
    try {
      if (previousQueryOperation != null) {
        try {
          await previousQueryOperation;
        } catch (_) {
          // 前一次查询失败不阻止最新查询继续读取本地数据
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
        _setChangingQuery(false);
      }
    }
  }

  /// 启动排序或筛选查询
  Future<bool> _startQueryChange() {
    final generation = ++_queryGeneration;
    _setChangingQuery(true);
    final previousQueryOperation = _queryChangeOperation;
    late final Future<bool> operation;
    operation = _applyQueryChange(
      generation,
      previousQueryOperation,
    ).then((success) {
      if (!success && generation == _queryGeneration && !_isDisposed) {
        _sort = _committedSort;
        _direction = _committedDirection;
        _searchKeyword = _committedSearchKeyword;
        _levelPositions = _committedLevelPositions;
        _levelIndexRevision = _committedLevelIndexRevision;
        notifyListeners();
      } else if (success && generation == _queryGeneration && !_isDisposed) {
        _committedSort = _sort;
        _committedDirection = _direction;
        _committedSearchKeyword = _searchKeyword;
        _committedLevelPositions = _levelPositions;
        _committedLevelIndexRevision = _levelIndexRevision;
        _resumePagingAfterIndependentWindowCommit();
      }
      return success;
    }).whenComplete(() {
      if (identical(_queryChangeOperation, operation)) {
        _queryChangeOperation = null;
      }
    });
    _queryChangeOperation = operation;
    return operation;
  }

  /// 更新排序或筛选切换加载状态
  ///
  /// [value] 是否正在切换查询条件
  void _setChangingQuery(bool value) {
    if (_isDisposed || _isChangingQuery == value) {
      return;
    }
    _isChangingQuery = value;
    notifyListeners();
  }

  /// 通知页面刷新状态变化
  void _notifyRefreshStateChanged() => notifyListeners();

  /// 转换当前用户圣殿展示条目
  ///
  /// [items] 本地圣殿条目
  @override
  List<UserTempleSnapshotEntry> convertPageItems(
    List<UserTempleSnapshotEntry> items,
  ) =>
      items;
}
