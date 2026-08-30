import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 每周萌王接口条目
///
/// [characterId] 角色 ID
/// [characterName] 角色名称
/// [characterLevel] 角色等级
/// [cover] 圣殿封面地址
/// [avatar] 头像地址
/// [price] 当前评估价
/// [extra] 溢出金额
/// [assets] 拍卖数量
/// [sacrifices] 英灵殿数量
/// [type] 拍卖人数
class TopWeekApiItem {
  /// 创建每周萌王接口条目
  ///
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  /// [characterLevel] 角色等级
  /// [cover] 圣殿封面地址
  /// [avatar] 头像地址
  /// [price] 当前评估价
  /// [extra] 溢出金额
  /// [assets] 拍卖数量
  /// [sacrifices] 英灵殿数量
  /// [type] 拍卖人数
  const TopWeekApiItem({
    required this.characterId,
    required this.characterName,
    required this.characterLevel,
    required this.cover,
    required this.avatar,
    required this.price,
    required this.extra,
    required this.assets,
    required this.sacrifices,
    required this.type,
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 角色等级
  final int characterLevel;

  /// 圣殿封面地址
  final String cover;

  /// 头像地址
  final String avatar;

  /// 当前评估价
  final double price;

  /// 溢出金额
  final double extra;

  /// 拍卖数量
  final int assets;

  /// 英灵殿数量
  final int sacrifices;

  /// 拍卖人数
  final int type;

  /// 从 JSON 创建每周萌王接口条目
  ///
  /// [json] 原始条目 JSON
  factory TopWeekApiItem.fromJson(Map<String, Object?> json) {
    return TopWeekApiItem(
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      characterName: TinygrailResponseParser.asString(json['CharacterName']),
      characterLevel: TinygrailResponseParser.asInt(json['CharacterLevel']),
      cover: TinygrailResponseParser.asString(json['Cover']),
      avatar: TinygrailResponseParser.asString(json['Avatar']),
      price: TinygrailResponseParser.asDouble(json['Price']),
      extra: TinygrailResponseParser.asDouble(json['Extra']),
      assets: TinygrailResponseParser.asInt(json['Assets']),
      sacrifices: TinygrailResponseParser.asInt(json['Sacrifices']),
      type: TinygrailResponseParser.asInt(json['Type']),
    );
  }
}
