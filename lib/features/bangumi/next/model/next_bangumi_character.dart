import 'package:magrail_app/core/network/tinygrail_response.dart';

/// Next Bangumi 角色详情
final class NextBangumiCharacter {
  /// 创建 Next Bangumi 角色详情
  ///
  /// [characterId] 角色 ID
  /// [name] 原名
  /// [nameCn] 中文名
  /// [avatarUrl] 小尺寸头像地址
  const NextBangumiCharacter({
    required this.characterId,
    required this.name,
    required this.nameCn,
    required this.avatarUrl,
  });

  /// 角色 ID
  final int characterId;

  /// 原名
  final String name;

  /// 中文名
  final String nameCn;

  /// 小尺寸头像地址
  final String avatarUrl;

  /// 从 JSON 创建 Next Bangumi 角色详情
  ///
  /// [json] 原始角色详情 JSON
  factory NextBangumiCharacter.fromJson(Map<String, Object?> json) {
    final images = TinygrailResponseParser.asObjectMap(json['images']);

    return NextBangumiCharacter(
      characterId: TinygrailResponseParser.asInt(json['id']),
      name: TinygrailResponseParser.asString(json['name']),
      nameCn: TinygrailResponseParser.asString(json['nameCN']),
      avatarUrl: TinygrailResponseParser.asString(images?['small']),
    );
  }
}
