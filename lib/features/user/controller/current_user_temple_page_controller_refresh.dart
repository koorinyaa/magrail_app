part of 'current_user_temple_page_controller.dart';

// 静默刷新只重载当前页及前后各一页，避免替换整个圣殿网格
const int _refreshAdjacentPageCount = 1;

/// 当前用户圣殿控制器的刷新实现
extension _CurrentUserTemplePageControllerRefresh
    on CurrentUserTemplePageController {
  /// 首屏缓存展示后的后台刷新
  void _scheduleAutomaticRefresh() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) {
        return;
      }
      unawaited(_runAutomaticRefresh());
    });
  }

  /// 执行自动刷新并在失败时通知页面
  Future<void> _runAutomaticRefresh() async {
    final startedByAutomatic = _templeRefreshOperation == null;
    final operation = _startOrJoinTempleRefresh(blockPageLoading: false);
    _automaticRefreshOperation = operation;
    final success = await operation;
    if (identical(_automaticRefreshOperation, operation)) {
      _automaticRefreshOperation = null;
    }
    final shouldReportFailure = startedByAutomatic &&
        !success &&
        !_suppressAutomaticRefreshFailure &&
        !_isDisposed;
    _suppressAutomaticRefreshFailure = false;
    if (startedByAutomatic && success && !_isDisposed) {
      _onAutomaticRefreshSucceeded();
    } else if (shouldReportFailure) {
      _onAutomaticRefreshFailed();
    }
  }

  /// 启动或复用圣殿刷新流程
  ///
  /// [blockPageLoading] 是否暂停页面分页交互
  Future<bool> _startOrJoinTempleRefresh({
    required bool blockPageLoading,
  }) {
    final existing = _templeRefreshOperation;
    if (existing != null) {
      return existing;
    }
    if (blockPageLoading) {
      _setPageBlockingRefresh(true);
    }
    late final Future<bool> operation;
    operation = _refreshTemplesAndReloadVisibleWindow(
      waitForQueryChange: !blockPageLoading,
    ).whenComplete(() {
      if (!identical(_templeRefreshOperation, operation)) {
        return;
      }
      _templeRefreshOperation = null;
      if (blockPageLoading) {
        _setPageBlockingRefresh(false);
        _resumeDeferredNextPageLoad();
      }
    });
    _templeRefreshOperation = operation;
    return operation;
  }

  /// 请求圣殿并替换当前分页窗口
  ///
  /// [waitForQueryChange] 是否等待当前排序或筛选任务完成
  Future<bool> _refreshTemplesAndReloadVisibleWindow({
    required bool waitForQueryChange,
  }) async {
    try {
      await _snapshotRepository.refreshTemples(
        username: _username,
        nickname: _nickname,
      );
      while (
          !_isDisposed && waitForQueryChange && _queryChangeOperation != null) {
        await _queryChangeOperation;
      }
      return await _replaceWithLatestTempleWindow();
    } catch (_) {
      return false;
    }
  }

  /// 等待首屏加载与页面阻塞刷新任务
  Future<void> _waitForInitialLoadAndBlockingRefresh() async {
    final initialOperation = _initialPageOperation;
    if (initialOperation != null) {
      try {
        await initialOperation;
      } catch (_) {
        // 查询流程将在本地分页替换时返回最终失败状态
      }
    }
    while (_isPageBlockingRefresh && !_isDisposed) {
      final refreshOperation = _templeRefreshOperation;
      if (refreshOperation != null) {
        await refreshOperation;
        continue;
      }
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  /// 刷新等级快速跳转目录
  Future<void> _refreshLevelPositions() async {
    if (_sort != UserTempleSnapshotSort.characterLevel || _isDisposed) {
      _levelPositions = const [];
      return;
    }
    _levelPositions = await _snapshotRepository.readTempleLevelPositions(
      username: _username,
      direction: _direction,
      searchKeyword: _searchKeyword,
    );
  }
}
