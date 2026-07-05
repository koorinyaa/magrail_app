import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 用户资金日志接口条目
final class UserBalanceLogApiItem {
  /// 创建用户资金日志接口条目
  ///
  /// [id] 日志 ID
  /// [balance] 变动后的资金余额
  /// [change] 本次资金变动
  /// [amount] 本次股份变动
  /// [logTime] 日志时间
  /// [relatedId] 关联对象 ID
  /// [type] 日志类型
  /// [description] 日志描述
  const UserBalanceLogApiItem({
    required this.id,
    required this.balance,
    required this.change,
    required this.amount,
    required this.logTime,
    required this.relatedId,
    required this.type,
    required this.description,
  });

  /// 日志 ID
  final int id;

  /// 变动后的资金余额
  final double balance;

  /// 本次资金变动
  final double change;

  /// 本次股份变动
  final int amount;

  /// 日志时间
  final String logTime;

  /// 关联对象 ID
  final int relatedId;

  /// 日志类型
  final int type;

  /// 日志描述
  final String description;

  /// 从 JSON 创建用户资金日志接口条目
  ///
  /// [json] 原始接口 JSON
  factory UserBalanceLogApiItem.fromJson(Map<String, Object?> json) {
    return UserBalanceLogApiItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      balance: TinygrailResponseParser.asDouble(json['Balance']),
      change: TinygrailResponseParser.asDouble(json['Change']),
      amount: TinygrailResponseParser.asInt(json['Amount']),
      logTime: TinygrailResponseParser.asString(json['LogTime']),
      relatedId: TinygrailResponseParser.asInt(json['RelatedId']),
      type: TinygrailResponseParser.asInt(json['Type']),
      description: TinygrailResponseParser.asString(json['Description']),
    );
  }
}
