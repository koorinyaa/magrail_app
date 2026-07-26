part of 'user_temple_snapshot_page_controller.dart';

/// 用户圣殿等级虚拟网格控制
extension UserTempleSnapshotPageControllerLevel
    on UserTempleSnapshotPageController {
  /// 准备指定角色等级的目标分页
  ///
  /// [level] 目标角色等级
  Future<int?> prepareLevelJump(int level) async {
    if (_sort != UserTempleSnapshotSort.characterLevel || _isDisposed) {
      return null;
    }
    await _waitForInitialLoadAndBlockingRefresh();
    final revision = _levelIndexRevision;
    final queryGeneration = _queryGeneration;
    final position =
        _levelPositions.where((item) => item.level == level).firstOrNull;
    if (revision == null || position == null) {
      return null;
    }
    final loaded = await _ensureLevelItem(position.absoluteIndex);
    if (!loaded ||
        _isDisposed ||
        queryGeneration != _queryGeneration ||
        revision != _levelIndexRevision) {
      return null;
    }
    return position.absoluteIndex;
  }

  /// 读取等级排序下指定绝对位置的圣殿
  ///
  /// [absoluteIndex] 当前排序下的绝对条目下标
  UserTempleSnapshotEntry? levelItemAt(int absoluteIndex) {
    return _levelPageCache.itemAt(absoluteIndex);
  }

  /// 处理等级虚拟网格条目构建
  ///
  /// [absoluteIndex] 当前排序下的绝对条目下标
  void handleLevelItemBuilt(int absoluteIndex) {
    if (!usesVirtualLevelGrid ||
        _levelPageCache.itemAt(absoluteIndex) != null) {
      return;
    }
    unawaited(_ensureLevelItem(absoluteIndex));
  }

  /// 确保等级排序下指定位置已经载入缓存
  ///
  /// [absoluteIndex] 当前排序下的绝对条目下标
  Future<bool> _ensureLevelItem(int absoluteIndex) {
    final revision = _levelIndexRevision;
    if (revision == null) {
      return Future<bool>.value(false);
    }
    return _levelPageCache.ensureItem(
      absoluteIndex,
      pageLoader: ({required page, required pageSize}) => _readRequiredPage(
        page: page,
        pageSize: pageSize,
        expectedRevision: revision,
      ),
      onChanged: () {
        if (!_isDisposed && revision == _levelIndexRevision) {
          _notifyRefreshStateChanged();
        }
      },
    );
  }

  /// 提交等级排序分页缓存
  void _commitLevelPageCache() {
    if (!usesVirtualLevelGrid || _levelPositions.isEmpty) {
      _levelPageCache.clear();
      _levelLayoutVersion += 1;
      return;
    }
    final totalItems = _levelPositions.fold<int>(
      0,
      (total, position) => total + position.itemCount,
    );
    _levelPageCache.configure(
      totalItems: totalItems,
      firstPage: _windowFirstPage,
      items: items,
    );
    _levelLayoutVersion += 1;
  }

  /// 读取旧等级目录中指定绝对位置的圣殿角色等级
  ///
  /// [absoluteIndex] 旧快照中的绝对条目下标
  int? _levelAtAbsoluteIndex(int? absoluteIndex) {
    if (absoluteIndex == null) {
      return null;
    }
    for (final position in _levelPositions) {
      if (absoluteIndex >= position.absoluteIndex &&
          absoluteIndex < position.absoluteIndex + position.itemCount) {
        return position.level;
      }
    }
    return null;
  }

  /// 解析圣殿刷新后的等级回退位置
  ///
  /// [positions] 新快照等级目录
  /// [previousLevel] 刷新前顶部圣殿角色等级
  /// [previousAbsoluteIndex] 刷新前绝对条目下标
  /// [totalItems] 新快照条目总数
  int _fallbackLevelAbsoluteIndex(
    List<UserTempleLevelPosition> positions, {
    required int? previousLevel,
    required int previousAbsoluteIndex,
    required int totalItems,
  }) {
    if (positions.isNotEmpty && previousLevel != null) {
      var nearest = positions.first;
      for (final position in positions.skip(1)) {
        if ((position.level - previousLevel).abs() <
            (nearest.level - previousLevel).abs()) {
          nearest = position;
        }
      }
      return nearest.absoluteIndex;
    }
    return previousAbsoluteIndex.clamp(0, totalItems - 1).toInt();
  }
}
