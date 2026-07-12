/// 当前用户角色本地排序字段
enum UserCharacterSnapshotSort {
  /// 持股数量
  holdings('持股'),

  /// 角色等级
  level('等级'),

  /// 角色单期股息
  singleDividend('股息'),

  /// 角色持股总息
  totalDividend('总息'),

  /// 通天塔排名
  towerRank('通天塔'),

  /// 角色星级
  stars('星级'),

  /// 固定资产
  sacrifices('圣殿'),

  /// 当前价格
  currentPrice('当前价');

  /// 创建当前用户角色本地排序字段
  ///
  /// [label] 界面文案
  const UserCharacterSnapshotSort(this.label);

  /// 界面文案
  final String label;
}

/// 当前用户角色本地排序方向
enum UserCharacterSnapshotSortDirection {
  /// 升序
  ascending,

  /// 降序
  descending,
}

/// 当前用户角色等级跳转位置
class UserCharacterLevelPosition {
  /// 创建当前用户角色等级跳转位置
  ///
  /// [level] 角色等级
  /// [absoluteIndex] 当前排序下的起始下标
  const UserCharacterLevelPosition({
    required this.level,
    required this.absoluteIndex,
  });

  /// 角色等级
  final int level;

  /// 当前排序下的起始下标
  final int absoluteIndex;
}
