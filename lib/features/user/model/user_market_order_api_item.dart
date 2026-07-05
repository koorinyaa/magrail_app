import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 用户委托订单方向
enum UserMarketOrderSide {
  /// 买单列表
  bid,

  /// 卖单列表
  ask,
}

/// 用户委托订单接口条目
final class UserMarketOrderApiItem {
  /// 创建用户委托订单接口条目
  ///
  /// [id] 订单 ID
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [icon] 角色头像地址
  /// [level] 角色等级
  /// [zeroCount] ST 等级
  /// [lastOrder] 最近委托时间
  /// [state] 委托数量
  /// [current] 当前价
  /// [fluctuation] 当前价涨跌幅
  const UserMarketOrderApiItem({
    required this.id,
    required this.characterId,
    required this.name,
    required this.icon,
    required this.level,
    required this.zeroCount,
    required this.lastOrder,
    required this.state,
    required this.current,
    required this.fluctuation,
  });

  /// 订单 ID
  final int id;

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

  /// 最近委托时间
  final String lastOrder;

  /// 委托数量
  final int state;

  /// 当前价
  final double current;

  /// 当前价涨跌幅
  final double fluctuation;

  /// 从 JSON 创建用户委托订单接口条目
  ///
  /// [json] 原始接口 JSON
  factory UserMarketOrderApiItem.fromJson(Map<String, Object?> json) {
    return UserMarketOrderApiItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      name: TinygrailResponseParser.asString(json['Name']),
      icon: TinygrailResponseParser.asString(json['Icon']),
      level: TinygrailResponseParser.asInt(json['Level']),
      zeroCount: TinygrailResponseParser.asInt(json['ZeroCount']),
      lastOrder: TinygrailResponseParser.asString(json['LastOrder']),
      state: TinygrailResponseParser.asInt(json['State']),
      current: TinygrailResponseParser.asDouble(json['Current']),
      fluctuation: TinygrailResponseParser.asDouble(json['Fluctuation']),
    );
  }
}
