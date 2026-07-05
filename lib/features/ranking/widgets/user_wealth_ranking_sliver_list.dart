import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/features/ranking/model/ranking_entry.dart';
import 'package:magrail_app/features/user/widgets/user_avatar.dart';
import 'package:magrail_app/features/user/widgets/user_profile_card_components.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 番市首富 sliver 列表
class UserWealthRankingSliverList extends StatelessWidget {
  /// 创建番市首富 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 番市首富条目
  /// [onItemBuilt] 条目构建回调
  const UserWealthRankingSliverList({
    super.key,
    required this.items,
    required this.onItemBuilt,
  });

  static const double _itemExtent = 84;

  /// 番市首富条目
  final List<UserWealthRankingEntry> items;

  /// 条目构建回调
  final ValueChanged<int> onItemBuilt;

  /// 构建番市首富 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: _itemExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          onItemBuilt(index);

          return Padding(
            padding: AppSafeAreaInsets.fromLTRB(
              context,
              left: 12,
              top: 0,
              right: 12,
              bottom: 6,
            ),
            child: _WealthRankingRow(item: item),
          );
        },
        childCount: items.length,
      ),
    );
  }
}

/// 番市首富骨架列表
class UserWealthRankingSkeletonList extends StatelessWidget {
  /// 创建番市首富骨架列表
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  const UserWealthRankingSkeletonList({
    super.key,
    this.itemCount = 20,
  });

  /// 骨架条目数量
  final int itemCount;

  /// 构建番市首富骨架列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: UserWealthRankingSliverList._itemExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: AppSafeAreaInsets.fromLTRB(
              context,
              left: 12,
              top: 0,
              right: 12,
              bottom: 6,
            ),
            child: const _WealthRankingSkeletonRow(),
          );
        },
        childCount: itemCount,
      ),
    );
  }
}

/// 番市首富排行骨架行
class _WealthRankingSkeletonRow extends StatelessWidget {
  /// 创建番市首富排行骨架行
  const _WealthRankingSkeletonRow();

  /// 构建番市首富排行骨架行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        child: Row(
          children: [
            Bone(
              width: 46,
              height: 46,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Bone(
                                width: 88,
                                height: 15,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Bone(
                              width: 30,
                              height: 14,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            const SizedBox(width: 5),
                            Bone(
                              width: 28,
                              height: 14,
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 82,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Bone(
                              width: 10,
                              height: 10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Bone(
                                width: 42,
                                height: 10,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Bone(
                    width: 112,
                    height: 11,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    height: 12,
                    child: Row(
                      children: [
                        Expanded(
                          child: Bone(
                            height: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Bone(
                            height: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Bone(
                            height: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 番市首富排行行
class _WealthRankingRow extends StatelessWidget {
  /// 创建番市首富排行行
  ///
  /// [item] 番市首富排行条目
  const _WealthRankingRow({
    required this.item,
  });

  /// 番市首富排行条目
  final UserWealthRankingEntry item;

  /// 构建番市首富排行行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeTimeText = TinygrailFormatters.shortRelativeTime(
      item.lastActiveDate,
    );
    final activeTimeColor = colorScheme.onSurfaceVariant.withValues(
      alpha: 0.58,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openUser(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          child: Row(
            children: [
              UserAvatar(
                imageUrl: item.avatar,
                isBanned: item.isBanned,
                size: 46,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: item.isBanned
                                        ? colorScheme.error
                                        : colorScheme.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    height: 1.05,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              UserProfileRankBadge(
                                rank: item.rank,
                                isCompact: true,
                              ),
                              if (item.rankChangeLabel != '-') ...[
                                const SizedBox(width: 5),
                                _RankChangeBadge(item: item),
                              ],
                            ],
                          ),
                        ),
                        if (activeTimeText.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 82,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  LucideIcons.clock3,
                                  size: 10,
                                  color: activeTimeColor,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    activeTimeText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: activeTimeColor,
                                      fontSize: 10,
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
                    SizedBox(
                      height: 14,
                      child: Text(
                        '总资产 ${Formatters.tinygrailCompactValue(
                          item.assets,
                          prefix: '₵',
                        )}',
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
                    _WealthMetricLine(item: item),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 打开用户详情页
  ///
  /// [context] 当前组件树上下文
  void _openUser(BuildContext context) {
    if (item.name.trim().isEmpty) {
      return;
    }

    context.pushNamed(
      'userDetail',
      queryParameters: {'username': item.name},
    );
  }
}

/// 番市首富指标行
class _WealthMetricLine extends StatelessWidget {
  /// 创建番市首富指标行
  ///
  /// [item] 番市首富排行条目
  const _WealthMetricLine({
    required this.item,
  });

  /// 番市首富排行条目
  final UserWealthRankingEntry item;

  /// 构建番市首富指标行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = TextStyle(
      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.58),
      fontSize: 10,
      fontWeight: FontWeight.w600,
      height: 1,
    );

    return SizedBox(
      height: 12,
      child: Row(
        children: [
          Flexible(
            child: Text(
              '股息 ${Formatters.tinygrailCompactValue(
                item.share,
                prefix: '₵',
              )}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '流动 ${Formatters.tinygrailCompactValue(
                item.totalBalance,
                prefix: '₵',
              )}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '初始 ${Formatters.tinygrailCompactValue(
                item.principal,
                prefix: '₵',
              )}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}

/// 排名变化徽标
class _RankChangeBadge extends StatelessWidget {
  /// 创建排名变化徽标
  ///
  /// [item] 番市首富排行条目
  const _RankChangeBadge({
    required this.item,
  });

  /// 番市首富排行条目
  final UserWealthRankingEntry item;

  /// 构建排名变化徽标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final color = _rankChangeColor;

    return Container(
      height: 14,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        item.rankChangeLabel,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }

  /// 排名变化颜色
  Color get _rankChangeColor {
    if (item.lastIndex == 0) {
      return const Color(0xFF45D216);
    }

    if (item.lastIndex > item.rank) {
      return const Color(0xFFFF658D);
    }

    if (item.lastIndex < item.rank) {
      return const Color(0xFF65BCFF);
    }

    return const Color(0xFF9CA3AF);
  }
}
