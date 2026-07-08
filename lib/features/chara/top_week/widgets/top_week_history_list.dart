import 'package:flutter/material.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/top_week/model/top_week_history_api_item.dart';

/// 往期萌王列表
class TopWeekHistoryList extends StatelessWidget {
  /// 创建往期萌王列表
  ///
  /// [key] Flutter 组件标识
  /// [page] 当前分页数据
  /// [padding] 列表滚动内边距
  const TopWeekHistoryList({
    super.key,
    required this.page,
    this.padding = EdgeInsets.zero,
  });

  /// 当前分页数据
  final TinygrailPage<TopWeekHistoryApiItem> page;

  /// 列表滚动内边距
  final EdgeInsetsGeometry padding;

  static const double _horizontalPadding = 12;
  static const double _rankWidth = 34;
  static const double _rankAvatarGap = 6;
  static const double _avatarSize = 48;
  static const double _avatarTextGap = 10;
  static const double _dividerIndent = _horizontalPadding +
      _rankWidth +
      _rankAvatarGap +
      _avatarSize +
      _avatarTextGap;

  /// 构建往期萌王列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final items = [...page.items]..sort((a, b) => a.level.compareTo(b.level));

    return ListView.separated(
      padding: padding,
      primary: false,
      itemCount: items.length,
      separatorBuilder: (context, index) {
        return const TopWeekHistoryDivider();
      },
      itemBuilder: (context, index) {
        return _TopWeekHistoryListItem(
          item: items[index],
        );
      },
    );
  }
}

/// 往期萌王条目
class _TopWeekHistoryListItem extends StatelessWidget {
  /// 创建往期萌王条目
  ///
  /// [item] 往期萌王接口条目
  const _TopWeekHistoryListItem({
    required this.item,
  });

  /// 往期萌王接口条目
  final TopWeekHistoryApiItem item;

  /// 构建往期萌王条目
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.avatar);
    final avatarHeroTag = createCharacterDetailAvatarHeroTag(
      characterId: item.characterId,
      avatarUrl: avatarUrl,
      source: item,
    );

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: item.characterId <= 0
              ? null
              : () {
                  openCharacterDetail(
                    context,
                    characterId: item.characterId,
                    name: item.name,
                    avatarUrl: avatarUrl,
                    avatarHeroTag: avatarHeroTag,
                  );
                },
          child: Padding(
            padding: AppSafeAreaInsets.symmetricHorizontal(
              context,
              horizontal: TopWeekHistoryList._horizontalPadding,
              vertical: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _TopWeekHistoryRankText(
                  rank: item.level,
                  color: _resolveRankColor(item.level),
                ),
                const SizedBox(width: TopWeekHistoryList._rankAvatarGap),
                _TopWeekHistoryAvatar(
                  imageUrl: avatarUrl,
                  heroTag: avatarHeroTag,
                ),
                const SizedBox(width: TopWeekHistoryList._avatarTextGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TopWeekHistoryNameRow(item: item),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 14,
                        child: Text(
                          _formatPrice(item.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      SizedBox(
                        height: 12,
                        child: Text(
                          _formatExtra(item.extra),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.58,
                            ),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _TopWeekHistoryPeopleCount(
                  value: Formatters.groupedNumber(item.assets),
                  color: colorScheme.onSurfaceVariant.withValues(
                    alpha: isDark ? 0.74 : 0.62,
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant.withValues(
                      alpha: isDark ? 0.72 : 0.54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 格式化超出金额
  ///
  /// [extra] 超出金额
  String _formatExtra(double extra) {
    final prefix = extra > 0 ? '+' : '';
    return '$prefix${Formatters.tinygrailCurrency(extra.truncate())}';
  }

  /// 格式化总金额
  ///
  /// [price] 总金额
  String _formatPrice(double price) {
    return Formatters.tinygrailCurrency(price.truncate());
  }

  /// 解析排名颜色
  ///
  /// [rank] 当前排名
  Color _resolveRankColor(int rank) {
    return switch (rank) {
      1 => const Color(0xFFF2B72F),
      2 => const Color(0xFF6F85A6),
      3 => const Color(0xFFA7653D),
      >= 4 && <= 6 => const Color(0xFF78A86B),
      _ => const Color(0xFFA1A1AA),
    };
  }
}

/// 往期萌王头像
class _TopWeekHistoryAvatar extends StatelessWidget {
  /// 创建往期萌王头像
  ///
  /// [imageUrl] 头像地址
  /// [heroTag] 头像转场标识
  const _TopWeekHistoryAvatar({
    required this.imageUrl,
    required this.heroTag,
  });

  /// 头像地址
  final String imageUrl;

  /// 头像转场标识
  final String? heroTag;

  /// 构建往期萌王头像
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final avatar = CharacterAvatar(
      imageUrl: imageUrl,
      size: TopWeekHistoryList._avatarSize,
      borderRadius: 16,
    );
    final resolvedHeroTag = heroTag?.trim();
    if (resolvedHeroTag == null || resolvedHeroTag.isEmpty) {
      return avatar;
    }

    return Hero(
      tag: resolvedHeroTag,
      transitionOnUserGestures: true,
      child: avatar,
    );
  }
}

/// 往期萌王名称行
class _TopWeekHistoryNameRow extends StatelessWidget {
  /// 创建往期萌王名称行
  ///
  /// [item] 往期萌王接口条目
  const _TopWeekHistoryNameRow({
    required this.item,
  });

  /// 往期萌王接口条目
  final TopWeekHistoryApiItem item;

  /// 构建往期萌王名称行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                ),
              ),
              const SizedBox(width: 6),
              LevelBadge(
                level: item.characterLevel,
                isCompact: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 往期萌王列表分隔线
class TopWeekHistoryDivider extends StatelessWidget {
  /// 创建往期萌王列表分隔线
  const TopWeekHistoryDivider({super.key});

  /// 构建往期萌王列表分隔线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: TopWeekHistoryList._dividerIndent,
        top: 0,
        right: TopWeekHistoryList._horizontalPadding,
        bottom: 0,
      ),
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: colorScheme.outlineVariant.withValues(
          alpha: isDark ? 0.32 : 0.58,
        ),
      ),
    );
  }
}

/// 往期萌王排名数字
class _TopWeekHistoryRankText extends StatelessWidget {
  /// 创建往期萌王排名数字
  ///
  /// [rank] 当前排名
  /// [color] 排名颜色
  const _TopWeekHistoryRankText({
    required this.rank,
    required this.color,
  });

  /// 当前排名
  final int rank;

  /// 排名颜色
  final Color color;

  /// 构建往期萌王排名数字
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: TopWeekHistoryList._rankWidth,
      height: 48,
      child: Center(
        child: Text(
          '$rank',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// 往期萌王人数
class _TopWeekHistoryPeopleCount extends StatelessWidget {
  /// 创建往期萌王人数
  ///
  /// [value] 人数文本
  /// [color] 文本颜色
  const _TopWeekHistoryPeopleCount({
    required this.value,
    required this.color,
  });

  /// 人数文本
  final String value;

  /// 文本颜色
  final Color color;

  /// 构建往期萌王人数
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 48,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_rounded,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 3),
            Text(
              value,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
