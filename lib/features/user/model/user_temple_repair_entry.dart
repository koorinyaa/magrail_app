import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

/// 受损圣殿补塔条目
final class UserTempleRepairEntry {
  /// 创建受损圣殿补塔条目
  ///
  /// [temple] 用户圣殿资料
  /// [availableAmount] 当前角色可用活股数量
  /// [hasCharacterData] 是否找到对应用户持股资料
  const UserTempleRepairEntry({
    required this.temple,
    required this.availableAmount,
    required this.hasCharacterData,
  });

  /// 用户圣殿资料
  final UserTempleApiItem temple;

  /// 当前角色可用活股数量
  final int availableAmount;

  /// 是否找到对应用户持股资料
  final bool hasCharacterData;

  /// 圣殿受损度
  int get damagedAmount => temple.sacrifices - temple.assets;

  /// 补满当前圣殿所需活股数量
  int get requiredAmount => damagedAmount > 0 ? damagedAmount ~/ 2 : 0;

  /// 是否允许补塔
  bool get canRepair =>
      hasCharacterData &&
      requiredAmount > 0 &&
      availableAmount >= requiredAmount;
}
