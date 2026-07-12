part of 'current_user_character_page_controller.dart';

// 静默刷新只重载当前页及前后各一页，避免替换整个角色列表
const int _refreshAdjacentPageCount = 1;

/// 当前用户角色控制器的刷新实现
extension _CurrentUserCharacterPageControllerRefresh
    on CurrentUserCharacterPageController {
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
    final startedByAutomatic = _characterRefreshOperation == null;
    final operation = _startOrJoinCharacterRefresh(blockPageLoading: false);
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

  /// 启动或复用角色刷新流程
  ///
  /// [blockPageLoading] 是否暂停页面分页交互
  Future<bool> _startOrJoinCharacterRefresh({
    required bool blockPageLoading,
  }) {
    final existing = _characterRefreshOperation;
    if (existing != null) {
      return existing;
    }
    if (blockPageLoading) {
      _setPageBlockingRefresh(true);
    }
    late final Future<bool> operation;
    operation = _refreshCharactersAndReloadVisibleWindow(
      waitForSortChange: !blockPageLoading,
    ).whenComplete(() {
      if (!identical(_characterRefreshOperation, operation)) {
        return;
      }
      _characterRefreshOperation = null;
      if (blockPageLoading) {
        _setPageBlockingRefresh(false);
        _resumeDeferredNextPageLoad();
      }
    });
    _characterRefreshOperation = operation;
    return operation;
  }

  /// 请求角色全量数据并从数据库替换当前分页窗口
  ///
  /// [waitForSortChange] 是否等待当前排序任务完成
  Future<bool> _refreshCharactersAndReloadVisibleWindow({
    required bool waitForSortChange,
  }) async {
    try {
      await _snapshotRepository.refreshCharacters(
        username: _username,
        nickname: _nickname,
      );
      while (!_isDisposed && waitForSortChange && _sortChangeOperation != null) {
        await _sortChangeOperation;
      }
      return await _replaceWithLatestCharacterWindow();
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
        // 排序流程将在本地分页替换时返回最终失败状态
      }
    }
    while (_isPageBlockingRefresh && !_isDisposed) {
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

}
