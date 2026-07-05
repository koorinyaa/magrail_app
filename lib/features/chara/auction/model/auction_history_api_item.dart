import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 角色往期拍卖接口条目
class AuctionHistoryApiItem {
  /// 创建角色往期拍卖接口条目
  ///
  /// [id] 拍卖记录 ID
  /// [characterId] 角色 ID
  /// [userId] 用户内部 ID
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [price] 拍卖价格
  /// [amount] 拍卖数量
  /// [bid] 拍卖时间
  /// [state] 拍卖结果状态
  const AuctionHistoryApiItem({
    required this.id,
    required this.characterId,
    required this.userId,
    required this.username,
    required this.nickname,
    required this.price,
    required this.amount,
    required this.bid,
    required this.state,
  });

  /// 拍卖记录 ID
  final int id;

  /// 角色 ID
  final int characterId;

  /// 用户内部 ID
  final int userId;

  /// 用户名
  final String username;

  /// 用户昵称
  final String nickname;

  /// 拍卖价格
  final double price;

  /// 拍卖数量
  final int amount;

  /// 拍卖时间
  final String bid;

  /// 拍卖结果状态
  final int state;

  /// 是否竞拍成功
  bool get isSuccess => state == 1;

  /// 从 JSON 创建角色往期拍卖接口条目
  ///
  /// [json] 原始拍卖记录 JSON
  factory AuctionHistoryApiItem.fromJson(Map<String, Object?> json) {
    return AuctionHistoryApiItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      userId: TinygrailResponseParser.asInt(json['UserId']),
      username: TinygrailResponseParser.asString(json['Username']),
      nickname: TinygrailResponseParser.asString(json['Nickname']),
      price: TinygrailResponseParser.asDouble(json['Price']),
      amount: TinygrailResponseParser.asInt(json['Amount']),
      bid: TinygrailResponseParser.asString(json['Bid']),
      state: TinygrailResponseParser.asInt(json['State']),
    );
  }
}
