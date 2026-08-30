/// 用户资产等级分组
class UserAssetLevelGroup {
  /// 创建用户资产等级分组
  ///
  /// [level] 角色等级
  /// [absoluteIndex] 当前排序下的起始条目下标
  /// [itemCount] 当前等级条目数量
  const UserAssetLevelGroup({
    required this.level,
    required this.absoluteIndex,
    required this.itemCount,
  });

  /// 角色等级
  final int level;

  /// 当前排序下的起始条目下标
  final int absoluteIndex;

  /// 当前等级条目数量
  final int itemCount;

  /// 当前等级结束条目下标
  int get endAbsoluteIndex => absoluteIndex + itemCount;
}

/// 用户资产等级虚拟布局条目
class UserAssetLevelLayoutEntry {
  /// 创建用户资产等级虚拟布局条目
  ///
  /// [level] 角色等级
  /// [firstAbsoluteIndex] 标题或内容行对应的首个条目下标
  /// [itemCount] 内容行条目数量
  /// [isHeader] 是否为等级标题
  /// [isLastRow] 是否为当前等级最后一行
  const UserAssetLevelLayoutEntry({
    required this.level,
    required this.firstAbsoluteIndex,
    required this.itemCount,
    required this.isHeader,
    required this.isLastRow,
  });

  /// 角色等级
  final int level;

  /// 标题或内容行对应的首个条目下标
  final int firstAbsoluteIndex;

  /// 内容行条目数量
  final int itemCount;

  /// 是否为等级标题
  final bool isHeader;

  /// 是否为当前等级最后一行
  final bool isLastRow;
}

/// 用户资产等级虚拟布局
class UserAssetLevelLayout {
  /// 创建用户资产等级虚拟布局
  ///
  /// [groups] 已按当前方向排列的等级分组
  /// [crossAxisCount] 单行条目数量
  /// [version] 当前查询和快照对应的布局版本
  UserAssetLevelLayout({
    required List<UserAssetLevelGroup> groups,
    required this.crossAxisCount,
    required this.version,
  }) : assert(crossAxisCount > 0),
       groups = List<UserAssetLevelGroup>.unmodifiable(groups) {
    var virtualIndex = 0;
    final starts = <int>[];
    for (final group in this.groups) {
      starts.add(virtualIndex);
      virtualIndex += 1 + (group.itemCount / crossAxisCount).ceil();
    }
    _groupVirtualStarts = List<int>.unmodifiable(starts);
    virtualItemCount = virtualIndex;
  }

  /// 已按当前方向排列的等级分组
  final List<UserAssetLevelGroup> groups;

  /// 单行条目数量
  final int crossAxisCount;

  /// 当前查询和快照对应的布局版本
  final int version;

  late final List<int> _groupVirtualStarts;

  /// 虚拟布局条目总数
  late final int virtualItemCount;

  /// 实际资产条目总数
  int get itemCount {
    if (groups.isEmpty) {
      return 0;
    }
    return groups.last.endAbsoluteIndex;
  }

  /// 判断是否与另一布局使用相同映射
  ///
  /// [other] 待比较布局
  bool hasSameMapping(UserAssetLevelLayout other) {
    return version == other.version && crossAxisCount == other.crossAxisCount;
  }

  /// 读取指定虚拟下标对应的布局条目
  ///
  /// [virtualIndex] 虚拟布局下标
  UserAssetLevelLayoutEntry? entryAt(int virtualIndex) {
    if (virtualIndex < 0 || virtualIndex >= virtualItemCount) {
      return null;
    }
    for (var groupIndex = groups.length - 1; groupIndex >= 0; groupIndex -= 1) {
      final groupStart = _groupVirtualStarts[groupIndex];
      if (virtualIndex < groupStart) {
        continue;
      }
      final group = groups[groupIndex];
      if (virtualIndex == groupStart) {
        return UserAssetLevelLayoutEntry(
          level: group.level,
          firstAbsoluteIndex: group.absoluteIndex,
          itemCount: 0,
          isHeader: true,
          isLastRow: false,
        );
      }
      final rowIndex = virtualIndex - groupStart - 1;
      final firstAbsoluteIndex =
          group.absoluteIndex + rowIndex * crossAxisCount;
      final itemCount = (group.endAbsoluteIndex - firstAbsoluteIndex)
          .clamp(0, crossAxisCount)
          .toInt();
      return UserAssetLevelLayoutEntry(
        level: group.level,
        firstAbsoluteIndex: firstAbsoluteIndex,
        itemCount: itemCount,
        isHeader: false,
        isLastRow: firstAbsoluteIndex + itemCount >= group.endAbsoluteIndex,
      );
    }
    return null;
  }

  /// 计算实际条目对应的虚拟布局下标
  ///
  /// [absoluteIndex] 当前排序下的实际条目下标
  int? virtualIndexForAbsoluteIndex(int absoluteIndex) {
    for (var groupIndex = 0; groupIndex < groups.length; groupIndex += 1) {
      final group = groups[groupIndex];
      if (absoluteIndex < group.absoluteIndex ||
          absoluteIndex >= group.endAbsoluteIndex) {
        continue;
      }
      final localIndex = absoluteIndex - group.absoluteIndex;
      return _groupVirtualStarts[groupIndex] + 1 + localIndex ~/ crossAxisCount;
    }
    return null;
  }

  /// 计算等级标题对应的虚拟布局下标
  ///
  /// [level] 目标角色等级
  int? virtualIndexForLevel(int level) {
    final groupIndex = groups.indexWhere((group) => group.level == level);
    return groupIndex < 0 ? null : _groupVirtualStarts[groupIndex];
  }
}
