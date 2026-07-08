import 'package:magrail_app/core/network/tinygrail_response.dart';

/// Next Bangumi 条目详情
final class NextBangumiSubject {
  /// 创建 Next Bangumi 条目详情
  ///
  /// [subjectId] 条目 ID
  /// [name] 原名
  /// [nameCn] 中文名
  /// [info] 条目信息
  /// [summary] 条目介绍
  /// [coverUrl] 大尺寸封面地址
  /// [tags] 条目标签名称
  /// [score] 评分
  const NextBangumiSubject({
    required this.subjectId,
    required this.name,
    required this.nameCn,
    required this.info,
    required this.summary,
    required this.coverUrl,
    required this.tags,
    required this.score,
  });

  /// 条目 ID
  final int subjectId;

  /// 原名
  final String name;

  /// 中文名
  final String nameCn;

  /// 条目信息
  final String info;

  /// 条目介绍
  final String summary;

  /// 大尺寸封面地址
  final String coverUrl;

  /// 条目标签名称
  final List<String> tags;

  /// 评分
  final double score;

  /// 展示名称
  String get displayName {
    final resolvedNameCn = nameCn.trim();
    if (resolvedNameCn.isNotEmpty) {
      return resolvedNameCn;
    }

    final resolvedName = name.trim();
    return resolvedName.isEmpty ? 'bgm条目' : resolvedName;
  }

  /// 从 JSON 创建 Next Bangumi 条目详情
  ///
  /// [json] 原始条目详情 JSON
  factory NextBangumiSubject.fromJson(Map<String, Object?> json) {
    final images = TinygrailResponseParser.asObjectMap(json['images']);
    final rating = TinygrailResponseParser.asObjectMap(json['rating']);

    return NextBangumiSubject(
      subjectId: TinygrailResponseParser.asInt(json['id']),
      name: TinygrailResponseParser.asString(json['name']),
      nameCn: TinygrailResponseParser.asString(json['nameCN']),
      info: TinygrailResponseParser.asString(json['info']),
      summary: TinygrailResponseParser.asString(json['summary']),
      coverUrl: TinygrailResponseParser.asString(images?['large']),
      tags: _tagNamesFromJson(json['tags']),
      score: TinygrailResponseParser.asDouble(rating?['score']),
    );
  }
}

/// 从 JSON 字段读取标签名称
///
/// [value] 原始标签字段值
List<String> _tagNamesFromJson(Object? value) {
  if (value is! List) {
    return const <String>[];
  }

  return value
      .whereType<Map<Object?, Object?>>()
      .map(
        (item) => TinygrailResponseParser.asString(item['name']).trim(),
      )
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
