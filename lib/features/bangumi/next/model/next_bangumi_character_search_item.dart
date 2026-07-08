import 'package:magrail_app/core/network/tinygrail_response.dart';

/// Next Bangumi 角色搜索分页结果
final class NextBangumiCharacterSearchPage {
  /// 创建 Next Bangumi 角色搜索分页结果
  ///
  /// [items] 搜索结果
  /// [total] 接口返回的原始总数
  /// [rawItemCount] 当前页接口返回的原始条目数
  const NextBangumiCharacterSearchPage({
    required this.items,
    required this.total,
    required this.rawItemCount,
  });

  /// 搜索结果
  final List<NextBangumiCharacterSearchItem> items;

  /// 接口返回的原始总数
  final int total;

  /// 当前页接口返回的原始条目数
  final int rawItemCount;
}

/// Next Bangumi 角色搜索结果条目
final class NextBangumiCharacterSearchItem {
  /// 创建 Next Bangumi 角色搜索结果条目
  ///
  /// [characterId] 角色 ID
  /// [name] 原名
  /// [nameCn] 中文名
  /// [avatarUrl] 小尺寸头像地址
  const NextBangumiCharacterSearchItem({
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

  /// 从 JSON 创建 Next Bangumi 角色搜索结果条目
  ///
  /// [json] 原始搜索结果 JSON
  factory NextBangumiCharacterSearchItem.fromJson(
    Map<String, Object?> json,
  ) {
    final images = TinygrailResponseParser.asObjectMap(json['images']);

    return NextBangumiCharacterSearchItem(
      characterId: TinygrailResponseParser.asInt(json['id']),
      name: TinygrailResponseParser.asString(json['name']),
      nameCn: TinygrailResponseParser.asString(json['nameCN']),
      avatarUrl: TinygrailResponseParser.asString(images?['small']),
    );
  }
}
