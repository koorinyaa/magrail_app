import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 角色搜索结果条目
final class CharacterDetailSearchItem {
  /// 创建角色搜索结果条目
  ///
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [icon] 角色头像地址
  /// [level] 角色等级
  /// [zeroCount] ST 等级
  /// [stars] 角色星级
  /// [starForces] 星之力
  /// [userTotal] 当前用户持股数量
  /// [userAmount] 当前用户可用活股数量
  /// [sacrifices] 当前用户固定资产数量
  const CharacterDetailSearchItem({
    required this.characterId,
    required this.name,
    required this.icon,
    required this.level,
    required this.zeroCount,
    required this.stars,
    required this.starForces,
    this.userTotal = 0,
    this.userAmount = 0,
    this.sacrifices = 0,
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 角色头像地址
  final String icon;

  /// 角色等级
  final int level;

  /// ST 等级
  final int zeroCount;

  /// 角色星级
  final int stars;

  /// 星之力数值
  final int starForces;

  /// 当前用户持股数量
  final int userTotal;

  /// 当前用户可用活股数量
  final int userAmount;

  /// 当前用户固定资产数量
  final int sacrifices;

  /// 从 JSON 创建角色搜索结果条目
  ///
  /// [json] 原始搜索结果 JSON
  factory CharacterDetailSearchItem.fromJson(Map<String, Object?> json) {
    final characterId = TinygrailResponseParser.asInt(json['CharacterId']);

    return CharacterDetailSearchItem(
      characterId: characterId > 0
          ? characterId
          : TinygrailResponseParser.asInt(json['Id']),
      name: TinygrailResponseParser.asString(json['Name']),
      icon: TinygrailResponseParser.asString(json['Icon']),
      level: TinygrailResponseParser.asInt(json['Level']),
      zeroCount: TinygrailResponseParser.asInt(json['ZeroCount']),
      stars: TinygrailResponseParser.asInt(json['Stars']),
      starForces: TinygrailResponseParser.asInt(json['StarForces']),
      userTotal: TinygrailResponseParser.asInt(json['UserTotal']),
      userAmount: TinygrailResponseParser.asInt(json['UserAmount']),
      sacrifices: TinygrailResponseParser.asInt(json['Sacrifices']),
    );
  }
}
