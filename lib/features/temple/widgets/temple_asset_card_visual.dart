part of 'temple_asset_card.dart';

/// 圣殿资产视觉区
class _TempleAssetVisual extends StatelessWidget {
  /// 创建圣殿资产视觉区
  ///
  /// [data] 圣殿资产卡片展示数据
  /// [enableCoverPreview] 是否允许点击圣殿封面查看大图
  const _TempleAssetVisual({
    required this.data,
    required this.enableCoverPreview,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 是否允许点击圣殿封面查看大图
  final bool enableCoverPreview;

  /// 构建圣殿资产视觉区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _TempleAssetThumbnail(
      data: data,
      enableCoverPreview: enableCoverPreview,
    );
  }
}

/// 圣殿资产缩略图
class _TempleAssetThumbnail extends StatelessWidget {
  /// 创建圣殿资产缩略图
  ///
  /// [data] 圣殿资产卡片展示数据
  /// [enableCoverPreview] 是否允许点击圣殿封面查看大图
  const _TempleAssetThumbnail({
    required this.data,
    required this.enableCoverPreview,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 是否允许点击圣殿封面查看大图
  final bool enableCoverPreview;

  /// 构建圣殿资产缩略图
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final thumbnailShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];

    if (!data.hasTemple) {
      return SizedBox(
        height: _templeAssetThumbnailHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_templeAssetThumbnailRadius),
            boxShadow: thumbnailShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_templeAssetThumbnailRadius),
            child: const _TempleAssetEmptyThumbnail(),
          ),
        ),
      );
    }

    final coverUrl = TinygrailAssetUrls.getSmallCover(data.cover);
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(data.avatar);
    final linkCoverUrl = TinygrailAssetUrls.getSmallCover(data.linkCover);
    final linkAvatarUrl = TinygrailAssetUrls.normalizeAvatar(data.linkAvatar);
    final imageUrl = _viewerImageUrl;
    final heroTag = _heroTag;

    if (data.hasLink) {
      return SizedBox(
        height: _templeAssetThumbnailHeight,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: _templeAssetLinkedThumbnailXOffset,
              top: 0,
              width: _templeAssetLinkedThumbnailWidth,
              height: _templeAssetLinkedThumbnailHeight,
              child: _TempleAssetCoverCard(
                coverUrl: linkCoverUrl,
                avatarUrl: linkAvatarUrl,
                boxShadow: thumbnailShadow,
              ),
            ),
            Positioned(
              left: 0,
              top: _templeAssetLinkedThumbnailYOffset,
              width: _templeAssetLinkedThumbnailWidth,
              height: _templeAssetLinkedThumbnailHeight,
              child: _TempleAssetCoverCard(
                coverUrl: coverUrl,
                avatarUrl: avatarUrl,
                boxShadow: thumbnailShadow,
                data: data,
                heroTag: heroTag,
                onTap: enableCoverPreview && imageUrl.isNotEmpty
                    ? () => _openImageViewer(
                          context,
                          imageUrl: imageUrl,
                          heroTag: heroTag,
                        )
                    : null,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: _templeAssetThumbnailHeight,
      child: _TempleAssetCoverCard(
        coverUrl: coverUrl,
        avatarUrl: avatarUrl,
        boxShadow: thumbnailShadow,
        data: data,
        heroTag: heroTag,
        onTap: enableCoverPreview && imageUrl.isNotEmpty
            ? () => _openImageViewer(
                  context,
                  imageUrl: imageUrl,
                  heroTag: heroTag,
                )
            : null,
      ),
    );
  }

  /// 打开圣殿封面大图
  ///
  /// [context] 当前组件树上下文
  /// [imageUrl] 图片查看地址
  /// [heroTag] 图片 Hero 标识
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

  /// 全屏查看图片地址
  String get _viewerImageUrl {
    final coverUrl = TinygrailAssetUrls.getLargeCover(data.cover);
    if (coverUrl.isNotEmpty) {
      return coverUrl;
    }

    return TinygrailAssetUrls.normalizeAvatar(data.avatar);
  }

  /// 圣殿封面 Hero 标识
  String get _heroTag {
    final heroTag = data.heroTag?.trim();
    if (heroTag != null && heroTag.isNotEmpty) {
      return heroTag;
    }

    return 'temple-asset-card-${data.templeId ?? 0}-${data.characterId}';
  }
}

/// 圣殿资产封面卡片
class _TempleAssetCoverCard extends StatelessWidget {
  /// 创建圣殿资产封面卡片
  ///
  /// [coverUrl] 圣殿封面地址
  /// [avatarUrl] 圣殿头像地址
  /// [boxShadow] 封面阴影
  /// [data] 圣殿资产卡片展示数据
  /// [heroTag] 图片 Hero 标识
  /// [onTap] 封面点击回调
  const _TempleAssetCoverCard({
    required this.coverUrl,
    required this.avatarUrl,
    required this.boxShadow,
    this.data,
    this.heroTag,
    this.onTap,
  });

  /// 圣殿封面地址
  final String coverUrl;

  /// 圣殿头像地址
  final String avatarUrl;

  /// 封面阴影
  final List<BoxShadow> boxShadow;

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData? data;

  /// 图片 Hero 标识
  final String? heroTag;

  /// 封面点击回调
  final VoidCallback? onTap;

  /// 构建圣殿资产封面卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final tag = heroTag;
    final coverImage = TempleCoverImage(
      coverUrl: coverUrl,
      avatarUrl: avatarUrl,
      fallbackAvatarAlignment: Alignment.center,
      placeholderIconSize: 30,
    );
    final tapCallback = onTap;
    final badgeData = data;
    final line = TinygrailFormatters.decodeHtmlEntities(
      badgeData?.line ?? '',
    ).trim();

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_templeAssetThumbnailRadius),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_templeAssetThumbnailRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (tag == null)
              coverImage
            else
              Hero(
                tag: tag,
                child: coverImage,
              ),
            if (badgeData != null)
              Positioned(
                left: 8,
                top: 8,
                child: _TempleAssetLevelBadge(data: badgeData),
              ),
            if (tapCallback != null)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: tapCallback,
                    splashColor: Colors.white.withValues(alpha: 0.12),
                    highlightColor: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
            if (line.isNotEmpty)
              Positioned(
                right: 8,
                bottom: 8,
                child: _TempleAssetLineButton(line: line),
              ),
          ],
        ),
      ),
    );
  }
}

/// 圣殿资产台词按钮
class _TempleAssetLineButton extends StatelessWidget {
  /// 创建圣殿资产台词按钮
  ///
  /// [line] 角色台词
  const _TempleAssetLineButton({
    required this.line,
  });

  /// 角色台词
  final String line;

  /// 构建圣殿资产台词按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final tooltipSurfaceAlpha =
        isDark ? AppBlurStyle.lightSurfaceAlpha : AppBlurStyle.darkSurfaceAlpha;

    return Tooltip(
      message: line,
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: false,
      showDuration: const Duration(seconds: 5),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(
          alpha: tooltipSurfaceAlpha,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      textStyle: TextStyle(
        color: isDark ? Colors.black : Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.45,
      ),
      child: Material(
        color: Colors.black.withValues(alpha: 0.42),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: const SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            LucideIcons.messageSquareQuote,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// 圣殿资产等级徽标
class _TempleAssetLevelBadge extends StatelessWidget {
  /// 创建圣殿资产等级徽标
  ///
  /// [data] 圣殿资产卡片展示数据
  const _TempleAssetLevelBadge({
    required this.data,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 构建圣殿资产等级徽标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _themeColor.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        _levelText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }

  /// 圣殿等级文本
  String get _levelText {
    if (data.refine > 0) {
      return '+${data.refine}';
    }

    return '${data.level}';
  }

  /// 圣殿主题色
  Color get _themeColor {
    return _templeLevelColor(data.level);
  }
}

/// 圣殿空缩略图
class _TempleAssetEmptyThumbnail extends StatelessWidget {
  /// 创建圣殿空缩略图
  const _TempleAssetEmptyThumbnail();

  /// 构建圣殿空缩略图
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.28 : 0.54,
        ),
        borderRadius: BorderRadius.circular(_templeAssetThumbnailRadius),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 24,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              '未创建圣殿',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.78),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
