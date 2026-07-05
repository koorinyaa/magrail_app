import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 用户交易记录接口条目
final class UserTradeLogApiItem {
  /// 创建用户交易记录接口条目
  ///
  /// [id] 记录 ID
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [tradeTime] 交易时间
  /// [seller] 卖家用户名
  /// [sellerName] 卖家昵称
  /// [sellerIp] 卖家 IP 记录
  /// [buyer] 买家用户名
  /// [buyerName] 买家昵称
  /// [buyerIp] 买家 IP 记录
  /// [price] 交易价格
  /// [amount] 交易数量
  const UserTradeLogApiItem({
    required this.id,
    required this.characterId,
    required this.name,
    required this.tradeTime,
    required this.seller,
    required this.sellerName,
    required this.sellerIp,
    required this.buyer,
    required this.buyerName,
    required this.buyerIp,
    required this.price,
    required this.amount,
  });

  /// 记录 ID
  final int id;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 交易时间
  final String tradeTime;

  /// 卖家用户名
  final String seller;

  /// 卖家昵称
  final String sellerName;

  /// 卖家 IP 记录
  final String sellerIp;

  /// 买家用户名
  final String buyer;

  /// 买家昵称
  final String buyerName;

  /// 买家 IP 记录
  final String buyerIp;

  /// 交易价格
  final double price;

  /// 交易数量
  final int amount;

  /// 是否为同 IP 交易记录
  bool get isSameIpTrade {
    final resolvedSellerIp = _normalizeIpRecord(sellerIp);
    final resolvedBuyerIp = _normalizeIpRecord(buyerIp);
    return resolvedSellerIp.isNotEmpty &&
        resolvedBuyerIp.isNotEmpty &&
        resolvedSellerIp == resolvedBuyerIp;
  }

  /// 归一化 IP 记录
  ///
  /// [ip] 原始 IP 记录
  String _normalizeIpRecord(String ip) {
    final resolvedIp = ip.trim().toLowerCase();
    if (resolvedIp.isEmpty || resolvedIp == 'no record') {
      return '';
    }

    return resolvedIp;
  }

  /// 从 JSON 创建用户交易记录接口条目
  ///
  /// [json] 原始接口 JSON
  factory UserTradeLogApiItem.fromJson(Map<String, Object?> json) {
    return UserTradeLogApiItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      name: TinygrailResponseParser.asString(json['Name']),
      tradeTime: TinygrailResponseParser.asString(json['TradeTime']),
      seller: TinygrailResponseParser.asString(json['Seller']),
      sellerName: TinygrailResponseParser.asString(json['SellerName']),
      sellerIp: TinygrailResponseParser.asString(json['SellerIp']),
      buyer: TinygrailResponseParser.asString(json['Buyer']),
      buyerName: TinygrailResponseParser.asString(json['BuyerName']),
      buyerIp: TinygrailResponseParser.asString(json['BuyerIp']),
      price: TinygrailResponseParser.asDouble(json['Price']),
      amount: TinygrailResponseParser.asInt(json['Amount']),
    );
  }
}
