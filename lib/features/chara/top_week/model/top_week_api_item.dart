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

  final int characterId;
  final String characterName;
  final int characterLevel;
  final String cover;
  final String avatar;
  final double price;
  final double extra;
  final int assets;
  final int sacrifices;
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
