import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 用户圣殿接口条目
class UserTempleApiItem {
  /// 创建用户圣殿接口条目
  ///
  /// [id] 圣殿 ID
  /// [userId] 用户 ID
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [avatar] 角色头像地址
  /// [cover] 圣殿封面地址
  /// [line] 圣殿台词
  /// [assets] 圣殿资产值
  /// [sacrifices] 圣殿资产上限
  /// [rate] 基础股息
  /// [characterRank] 通天塔排名
  /// [characterStars] 角色星级
  /// [characterLevel] 角色等级
  /// [zeroCount] ST 等级
  /// [level] 圣殿等级
  /// [starForces] 圣殿星之力
  /// [refine] 精炼等级
  /// [create] 建塔日期
  /// [link] LINK 另一侧圣殿
  const UserTempleApiItem({
    required this.id,
    required this.userId,
    required this.characterId,
    required this.name,
    required this.avatar,
    required this.cover,
    required this.line,
    required this.assets,
    required this.sacrifices,
    required this.rate,
    this.characterRank = 0,
    this.characterStars = 0,
    required this.characterLevel,
    required this.zeroCount,
    required this.level,
    required this.starForces,
    required this.refine,
    this.create = '',
    this.link,
  });

  /// 圣殿 ID
  final int id;

  /// 用户 ID
  final int userId;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 角色头像地址
  final String avatar;

  /// 圣殿封面地址
  final String cover;

  /// 圣殿台词
  final String line;

  /// 圣殿资产值
  final int assets;

  /// 圣殿资产上限
  final int sacrifices;

  /// 基础股息
  final double rate;

  /// 通天塔排名
  final int characterRank;

  /// 角色星级
  final int characterStars;

  /// 角色等级
  final int characterLevel;

  /// ST 等级
  final int zeroCount;

  /// 圣殿等级
  final int level;

  /// 圣殿星之力
  final int starForces;

  /// 精炼等级
  final int refine;

  /// 建塔日期
  final String create;

  /// LINK 另一侧圣殿
  final UserTempleApiItem? link;

  /// 从 JSON 创建用户圣殿接口条目
  ///
  /// [json] 原始条目 JSON
  factory UserTempleApiItem.fromJson(Map<String, Object?> json) {
    final linkJson = TinygrailResponseParser.asObjectMap(json['Link']);

    return UserTempleApiItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      userId: TinygrailResponseParser.asInt(json['UserId']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      name: TinygrailResponseParser.asString(json['Name']),
      avatar: TinygrailResponseParser.asString(json['Avatar']),
      cover: TinygrailResponseParser.asString(json['Cover']),
      line: TinygrailResponseParser.asString(json['Line']),
      assets: TinygrailResponseParser.asInt(json['Assets']),
      sacrifices: TinygrailResponseParser.asInt(json['Sacrifices']),
      rate: TinygrailResponseParser.asDouble(json['Rate']),
      characterRank: TinygrailResponseParser.asInt(json['CharacterRank']),
      characterStars: TinygrailResponseParser.asInt(json['CharacterStars']),
      characterLevel: TinygrailResponseParser.asInt(json['CharacterLevel']),
      zeroCount: TinygrailResponseParser.asInt(json['ZeroCount']),
      level: TinygrailResponseParser.asInt(json['Level']),
      starForces: TinygrailResponseParser.asInt(json['StarForces']),
      refine: TinygrailResponseParser.asInt(json['Refine']),
      create: TinygrailResponseParser.asString(json['Create']),
      link: linkJson == null ? null : UserTempleApiItem.fromJson(linkJson),
    );
  }

  /// 转换为缓存 JSON
  Map<String, Object?> toJson() {
    return {
      'Id': id,
      'UserId': userId,
      'CharacterId': characterId,
      'Name': name,
      'Avatar': avatar,
      'Cover': cover,
      'Line': line,
      'Assets': assets,
      'Sacrifices': sacrifices,
      'Rate': rate,
      'CharacterRank': characterRank,
      'CharacterStars': characterStars,
      'CharacterLevel': characterLevel,
      'ZeroCount': zeroCount,
      'Level': level,
      'StarForces': starForces,
      'Refine': refine,
      'Create': create,
      'Link': link?.toJson(),
    };
  }
}
