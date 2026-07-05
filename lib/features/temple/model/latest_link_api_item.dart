import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 最新连接接口条目
class LatestLinkApiItem {
  /// 创建最新连接接口条目
  ///
  /// [id] 圣殿 ID
  /// [userId] 用户 ID
  /// [name] 用户名
  /// [nickname] 用户昵称
  /// [avatar] 用户头像地址
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  /// [cover] 圣殿封面地址
  /// [linkId] 连接角色 ID
  /// [assets] 圣殿资产值
  /// [sacrifices] 圣殿资产上限
  /// [level] 圣殿等级
  /// [starForces] 圣殿星之力
  /// [create] 圣殿创建时间
  const LatestLinkApiItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.nickname,
    required this.avatar,
    required this.characterId,
    required this.characterName,
    required this.cover,
    required this.linkId,
    required this.assets,
    required this.sacrifices,
    required this.level,
    required this.starForces,
    required this.create,
  });

  /// 圣殿 ID
  final int id;

  /// 用户 ID
  final int userId;

  /// 用户名
  final String name;

  /// 用户昵称
  final String nickname;

  /// 用户头像地址
  final String avatar;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 圣殿封面地址
  final String cover;

  /// 连接角色 ID
  final int linkId;

  /// 圣殿资产值
  final int assets;

  /// 圣殿资产上限
  final int sacrifices;

  /// 圣殿等级
  final int level;

  /// 圣殿星之力
  final int starForces;

  /// 圣殿创建时间
  final String create;

  /// 从 JSON 创建最新连接接口条目
  ///
  /// [json] 原始条目 JSON
  factory LatestLinkApiItem.fromJson(Map<String, Object?> json) {
    return LatestLinkApiItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      userId: TinygrailResponseParser.asInt(json['UserId']),
      name: TinygrailResponseParser.asString(json['Name']),
      nickname: TinygrailResponseParser.asString(json['Nickname']),
      avatar: TinygrailResponseParser.asString(json['Avatar']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      characterName: TinygrailResponseParser.asString(json['CharacterName']),
      cover: TinygrailResponseParser.asString(json['Cover']),
      linkId: TinygrailResponseParser.asInt(json['LinkId']),
      assets: TinygrailResponseParser.asInt(json['Assets']),
      sacrifices: TinygrailResponseParser.asInt(json['Sacrifices']),
      level: TinygrailResponseParser.asInt(json['Level']),
      starForces: TinygrailResponseParser.asInt(json['StarForces']),
      create: TinygrailResponseParser.asString(json['Create']),
    );
  }
}
