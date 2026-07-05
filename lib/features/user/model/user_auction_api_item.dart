import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/chara/auction/model/auction_api_item.dart';

/// 用户拍卖接口条目
final class UserAuctionApiItem {
  /// 创建用户拍卖接口条目
  ///
  /// [id] 拍卖记录 ID
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [icon] 角色头像地址
  /// [state] 拍卖状态
  /// [start] 拍卖底价
  /// [type] 英灵殿数量
  /// [bid] 出价时间
  /// [price] 出价金额
  /// [amount] 出价数量
  /// [auctionDetail] 当前拍卖详情
  const UserAuctionApiItem({
    required this.id,
    required this.characterId,
    required this.name,
    required this.icon,
    required this.state,
    required this.start,
    required this.type,
    required this.bid,
    required this.price,
    required this.amount,
    this.auctionDetail,
  });

  /// 拍卖记录 ID
  final int id;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 角色头像地址
  final String icon;

  /// 拍卖状态
  final int state;

  /// 拍卖底价
  final double start;

  /// 英灵殿数量
  final int type;

  /// 出价时间
  final String bid;

  /// 出价金额
  final double price;

  /// 出价数量
  final int amount;

  /// 当前拍卖详情
  final AuctionApiItem? auctionDetail;

  /// 从 JSON 创建用户拍卖接口条目
  ///
  /// [json] 原始接口 JSON
  factory UserAuctionApiItem.fromJson(Map<String, Object?> json) {
    return UserAuctionApiItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      name: TinygrailResponseParser.asString(json['Name']),
      icon: TinygrailResponseParser.asString(json['Icon']),
      state: TinygrailResponseParser.asInt(json['State']),
      start: TinygrailResponseParser.asDouble(json['Start']),
      type: TinygrailResponseParser.asInt(json['Type']),
      bid: TinygrailResponseParser.asString(json['Bid']),
      price: TinygrailResponseParser.asDouble(json['Price']),
      amount: TinygrailResponseParser.asInt(json['Amount']),
    );
  }

  /// 复制用户拍卖接口条目
  ///
  /// [auctionDetail] 当前拍卖详情
  UserAuctionApiItem copyWith({
    AuctionApiItem? auctionDetail,
  }) {
    return UserAuctionApiItem(
      id: id,
      characterId: characterId,
      name: name,
      icon: icon,
      state: state,
      start: start,
      type: type,
      bid: bid,
      price: price,
      amount: amount,
      auctionDetail: auctionDetail ?? this.auctionDetail,
    );
  }
}
