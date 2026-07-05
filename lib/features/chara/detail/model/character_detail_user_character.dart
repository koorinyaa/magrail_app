import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 角色详情指定用户持股资料
class CharacterDetailUserCharacter {
  /// 创建角色详情指定用户持股资料
  ///
  /// [amount] 可用活股数量
  /// [total] 当前总持股数量
  /// [sacrifices] 固定资产数量
  /// [price] 持股评估价
  const CharacterDetailUserCharacter({
    required this.amount,
    required this.total,
    required this.sacrifices,
    required this.price,
  });

  /// 创建空的角色详情指定用户持股资料
  const CharacterDetailUserCharacter.empty()
      : amount = 0,
        total = 0,
        sacrifices = 0,
        price = 0;

  /// 可用活股数量
  final int amount;

  /// 当前总持股数量
  final int total;

  /// 固定资产数量
  final int sacrifices;

  /// 持股评估价
  final double price;

  /// 从 JSON 创建角色详情指定用户持股资料
  ///
  /// [json] 原始持股 JSON
  factory CharacterDetailUserCharacter.fromJson(Map<String, Object?> json) {
    return CharacterDetailUserCharacter(
      amount: TinygrailResponseParser.asInt(json['Amount']),
      total: TinygrailResponseParser.asInt(json['Total']),
      sacrifices: TinygrailResponseParser.asInt(json['Sacrifices']),
      price: TinygrailResponseParser.asDouble(json['Price']),
    );
  }
}
