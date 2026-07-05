import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 用户股息预测
class UserShareBonusForecast {
  /// 创建用户股息预测
  ///
  /// [total] 计息股份数量
  /// [temples] 圣殿数量
  /// [share] 预期股息
  /// [tax] 个人所得税
  /// [daily] 登录奖励
  const UserShareBonusForecast({
    required this.total,
    required this.temples,
    required this.share,
    required this.tax,
    required this.daily,
  });

  /// 计息股份数量
  final int total;

  /// 圣殿数量
  final int temples;

  /// 预期股息
  final double share;

  /// 个人所得税
  final double tax;

  /// 登录奖励
  final double daily;

  /// 税后股息
  double get afterTax => share - tax;

  /// 个税比例
  double get taxRate {
    if (share <= 0) {
      return 0;
    }

    return tax / share;
  }

  /// 从 JSON 创建用户股息预测
  ///
  /// [json] 原始响应 JSON
  factory UserShareBonusForecast.fromJson(Map<String, Object?> json) {
    return UserShareBonusForecast(
      total: TinygrailResponseParser.asInt(json['Total']),
      temples: TinygrailResponseParser.asInt(json['Temples']),
      share: TinygrailResponseParser.asDouble(json['Share']),
      tax: TinygrailResponseParser.asDouble(json['Tax']),
      daily: TinygrailResponseParser.asDouble(json['Daily']),
    );
  }
}
