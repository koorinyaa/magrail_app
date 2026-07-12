import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/user/assets/model/user_character_snapshot_query.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_repository.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';

/// 当前用户角色二级页面控制器
class CurrentUserCharacterPageController extends TinygrailPagedListController<
    UserCharacterApiItem, UserCharacterApiItem> {
  /// 创建当前用户角色二级页面控制器
  ///
  /// [snapshotRepository] 用户资产快照仓库
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [onAutomaticRefreshFailed] 后台刷新失败回调
  /// [pageSize] 每页角色数量
  CurrentUserCharacterPageController({
    required UserAssetSnapshotRepository snapshotRepository,
    required String username,
    required String nickname,
    required VoidCallback onAutomaticRefreshFailed,
    super.pageSize = defaultPageSize,
  })  : _snapshotRepository = snapshotRepository,
        _username = username.trim(),
        _nickname = nickname.trim(),
        _onAutomaticRefreshFailed = onAutomaticRefreshFailed;

  /// 当前用户角色本地分页数量
  static const int defaultPageSize = 100;

  final UserAssetSnapshotRepository _snapshotRepository;
  final String _username;
  final String _nickname;
  final VoidCallback _onAutomaticRefreshFailed;

  bool _isDisposed = false;
  bool _isCharacterDataRefreshing = false;
  bool _isChangingSort = false;
  bool _initialPageRequested = false;
  bool _shouldLoadNextPageAfterRefresh = false;
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
      !_isChangingSort && !_isCharacterDataRefreshing && _windowFirstPage > 1;

  /// 后台刷新期间暂停下一页请求
  @override
  bool get isNextPageLoadPaused =>
      _isCharacterDataRefreshing || _isChangingSort;

  /// 后台刷新期间显示底部分页加载状态
  @override
  bool get showPausedLoadMoreIndicator => _isCharacterDataRefreshing;

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
    await _waitForInitialLoadAndCharacterRefresh();
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

  /// 刷新当前用户角色并替换第一页
  @override
  Future<bool> refresh() async {
    final automaticOperation = _automaticRefreshOperation;
    if (automaticOperation != null) {
      _suppressAutomaticRefreshFailure = true;
      return automaticOperation;
    }
    return _startOrJoinCharacterRefresh();
  }

  /// 记录后台刷新期间触发的预加载位置
  ///
  /// [index] 当前构建的展示条目下标
  @override
  void handleItemBuilt(int index) {
    if (!_isCharacterDataRefreshing) {
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
      _shouldLoadNextPageAfterRefresh = true;
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

    _setCharacterDataRefreshing(true);
    try {
      await _snapshotRepository.refreshCharacters(
        username: _username,
        nickname: _nickname,
      );
    } finally {
      _setCharacterDataRefreshing(false);
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

  /// 首屏缓存展示后的后台刷新
  void _scheduleAutomaticRefresh() {
    _setCharacterDataRefreshing(true);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) {
        return;
      }
      unawaited(_runAutomaticRefresh());
    });
  }

  /// 执行自动刷新并在失败时通知页面
  Future<void> _runAutomaticRefresh() async {
    final startedByAutomatic = _characterRefreshOperation == null;
    final operation = _startOrJoinCharacterRefresh();
    _automaticRefreshOperation = operation;
    final success = await operation;
    if (identical(_automaticRefreshOperation, operation)) {
      _automaticRefreshOperation = null;
    }
    final shouldReport = startedByAutomatic &&
        !success &&
        !_suppressAutomaticRefreshFailure &&
        !_isDisposed;
    _suppressAutomaticRefreshFailure = false;
    if (shouldReport) {
      _onAutomaticRefreshFailed();
    }
  }

  /// 启动或复用角色刷新流程
  Future<bool> _startOrJoinCharacterRefresh() {
    final existing = _characterRefreshOperation;
    if (existing != null) {
      return existing;
    }
    _setCharacterDataRefreshing(true);
    late final Future<bool> operation;
    operation = _refreshCharactersAndReloadFirstPage().whenComplete(() {
      if (!identical(_characterRefreshOperation, operation)) {
        return;
      }
      _characterRefreshOperation = null;
      _setCharacterDataRefreshing(false);
      _resumeDeferredNextPageLoad();
    });
    _characterRefreshOperation = operation;
    return operation;
  }

  /// 请求角色全量数据并从数据库替换第一页
  Future<bool> _refreshCharactersAndReloadFirstPage() async {
    try {
      await waitForPagingIdle();
      if (_isDisposed) {
        return false;
      }
      await _snapshotRepository.refreshCharacters(
        username: _username,
        nickname: _nickname,
      );
      if (_isDisposed) {
        return false;
      }
      await waitForPagingIdle();
      if (_isDisposed) {
        return false;
      }
      // 排序请求会在刷新结束后读取最新数据库，避免重复替换分页窗口
      if (_isChangingSort) {
        return true;
      }
      await _refreshLevelPositions();
      if (_isDisposed) {
        return false;
      }
      final success = await super.refresh();
      if (success) {
        _windowFirstPage = 1;
        _committedSort = _sort;
        _committedDirection = _direction;
        _committedLevelPositions = _levelPositions;
      }
      return success;
    } catch (_) {
      return false;
    }
  }

  /// 更新原始数据刷新状态
  ///
  /// [value] 是否正在刷新原始数据
  void _setCharacterDataRefreshing(bool value) {
    if (_isDisposed || _isCharacterDataRefreshing == value) {
      return;
    }
    _isCharacterDataRefreshing = value;
    notifyListeners();
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
      await _waitForInitialLoadAndCharacterRefresh();
      await waitForPagingIdle();
      if (_isDisposed || generation != _queryGeneration) {
        return false;
      }
      await _refreshLevelPositions();
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

  /// 等待首屏加载与角色数据刷新任务
  Future<void> _waitForInitialLoadAndCharacterRefresh() async {
    final initialOperation = _initialPageOperation;
    if (initialOperation != null) {
      try {
        await initialOperation;
      } catch (_) {
        // 排序流程将在本地分页替换时返回最终失败状态
      }
    }
    // 缓存首屏后的自动刷新会在下一帧启动，排序需覆盖这段排队时间
    while (_isCharacterDataRefreshing && !_isDisposed) {
      final refreshOperation = _characterRefreshOperation;
      if (refreshOperation != null) {
        await refreshOperation;
        continue;
      }
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  /// 刷新等级快速跳转目录
  Future<void> _refreshLevelPositions() async {
    if (_sort != UserCharacterSnapshotSort.level || _isDisposed) {
      _levelPositions = const [];
      return;
    }
    _levelPositions = await _snapshotRepository.readCharacterLevelPositions(
      username: _username,
      direction: _direction,
    );
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

  /// 恢复刷新期间暂缓的下一页加载
  void _resumeDeferredNextPageLoad() {
    if (_isDisposed || !_shouldLoadNextPageAfterRefresh) {
      return;
    }
    _shouldLoadNextPageAfterRefresh = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        unawaited(loadNextPage());
      }
    });
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
