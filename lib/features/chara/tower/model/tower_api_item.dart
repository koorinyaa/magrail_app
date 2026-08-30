import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 通天塔角色接口条目
///
/// [characterId] 角色 ID
/// [id] 角色内部 ID
/// [name] 角色名称
/// [icon] 角色头像地址
/// [level] 角色等级
/// [zeroCount] ST 等级
/// [starForces] 星之力
/// [stars] 星级
/// [rank] 通天塔排名
class TowerApiItem {
  /// 创建通天塔角色接口条目
  ///
  /// [characterId] 角色 ID
  /// [id] 角色内部 ID
  /// [name] 角色名称
  /// [icon] 角色头像地址
  /// [level] 角色等级
  /// [zeroCount] ST 等级
  /// [starForces] 星之力
  /// [stars] 星级
  /// [rank] 通天塔排名
  const TowerApiItem({
    required this.characterId,
    required this.id,
    required this.name,
    required this.icon,
    required this.level,
    required this.zeroCount,
    required this.starForces,
    required this.stars,
    required this.rank,
  });

  /// 角色 ID
  final int characterId;

  /// 角色内部 ID
  final int id;

  /// 角色名称
  final String name;

  /// 角色头像地址
  final String icon;

  /// 角色等级
  final int level;

  /// ST 等级
  final int zeroCount;

  /// 星之力
  final int starForces;

  /// 星级
  final int stars;

  /// 通天塔排名
  final int rank;

  /// 从 JSON 创建通天塔角色接口条目
  ///
  /// [json] 原始条目 JSON
  factory TowerApiItem.fromJson(Map<String, Object?> json) {
    return TowerApiItem(
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      id: TinygrailResponseParser.asInt(json['Id']),
      name: TinygrailResponseParser.asString(json['Name']),
      icon: TinygrailResponseParser.asString(json['Icon']),
      level: TinygrailResponseParser.asInt(json['Level']),
      zeroCount: TinygrailResponseParser.asInt(json['ZeroCount']),
      starForces: TinygrailResponseParser.asInt(json['StarForces']),
      stars: TinygrailResponseParser.asInt(json['Stars']),
      rank: TinygrailResponseParser.asInt(json['Rank']),
    );
  }
}
