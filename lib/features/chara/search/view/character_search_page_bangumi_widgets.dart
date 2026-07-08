part of 'character_search_page.dart';

/// 角色搜索来源切换器
class _CharacterSearchSourceSegmentedControl extends StatelessWidget {
  /// 创建角色搜索来源切换器
  ///
  /// [value] 当前搜索来源
  /// [onChanged] 搜索来源变化回调
  const _CharacterSearchSourceSegmentedControl({
    required this.value,
    required this.onChanged,
  });

  /// 当前搜索来源
  final _CharacterSearchSource value;

  /// 搜索来源变化回调
  final ValueChanged<_CharacterSearchSource> onChanged;

  /// 构建角色搜索来源切换器
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final selectedIndex = _CharacterSearchSource.values.indexOf(value);

    return GlassSegmentedControl(
      segments: [
        for (final source in _CharacterSearchSource.values)
          GlassSegment(label: _labelForCharacterSearchSource(source)),
      ],
      selectedIndex: selectedIndex,
      onSegmentSelected: (index) {
        final source = _CharacterSearchSource.values[index];
        if (source == value) {
          return;
        }
        onChanged(source);
      },
      backgroundColor: isDark
          ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.82)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.76),
      useOwnLayer: true,
      quality: GlassQuality.minimal,
    );
  }
}

/// Bangumi 角色搜索结果行
class _BangumiCharacterSearchRow extends StatelessWidget {
  /// 创建 Bangumi 角色搜索结果行
  ///
  /// [item] Bangumi 搜索结果角色
  /// [status] 小圣杯角色状态
  /// [avatarUrl] 合并后头像地址
  /// [avatarHeroTag] 头像转场标识
  /// [onTap] 点击回调
  const _BangumiCharacterSearchRow({
    required this.item,
    required this.status,
    required this.avatarUrl,
    required this.avatarHeroTag,
    required this.onTap,
  });

  /// Bangumi 搜索结果角色
  final NextBangumiCharacterSearchItem item;

  /// 小圣杯角色状态
  final CharacterDetailBasicInfo? status;

  /// 合并后头像地址
  final String avatarUrl;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 点击回调
  final VoidCallback onTap;

  /// 构建 Bangumi 角色搜索结果行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rawName = item.nameCn.trim().isNotEmpty ? item.nameCn : item.name;
    final name = TinygrailFormatters.decodeHtmlEntities(rawName).trim();
    final avatar = CharacterAvatar(
      imageUrl: TinygrailAssetUrls.normalizeAvatar(avatarUrl),
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
                        _BangumiCharacterStatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '#${item.characterId}',
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

/// Bangumi 角色小圣杯状态标签
class _BangumiCharacterStatusBadge extends StatelessWidget {
  /// 创建 Bangumi 角色小圣杯状态标签
  ///
  /// [status] 小圣杯角色状态
  const _BangumiCharacterStatusBadge({
    required this.status,
  });

  /// 小圣杯角色状态
  final CharacterDetailBasicInfo? status;

  /// 构建 Bangumi 角色小圣杯状态标签
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final resolvedStatus = status;
    if (resolvedStatus?.pageType == CharacterDetailPageType.trade) {
      final header = resolvedStatus?.tradeHeader;
      return LevelBadge(
        level: header?.level ?? 0,
        zeroCount: header?.zeroCount ?? 0,
        isCompact: true,
      );
    }

    if (resolvedStatus?.pageType == CharacterDetailPageType.ico) {
      return const LevelBadge.ico(isCompact: true);
    }

    return const LevelBadge.unlisted(isCompact: true);
  }
}

/// Bangumi 条目搜索结果行
class _BangumiSubjectSearchRow extends StatelessWidget {
  /// 创建 Bangumi 条目搜索结果行
  ///
  /// [item] Bangumi 条目搜索结果
  /// [onTap] 点击回调
  const _BangumiSubjectSearchRow({
    required this.item,
    required this.onTap,
  });

  /// Bangumi 条目搜索结果
  final NextBangumiSubjectSearchItem item;

  /// 点击回调
  final VoidCallback onTap;

  /// 构建 Bangumi 条目搜索结果行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rawTitle = item.nameCn.trim().isNotEmpty ? item.nameCn : item.name;
    final title = TinygrailFormatters.decodeHtmlEntities(rawTitle).trim();
    final info = TinygrailFormatters.decodeHtmlEntities(item.info).trim();

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
                          maxLines: item.metaTags.isEmpty ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ],
                      if (item.metaTags.isNotEmpty) ...[
                        const Spacer(),
                        _BangumiSubjectMetaTagList(tags: item.metaTags),
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

/// Bangumi 条目元标签列表
class _BangumiSubjectMetaTagList extends StatelessWidget {
  /// 创建 Bangumi 条目元标签列表
  ///
  /// [tags] 元标签文本
  const _BangumiSubjectMetaTagList({
    required this.tags,
  });

  /// 元标签文本
  final List<String> tags;

  /// 构建 Bangumi 条目元标签列表
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

/// Bangumi 条目元标签胶囊
class _BangumiSubjectMetaTag extends StatelessWidget {
  /// 创建 Bangumi 条目元标签胶囊
  ///
  /// [text] 标签文本
  const _BangumiSubjectMetaTag({
    required this.text,
  });

  /// 标签文本
  final String text;

  /// 构建 Bangumi 条目元标签胶囊
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

const double _bangumiSubjectCoverWidth = 42;
const double _bangumiSubjectCoverHeight = 60;

/// Bangumi 条目搜索封面
class _BangumiSubjectCover extends StatelessWidget {
  /// 创建 Bangumi 条目搜索封面
  ///
  /// [coverUrl] 封面地址
  const _BangumiSubjectCover({
    required this.coverUrl,
  });

  /// 封面地址
  final String coverUrl;

  /// 构建 Bangumi 条目搜索封面
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

/// Bangumi 条目评分
class _BangumiSubjectScore extends StatelessWidget {
  /// 创建 Bangumi 条目评分
  ///
  /// [score] 评分
  const _BangumiSubjectScore({
    required this.score,
  });

  /// 评分
  final double score;

  /// 构建 Bangumi 条目评分
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

/// Bangumi 条目搜索骨架列表
class _BangumiSubjectSearchSkeletonList extends StatelessWidget {
  /// 创建 Bangumi 条目搜索骨架列表
  const _BangumiSubjectSearchSkeletonList();

  /// 构建 Bangumi 条目搜索骨架列表
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
          return const _CharacterSearchSectionLabel(text: '条目');
        }

        final rowIndex = index - 1;
        if (rowIndex.isOdd) {
          return const _CharacterSearchDivider();
        }

        return const Skeletonizer(
          enabled: true,
          child: _BangumiSubjectSearchSkeletonRow(),
        );
      },
      itemCount: 12,
    );
  }
}

/// Bangumi 条目搜索骨架行
class _BangumiSubjectSearchSkeletonRow extends StatelessWidget {
  /// 创建 Bangumi 条目搜索骨架行
  const _BangumiSubjectSearchSkeletonRow();

  /// 构建 Bangumi 条目搜索骨架行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 4),
          Bone(
            width: 42,
            height: 60,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Bone(
                  width: 132,
                  height: 13,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                SizedBox(height: 8),
                Bone(
                  width: double.infinity,
                  height: 11,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                SizedBox(height: 5),
                Bone(
                  width: 168,
                  height: 11,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Bone(
            width: 44,
            height: 14,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          SizedBox(width: 4),
        ],
      ),
    );
  }
}

/// 解析角色搜索来源标签
///
/// [source] 搜索来源
String _labelForCharacterSearchSource(_CharacterSearchSource source) {
  return switch (source) {
    _CharacterSearchSource.tinygrail => '小圣杯',
    _CharacterSearchSource.bangumi => 'bgm角色',
    _CharacterSearchSource.bangumiSubject => 'bgm条目',
  };
}
