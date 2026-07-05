import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 拍卖接口条目
final class AuctionApiItem {
  /// 创建拍卖接口条目
  ///
  /// [id] 拍卖记录 ID
  /// [characterId] 角色 ID
  /// [state] 竞拍人数
  /// [type] 竞拍数量
  /// [price] 当前出价
  /// [amount] 当前数量
  const AuctionApiItem({
    required this.id,
    required this.characterId,
    required this.state,
    required this.type,
    required this.price,
    required this.amount,
  });

  /// 拍卖记录 ID
  final int id;

  /// 角色 ID
  final int characterId;

  /// 竞拍人数
  final int state;

  /// 竞拍数量
  final int type;

  /// 当前出价
  final double price;

  /// 当前数量
  final int amount;

  /// 从 JSON 创建拍卖接口条目
  ///
  /// [json] 原始接口 JSON
  factory AuctionApiItem.fromJson(Map<String, Object?> json) {
    return AuctionApiItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      state: TinygrailResponseParser.asInt(json['State']),
      type: TinygrailResponseParser.asInt(json['Type']),
      price: TinygrailResponseParser.asDouble(json['Price']),
      amount: TinygrailResponseParser.asInt(json['Amount']),
    );
  }
}
