/// 角色全量列表本地排序字段
enum CharacterFullListSort {
  /// 角色数量
  quantity('数量'),

  /// 角色等级
  level('等级'),

  /// 角色股息
  dividend('股息'),

  /// 通天塔排名
  towerRank('通天塔'),

  /// 角色星级
  stars('星级'),

  /// 当前价格
  currentPrice('当前价'),

  /// 角色市值
  marketValue('市值'),

  /// 当前价格涨跌幅
  fluctuation('涨跌'),

  /// ST 等级
  st('ST'),

  /// 角色流通数量
  circulation('流通'),

  /// 角色买单数量
  bids('买单'),

  /// 角色卖单数量
  asks('卖单'),

  /// 角色上市日期
  listedDate('上市日期');

  /// 创建角色全量列表本地排序字段
  ///
  /// [label] 界面文案
  const CharacterFullListSort(this.label);

  /// 界面文案
  final String label;
}

/// 角色全量列表本地排序方向
enum CharacterFullListSortDirection {
  /// 升序
  ascending,

  /// 降序
  descending,
}

/// 角色全量列表等级跳转位置
class CharacterFullListLevelPosition {
  /// 创建角色全量列表等级跳转位置
  ///
  /// [level] 角色等级
  /// [itemIndex] 当前列表中的起始下标
  const CharacterFullListLevelPosition({
    required this.level,
    required this.itemIndex,
  });

  /// 角色等级
  final int level;

  /// 当前列表中的起始下标
  final int itemIndex;
}
