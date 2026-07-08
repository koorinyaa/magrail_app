part of 'next_bangumi_subject_page.dart';

const double _subjectContentMaxWidth = 560;
const double _subjectCoverWidth = 176;
const double _subjectCoverPlaceholderHeight = 250;

/// Next Bangumi 条目详情固定顶部浮层
class _NextBangumiSubjectFloatingToolbar extends StatelessWidget {
  /// 创建 Next Bangumi 条目详情固定顶部浮层
  ///
  /// [toolbarHeight] 顶部操作区高度
  /// [progress] 顶部背景从透明到模糊浮层的滚动进度
  /// [titleProgress] 顶部标题显示进度
  /// [title] 顶部标题
  /// [onSearchPressed] 搜索按钮点击回调
  const _NextBangumiSubjectFloatingToolbar({
    required this.toolbarHeight,
    required this.progress,
    required this.titleProgress,
    required this.title,
    required this.onSearchPressed,
  });

  /// 顶部操作区高度
  final double toolbarHeight;

  /// 顶部背景从透明到模糊浮层的滚动进度
  final double progress;

  /// 顶部标题显示进度
  final double titleProgress;

  /// 顶部标题
  final String title;

  /// 搜索按钮点击回调
  final VoidCallback onSearchPressed;

  /// 构建 Next Bangumi 条目详情固定顶部浮层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.paddingOf(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundAlpha = progress *
        (isDark
            ? AppBlurStyle.darkSurfaceAlpha
            : AppBlurStyle.lightSurfaceAlpha);
    final backgroundColor = colorScheme.surface.withValues(
      alpha: backgroundAlpha,
    );
    final blurSigma = AppBlurStyle.sigma * progress;

    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(color: backgroundColor),
            child: Padding(
              padding: EdgeInsets.only(
                left: safePadding.left,
                top: safePadding.top,
                right: safePadding.right + 12,
              ),
              child: _NextBangumiSubjectTopActions(
                toolbarHeight: toolbarHeight,
                titleProgress: titleProgress,
                title: title,
                onSearchPressed: onSearchPressed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Next Bangumi 条目详情顶部操作区
class _NextBangumiSubjectTopActions extends StatelessWidget {
  /// 创建 Next Bangumi 条目详情顶部操作区
  ///
  /// [toolbarHeight] 顶部操作区高度
  /// [titleProgress] 顶部标题显示进度
  /// [title] 顶部标题
  /// [onSearchPressed] 搜索按钮点击回调
  const _NextBangumiSubjectTopActions({
    required this.toolbarHeight,
    required this.titleProgress,
    required this.title,
    required this.onSearchPressed,
  });

  /// 顶部操作区高度
  final double toolbarHeight;

  /// 顶部标题显示进度
  final double titleProgress;

  /// 顶部标题
  final String title;

  /// 搜索按钮点击回调
  final VoidCallback onSearchPressed;

  /// 构建 Next Bangumi 条目详情顶部操作区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconButtonStyle =
        (IconButtonTheme.of(context).style ?? const ButtonStyle()).copyWith(
      foregroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
      fixedSize: WidgetStatePropertyAll(Size.square(toolbarHeight)),
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
    );

    return IconButtonTheme(
      data: IconButtonThemeData(style: iconButtonStyle),
      child: IconTheme(
        data: IconThemeData(color: colorScheme.onSurface),
        child: SizedBox(
          width: double.infinity,
          height: toolbarHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: kToolbarHeight,
                  child: Center(
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: kToolbarHeight,
                  child: Center(
                    child: IconButton(
                      onPressed: onSearchPressed,
                      icon: const Icon(
                        Icons.search_rounded,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              _NextBangumiSubjectTopTitle(
                title: title,
                progress: titleProgress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Next Bangumi 条目详情顶部标题
class _NextBangumiSubjectTopTitle extends StatelessWidget {
  /// 创建 Next Bangumi 条目详情顶部标题
  ///
  /// [title] 标题文本
  /// [progress] 标题显示进度
  const _NextBangumiSubjectTopTitle({
    required this.title,
    required this.progress,
  });

  /// 标题文本
  final String title;

  /// 标题显示进度
  final double progress;

  /// 构建 Next Bangumi 条目详情顶部标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (progress <= 0) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final visibleProgress = Curves.easeOutCubic.transform(
      progress.clamp(0.0, 1.0).toDouble(),
    );

    return Opacity(
      opacity: visibleProgress,
      child: Transform.translate(
        offset: Offset(0, 6 * (1 - visibleProgress)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Next Bangumi 条目详情 Sliver
class _NextBangumiSubjectDetailSliver extends StatelessWidget {
  /// 创建 Next Bangumi 条目详情 Sliver
  ///
  /// [subject] 条目详情
  const _NextBangumiSubjectDetailSliver({
    required this.subject,
  });

  /// 条目详情
  final NextBangumiSubject subject;

  /// 构建 Next Bangumi 条目详情 Sliver
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: _subjectContentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _NextBangumiSubjectCover(coverUrl: subject.coverUrl),
                  const SizedBox(height: 18),
                  _NextBangumiSubjectTitle(subject: subject),
                  if (subject.info.trim().isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _NextBangumiSubjectParagraph(
                      text: _decodeBangumiSubjectText(subject.info),
                    ),
                  ],
                  if (subject.summary.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _NextBangumiSubjectParagraph(
                      text: _decodeBangumiSubjectText(subject.summary),
                      isMuted: true,
                      maxLines: 10,
                    ),
                  ],
                  if (subject.tags.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _NextBangumiSubjectTagWrap(tags: subject.tags),
                  ],
                  const SizedBox(height: 18),
                  _NextBangumiSubjectScore(score: subject.score),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Next Bangumi 条目详情封面
class _NextBangumiSubjectCover extends StatelessWidget {
  /// 创建 Next Bangumi 条目详情封面
  ///
  /// [coverUrl] 封面地址
  const _NextBangumiSubjectCover({
    required this.coverUrl,
  });

  /// 封面地址
  final String coverUrl;

  /// 构建 Next Bangumi 条目详情封面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final resolvedCoverUrl = _normalizeBangumiSubjectCover(coverUrl);
    if (resolvedCoverUrl.isEmpty) {
      return const _NextBangumiSubjectCoverPlaceholder();
    }

    final heroTag = _bangumiSubjectCoverHeroTag(resolvedCoverUrl);

    return CachedNetworkImage(
      imageUrl: resolvedCoverUrl,
      imageBuilder: (context, imageProvider) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openImageViewer(
                context,
                imageUrl: resolvedCoverUrl,
                heroTag: heroTag,
              ),
              splashColor: Colors.white.withValues(alpha: 0.12),
              highlightColor: Colors.white.withValues(alpha: 0.06),
              child: Hero(
                tag: heroTag,
                child: Image(
                  image: imageProvider,
                  width: _subjectCoverWidth,
                  fit: BoxFit.fitWidth,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
        );
      },
      placeholder: (context, url) {
        return const _NextBangumiSubjectCoverSkeleton();
      },
      errorWidget: (context, url, error) {
        return const _NextBangumiSubjectCoverPlaceholder();
      },
    );
  }

  /// 打开条目封面大图
  ///
  /// [context] 当前组件上下文
  /// [imageUrl] 封面大图地址
  /// [heroTag] 封面 Hero 标识
  void _openImageViewer(
    BuildContext context, {
    required String imageUrl,
    required String heroTag,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullscreenImageViewerPage(
            imageUrl: imageUrl,
            heroTag: heroTag,
          );
        },
      ),
    );
  }
}

/// Next Bangumi 条目详情封面骨架
class _NextBangumiSubjectCoverSkeleton extends StatelessWidget {
  /// 创建 Next Bangumi 条目详情封面骨架
  const _NextBangumiSubjectCoverSkeleton();

  /// 构建 Next Bangumi 条目详情封面骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Skeletonizer.zone(
      child: Bone(
        width: _subjectCoverWidth,
        height: _subjectCoverPlaceholderHeight,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}

/// Next Bangumi 条目详情封面占位
class _NextBangumiSubjectCoverPlaceholder extends StatelessWidget {
  /// 创建 Next Bangumi 条目详情封面占位
  const _NextBangumiSubjectCoverPlaceholder();

  /// 构建 Next Bangumi 条目详情封面占位
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: _subjectCoverWidth,
      height: _subjectCoverPlaceholderHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 34,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.68),
        ),
      ),
    );
  }
}

/// Next Bangumi 条目详情标题
class _NextBangumiSubjectTitle extends StatelessWidget {
  /// 创建 Next Bangumi 条目详情标题
  ///
  /// [subject] 条目详情
  const _NextBangumiSubjectTitle({
    required this.subject,
  });

  /// 条目详情
  final NextBangumiSubject subject;

  /// 构建 Next Bangumi 条目详情标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      _decodeBangumiSubjectText(subject.displayName),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.16,
      ),
    );
  }
}

/// Next Bangumi 条目详情段落
class _NextBangumiSubjectParagraph extends StatelessWidget {
  /// 创建 Next Bangumi 条目详情段落
  ///
  /// [text] 段落文本
  /// [isMuted] 是否使用更浅的文字颜色
  /// [maxLines] 最大显示行数
  const _NextBangumiSubjectParagraph({
    required this.text,
    this.isMuted = false,
    this.maxLines,
  });

  /// 段落文本
  final String text;

  /// 是否使用更浅的文字颜色
  final bool isMuted;

  /// 最大显示行数
  final int? maxLines;

  /// 构建 Next Bangumi 条目详情段落
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      text,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: colorScheme.onSurfaceVariant.withValues(
          alpha: isMuted ? 0.72 : 1,
        ),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.45,
      ),
    );
  }
}

/// Next Bangumi 条目详情标签组
class _NextBangumiSubjectTagWrap extends StatelessWidget {
  /// 创建 Next Bangumi 条目详情标签组
  ///
  /// [tags] 标签文本
  const _NextBangumiSubjectTagWrap({
    required this.tags,
  });

  /// 标签文本
  final List<String> tags;

  /// 构建 Next Bangumi 条目详情标签组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 7,
      children: [
        for (final tag in tags) _NextBangumiSubjectTag(text: tag),
      ],
    );
  }
}

/// Next Bangumi 条目详情标签胶囊
class _NextBangumiSubjectTag extends StatelessWidget {
  /// 创建 Next Bangumi 条目详情标签胶囊
  ///
  /// [text] 标签文本
  const _NextBangumiSubjectTag({
    required this.text,
  });

  /// 标签文本
  final String text;

  /// 构建 Next Bangumi 条目详情标签胶囊
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
      child: IntrinsicWidth(
        child: Container(
          constraints: const BoxConstraints(minHeight: 22),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Next Bangumi 条目详情评分
class _NextBangumiSubjectScore extends StatelessWidget {
  /// 创建 Next Bangumi 条目详情评分
  ///
  /// [score] 评分
  const _NextBangumiSubjectScore({
    required this.score,
  });

  /// 评分
  final double score;

  /// 构建 Next Bangumi 条目详情评分
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final text = score > 0 ? score.toStringAsFixed(2) : '暂无评分';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: 18,
          color: score > 0 ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    );
  }
}
