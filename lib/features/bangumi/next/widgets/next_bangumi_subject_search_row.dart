import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/temple_cover_image.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_subject_search_item.dart';

const double _bangumiSubjectCoverWidth = 42;
const double _bangumiSubjectCoverHeight = 60;

/// Next Bangumi 条目列表行
class NextBangumiSubjectSearchRow extends StatelessWidget {
  /// 创建 Next Bangumi 条目列表行
  ///
  /// [key] Flutter 组件标识
  /// [item] Bangumi 条目
  /// [thirdLineTags] 第三行胶囊文案覆盖
  /// [onTap] 点击回调
  const NextBangumiSubjectSearchRow({
    super.key,
    required this.item,
    this.thirdLineTags,
    required this.onTap,
  });

  /// Bangumi 条目
  final NextBangumiSubjectSearchItem item;

  /// 第三行胶囊文案覆盖
  final List<String>? thirdLineTags;

  /// 点击回调
  final VoidCallback onTap;

  /// 构建 Next Bangumi 条目列表行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rawTitle = item.nameCn.trim().isNotEmpty ? item.nameCn : item.name;
    final title = TinygrailFormatters.decodeHtmlEntities(rawTitle).trim();
    final info = TinygrailFormatters.decodeHtmlEntities(item.info).trim();
    final resolvedThirdLineTags = thirdLineTags ?? item.metaTags;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 4),
              _BangumiSubjectCover(coverUrl: item.coverUrl),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: _bangumiSubjectCoverHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isEmpty ? '未知条目' : title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      if (info.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          info,
                          maxLines: resolvedThirdLineTags.isEmpty ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ],
                      if (resolvedThirdLineTags.isNotEmpty) ...[
                        const Spacer(),
                        _BangumiSubjectMetaTagList(
                          tags: resolvedThirdLineTags,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (item.score > 0) ...[
                const SizedBox(width: 10),
                SizedBox(
                  height: _bangumiSubjectCoverHeight,
                  child: Center(
                    child: _BangumiSubjectScore(score: item.score),
                  ),
                ),
              ],
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Next Bangumi 条目元标签列表
class _BangumiSubjectMetaTagList extends StatelessWidget {
  /// 创建 Next Bangumi 条目元标签列表
  ///
  /// [tags] 元标签文本
  const _BangumiSubjectMetaTagList({
    required this.tags,
  });

  /// 元标签文本
  final List<String> tags;

  /// 构建 Next Bangumi 条目元标签列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < tags.length; index += 1) ...[
              if (index > 0) const SizedBox(width: 5),
              _BangumiSubjectMetaTag(text: tags[index]),
            ],
          ],
        ),
      ),
    );
  }
}

/// Next Bangumi 条目元标签胶囊
class _BangumiSubjectMetaTag extends StatelessWidget {
  /// 创建 Next Bangumi 条目元标签胶囊
  ///
  /// [text] 标签文本
  const _BangumiSubjectMetaTag({
    required this.text,
  });

  /// 标签文本
  final String text;

  /// 构建 Next Bangumi 条目元标签胶囊
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.44 : 0.68,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 22),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        alignment: Alignment.center,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Next Bangumi 条目封面
class _BangumiSubjectCover extends StatelessWidget {
  /// 创建 Next Bangumi 条目封面
  ///
  /// [coverUrl] 封面地址
  const _BangumiSubjectCover({
    required this.coverUrl,
  });

  /// 封面地址
  final String coverUrl;

  /// 构建 Next Bangumi 条目封面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedCoverUrl = TinygrailAssetUrls.normalizeBangumiUrl(coverUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: _bangumiSubjectCoverWidth,
        height: _bangumiSubjectCoverHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.58),
          ),
          child: TempleCoverImage(
            coverUrl: resolvedCoverUrl,
            avatarUrl: '',
            fit: BoxFit.contain,
            alignment: Alignment.center,
            placeholderIconSize: 20,
          ),
        ),
      ),
    );
  }
}

/// Next Bangumi 条目评分
class _BangumiSubjectScore extends StatelessWidget {
  /// 创建 Next Bangumi 条目评分
  ///
  /// [score] 评分
  const _BangumiSubjectScore({
    required this.score,
  });

  /// 评分
  final double score;

  /// 构建 Next Bangumi 条目评分
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: 15,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 3),
        Text(
          score.toStringAsFixed(2),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    );
  }
}
