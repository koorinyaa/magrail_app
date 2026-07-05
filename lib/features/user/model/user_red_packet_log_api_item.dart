import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 用户红包记录接口条目
final class UserRedPacketLogApiItem {
  /// 创建用户红包记录接口条目
  ///
  /// [id] 记录 ID
  /// [logTime] 记录时间
  /// [type] 记录类型
  /// [change] 红包金额变化
  /// [relatedName] 关联用户名
  /// [description] 记录描述
  const UserRedPacketLogApiItem({
    required this.id,
    required this.logTime,
    required this.type,
    required this.change,
    required this.relatedName,
    required this.description,
  });

  /// 记录 ID
  final int id;

  /// 记录时间
  final String logTime;

  /// 记录类型
  final int type;

  /// 红包金额变化
  final double change;

  /// 关联用户名
  final String relatedName;

  /// 记录描述
  final String description;

  /// 记录类型文案
  String get typeName {
    return switch (type) {
      16 => '发出红包',
      17 => '收到红包',
      _ => '红包记录',
    };
  }

  /// 从 JSON 创建用户红包记录接口条目
  ///
  /// [json] 原始接口 JSON
  factory UserRedPacketLogApiItem.fromJson(Map<String, Object?> json) {
    return UserRedPacketLogApiItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      logTime: TinygrailResponseParser.asString(json['LogTime']),
      type: TinygrailResponseParser.asInt(json['Type']),
      change: TinygrailResponseParser.asDouble(json['Change']),
      relatedName: TinygrailResponseParser.asString(json['RelatedName']),
      description: TinygrailResponseParser.asString(json['Description']),
    );
  }
}
