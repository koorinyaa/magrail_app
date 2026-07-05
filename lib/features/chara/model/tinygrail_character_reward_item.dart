import 'package:magrail_app/core/network/tinygrail_response.dart';

/// Tinygrail 角色抽奖接口条目
final class TinygrailCharacterRewardItem {
  /// 创建 Tinygrail 角色抽奖接口条目
  ///
  /// [id] 角色 ID
  /// [name] 角色名称
  /// [cover] 角色封面
  /// [level] 角色等级
  /// [currentPrice] 当前价格
  /// [amount] 获得数量
  /// [sellPrice] 可出售价格
  /// [sellAmount] 可出售数量
  /// [rate] 基础股息
  /// [financePrice] 融资价格
  const TinygrailCharacterRewardItem({
    required this.id,
    required this.name,
    required this.cover,
    required this.level,
    required this.currentPrice,
    required this.amount,
    required this.sellPrice,
    required this.sellAmount,
    required this.rate,
    required this.financePrice,
  });

  /// 角色 ID
  final int id;

  /// 角色名称
  final String name;

  /// 角色封面
  final String cover;

  /// 角色等级
  final int level;

  /// 当前价格
  final double currentPrice;

  /// 获得数量
  final int amount;

  /// 可出售价格
  final double sellPrice;

  /// 可出售数量
  final int sellAmount;

  /// 基础股息
  final double rate;

  /// 融资价格
  final double financePrice;

  /// 是否可出售
  bool get canSell => sellPrice > 0 && sellAmount > 0;

  /// 从 JSON 创建 Tinygrail 角色抽奖接口条目
  ///
  /// [json] 原始接口 JSON
  factory TinygrailCharacterRewardItem.fromJson(Map<String, Object?> json) {
    return TinygrailCharacterRewardItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      name: TinygrailResponseParser.asString(json['Name']),
      cover: TinygrailResponseParser.asString(json['Cover']),
      level: TinygrailResponseParser.asInt(json['Level']),
      currentPrice: TinygrailResponseParser.asDouble(json['CurrentPrice']),
      amount: TinygrailResponseParser.asInt(json['Amount']),
      sellPrice: TinygrailResponseParser.asDouble(json['SellPrice']),
      sellAmount: TinygrailResponseParser.asInt(json['SellAmount']),
      rate: TinygrailResponseParser.asDouble(json['Rate']),
      financePrice: TinygrailResponseParser.asDouble(json['FinancePrice']),
    );
  }

  /// 复制 Tinygrail 角色抽奖接口条目
  ///
  /// [amount] 替换后的获得数量
  /// [sellPrice] 替换后的可出售价格
  /// [sellAmount] 替换后的可出售数量
  TinygrailCharacterRewardItem copyWith({
    int? amount,
    double? sellPrice,
    int? sellAmount,
  }) {
    return TinygrailCharacterRewardItem(
      id: id,
      name: name,
      cover: cover,
      level: level,
      currentPrice: currentPrice,
      amount: amount ?? this.amount,
      sellPrice: sellPrice ?? this.sellPrice,
      sellAmount: sellAmount ?? this.sellAmount,
      rate: rate,
      financePrice: financePrice,
    );
  }
}
