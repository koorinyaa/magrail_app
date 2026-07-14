import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

/// 当前用户圣殿本地排序字段
enum UserTempleSnapshotSort {
  /// 按圣殿资产值排序
  assets('资产值'),

  /// 按角色等级排序
  characterLevel('等级'),

  /// 按圣殿受损程度排序
  damaged('受损度'),

  /// 按圣殿单元股息排序
  singleDividend('股息'),

  /// 按圣殿总息排序
  totalDividend('总息'),

  /// 按圣殿星之力排序
  starForces('星之力'),

  /// 按圣殿精炼等级排序
  refine('精炼'),

  /// 按圣殿建塔日期排序
  create('建塔日期');

  /// 创建当前用户圣殿本地排序字段
  ///
  /// [label] 排序工具栏文案
  const UserTempleSnapshotSort(this.label);

  /// 排序工具栏文案
  final String label;
}

/// 当前用户圣殿本地排序方向
enum UserTempleSnapshotSortDirection {
  /// 升序
  ascending,

  /// 降序
  descending,
}

/// 当前用户圣殿等级跳转位置
class UserTempleLevelPosition {
  /// 创建当前用户圣殿等级跳转位置
  ///
  /// [level] 角色等级
  /// [absoluteIndex] 当前排序下的起始下标
  const UserTempleLevelPosition({
    required this.level,
    required this.absoluteIndex,
  });

  /// 角色等级
  final int level;

  /// 当前排序下的起始下标
  final int absoluteIndex;
}

/// 当前用户圣殿分页展示条目
class UserTempleSnapshotEntry {
  /// 创建当前用户圣殿分页展示条目
  ///
  /// [item] 用户圣殿接口条目
  /// [singleDividend] 修正后的圣殿单元股息
  /// [totalDividend] 修正后的圣殿总息
  const UserTempleSnapshotEntry({
    required this.item,
    required this.singleDividend,
    required this.totalDividend,
  });

  /// 用户圣殿接口条目
  final UserTempleApiItem item;

  /// 修正后的圣殿单元股息
  final double singleDividend;

  /// 修正后的圣殿总息
  final double totalDividend;
}
