import 'dart:math' as math;

import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';

/// 角色详情圣殿条目
class CharacterDetailTempleItem {
  /// 创建角色详情圣殿条目
  ///
  /// [id] 圣殿 ID
  /// [ownerName] 拥有者用户名
  /// [ownerNickname] 拥有者昵称
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  /// [avatar] 角色头像地址
  /// [cover] 圣殿封面地址
  /// [line] 圣殿台词
  /// [assets] 固定资产当前值
  /// [sacrifices] 固定资产上限
  /// [characterLevel] 角色等级
  /// [zeroCount] ST 等级
  /// [linkId] LINK 目标角色 ID
  /// [level] 圣殿等级
  /// [starForces] 圣殿星之力
  /// [refine] 精炼等级
  /// [create] 圣殿创建时间
  /// [link] LINK 另一侧圣殿
  const CharacterDetailTempleItem({
    required this.id,
    required this.ownerName,
    required this.ownerNickname,
    required this.characterId,
    required this.characterName,
    required this.avatar,
    required this.cover,
    required this.line,
    required this.assets,
    required this.sacrifices,
    required this.characterLevel,
    required this.zeroCount,
    required this.linkId,
    required this.level,
    required this.starForces,
    required this.refine,
    required this.create,
    this.link,
  });

  /// 圣殿 ID
  final int id;

  /// 拥有者用户名
  final String ownerName;

  /// 拥有者昵称
  final String ownerNickname;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 角色头像地址
  final String avatar;

  /// 圣殿封面地址
  final String cover;

  /// 圣殿台词
  final String line;

  /// 固定资产当前值
  final int assets;

  /// 固定资产上限
  final int sacrifices;

  /// 角色等级
  final int characterLevel;

  /// ST 等级
  final int zeroCount;

  /// LINK 目标角色 ID
  final int linkId;

  /// 圣殿等级
  final int level;

  /// 圣殿星之力
  final int starForces;

  /// 精炼等级
  final int refine;

  /// 圣殿创建时间
  final String create;

  /// LINK 另一侧圣殿
  final CharacterDetailTempleItem? link;

  /// 是否存在有效 LINK
  bool get hasLink => link != null;

  /// 拥有者展示文案
  String get ownerLabel {
    final nickname =
        TinygrailFormatters.decodeHtmlEntities(ownerNickname).trim();
    if (nickname.isNotEmpty) {
      return '@$nickname';
    }

    final name = ownerName.trim();
    return name.isEmpty ? '@-' : '@$name';
  }

  /// LINK 值
  int get linkValue {
    final linked = link;
    if (linked == null) {
      return 0;
    }

    return math.min(assets, linked.assets);
  }

  /// 获取展示角色名称
  ///
  /// [fallback] 角色名称为空时使用的兜底文案
  String displayCharacterName(String fallback) {
    final resolved = characterName.trim();
    if (resolved.isNotEmpty) {
      return resolved;
    }

    return fallback;
  }

  /// 从 JSON 创建角色详情圣殿条目
  ///
  /// [json] 原始圣殿 JSON
  factory CharacterDetailTempleItem.fromJson(Map<String, Object?> json) {
    return CharacterDetailTempleItem._fromJson(json, isLinkedTemple: false);
  }

  /// 从 JSON 创建角色详情圣殿条目
  ///
  /// [json] 原始圣殿 JSON
  /// [isLinkedTemple] 是否为 LINK 内层圣殿
  factory CharacterDetailTempleItem._fromJson(
    Map<String, Object?> json, {
    required bool isLinkedTemple,
  }) {
    final linkJson = TinygrailResponseParser.asObjectMap(json['Link']);
    final rawName = TinygrailResponseParser.asString(json['Name']);
    final rawCharacterName =
        TinygrailResponseParser.asString(json['CharacterName']);

    return CharacterDetailTempleItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      ownerName: isLinkedTemple ? '' : rawName,
      ownerNickname: isLinkedTemple
          ? ''
          : TinygrailResponseParser.asString(json['Nickname']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      characterName: isLinkedTemple && rawCharacterName.isEmpty
          ? rawName
          : rawCharacterName,
      avatar: TinygrailResponseParser.asString(json['Avatar']),
      cover: TinygrailResponseParser.asString(json['Cover']),
      line: TinygrailResponseParser.asString(json['Line']),
      assets: TinygrailResponseParser.asInt(json['Assets']),
      sacrifices: TinygrailResponseParser.asInt(json['Sacrifices']),
      characterLevel: TinygrailResponseParser.asInt(json['CharacterLevel']),
      zeroCount: TinygrailResponseParser.asInt(json['ZeroCount']),
      linkId: TinygrailResponseParser.asInt(json['LinkId']),
      level: TinygrailResponseParser.asInt(json['Level']),
      starForces: TinygrailResponseParser.asInt(json['StarForces']),
      refine: TinygrailResponseParser.asInt(json['Refine']),
      create: TinygrailResponseParser.asString(json['Create']),
      link: linkJson == null
          ? null
          : CharacterDetailTempleItem._fromJson(
              linkJson,
              isLinkedTemple: true,
            ),
    );
  }
}
