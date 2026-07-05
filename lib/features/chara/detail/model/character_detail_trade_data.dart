import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 角色详情交易方向
enum CharacterDetailTradeSide {
  /// 买入角色
  buy,

  /// 卖出角色
  sell,
}

/// 角色详情委托类型
enum CharacterDetailTradeOrderType {
  /// 普通委托
  regular,

  /// 冰山委托
  iceberg,
}

/// 角色详情深度信息
final class CharacterDetailTradeDepth {
  /// 创建角色详情深度信息
  ///
  /// [asks] 卖单深度
  /// [bids] 买单深度
  const CharacterDetailTradeDepth({
    required this.asks,
    required this.bids,
  });

  /// 创建空深度信息
  const CharacterDetailTradeDepth.empty()
      : asks = const <CharacterDetailTradeDepthItem>[],
        bids = const <CharacterDetailTradeDepthItem>[];

  /// 卖单深度
  final List<CharacterDetailTradeDepthItem> asks;

  /// 买单深度
  final List<CharacterDetailTradeDepthItem> bids;

  /// 从 JSON 创建角色详情深度信息
  ///
  /// [json] 原始深度信息 JSON
  factory CharacterDetailTradeDepth.fromJson(Map<String, Object?> json) {
    return CharacterDetailTradeDepth(
      asks: TinygrailResponseParser.asObjectList(
            json['Asks'],
            CharacterDetailTradeDepthItem.fromJson,
          ) ??
          const <CharacterDetailTradeDepthItem>[],
      bids: TinygrailResponseParser.asObjectList(
            json['Bids'],
            CharacterDetailTradeDepthItem.fromJson,
          ) ??
          const <CharacterDetailTradeDepthItem>[],
    );
  }
}

/// 角色详情深度条目
final class CharacterDetailTradeDepthItem {
  /// 创建角色详情深度条目
  ///
  /// [price] 委托价格
  /// [amount] 委托数量
  /// [type] 委托类型
  const CharacterDetailTradeDepthItem({
    required this.price,
    required this.amount,
    required this.type,
  });

  /// 委托价格
  final double price;

  /// 委托数量
  final int amount;

  /// 委托类型
  final int type;

  /// 是否为冰山委托
  bool get isIceberg => type == 1;

  /// 从 JSON 创建角色详情深度条目
  ///
  /// [json] 原始深度条目 JSON
  factory CharacterDetailTradeDepthItem.fromJson(Map<String, Object?> json) {
    return CharacterDetailTradeDepthItem(
      price: TinygrailResponseParser.asDouble(json['Price']),
      amount: TinygrailResponseParser.asInt(json['Amount']),
      type: TinygrailResponseParser.asInt(json['Type']),
    );
  }
}

/// 当前用户角色交易资料
final class CharacterDetailUserTrading {
  /// 创建当前用户角色交易资料
  ///
  /// [id] 当前用户内部 ID
  /// [balance] 当前用户余额
  /// [amount] 当前角色可用活股
  /// [sacrifices] 当前角色固定资产数量
  /// [asks] 当前用户卖出委托
  /// [bids] 当前用户买入委托
  /// [askHistory] 当前用户卖出成交记录
  /// [bidHistory] 当前用户买入成交记录
  const CharacterDetailUserTrading({
    required this.id,
    required this.balance,
    required this.amount,
    required this.sacrifices,
    required this.asks,
    required this.bids,
    required this.askHistory,
    required this.bidHistory,
  });

  /// 创建空的当前用户角色交易资料
  const CharacterDetailUserTrading.empty()
      : id = 0,
        balance = 0,
        amount = 0,
        sacrifices = 0,
        asks = const <CharacterDetailTradeOrder>[],
        bids = const <CharacterDetailTradeOrder>[],
        askHistory = const <CharacterDetailTradeHistoryOrder>[],
        bidHistory = const <CharacterDetailTradeHistoryOrder>[];

  /// 当前用户内部 ID
  final int id;

  /// 当前用户余额
  final double balance;

  /// 当前角色可用活股
  final int amount;

  /// 当前角色固定资产数量
  final int sacrifices;

  /// 当前用户卖出委托
  final List<CharacterDetailTradeOrder> asks;

  /// 当前用户买入委托
  final List<CharacterDetailTradeOrder> bids;

  /// 当前用户卖出成交记录
  final List<CharacterDetailTradeHistoryOrder> askHistory;

  /// 当前用户买入成交记录
  final List<CharacterDetailTradeHistoryOrder> bidHistory;

  /// 当前仍有效的卖出委托
  Iterable<CharacterDetailTradeOrder> get activeAsks {
    return asks.where((order) => order.amount > 0);
  }

  /// 当前仍有效的买入委托
  Iterable<CharacterDetailTradeOrder> get activeBids {
    return bids.where((order) => order.amount > 0);
  }

  /// 当前委托总数
  int get activeOrderCount {
    return activeAsks.length + activeBids.length;
  }

  /// 是否存在当前委托
  bool get hasActiveOrders => activeOrderCount > 0;

  /// 从 JSON 创建当前用户角色交易资料
  ///
  /// [json] 原始交易资料 JSON
  factory CharacterDetailUserTrading.fromJson(Map<String, Object?> json) {
    return CharacterDetailUserTrading(
      id: TinygrailResponseParser.asInt(json['Id']),
      balance: TinygrailResponseParser.asDouble(json['Balance']),
      amount: TinygrailResponseParser.asInt(json['Amount']),
      sacrifices: TinygrailResponseParser.asInt(json['Sacrifices']),
      asks: TinygrailResponseParser.asObjectList(
            json['Asks'],
            CharacterDetailTradeOrder.fromJson,
          ) ??
          const <CharacterDetailTradeOrder>[],
      bids: TinygrailResponseParser.asObjectList(
            json['Bids'],
            CharacterDetailTradeOrder.fromJson,
          ) ??
          const <CharacterDetailTradeOrder>[],
      askHistory: TinygrailResponseParser.asObjectList(
            json['AskHistory'],
            CharacterDetailTradeHistoryOrder.fromJson,
          ) ??
          const <CharacterDetailTradeHistoryOrder>[],
      bidHistory: TinygrailResponseParser.asObjectList(
            json['BidHistory'],
            CharacterDetailTradeHistoryOrder.fromJson,
          ) ??
          const <CharacterDetailTradeHistoryOrder>[],
    );
  }
}

/// 角色详情当前交易委托
final class CharacterDetailTradeOrder {
  /// 创建角色详情当前交易委托
  ///
  /// [id] 委托 ID
  /// [userId] 用户内部 ID
  /// [characterId] 角色 ID
  /// [price] 委托价格
  /// [amount] 委托数量
  /// [begin] 开始时间
  /// [end] 结束时间
  /// [state] 委托状态
  /// [type] 委托类型
  const CharacterDetailTradeOrder({
    required this.id,
    required this.userId,
    required this.characterId,
    required this.price,
    required this.amount,
    required this.begin,
    required this.end,
    required this.state,
    required this.type,
  });

  /// 委托 ID
  final int id;

  /// 用户内部 ID
  final int userId;

  /// 角色 ID
  final int characterId;

  /// 委托价格
  final double price;

  /// 委托数量
  final int amount;

  /// 开始时间
  final String begin;

  /// 结束时间
  final String end;

  /// 委托状态
  final int state;

  /// 委托类型
  final int type;

  /// 是否为冰山委托
  bool get isIceberg => type == 1;

  /// 委托合计金额
  double get total => price * amount;

  /// 从 JSON 创建角色详情当前交易委托
  ///
  /// [json] 原始委托 JSON
  factory CharacterDetailTradeOrder.fromJson(Map<String, Object?> json) {
    return CharacterDetailTradeOrder(
      id: TinygrailResponseParser.asInt(json['Id']),
      userId: TinygrailResponseParser.asInt(json['UserId']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      price: TinygrailResponseParser.asDouble(json['Price']),
      amount: TinygrailResponseParser.asInt(json['Amount']),
      begin: TinygrailResponseParser.asString(json['Begin']),
      end: TinygrailResponseParser.asString(json['End']),
      state: TinygrailResponseParser.asInt(json['State']),
      type: TinygrailResponseParser.asInt(json['Type']),
    );
  }
}

/// 角色详情历史成交委托
final class CharacterDetailTradeHistoryOrder {
  /// 创建角色详情历史成交委托
  ///
  /// [id] 委托 ID
  /// [userId] 用户内部 ID
  /// [characterId] 角色 ID
  /// [price] 成交价格
  /// [amount] 成交数量
  /// [tradeTime] 成交时间
  const CharacterDetailTradeHistoryOrder({
    required this.id,
    required this.userId,
    required this.characterId,
    required this.price,
    required this.amount,
    required this.tradeTime,
  });

  /// 委托 ID
  final int id;

  /// 用户内部 ID
  final int userId;

  /// 角色 ID
  final int characterId;

  /// 成交价格
  final double price;

  /// 成交数量
  final int amount;

  /// 成交时间
  final String tradeTime;

  /// 成交合计金额
  double get total => price * amount;

  /// 从 JSON 创建角色详情历史成交委托
  ///
  /// [json] 原始历史成交 JSON
  factory CharacterDetailTradeHistoryOrder.fromJson(
    Map<String, Object?> json,
  ) {
    return CharacterDetailTradeHistoryOrder(
      id: TinygrailResponseParser.asInt(json['Id']),
      userId: TinygrailResponseParser.asInt(json['UserId']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      price: TinygrailResponseParser.asDouble(json['Price']),
      amount: TinygrailResponseParser.asInt(json['Amount']),
      tradeTime: TinygrailResponseParser.asString(json['TradeTime']),
    );
  }
}
