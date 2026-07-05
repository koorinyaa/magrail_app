import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 用户 ICO 接口条目
class UserIcoApiItem {
  /// 创建用户 ICO 接口条目
  ///
  /// [id] ICO ID
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [icon] 角色头像地址
  /// [total] 已筹集金额
  /// [state] 当前用户已注资金额
  /// [end] ICO 结束时间
  const UserIcoApiItem({
    required this.id,
    required this.characterId,
    required this.name,
    required this.icon,
    required this.total,
    required this.state,
    required this.end,
  });

  /// ICO ID
  final int id;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 角色头像地址
  final String icon;

  /// 已筹集金额
  final double total;

  /// 当前用户已注资金额
  final double state;

  /// ICO 结束时间
  final String end;

  /// 从 JSON 创建用户 ICO 接口条目
  ///
  /// [json] 原始条目 JSON
  factory UserIcoApiItem.fromJson(Map<String, Object?> json) {
    return UserIcoApiItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      name: TinygrailResponseParser.asString(json['Name']),
      icon: TinygrailResponseParser.asString(json['Icon']),
      total: TinygrailResponseParser.asDouble(json['Total']),
      state: TinygrailResponseParser.asDouble(json['State']),
      end: TinygrailResponseParser.asString(json['End']),
    );
  }

  /// 转换为缓存 JSON
  Map<String, Object?> toJson() {
    return {
      'Id': id,
      'CharacterId': characterId,
      'Name': name,
      'Icon': icon,
      'Total': total,
      'State': state,
      'End': end,
    };
  }
}
