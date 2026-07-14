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
      waitForQueryChange: !blockPageLoading,
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
  /// [waitForQueryChange] 是否等待当前排序或筛选任务完成
  Future<bool> _refreshCharactersAndReloadVisibleWindow({
    required bool waitForQueryChange,
  }) async {
    var windowReplaced = false;
    try {
      final shouldReloadSnapshot = await _snapshotRepository.refreshCharacters(
        username: _username,
        nickname: _nickname,
      );
      final sourceState = await _snapshotRepository.readSourceState(_username);
      final snapshotRevision = sourceState?.revisions.characters;
      if (snapshotRevision == null) {
        return false;
      }
      if (!shouldReloadSnapshot && snapshotRevision == _windowRevision) {
        _setRefreshSnapshotPending(false);
        _resumeDeferredNextPageLoad();
        return true;
      }
      if (waitForQueryChange) {
        _setRefreshSnapshotPending(true);
      }
      try {
        while (!_isDisposed &&
            waitForQueryChange &&
            _queryChangeOperation != null) {
          await _queryChangeOperation;
        }
        windowReplaced = await _replaceWithLatestCharacterWindow(
          expectedRevision: snapshotRevision,
        );
        return windowReplaced;
      } finally {
        if (waitForQueryChange && windowReplaced) {
          _setRefreshSnapshotPending(false);
          _resumeDeferredNextPageLoad();
        }
      }
    } catch (_) {
      return false;
    }
  }

  /// 加载当前用户角色第一页
  ///
  /// [pageSize] 每页角色数量
  Future<TinygrailPage<UserCharacterApiItem>> _loadInitialPage(
    int pageSize,
  ) async {
    final sourceState = await _snapshotRepository.readSourceState(_username);
    TinygrailPage<UserCharacterApiItem>? cached;
    if (sourceState?.isCharacterDataFreshAt(DateTime.now()) ?? false) {
      final revision = sourceState!.revisions.characters;
      cached = await _snapshotRepository.readCharacterPage(
        username: _username,
        page: 1,
        pageSize: pageSize,
        sort: _sort,
        direction: _direction,
        searchKeyword: _searchKeyword,
        expectedRevision: revision,
      );
      if (cached != null) {
        _windowRevision = revision;
      }
    }
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
    final refreshedState = await _snapshotRepository.readSourceState(_username);
    final refreshedRevision = refreshedState?.revisions.characters;
    if (refreshedRevision == null) {
      throw StateError('用户角色本地数据不可用');
    }
    final firstPage = await _readRequiredPage(
      page: 1,
      pageSize: pageSize,
      expectedRevision: refreshedRevision,
    );
    _windowRevision = refreshedRevision;
    return firstPage;
  }

  /// 读取必须存在的当前用户角色分页
  ///
  /// [page] 页码
  /// [pageSize] 每页角色数量
  /// [expectedRevision] 必须匹配的角色快照版本
  Future<TinygrailPage<UserCharacterApiItem>> _readRequiredPage({
    required int page,
    required int pageSize,
    int? expectedRevision,
  }) async {
    final result = await _snapshotRepository.readCharacterPage(
      username: _username,
      page: page,
      pageSize: pageSize,
      sort: _sort,
      direction: _direction,
      searchKeyword: _searchKeyword,
      expectedRevision: expectedRevision,
    );
    if (result == null) {
      throw StateError('用户角色本地数据不可用');
    }
    return result;
  }

  /// 更新页面阻塞刷新状态
  ///
  /// [value] 是否暂停页面分页交互
  void _setPageBlockingRefresh(bool value) {
    if (_isDisposed || _isPageBlockingRefresh == value) {
      return;
    }
    _isPageBlockingRefresh = value;
    _notifyRefreshStateChanged();
  }

  /// 更新刷新快照待提交状态
  ///
  /// [value] 新快照是否尚未提交到页面窗口
  void _setRefreshSnapshotPending(bool value) {
    if (_isDisposed || _isRefreshSnapshotPending == value) {
      return;
    }
    _isRefreshSnapshotPending = value;
    _notifyRefreshStateChanged();
  }

  /// 在没有活动刷新时恢复普通分页
  void _resumePagingAfterIndependentWindowCommit() {
    if (_characterRefreshOperation != null) {
      return;
    }
    _setRefreshSnapshotPending(false);
    _resumeDeferredNextPageLoad();
  }

  /// 恢复刷新期间暂缓的下一页加载
  void _resumeDeferredNextPageLoad() {
    if (_isDisposed || !_shouldLoadNextPageAfterRefreshPause) {
      return;
    }
    _shouldLoadNextPageAfterRefreshPause = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        unawaited(loadNextPage());
      }
    });
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
      _levelIndexRevision = null;
      return;
    }
    final levelIndex = await _snapshotRepository.readCharacterLevelIndex(
      username: _username,
      direction: _direction,
      searchKeyword: _searchKeyword,
    );
    _levelPositions = levelIndex.positions;
    _levelIndexRevision = levelIndex.revision;
  }
}
