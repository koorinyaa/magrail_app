import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 角色详情 ICO 头部资料
class CharacterDetailIcoInfo {
  /// 创建角色详情 ICO 头部资料
  ///
  /// [id] ICO 记录 ID
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [icon] 角色头像地址
  /// [begin] ICO 开始时间
  /// [end] ICO 结束时间
  /// [total] 已筹集金额
  /// [users] 参与人数
  const CharacterDetailIcoInfo({
    required this.id,
    required this.characterId,
    required this.name,
    required this.icon,
    required this.begin,
    required this.end,
    required this.total,
    required this.users,
  });

  /// ICO 记录 ID
  final int id;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 角色头像地址
  final String icon;

  /// ICO 开始时间
  final String begin;

  /// ICO 结束时间
  final String end;

  /// 已筹集金额
  final double total;

  /// 参与人数
  final int users;

  /// 从 JSON 创建角色详情 ICO 头部资料
  ///
  /// [json] 原始 ICO JSON
  factory CharacterDetailIcoInfo.fromJson(Map<String, Object?> json) {
    final characterId = TinygrailResponseParser.asInt(json['CharacterId']);

    return CharacterDetailIcoInfo(
      id: TinygrailResponseParser.asInt(json['Id']),
      characterId: characterId > 0
          ? characterId
          : TinygrailResponseParser.asInt(json['Id']),
      name: TinygrailResponseParser.asString(json['Name']),
      icon: TinygrailResponseParser.asString(json['Icon']),
      begin: TinygrailResponseParser.asString(json['Begin']),
      end: TinygrailResponseParser.asString(json['End']),
      total: TinygrailResponseParser.asDouble(json['Total']),
      users: TinygrailResponseParser.asInt(json['Users']),
    );
  }
}
