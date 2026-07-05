import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 用户道具接口条目
final class UserItemApiItem {
  /// 创建用户道具接口条目
  ///
  /// [id] 道具 ID
  /// [name] 道具名称
  /// [icon] 道具图标
  /// [line] 道具描述文本
  /// [description] 道具补充描述
  /// [amount] 道具数量
  const UserItemApiItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.line,
    required this.description,
    required this.amount,
  });

  /// 道具 ID
  final int id;

  /// 道具名称
  final String name;

  /// 道具图标
  final String icon;

  /// 道具描述文本
  final String line;

  /// 道具补充描述
  final String? description;

  /// 道具数量
  final int amount;

  /// 从 JSON 创建用户道具接口条目
  ///
  /// [json] 原始 JSON
  factory UserItemApiItem.fromJson(Map<String, Object?> json) {
    return UserItemApiItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      name: TinygrailResponseParser.asString(json['Name']),
      icon: TinygrailResponseParser.asString(json['Icon']),
      line: TinygrailResponseParser.asString(json['Line']),
      description: TinygrailResponseParser.asNullableString(
        json['Description'],
      ),
      amount: TinygrailResponseParser.asInt(json['Amount']),
    );
  }
}
