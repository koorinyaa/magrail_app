import 'package:magrail_app/core/network/tinygrail_response.dart';

/// ICO 角色条目
class IcoCharacterEntry {
  /// 创建 ICO 角色条目
  ///
  /// [id] ICO ID
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [icon] 角色头像地址
  /// [total] 已筹集金额
  /// [users] 参与人数
  /// [end] ICO 结束时间
  /// [type] ICO 类型
  /// [bonus] 额外分红期数
  const IcoCharacterEntry({
    required this.id,
    required this.characterId,
    required this.name,
    required this.icon,
    required this.total,
    required this.users,
    required this.end,
    required this.type,
    required this.bonus,
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

  /// 参与人数
  final int users;

  /// ICO 结束时间
  final String end;

  /// ICO 类型
  final int type;

  /// 额外分红期数
  final int bonus;

  /// 从 JSON 创建 ICO 角色条目
  ///
  /// [json] 原始条目 JSON
  factory IcoCharacterEntry.fromJson(Map<String, Object?> json) {
    final parsedCharacterId = TinygrailResponseParser.asInt(
      json['CharacterId'],
    );
    final id = TinygrailResponseParser.asInt(json['Id']);

    return IcoCharacterEntry(
      id: id,
      characterId: parsedCharacterId == 0 ? id : parsedCharacterId,
      name: TinygrailResponseParser.asString(json['Name']),
      icon: TinygrailResponseParser.asString(json['Icon']),
      total: TinygrailResponseParser.asDouble(json['Total']),
      users: TinygrailResponseParser.asInt(json['Users']),
      end: TinygrailResponseParser.asString(json['End']),
      type: TinygrailResponseParser.asInt(json['Type']),
      bonus: TinygrailResponseParser.asInt(json['Bonus']),
    );
  }
}
