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
  /// [assets] 圣殿资产值
  /// [sacrifices] 圣殿资产上限
  /// [level] 圣殿等级
  /// [starForces] 圣殿星之力
  /// [refine] 精炼等级
  /// [create] 圣殿创建时间
  /// [link] LINK 另一侧圣殿
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
    required this.assets,
    required this.sacrifices,
    required this.level,
    required this.starForces,
    required this.refine,
    required this.create,
    this.link,
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

  /// 圣殿资产值
  final int assets;

  /// 圣殿资产上限
  final int sacrifices;

  /// 圣殿等级
  final int level;

  /// 圣殿星之力
  final int starForces;

  /// 精炼等级
  final int refine;

  /// 圣殿创建时间
  final String create;

  /// LINK 另一侧圣殿
  final TempleApiItem? link;

  /// 从 JSON 创建圣殿接口条目
  ///
  /// [json] 原始条目 JSON
  factory TempleApiItem.fromJson(Map<String, Object?> json) {
    return TempleApiItem._fromJson(json, isLinkedTemple: false);
  }

  /// 从 JSON 创建圣殿接口条目
  ///
  /// [json] 原始条目 JSON
  /// [isLinkedTemple] 是否为 LINK 内层圣殿
  factory TempleApiItem._fromJson(
    Map<String, Object?> json, {
    required bool isLinkedTemple,
  }) {
    final linkJson = isLinkedTemple
        ? null
        : TinygrailResponseParser.asObjectMap(json['Link']);
    final rawName = TinygrailResponseParser.asString(json['Name']);
    final rawCharacterName =
        TinygrailResponseParser.asString(json['CharacterName']);

    return TempleApiItem(
      nickname: isLinkedTemple
          ? ''
          : TinygrailResponseParser.asString(json['Nickname']),
      name: isLinkedTemple ? '' : rawName,
      avatar: TinygrailResponseParser.asString(json['Avatar']),
      rate: TinygrailResponseParser.asDouble(json['Rate']),
      characterLevel: TinygrailResponseParser.asInt(json['CharacterLevel']),
      zeroCount: TinygrailResponseParser.asInt(json['ZeroCount']),
      characterName: isLinkedTemple && rawCharacterName.isEmpty
          ? rawName
          : rawCharacterName,
      id: TinygrailResponseParser.asInt(json['Id']),
      userId: TinygrailResponseParser.asInt(json['UserId']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      cover: TinygrailResponseParser.asString(json['Cover']),
      line: TinygrailResponseParser.asString(json['Line']),
      assets: TinygrailResponseParser.asInt(json['Assets']),
      sacrifices: TinygrailResponseParser.asInt(json['Sacrifices']),
      level: TinygrailResponseParser.asInt(json['Level']),
      starForces: TinygrailResponseParser.asInt(json['StarForces']),
      refine: TinygrailResponseParser.asInt(json['Refine']),
      create: TinygrailResponseParser.asString(json['Create']),
      link: linkJson == null
          ? null
          : TempleApiItem._fromJson(
              linkJson,
              isLinkedTemple: true,
            ),
    );
  }
}
