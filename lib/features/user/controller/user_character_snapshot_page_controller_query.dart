part of 'user_character_snapshot_page_controller.dart';

/// 用户角色快照控制器的排序与搜索实现
extension UserCharacterSnapshotPageControllerQuery
    on UserCharacterSnapshotPageController {
  /// 切换用户角色排序
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

  /// 提交最新排序与筛选查询
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
        _notifyRefreshStateChanged();
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
      await _waitForPagingToSettle();
      if (_isDisposed || generation != _queryGeneration) {
        return false;
      }
      await _refreshLevelPositions();
      await _waitForPagingToSettle();
      if (_isDisposed || generation != _queryGeneration) {
        return false;
      }
      final success = await _replaceQueryFromFirstPage(
        shouldCommit: () => !_isDisposed && generation == _queryGeneration,
      );
      if (_isDisposed || generation != _queryGeneration) {
        return false;
      }
      if (success) {
        _windowFirstPage = 1;
        _commitLevelPageCache();
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

  /// 更新排序或筛选切换加载状态
  ///
  /// [value] 是否正在切换查询条件
  void _setChangingQuery(bool value) {
    if (_isDisposed || _isChangingQuery == value) {
      return;
    }
    _isChangingQuery = value;
    _notifyRefreshStateChanged();
  }
}
