/// ICO 角色本地排序字段
enum IcoCharacterSort {
  /// 即将结束
  endingSoon('即将结束'),

  /// 最多资金
  maxValue('最多资金'),

  /// 最多人数
  maxUsers('最多人数'),

  /// 最近活跃
  recentActive('最近活跃');

  /// 创建 ICO 角色本地排序字段
  ///
  /// [label] 排序栏文案
  const IcoCharacterSort(this.label);

  /// 排序栏文案
  final String label;
}
