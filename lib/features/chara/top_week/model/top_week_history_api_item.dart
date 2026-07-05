import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 往期萌王接口条目
///
/// [characterId] 角色 ID
/// [name] 角色名称
/// [characterLevel] 角色等级
/// [level] 当期排名
/// [avatar] 头像地址
/// [extra] 超出金额
/// [price] 总金额
/// [assets] 参与人数
/// [create] 记录创建时间
class TopWeekHistoryApiItem {
  const TopWeekHistoryApiItem({
    required this.characterId,
    required this.name,
    required this.characterLevel,
    required this.level,
    required this.avatar,
    required this.extra,
    required this.price,
    required this.assets,
    required this.create,
  });

  final int characterId;
  final String name;
  final int characterLevel;
  final int level;
  final String avatar;
  final double extra;
  final double price;
  final int assets;
  final String create;

  /// 从 JSON 创建往期萌王接口条目
  ///
  /// [json] 原始条目 JSON
  factory TopWeekHistoryApiItem.fromJson(Map<String, Object?> json) {
    return TopWeekHistoryApiItem(
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      name: TinygrailResponseParser.asString(json['Name']),
      characterLevel: TinygrailResponseParser.asInt(json['CharacterLevel']),
      level: TinygrailResponseParser.asInt(json['Level']),
      avatar: TinygrailResponseParser.asString(json['Avatar']),
      extra: TinygrailResponseParser.asDouble(json['Extra']),
      price: TinygrailResponseParser.asDouble(json['Price']),
      assets: TinygrailResponseParser.asInt(json['Assets']),
      create: TinygrailResponseParser.asString(json['Create']),
    );
  }
}
