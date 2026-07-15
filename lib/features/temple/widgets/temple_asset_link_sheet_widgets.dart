part of 'temple_asset_link_sheet.dart';

/// 圣殿 LINK 抽屉标题区
class _TempleAssetLinkSheetHeader extends StatelessWidget {
  /// 创建圣殿 LINK 抽屉标题区
  ///
  /// [data] 圣殿资产卡片展示数据
  const _TempleAssetLinkSheetHeader({
    required this.data,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 构建圣殿 LINK 抽屉标题区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final resolvedCharacterName = data.characterName.trim().isEmpty
        ? '角色名称'
        : TinygrailFormatters.decodeHtmlEntities(data.characterName.trim());
    return AppBottomSheetHeader(
      icon: LucideIcons.link,
      title: 'LINK',
      subtitle: '#${data.characterId} 「$resolvedCharacterName」',
    );
  }
}

/// 圣殿 LINK 行内警告
class _TempleAssetLinkInlineWarning extends StatelessWidget {
  /// 创建圣殿 LINK 行内警告
  ///
  /// [text] 警告文本
  const _TempleAssetLinkInlineWarning({
    required this.text,
  });

  /// 警告文本
  final String text;

  /// 构建圣殿 LINK 行内警告
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

/// 圣殿 LINK 空文本
class _TempleAssetLinkEmptyText extends StatelessWidget {
  /// 创建圣殿 LINK 空文本
  ///
  /// [text] 展示文本
  const _TempleAssetLinkEmptyText({
    required this.text,
  });

  /// 展示文本
  final String text;

  /// 构建圣殿 LINK 空文本
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

/// 圣殿 LINK 加载骨架网格
class _TempleAssetLinkSkeletonGrid extends StatelessWidget {
  /// 创建圣殿 LINK 加载骨架网格
  const _TempleAssetLinkSkeletonGrid();

  /// 构建圣殿 LINK 加载骨架网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _TempleAssetLinkGridLayout.resolve(
          constraints.maxWidth,
        );

        return Skeletonizer.zone(
          child: GridView.builder(
            primary: false,
            padding: const EdgeInsets.only(bottom: 58),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.crossAxisCount,
              mainAxisSpacing: _templeAssetLinkGridSpacing,
              crossAxisSpacing: _templeAssetLinkGridSpacing,
              childAspectRatio: layout.childAspectRatio,
            ),
            itemBuilder: (context, index) {
              return const _TempleAssetLinkSkeletonTile();
            },
            itemCount: math.min(8, layout.crossAxisCount * 4),
          ),
        );
      },
    );
  }
}

/// 圣殿 LINK 加载骨架卡片
class _TempleAssetLinkSkeletonTile extends StatelessWidget {
  /// 创建圣殿 LINK 加载骨架卡片
  const _TempleAssetLinkSkeletonTile();

  /// 构建圣殿 LINK 加载骨架卡片
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

/// 圣殿 LINK 网格布局参数
class _TempleAssetLinkGridLayout {
  /// 创建圣殿 LINK 网格布局参数
  ///
  /// [crossAxisCount] 横向列数
  /// [tileWidth] 卡片宽度
  /// [tileHeight] 卡片高度
  const _TempleAssetLinkGridLayout({
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

  /// 解析圣殿 LINK 网格布局参数
  ///
  /// [maxWidth] 可用宽度
  static _TempleAssetLinkGridLayout resolve(double maxWidth) {
    final count = math.max(
      1,
      ((maxWidth + _templeAssetLinkGridSpacing) /
              (_templeAssetLinkMinTileWidth + _templeAssetLinkGridSpacing))
          .floor(),
    );
    final tileWidth = math.max(
      1.0,
      (maxWidth - _templeAssetLinkGridSpacing * (count - 1)) / count,
    );

    return _TempleAssetLinkGridLayout(
      crossAxisCount: count,
      tileWidth: tileWidth,
      tileHeight: TempleAssetLinkTempleTile.heightForWidth(tileWidth),
    );
  }
}
