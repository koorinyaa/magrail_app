import 'package:magrail_app/core/network/tinygrail_response.dart';

// 通天塔 500 名外按每颗星固定折算单期股息
const double _outsideTowerDividendPerStar = 2;

/// ST 角色条目
class StCharacterEntry {
  /// 创建 ST 角色条目
  ///
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [icon] 角色头像地址
  /// [level] 角色等级
  /// [zeroCount] ST 等级
  /// [total] 流通数量
  /// [bids] 买单数量
  /// [asks] 卖单数量
  /// [current] 当前价
  /// [fluctuation] 当前价涨跌幅
  /// [rate] 股息
  /// [rank] 通天塔排名
  /// [stars] 角色星级
  /// [starForces] 星之力
  const StCharacterEntry({
    required this.characterId,
    required this.name,
    required this.icon,
    required this.level,
    required this.zeroCount,
    required this.total,
    required this.bids,
    required this.asks,
    required this.current,
    required this.fluctuation,
    required this.rate,
    required this.rank,
    required this.stars,
    required this.starForces,
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

  /// 流通数量
  final int total;

  /// 买单数量
  final int bids;

  /// 卖单数量
  final int asks;

  /// 当前价
  final double current;

  /// 当前价涨跌幅
  final double fluctuation;

  /// 股息
  final double rate;

  /// 通天塔排名
  final int rank;

  /// 角色星级
  final int stars;

  /// 星之力
  final int starForces;

  /// 计算角色单期股息
  double get singleDividend {
    if (rank > 0 && rank <= 500) {
      return rate * 0.005 * (601 - rank);
    }
    return stars * _outsideTowerDividendPerStar;
  }

  /// 从 JSON 创建 ST 角色条目
  ///
  /// [json] 原始 JSON
  factory StCharacterEntry.fromJson(Map<String, Object?> json) {
    final parsedCharacterId = TinygrailResponseParser.asInt(
      json['CharacterId'],
    );
    final characterId = parsedCharacterId == 0
        ? TinygrailResponseParser.asInt(json['Id'])
        : parsedCharacterId;

    return StCharacterEntry(
      characterId: characterId,
      name: TinygrailResponseParser.asString(json['Name']),
      icon: TinygrailResponseParser.asString(json['Icon']),
      level: TinygrailResponseParser.asInt(json['Level']),
      zeroCount: TinygrailResponseParser.asInt(json['ZeroCount']),
      total: TinygrailResponseParser.asInt(json['Total']),
      bids: TinygrailResponseParser.asInt(json['Bids']),
      asks: TinygrailResponseParser.asInt(json['Asks']),
      current: TinygrailResponseParser.asDouble(json['Current']),
      fluctuation: TinygrailResponseParser.asDouble(json['Fluctuation']),
      rate: TinygrailResponseParser.asDouble(json['Rate']),
      rank: TinygrailResponseParser.asInt(json['Rank']),
      stars: TinygrailResponseParser.asInt(json['Stars']),
      starForces: TinygrailResponseParser.asInt(json['StarForces']),
    );
  }
}
