import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 角色交易记录图表接口条目
class CharacterTradeHistoryItem {
  /// 创建角色交易记录图表接口条目
  ///
  /// [id] 交易记录 ID
  /// [characterId] 角色 ID
  /// [time] 交易时间
  /// [begin] 开始价格
  /// [end] 结束价格
  /// [low] 最低价格
  /// [high] 最高价格
  /// [amount] 交易数量
  /// [price] 交易总额
  const CharacterTradeHistoryItem({
    required this.id,
    required this.characterId,
    required this.time,
    required this.begin,
    required this.end,
    required this.low,
    required this.high,
    required this.amount,
    required this.price,
  });

  /// 交易记录 ID
  final int id;

  /// 角色 ID
  final int characterId;

  /// 交易时间
  final String time;

  /// 开始价格
  final double begin;

  /// 结束价格
  final double end;

  /// 最低价格
  final double low;

  /// 最高价格
  final double high;

  /// 交易数量
  final int amount;

  /// 交易总额
  final double price;

  /// 成交单价
  double get unitPrice => amount > 0 ? price / amount : 0;

  /// 从 JSON 创建角色交易记录图表接口条目
  ///
  /// [json] 原始交易记录 JSON
  factory CharacterTradeHistoryItem.fromJson(Map<String, Object?> json) {
    return CharacterTradeHistoryItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      time: TinygrailResponseParser.asString(json['Time']),
      begin: TinygrailResponseParser.asDouble(json['Begin']),
      end: TinygrailResponseParser.asDouble(json['End']),
      low: TinygrailResponseParser.asDouble(json['Low']),
      high: TinygrailResponseParser.asDouble(json['High']),
      amount: TinygrailResponseParser.asInt(json['Amount']),
      price: TinygrailResponseParser.asDouble(json['Price']),
    );
  }
}
