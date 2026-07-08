import 'package:magrail_app/core/network/tinygrail_response.dart';

/// Next Bangumi 条目角色分页结果
final class NextBangumiSubjectCharacterPage {
  /// 创建 Next Bangumi 条目角色分页结果
  ///
  /// [items] 条目角色列表
  /// [total] 接口返回的原始总数
  /// [rawItemCount] 当前页接口返回的原始条目数量
  const NextBangumiSubjectCharacterPage({
    required this.items,
    required this.total,
    required this.rawItemCount,
  });

  /// 条目角色列表
  final List<NextBangumiSubjectCharacterItem> items;

  /// 接口返回的原始总数
  final int total;

  /// 当前页接口返回的原始条目数量
  final int rawItemCount;
}

/// Next Bangumi 条目角色
final class NextBangumiSubjectCharacterItem {
  /// 创建 Next Bangumi 条目角色
  ///
  /// [characterId] 角色 ID
  /// [name] 原名
  /// [nameCn] 中文名
  /// [avatarUrl] 小尺寸头像地址
  const NextBangumiSubjectCharacterItem({
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

  /// 展示名称
  String get displayName {
    final resolvedNameCn = nameCn.trim();
    if (resolvedNameCn.isNotEmpty) {
      return resolvedNameCn;
    }

    final resolvedName = name.trim();
    return resolvedName.isEmpty ? '未知角色' : resolvedName;
  }

  /// 从 JSON 创建 Next Bangumi 条目角色
  ///
  /// [json] 原始条目角色 JSON
  factory NextBangumiSubjectCharacterItem.fromJson(
    Map<String, Object?> json,
  ) {
    final character = TinygrailResponseParser.asObjectMap(json['character']);
    final images = TinygrailResponseParser.asObjectMap(character?['images']);

    return NextBangumiSubjectCharacterItem(
      characterId: TinygrailResponseParser.asInt(character?['id']),
      name: TinygrailResponseParser.asString(character?['name']),
      nameCn: TinygrailResponseParser.asString(character?['nameCN']),
      avatarUrl: TinygrailResponseParser.asString(images?['small']),
    );
  }
}
