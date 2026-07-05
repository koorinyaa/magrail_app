import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 角色排序条目
class CharacterRankEntry {
  /// 创建角色排序条目
  ///
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [icon] 角色头像地址
  /// [level] 角色等级
  /// [zeroCount] ST 等级
  /// [current] 当前价
  /// [fluctuation] 当前价涨跌幅
  /// [rate] 股息
  /// [marketValue] 市值
  const CharacterRankEntry({
    required this.characterId,
    required this.name,
    required this.icon,
    required this.level,
    required this.zeroCount,
    required this.current,
    required this.fluctuation,
    required this.rate,
    required this.marketValue,
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

  /// 当前价
  final double current;

  /// 当前价涨跌幅
  final double fluctuation;

  /// 股息
  final double rate;

  /// 市值
  final double marketValue;

  /// 从 JSON 创建角色排序条目
  ///
  /// [json] 原始 JSON
  factory CharacterRankEntry.fromJson(Map<String, Object?> json) {
    final characterId = TinygrailResponseParser.asInt(
      json['Id'] ?? json['CharacterId'],
    );
    final name = TinygrailResponseParser.asString(
      json['CharacterName'] ?? json['Name'],
    );

    return CharacterRankEntry(
      characterId: characterId,
      name: name,
      icon: TinygrailResponseParser.asString(json['Icon']),
      level: TinygrailResponseParser.asInt(json['Level']),
      zeroCount: TinygrailResponseParser.asInt(json['ZeroCount']),
      current: TinygrailResponseParser.asDouble(json['Current']),
      fluctuation: TinygrailResponseParser.asDouble(json['Fluctuation']),
      rate: TinygrailResponseParser.asDouble(json['Rate']),
      marketValue: TinygrailResponseParser.asDouble(json['MarketValue']),
    );
  }
}
