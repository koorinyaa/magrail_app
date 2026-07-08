part of 'bot_selection_sheet.dart';

/// bot 圣殿黑名单抽屉标题区
class _BotTempleBlacklistHeader extends StatelessWidget {
  /// 创建 bot 圣殿黑名单抽屉标题区
  ///
  /// [title] 标题文案
  /// [subtitle] 副标题文案
  /// [icon] 标题图标
  /// [imageAsset] 标题图片资源
  /// [useErrorColor] 是否使用错误色图标
  const _BotTempleBlacklistHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imageAsset,
    required this.useErrorColor,
  });

  /// 标题文案
  final String title;

  /// 副标题文案
  final String subtitle;

  /// 标题图标
  final IconData icon;

  /// 标题图片资源
  final String imageAsset;

  /// 是否使用错误色图标
  final bool useErrorColor;

  /// 构建 bot 圣殿黑名单抽屉标题区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = useErrorColor ? colorScheme.error : colorScheme.primary;

    return Row(
      children: [
        if (imageAsset.trim().isEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox.square(
              dimension: 40,
              child: Transform.scale(
                scale: 1.24,
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: iconColor,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// bot 圣殿黑名单行内警告
class _BotTempleBlacklistInlineWarning extends StatelessWidget {
  /// 创建 bot 圣殿黑名单行内警告
  ///
  /// [text] 警告文本
  const _BotTempleBlacklistInlineWarning({
    required this.text,
  });

  /// 警告文本
  final String text;

  /// 构建 bot 圣殿黑名单行内警告
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Text(
          text,
          style: TextStyle(
            color: colorScheme.onErrorContainer,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// bot 圣殿黑名单空状态文本
class _BotTempleBlacklistEmptyText extends StatelessWidget {
  /// 创建 bot 圣殿黑名单空状态文本
  ///
  /// [text] 展示文本
  const _BotTempleBlacklistEmptyText({
    required this.text,
  });

  /// 展示文本
  final String text;

  /// 构建 bot 圣殿黑名单空状态文本
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// bot 圣殿黑名单加载骨架网格
class _BotTempleBlacklistSkeletonGrid extends StatelessWidget {
  /// 创建 bot 圣殿黑名单加载骨架网格
  const _BotTempleBlacklistSkeletonGrid();

  /// 构建 bot 圣殿黑名单加载骨架网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _BotTempleBlacklistGridLayout.resolve(
          constraints.maxWidth,
        );

        return Skeletonizer.zone(
          child: GridView.builder(
            primary: false,
            padding: const EdgeInsets.only(bottom: 58),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.crossAxisCount,
              mainAxisSpacing: _botTempleBlacklistGridSpacing,
              crossAxisSpacing: _botTempleBlacklistGridSpacing,
              childAspectRatio: layout.childAspectRatio,
            ),
            itemBuilder: (context, index) {
              return const _BotTempleBlacklistSkeletonTile();
            },
            itemCount: math.min(8, layout.crossAxisCount * 4),
          ),
        );
      },
    );
  }
}

/// bot 圣殿黑名单加载骨架卡片
class _BotTempleBlacklistSkeletonTile extends StatelessWidget {
  /// 创建 bot 圣殿黑名单加载骨架卡片
  const _BotTempleBlacklistSkeletonTile();

  /// 构建 bot 圣殿黑名单加载骨架卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Bone(
      width: double.infinity,
      height: double.infinity,
      borderRadius: BorderRadius.all(Radius.circular(18)),
    );
  }
}

/// bot 圣殿黑名单网格布局参数
class _BotTempleBlacklistGridLayout {
  /// 创建 bot 圣殿黑名单网格布局参数
  ///
  /// [crossAxisCount] 横向列数
  /// [tileWidth] 卡片宽度
  /// [tileHeight] 卡片高度
  const _BotTempleBlacklistGridLayout({
    required this.crossAxisCount,
    required this.tileWidth,
    required this.tileHeight,
  });

  /// 横向列数
  final int crossAxisCount;

  /// 卡片宽度
  final double tileWidth;

  /// 卡片高度
  final double tileHeight;

  /// 网格宽高比
  double get childAspectRatio => tileWidth / tileHeight;

  /// 解析 bot 圣殿黑名单网格布局参数
  ///
  /// [maxWidth] 可用宽度
  static _BotTempleBlacklistGridLayout resolve(double maxWidth) {
    final count = math.max(
      1,
      ((maxWidth + _botTempleBlacklistGridSpacing) /
              (_botTempleBlacklistMinTileWidth +
                  _botTempleBlacklistGridSpacing))
          .floor(),
    );
    final tileWidth = math.max(
      1.0,
      (maxWidth - _botTempleBlacklistGridSpacing * (count - 1)) / count,
    );

    return _BotTempleBlacklistGridLayout(
      crossAxisCount: count,
      tileWidth: tileWidth,
      tileHeight: _BotTempleBlacklistTile.heightForWidth(tileWidth),
    );
  }
}

/// bot 圣殿黑名单圣殿卡片
class _BotTempleBlacklistTile extends StatelessWidget {
  /// 创建 bot 圣殿黑名单圣殿卡片
  ///
  /// [item] 圣殿选择项
  /// [width] 卡片宽度
  /// [isSelected] 是否已选
  /// [onPressed] 点击回调
  const _BotTempleBlacklistTile({
    required this.item,
    required this.width,
    required this.isSelected,
    required this.onPressed,
  });

  /// 圣殿选择项
  final BotTempleOption item;

  /// 卡片宽度
  final double width;

  /// 是否已选
  final bool isSelected;

  /// 点击回调
  final VoidCallback onPressed;

  /// 根据卡片宽度计算整体高度
  ///
  /// [width] 卡片宽度
  static double heightForWidth(double width) {
    return width / 3 * 4;
  }

  /// 构建 bot 圣殿黑名单圣殿卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectionColor = colorScheme.primary;

    return SizedBox(
      width: width,
      height: heightForWidth(width),
      child: Stack(
        children: [
          Positioned.fill(
            child: TempleCard(
              width: width,
              borderRadius: 18,
              coverUrl: TinygrailAssetUrls.getSmallCover(item.cover),
              avatarUrl: TinygrailAssetUrls.normalizeAvatar(item.avatar),
              characterName: _characterName,
              characterLevel: item.characterLevel,
              zeroCount: item.zeroCount,
              ownerLabel: _ownerLabel,
              templeLevel: item.level,
              refine: item.refine,
              starForces: item.starForces,
              heroTag: 'bot-temple-blacklist-${item.characterId}',
              onTap: onPressed,
            ),
          ),
          if (isSelected)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selectionColor.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selectionColor.withValues(alpha: 0.68),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: selectionColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const SizedBox.square(
                  dimension: 26,
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 角色名称
  String get _characterName {
    final name = item.name.trim();
    if (name.isEmpty) {
      return '#${item.characterId}';
    }

    return TinygrailFormatters.decodeHtmlEntities(name);
  }

  /// 圣殿资产展示文案
  String get _ownerLabel {
    final assets = Formatters.groupedNumber(item.assets);
    final sacrifices = Formatters.groupedNumber(item.sacrifices);
    return '$assets / $sacrifices';
  }
}

/// bot 圣殿黑名单搜索框
class _BotTempleBlacklistSearchField extends StatelessWidget {
  /// 创建 bot 圣殿黑名单搜索框
  ///
  /// [controller] 输入控制器
  const _BotTempleBlacklistSearchField({
    required this.controller,
  });

  /// 输入控制器
  final TextEditingController controller;

  /// 构建 bot 圣殿黑名单搜索框
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final borderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.26 : 0.42,
    );
    final focusedBorderColor = colorScheme.primary.withValues(
      alpha: isDark ? 0.34 : 0.30,
    );
    final borderRadius = BorderRadius.circular(999);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: AppBlurStyle.filter,
        child: TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded, size: 18),
            hintText: '搜索圣殿',
            filled: true,
            fillColor: AppBlurStyle.surfaceColor(context),
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: borderColor, width: 0.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: borderColor, width: 0.8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: focusedBorderColor, width: 0.9),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
          ),
        ),
      ),
    );
  }
}
