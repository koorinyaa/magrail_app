part of '../temple_asset_magic_character_search_panel.dart';

class _TempleAssetMagicSearchRow extends StatelessWidget {
  /// 创建圣殿资产魔法道具搜索结果行
  ///
  /// [item] 搜索结果条目
  /// [secondaryText] 第二行文本
  /// [usedTimeText] 最近使用时间文本
  /// [onTap] 点击回调
  const _TempleAssetMagicSearchRow({
    required this.item,
    required this.secondaryText,
    required this.usedTimeText,
    required this.onTap,
  });

  /// 搜索结果条目
  final TempleAssetMagicCharacterSearchItem item;

  /// 第二行文本
  final String secondaryText;

  /// 最近使用时间文本
  final String usedTimeText;

  /// 点击回调
  final VoidCallback onTap;

  /// 构建圣殿资产魔法道具搜索结果行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = TinygrailFormatters.decodeHtmlEntities(item.name);
    final usedTimeText = this.usedTimeText.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              const SizedBox(width: 4),
              CharacterAvatar(
                imageUrl: TinygrailAssetUrls.normalizeAvatar(item.icon),
                size: 38,
                borderRadius: 14,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name.isEmpty ? '#${item.characterId}' : name,
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
                        ),
                        if (usedTimeText.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 92),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  LucideIcons.clock3,
                                  size: 12,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.58),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    usedTimeText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
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

/// 圣殿资产魔法道具搜索行分割线
class _TempleAssetMagicSearchDivider extends StatelessWidget {
  /// 创建圣殿资产魔法道具搜索行分割线
  const _TempleAssetMagicSearchDivider();

  /// 构建圣殿资产魔法道具搜索行分割线
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

/// 圣殿资产魔法道具搜索分区分割线
class _TempleAssetMagicSearchSectionDivider extends StatelessWidget {
  /// 创建圣殿资产魔法道具搜索分区分割线
  ///
  /// [text] 分区标题
  const _TempleAssetMagicSearchSectionDivider({
    required this.text,
  });

  /// 分区标题
  final String text;

  /// 构建圣殿资产魔法道具搜索分区分割线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = colorScheme.outlineVariant.withValues(alpha: 0.56);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: dividerColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              text,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.68),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: dividerColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// 圣殿资产魔法道具搜索骨架列表
class _TempleAssetMagicSearchSkeletonList extends StatelessWidget {
  /// 创建圣殿资产魔法道具搜索骨架列表
  const _TempleAssetMagicSearchSkeletonList();

  /// 构建圣殿资产魔法道具搜索骨架列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        primary: false,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return const _TempleAssetMagicSearchSkeletonRow();
        },
        separatorBuilder: (context, index) {
          return const _TempleAssetMagicSearchDivider();
        },
        itemCount: 6,
      ),
    );
  }
}

/// 圣殿资产魔法道具搜索骨架行
class _TempleAssetMagicSearchSkeletonRow extends StatelessWidget {
  /// 创建圣殿资产魔法道具搜索骨架行
  const _TempleAssetMagicSearchSkeletonRow();

  /// 构建圣殿资产魔法道具搜索骨架行
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
                  width: 74,
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

/// 圣殿资产魔法行内警告
class _TempleAssetMagicInlineWarning extends StatelessWidget {
  /// 创建圣殿资产魔法行内警告
  ///
  /// [text] 警告文本
  const _TempleAssetMagicInlineWarning({
    required this.text,
  });

  /// 警告文本
  final String text;

  /// 构建圣殿资产魔法行内警告
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

/// 圣殿资产魔法空文本
class _TempleAssetMagicEmptyText extends StatelessWidget {
  /// 创建圣殿资产魔法空文本
  ///
  /// [text] 展示文本
  const _TempleAssetMagicEmptyText({
    required this.text,
  });

  /// 展示文本
  final String text;

  /// 构建圣殿资产魔法空文本
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
