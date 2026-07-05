import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 角色详情当前用户 ICO 注资资料
class CharacterDetailIcoUserInfo {
  /// 创建角色详情当前用户 ICO 注资资料
  ///
  /// [amount] 当前用户已注资金额
  const CharacterDetailIcoUserInfo({
    required this.amount,
  });

  /// 创建空的角色详情当前用户 ICO 注资资料
  const CharacterDetailIcoUserInfo.empty() : amount = 0;

  /// 当前用户已注资金额
  final double amount;

  /// 是否已经参与注资
  bool get hasInvested => amount > 0;

  /// 从 JSON 创建角色详情当前用户 ICO 注资资料
  ///
  /// [json] 原始注资 JSON
  factory CharacterDetailIcoUserInfo.fromJson(Map<String, Object?> json) {
    return CharacterDetailIcoUserInfo(
      amount: TinygrailResponseParser.asDouble(json['Amount']),
    );
  }
}
