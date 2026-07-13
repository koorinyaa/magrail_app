part of 'character_search_page.dart';

/// 角色搜索结果分区标题
class _CharacterSearchSectionLabel extends StatelessWidget {
  /// 创建角色搜索结果分区标题
  ///
  /// [text] 分区标题文本
  const _CharacterSearchSectionLabel({
    required this.text,
  });

  /// 分区标题文本
  final String text;

  /// 构建角色搜索结果分区标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.68),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 角色搜索结果行
class _CharacterSearchRow extends StatelessWidget {
  /// 创建角色搜索结果行
  ///
  /// [item] 搜索结果角色
  /// [onTap] 点击回调
  /// [avatarHeroTag] 头像转场标识
  const _CharacterSearchRow({
    required this.item,
    required this.avatarHeroTag,
    required this.onTap,
  });

  /// 搜索结果角色
  final CharacterDetailSearchItem item;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 点击回调
  final VoidCallback onTap;

  /// 构建角色搜索结果行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = TinygrailFormatters.decodeHtmlEntities(item.name).trim();
    final secondaryText = _buildSecondaryText(item);
    final avatar = CharacterAvatar(
      imageUrl: TinygrailAssetUrls.normalizeAvatar(item.icon),
      size: 38,
      borderRadius: 14,
    );
    final resolvedAvatarHeroTag = avatarHeroTag?.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              const SizedBox(width: 4),
              if (resolvedAvatarHeroTag == null ||
                  resolvedAvatarHeroTag.isEmpty)
                avatar
              else
                Hero(
                  tag: resolvedAvatarHeroTag,
                  transitionOnUserGestures: true,
                  child: avatar,
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name.isEmpty ? '未知角色' : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        LevelBadge(
                          level: item.level,
                          zeroCount: item.zeroCount,
                          isCompact: true,
                        ),
                      ],
                    ),
                    if (secondaryText.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        secondaryText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// 角色搜索行分割线
class _CharacterSearchDivider extends StatelessWidget {
  /// 创建角色搜索行分割线
  const _CharacterSearchDivider();

  /// 构建角色搜索行分割线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 52, right: 4),
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: colorScheme.outlineVariant.withValues(alpha: 0.52),
      ),
    );
  }
}

/// 角色搜索骨架列表
class _CharacterSearchSkeletonList extends StatelessWidget {
  /// 创建角色搜索骨架列表
  const _CharacterSearchSkeletonList();

  /// 构建角色搜索骨架列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom > 0
        ? mediaQuery.viewInsets.bottom
        : mediaQuery.padding.bottom;

    return ListView.builder(
      primary: false,
      padding: EdgeInsets.only(
        bottom: bottomInset + _characterSearchBottomContentPadding,
      ),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _CharacterSearchSectionLabel(text: '角色');
        }

        final rowIndex = index - 1;
        if (rowIndex.isOdd) {
          return const _CharacterSearchDivider();
        }

        return const Skeletonizer(
          enabled: true,
          child: _CharacterSearchSkeletonRow(),
        );
      },
      itemCount: 12,
    );
  }
}

/// 角色搜索骨架行
class _CharacterSearchSkeletonRow extends StatelessWidget {
  /// 创建角色搜索骨架行
  const _CharacterSearchSkeletonRow();

  /// 构建角色搜索骨架行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(width: 4),
          Bone(
            width: 38,
            height: 38,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Bone(
                      width: 112,
                      height: 13,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    SizedBox(width: 6),
                    Bone(
                      width: 34,
                      height: 15,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                  ],
                ),
                SizedBox(height: 7),
                Bone(
                  width: 140,
                  height: 11,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
              ],
            ),
          ),
          SizedBox(width: 4),
        ],
      ),
    );
  }
}

/// 角色搜索空文本
class _CharacterSearchEmptyText extends StatelessWidget {
  /// 创建角色搜索空文本
  ///
  /// [text] 展示文本
  const _CharacterSearchEmptyText({
    required this.text,
  });

  /// 展示文本
  final String text;

  /// 构建角色搜索空文本
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 角色搜索行内错误
class _CharacterSearchInlineWarning extends StatelessWidget {
  /// 创建角色搜索行内错误
  ///
  /// [text] 错误文本
  const _CharacterSearchInlineWarning({
    required this.text,
  });

  /// 错误文本
  final String text;

  /// 构建角色搜索行内错误
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

/// 圣殿搜索结果列表
class _CharacterSearchTempleResultList extends StatelessWidget {
  /// 创建圣殿搜索结果列表
  ///
  /// [items] 用户圣殿条目
  /// [ownerLabel] 圣殿所属用户文案
  /// [onTap] 点击回调
  const _CharacterSearchTempleResultList({
    required this.items,
    required this.ownerLabel,
    required this.onTap,
  });

  /// 用户圣殿条目
  final List<UserTempleApiItem> items;

  /// 圣殿所属用户文案
  final String ownerLabel;

  /// 点击回调
  final ValueChanged<UserTempleApiItem> onTap;

  /// 构建圣殿搜索结果列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _CharacterSearchEmptyText(text: '未找到相关圣殿');
    }

    const cardWidth = 148.0;
    final height = _CharacterSearchTempleResultCard.heightForWidth(cardWidth);

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        primary: false,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (context, index) {
          final item = items[index];
          return _CharacterSearchTempleResultCard(
            item: item,
            ownerLabel: ownerLabel,
            width: cardWidth,
            onTap: () => onTap(item),
          );
        },
      ),
    );
  }
}

/// 圣殿搜索结果卡片
class _CharacterSearchTempleResultCard extends StatelessWidget {
  /// 创建圣殿搜索结果卡片
  ///
  /// [item] 用户圣殿条目
  /// [ownerLabel] 圣殿所属用户文案
  /// [width] 卡片宽度
  /// [onTap] 点击回调
  const _CharacterSearchTempleResultCard({
    required this.item,
    required this.ownerLabel,
    required this.width,
    required this.onTap,
  });

  /// 用户圣殿条目
  final UserTempleApiItem item;

  /// 圣殿所属用户文案
  final String ownerLabel;

  /// 卡片宽度
  final double width;

  /// 点击回调
  final VoidCallback onTap;

  /// 根据卡片宽度计算整体高度
  ///
  /// [width] 卡片宽度
  static double heightForWidth(double width) {
    return width / 3 * 4 + 36;
  }

  /// 构建圣殿搜索结果卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: heightForWidth(width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TempleCard(
            width: width,
            coverUrl: TinygrailAssetUrls.getSmallCover(item.cover),
            avatarUrl: TinygrailAssetUrls.normalizeAvatar(item.avatar),
            characterName: TinygrailFormatters.decodeHtmlEntities(item.name),
            characterLevel: item.characterLevel,
            zeroCount: item.zeroCount,
            ownerLabel: ownerLabel,
            templeLevel: item.level,
            refine: item.refine,
            starForces: item.starForces,
            onTap: onTap,
          ),
          const SizedBox(height: 8),
          _CharacterSearchTempleProgress(item: item),
        ],
      ),
    );
  }
}

/// 圣殿搜索结果资产进度
class _CharacterSearchTempleProgress extends StatelessWidget {
  /// 创建圣殿搜索结果资产进度
  ///
  /// [item] 用户圣殿条目
  const _CharacterSearchTempleProgress({
    required this.item,
  });

  /// 用户圣殿条目
  final UserTempleApiItem item;

  /// 构建圣殿搜索结果资产进度
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = item.sacrifices <= 0
        ? 0.0
        : (item.assets / item.sacrifices).clamp(0.0, 1.0).toDouble();
    final trackColor = colorScheme.onSurfaceVariant.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.24 : 0.14,
    );
    final progressColor = _themeColor.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.92 : 0.86,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${Formatters.groupedNumber(item.assets)} / '
            '${Formatters.groupedNumber(item.sacrifices)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: trackColor,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 圣殿主题色
  Color get _themeColor {
    return switch (item.level) {
      2 => const Color(0xFFEAB308),
      3 => const Color(0xFFA855F7),
      _ => const Color(0xFF9CA3AF),
    };
  }
}

/// 构建角色搜索结果第二行文本
///
/// [item] 搜索结果角色
String _buildSecondaryText(CharacterDetailSearchItem item) {
  if (item.userTotal > 0) {
    return '持股 ${Formatters.groupedNumber(item.userTotal)}';
  }

  return '';
}
