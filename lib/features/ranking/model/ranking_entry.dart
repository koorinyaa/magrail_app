import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';

/// 排行榜条目基类
abstract base class RankingEntry {
  /// 创建排行榜条目基类
  const RankingEntry();
}

/// 圣殿精炼排行条目
final class TempleRefineRankingEntry extends RankingEntry {
  /// 创建圣殿精炼排行条目
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
  /// [starForces] 星之力
  /// [refine] 精炼等级
  /// [lastActiveDate] 最近活跃时间
  /// [rank] 当前排名
  const TempleRefineRankingEntry({
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
    required this.lastActiveDate,
    required this.rank,
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

  /// 星之力
  final int starForces;

  /// 精炼等级
  final int refine;

  /// 最近活跃时间
  final String lastActiveDate;

  /// 当前排名
  final int rank;

  /// 用户展示名称
  String get displayNickname {
    final decoded = TinygrailFormatters.decodeHtmlEntities(nickname).trim();
    return decoded.isEmpty ? name : decoded;
  }

  /// 角色展示名称
  String get displayCharacterName {
    return TinygrailFormatters.decodeHtmlEntities(characterName).trim();
  }

  /// 从 JSON 创建精炼排行条目
  ///
  /// [json] 原始条目 JSON
  /// [rank] 当前排名
  factory TempleRefineRankingEntry.fromJson(
    Map<String, Object?> json, {
    required int rank,
  }) {
    return TempleRefineRankingEntry(
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
      lastActiveDate: TinygrailResponseParser.asString(
        json['LastActiveDate'] ?? json['LastActive'],
      ),
      rank: rank,
    );
  }
}

/// 番市首富排行条目
final class UserWealthRankingEntry extends RankingEntry {
  /// 创建番市首富排行条目
  ///
  /// [name] 用户名
  /// [nickname] 用户昵称
  /// [avatar] 用户头像地址
  /// [assets] 总资产
  /// [share] 每周股息
  /// [totalBalance] 流动资金
  /// [principal] 初始资金
  /// [lastIndex] 上次排名
  /// [lastActiveDate] 最近活跃时间
  /// [state] 用户状态
  /// [rank] 当前排名
  const UserWealthRankingEntry({
    required this.name,
    required this.nickname,
    required this.avatar,
    required this.assets,
    required this.share,
    required this.totalBalance,
    required this.principal,
    required this.lastIndex,
    required this.lastActiveDate,
    required this.state,
    required this.rank,
  });

  /// 用户名
  final String name;

  /// 用户昵称
  final String nickname;

  /// 用户头像地址
  final String avatar;

  /// 总资产
  final double assets;

  /// 每周股息
  final double share;

  /// 流动资金
  final double totalBalance;

  /// 初始资金
  final double principal;

  /// 上次排名
  final int lastIndex;

  /// 最近活跃时间
  final String lastActiveDate;

  /// 用户状态
  final int state;

  /// 当前排名
  final int rank;

  /// 是否为小圣杯封禁状态
  bool get isBanned => state == 666;

  /// 用户展示名称
  String get displayName {
    final decoded = TinygrailFormatters.decodeHtmlEntities(nickname).trim();
    return decoded.isEmpty ? name : decoded;
  }

  /// 排名变化文案
  String get rankChangeLabel {
    if (lastIndex == 0) {
      return 'new';
    }

    if (lastIndex > rank) {
      return '+${lastIndex - rank}';
    }

    if (lastIndex < rank) {
      return '${lastIndex - rank}';
    }

    return '-';
  }

  /// 从 JSON 创建番市首富排行条目
  ///
  /// [json] 原始条目 JSON
  /// [rank] 当前排名
  factory UserWealthRankingEntry.fromJson(
    Map<String, Object?> json, {
    required int rank,
  }) {
    return UserWealthRankingEntry(
      name: TinygrailResponseParser.asString(json['Name']),
      nickname: TinygrailResponseParser.asString(json['Nickname']),
      avatar: TinygrailResponseParser.asString(json['Avatar']),
      assets: TinygrailResponseParser.asDouble(json['Assets']),
      share: TinygrailResponseParser.asDouble(json['Share']),
      totalBalance: TinygrailResponseParser.asDouble(json['TotalBalance']),
      principal: TinygrailResponseParser.asDouble(json['Principal']),
      lastIndex: TinygrailResponseParser.asInt(json['LastIndex']),
      lastActiveDate: TinygrailResponseParser.asString(
        json['LastActiveDate'],
      ),
      state: TinygrailResponseParser.asInt(json['State']),
      rank: rank,
    );
  }
}
