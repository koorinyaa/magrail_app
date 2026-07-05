import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';

/// 角色 GM 交易记录接口条目
class CharacterGmTradeHistoryItem {
  /// 创建角色 GM 交易记录接口条目
  ///
  /// [id] 交易记录 ID
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [seller] 卖方用户名
  /// [sellerName] 卖方昵称
  /// [sellerIp] 卖方 IP
  /// [buyer] 买方用户名
  /// [buyerName] 买方昵称
  /// [buyerIp] 买方 IP
  /// [price] 成交价格
  /// [amount] 成交数量
  /// [tradeTime] 交易时间
  const CharacterGmTradeHistoryItem({
    required this.id,
    required this.characterId,
    required this.name,
    required this.seller,
    required this.sellerName,
    required this.sellerIp,
    required this.buyer,
    required this.buyerName,
    required this.buyerIp,
    required this.price,
    required this.amount,
    required this.tradeTime,
  });

  /// 交易记录 ID
  final int id;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 卖方用户名
  final String seller;

  /// 卖方昵称
  final String sellerName;

  /// 卖方 IP
  final String sellerIp;

  /// 买方用户名
  final String buyer;

  /// 买方昵称
  final String buyerName;

  /// 买方 IP
  final String buyerIp;

  /// 成交价格
  final double price;

  /// 成交数量
  final int amount;

  /// 交易时间
  final String tradeTime;

  /// 是否为同 IP 交易记录
  bool get isSameIpTrade {
    final sellerIpText = _normalizeIpRecord(sellerIp);
    final buyerIpText = _normalizeIpRecord(buyerIp);
    return sellerIpText.isNotEmpty &&
        buyerIpText.isNotEmpty &&
        sellerIpText == buyerIpText;
  }

  /// 卖方展示名称
  String get sellerDisplayName {
    return _displayName(sellerName, seller);
  }

  /// 买方展示名称
  String get buyerDisplayName {
    return _displayName(buyerName, buyer);
  }

  /// 从 JSON 创建角色 GM 交易记录接口条目
  ///
  /// [json] 原始交易记录 JSON
  factory CharacterGmTradeHistoryItem.fromJson(Map<String, Object?> json) {
    return CharacterGmTradeHistoryItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      name: TinygrailResponseParser.asString(json['Name']),
      seller: TinygrailResponseParser.asString(json['Seller']),
      sellerName: TinygrailResponseParser.asString(json['SellerName']),
      sellerIp: TinygrailResponseParser.asString(json['SellerIp']),
      buyer: TinygrailResponseParser.asString(json['Buyer']),
      buyerName: TinygrailResponseParser.asString(json['BuyerName']),
      buyerIp: TinygrailResponseParser.asString(json['BuyerIp']),
      price: TinygrailResponseParser.asDouble(json['Price']),
      amount: TinygrailResponseParser.asInt(json['Amount']),
      tradeTime: TinygrailResponseParser.asString(json['TradeTime']),
    );
  }

  /// 解析用户展示名称
  ///
  /// [nickname] 用户昵称
  /// [username] 用户名
  String _displayName(String nickname, String username) {
    final decodedNickname =
        TinygrailFormatters.decodeHtmlEntities(nickname).trim();
    if (decodedNickname.isNotEmpty) {
      return decodedNickname;
    }

    final resolvedUsername = username.trim();
    return resolvedUsername.isEmpty ? '未知用户' : resolvedUsername;
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
}
