import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 圣殿接口条目
class TempleApiItem {
  /// 创建圣殿接口条目
  ///
  /// [nickname] 用户昵称
  /// [name] 用户名
  /// [avatar] 用户头像地址
  /// [rate] 基础股息
  /// [characterLevel] 角色等级
  /// [zeroCount] ST 等级
  /// [characterName] 角色名称
  /// [id] 圣殿 ID
  /// [userId] 用户 ID
  /// [characterId] 角色 ID
  /// [cover] 圣殿封面地址
  /// [line] 圣殿台词
  /// [level] 圣殿等级
  /// [starForces] 圣殿星之力
  /// [refine] 精炼等级
  const TempleApiItem({
    required this.nickname,
    required this.name,
    required this.avatar,
    required this.rate,
    required this.characterLevel,
    required this.zeroCount,
    required this.characterName,
    required this.id,
    required this.userId,
    required this.characterId,
    required this.cover,
    required this.line,
    required this.level,
    required this.starForces,
    required this.refine,
  });

  /// 用户昵称
  final String nickname;

  /// 用户名
  final String name;

  /// 用户头像地址
  final String avatar;

  /// 基础股息
  final double rate;

  /// 角色等级
  final int characterLevel;

  /// ST 等级
  final int zeroCount;

  /// 角色名称
  final String characterName;

  /// 圣殿 ID
  final int id;

  /// 用户 ID
  final int userId;

  /// 角色 ID
  final int characterId;

  /// 圣殿封面地址
  final String cover;

  /// 圣殿台词
  final String line;

  /// 圣殿等级
  final int level;

  /// 圣殿星之力
  final int starForces;

  /// 精炼等级
  final int refine;

  /// 从 JSON 创建圣殿接口条目
  ///
  /// [json] 原始条目 JSON
  factory TempleApiItem.fromJson(Map<String, Object?> json) {
    return TempleApiItem(
      nickname: TinygrailResponseParser.asString(json['Nickname']),
      name: TinygrailResponseParser.asString(json['Name']),
      avatar: TinygrailResponseParser.asString(json['Avatar']),
      rate: TinygrailResponseParser.asDouble(json['Rate']),
      characterLevel: TinygrailResponseParser.asInt(json['CharacterLevel']),
      zeroCount: TinygrailResponseParser.asInt(json['ZeroCount']),
      characterName: TinygrailResponseParser.asString(json['CharacterName']),
      id: TinygrailResponseParser.asInt(json['Id']),
      userId: TinygrailResponseParser.asInt(json['UserId']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      cover: TinygrailResponseParser.asString(json['Cover']),
      line: TinygrailResponseParser.asString(json['Line']),
      level: TinygrailResponseParser.asInt(json['Level']),
      starForces: TinygrailResponseParser.asInt(json['StarForces']),
      refine: TinygrailResponseParser.asInt(json['Refine']),
    );
  }
}
