import 'package:magrail_app/core/network/tinygrail_response.dart';

/// Next Bangumi 条目搜索分页结果
final class NextBangumiSubjectSearchPage {
  /// 创建 Next Bangumi 条目搜索分页结果
  ///
  /// [items] 搜索结果
  /// [total] 接口返回的原始总数
  /// [rawItemCount] 当前页接口返回的原始条目数
  const NextBangumiSubjectSearchPage({
    required this.items,
    required this.total,
    required this.rawItemCount,
  });

  /// 搜索结果
  final List<NextBangumiSubjectSearchItem> items;

  /// 接口返回的原始总数
  final int total;

  /// 当前页接口返回的原始条目数
  final int rawItemCount;
}

/// Next Bangumi 条目搜索结果条目
final class NextBangumiSubjectSearchItem {
  /// 创建 Next Bangumi 条目搜索结果条目
  ///
  /// [subjectId] 条目 ID
  /// [name] 原名
  /// [nameCn] 中文名
  /// [info] 条目摘要
  /// [metaTags] 条目元标签
  /// [coverUrl] 小尺寸封面地址
  /// [score] 评分
  const NextBangumiSubjectSearchItem({
    required this.subjectId,
    required this.name,
    required this.nameCn,
    required this.info,
    required this.metaTags,
    required this.coverUrl,
    required this.score,
  });

  /// 条目 ID
  final int subjectId;

  /// 原名
  final String name;

  /// 中文名
  final String nameCn;

  /// 条目摘要
  final String info;

  /// 条目元标签
  final List<String> metaTags;

  /// 小尺寸封面地址
  final String coverUrl;

  /// 评分
  final double score;

  /// 从 JSON 创建 Next Bangumi 条目搜索结果条目
  ///
  /// [json] 原始搜索结果 JSON
  factory NextBangumiSubjectSearchItem.fromJson(
    Map<String, Object?> json,
  ) {
    return NextBangumiSubjectSearchItem.fromSubjectJson(json);
  }

  /// 从条目 JSON 创建 Next Bangumi 条目搜索结果条目
  ///
  /// [json] 原始条目 JSON
  factory NextBangumiSubjectSearchItem.fromSubjectJson(
    Map<String, Object?> json,
  ) {
    final images = TinygrailResponseParser.asObjectMap(json['images']);
    final rating = TinygrailResponseParser.asObjectMap(json['rating']);

    return NextBangumiSubjectSearchItem(
      subjectId: TinygrailResponseParser.asInt(json['id']),
      name: TinygrailResponseParser.asString(json['name']),
      nameCn: TinygrailResponseParser.asString(json['nameCN']),
      info: TinygrailResponseParser.asString(json['info']),
      metaTags: _stringListFromJson(json['metaTags']),
      coverUrl: TinygrailResponseParser.asString(images?['small']),
      score: TinygrailResponseParser.asDouble(rating?['score']),
    );
  }
}

/// 从 JSON 字段读取字符串列表
///
/// [value] 原始字段值
List<String> _stringListFromJson(Object? value) {
  if (value is! List) {
    return const <String>[];
  }

  return value
      .map(TinygrailResponseParser.asString)
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
