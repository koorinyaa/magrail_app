import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_temple_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 用户圣殿自适应网格
class UserTempleResponsiveGrid extends StatelessWidget {
  /// 创建用户圣殿自适应网格
  ///
  /// [key] Flutter 组件标识
  /// [items] 用户圣殿条目
  /// [ownerLabel] 用户展示文案
  /// [showLevelHeaders] 是否显示角色等级分组标题
  /// [rightContentInset] 网格右侧额外预留宽度
  /// [sortValues] 圣殿排序字段补充展示值
  /// [onItemBuilt] 条目构建回调
  /// [onCharacterTap] 角色区域点击回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const UserTempleResponsiveGrid({
    super.key,
    required this.items,
    required this.ownerLabel,
    this.showLevelHeaders = false,
    this.rightContentInset = 0,
    this.sortValues = const <int, UserTempleSortValue>{},
    this.onItemBuilt,
    this.onCharacterTap,
    this.onAssetTap,
  });

  static const double _horizontalPadding = 12;
  static const double _topPadding = 10;
  static const double _mainAxisSpacing = 10;
  static const double _crossAxisSpacing = 10;
  static const double _minCardWidth = 156;

  /// 等级分组标题固定高度
  static const double levelHeaderExtent = 40;

  /// 等级快速跳转轨道的可点击宽度
  static const double levelRailWidth = 32;

  /// 网格为等级快速跳转轨道预留的右侧宽度
  static const double levelRailReservedWidth = 24;

  /// 用户圣殿条目
  final List<UserTempleApiItem> items;

  /// 用户展示文案
  final String ownerLabel;

  /// 是否显示角色等级分组标题
  final bool showLevelHeaders;

  /// 网格右侧额外预留宽度
  final double rightContentInset;

  /// 圣殿排序字段补充展示值
  final Map<int, UserTempleSortValue> sortValues;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 角色区域点击回调
  final ValueChanged<UserTempleApiItem>? onCharacterTap;

  /// 圣殿资产入口点击回调
  final ValueChanged<UserTempleApiItem>? onAssetTap;

  /// 构建用户圣殿自适应网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final metrics = resolveMetrics(
          constraints.crossAxisExtent,
          AppSafeAreaInsets.horizontalSum(context),
          showSortValue: sortValues.isNotEmpty,
          rightContentInset: rightContentInset,
        );
        final groups = showLevelHeaders ? _resolveLevelGroups(items) : null;
        return SliverPadding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: _horizontalPadding,
            top: _topPadding,
            right: _horizontalPadding + rightContentInset,
            bottom: 0,
          ),
          sliver: groups == null
              ? _buildGrid(context, metrics, start: 0, end: items.length)
              : SliverMainAxisGroup(
                  slivers: [
                    for (final group in groups) ...[
                      SliverToBoxAdapter(
                        child: _UserTempleLevelHeader(level: group.level),
                      ),
                      _buildGrid(
                        context,
                        metrics,
                        start: group.start,
                        end: group.end,
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }

  /// 构建指定条目范围的圣殿网格
  ///
  /// [context] 当前组件树上下文
  /// [metrics] 当前网格布局参数
  /// [start] 起始条目下标
  /// [end] 结束条目下标
  Widget _buildGrid(
    BuildContext context,
    UserTempleGridMetrics metrics, {
    required int start,
    required int end,
  }) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: metrics.crossAxisCount,
        mainAxisSpacing: _mainAxisSpacing,
        crossAxisSpacing: _crossAxisSpacing,
        childAspectRatio: metrics.childAspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, localIndex) {
          final index = start + localIndex;
          final item = items[index];
          onItemBuilt?.call(index);
          return UserTempleCard(
            item: item,
            ownerLabel: ownerLabel,
            width: metrics.cardWidth,
            heroTagPrefix: 'user-temple-page-cover-$index',
            sortValue: sortValues[item.id],
            onCharacterTap: onCharacterTap,
            onAssetTap: onAssetTap,
          );
        },
        childCount: end - start,
      ),
    );
  }

  /// 解析当前屏幕宽度下的网格参数
  ///
  /// [crossAxisExtent] Sliver 可用横向宽度
  /// [horizontalSafeArea] 横向安全区总宽度
  /// [showSortValue] 是否显示排序字段补充行
  /// [rightContentInset] 网格右侧额外预留宽度
  static UserTempleGridMetrics resolveMetrics(
    double crossAxisExtent,
    double horizontalSafeArea, {
    bool showSortValue = false,
    double rightContentInset = 0,
  }) {
    final contentWidth = math.max(
      0.0,
      crossAxisExtent -
          _horizontalPadding * 2 -
          horizontalSafeArea -
          rightContentInset,
    );
    if (contentWidth <= _crossAxisSpacing) {
      final cardWidth = math.max(contentWidth, 1.0);
      return UserTempleGridMetrics(
        crossAxisCount: 1,
        cardWidth: cardWidth,
        cardHeight: UserTempleCard.heightForWidth(
          cardWidth,
          showSortValue: showSortValue,
        ),
      );
    }

    final rawCount = ((contentWidth + _crossAxisSpacing) /
            (_minCardWidth + _crossAxisSpacing))
        .floor();
    final crossAxisCount = rawCount.clamp(1, 6).toInt();
    final cardWidth = math.max(
      0.0,
      (contentWidth - _crossAxisSpacing * (crossAxisCount - 1)) /
          crossAxisCount,
    );
    return UserTempleGridMetrics(
      crossAxisCount: crossAxisCount,
      cardWidth: cardWidth,
      cardHeight: UserTempleCard.heightForWidth(
        cardWidth,
        showSortValue: showSortValue,
      ),
    );
  }

  /// 计算当前圣殿网格内容高度
  ///
  /// [items] 已加载圣殿条目
  /// [metrics] 当前网格布局参数
  /// [showLevelHeaders] 是否包含角色等级分组标题
  static double contentExtent(
    List<UserTempleApiItem> items,
    UserTempleGridMetrics metrics, {
    bool showLevelHeaders = false,
  }) {
    if (items.isEmpty) {
      return 0;
    }
    if (!showLevelHeaders) {
      return _topPadding + metrics.gridExtent(items.length);
    }
    var extent = _topPadding;
    for (final group in _resolveLevelGroups(items)) {
      extent += levelHeaderExtent + metrics.gridExtent(group.length);
    }
    return extent;
  }

  /// 计算指定圣殿在网格内容中的顶部位置
  ///
  /// [items] 已加载圣殿条目
  /// [itemIndex] 圣殿条目下标
  /// [metrics] 当前网格布局参数
  /// [showLevelHeaders] 是否包含角色等级分组标题
  static double itemOffsetForIndex(
    List<UserTempleApiItem> items,
    int itemIndex,
    UserTempleGridMetrics metrics, {
    bool showLevelHeaders = false,
  }) {
    if (items.isEmpty) {
      return 0;
    }
    final resolvedIndex = itemIndex.clamp(0, items.length - 1).toInt();
    if (!showLevelHeaders) {
      return _topPadding +
          (resolvedIndex ~/ metrics.crossAxisCount) * metrics.rowExtent;
    }
    var offset = _topPadding;
    for (final group in _resolveLevelGroups(items)) {
      if (resolvedIndex < group.end) {
        final localIndex = resolvedIndex - group.start;
        return offset +
            levelHeaderExtent +
            (localIndex ~/ metrics.crossAxisCount) * metrics.rowExtent;
      }
      offset += levelHeaderExtent + metrics.gridExtent(group.length);
    }
    return offset;
  }

  /// 根据网格内容偏移量查找当前可视圣殿
  ///
  /// [items] 已加载圣殿条目
  /// [contentOffset] 网格内容顶部相对视口的偏移量
  /// [metrics] 当前网格布局参数
  /// [showLevelHeaders] 是否包含角色等级分组标题
  static int? itemIndexAtContentOffset(
    List<UserTempleApiItem> items,
    double contentOffset,
    UserTempleGridMetrics metrics, {
    bool showLevelHeaders = false,
  }) {
    if (items.isEmpty) {
      return null;
    }
    final resolvedOffset = contentOffset.clamp(0.0, double.infinity);
    if (!showLevelHeaders) {
      final row =
          math.max(0, resolvedOffset - _topPadding) ~/ metrics.rowExtent;
      return (row * metrics.crossAxisCount).clamp(0, items.length - 1).toInt();
    }
    var offset = _topPadding;
    for (final group in _resolveLevelGroups(items)) {
      final gridTop = offset + levelHeaderExtent;
      final gridBottom = gridTop + metrics.gridExtent(group.length);
      if (resolvedOffset < gridTop) {
        return group.start;
      }
      if (resolvedOffset < gridBottom) {
        final row = ((resolvedOffset - gridTop) ~/ metrics.rowExtent);
        return (group.start + row * metrics.crossAxisCount)
            .clamp(group.start, group.end - 1)
            .toInt();
      }
      offset = gridBottom;
    }
    return items.length - 1;
  }

  /// 计算目标圣殿所属等级分组的跳转位置
  ///
  /// [items] 当前分页窗口圣殿条目
  /// [itemIndex] 目标圣殿在分页窗口内的下标
  /// [metrics] 当前网格布局参数
  static double levelGroupOffsetForItem(
    List<UserTempleApiItem> items,
    int itemIndex,
    UserTempleGridMetrics metrics,
  ) {
    if (items.isEmpty) {
      return 0;
    }
    final resolvedIndex = itemIndex.clamp(0, items.length - 1).toInt();
    var offset = _topPadding;
    for (final group in _resolveLevelGroups(items)) {
      if (resolvedIndex < group.end) {
        return offset;
      }
      offset += levelHeaderExtent + metrics.gridExtent(group.length);
    }
    return offset;
  }
}

/// 用户圣殿网格布局参数
class UserTempleGridMetrics {
  /// 创建用户圣殿网格布局参数
  ///
  /// [crossAxisCount] 横向列数
  /// [cardWidth] 卡片宽度
  /// [cardHeight] 卡片高度
  const UserTempleGridMetrics({
    required this.crossAxisCount,
    required this.cardWidth,
    required this.cardHeight,
  });

  /// 横向列数
  final int crossAxisCount;

  /// 卡片宽度
  final double cardWidth;

  /// 卡片高度
  final double cardHeight;

  /// 网格宽高比
  double get childAspectRatio => cardWidth / cardHeight;

  /// 单行网格跨度
  double get rowExtent =>
      cardHeight + UserTempleResponsiveGrid._mainAxisSpacing;

  /// 计算指定条目数量的网格高度
  ///
  /// [itemCount] 网格条目数量
  double gridExtent(int itemCount) {
    if (itemCount <= 0) {
      return 0;
    }
    final rowCount = (itemCount / crossAxisCount).ceil();
    return rowCount * cardHeight +
        math.max(0, rowCount - 1) * UserTempleResponsiveGrid._mainAxisSpacing;
  }
}

/// 用户圣殿角色等级分组
class _UserTempleLevelGroup {
  /// 创建用户圣殿角色等级分组
  ///
  /// [start] 起始条目下标
  /// [end] 结束条目下标
  /// [level] 角色等级
  const _UserTempleLevelGroup({
    required this.start,
    required this.end,
    required this.level,
  });

  /// 起始条目下标
  final int start;

  /// 结束条目下标
  final int end;

  /// 角色等级
  final int level;

  /// 分组条目数量
  int get length => end - start;
}

/// 按连续角色等级拆分圣殿网格
///
/// [items] 已按角色等级排序的圣殿条目
List<_UserTempleLevelGroup> _resolveLevelGroups(
  List<UserTempleApiItem> items,
) {
  if (items.isEmpty) {
    return const [];
  }
  final groups = <_UserTempleLevelGroup>[];
  var groupStart = 0;
  for (var index = 1; index <= items.length; index += 1) {
    if (index < items.length &&
        items[index].characterLevel == items[groupStart].characterLevel) {
      continue;
    }
    groups.add(
      _UserTempleLevelGroup(
        start: groupStart,
        end: index,
        level: items[groupStart].characterLevel,
      ),
    );
    groupStart = index;
  }
  return groups;
}

/// 用户圣殿角色等级分组标题
class _UserTempleLevelHeader extends StatelessWidget {
  /// 创建用户圣殿角色等级分组标题
  ///
  /// [level] 角色等级
  const _UserTempleLevelHeader({required this.level});

  /// 角色等级
  final int level;

  /// 构建用户圣殿角色等级分组标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: UserTempleResponsiveGrid.levelHeaderExtent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Lv.$level',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

/// 用户圣殿自适应骨架网格
class UserTempleSkeletonGrid extends StatelessWidget {
  /// 创建用户圣殿自适应骨架网格
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架卡片数量
  const UserTempleSkeletonGrid({
    super.key,
    this.itemCount = 12,
  });

  /// 骨架卡片数量
  final int itemCount;

  /// 构建用户圣殿自适应骨架网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final metrics = UserTempleResponsiveGrid.resolveMetrics(
          constraints.crossAxisExtent,
          AppSafeAreaInsets.horizontalSum(context),
        );
        return SliverPadding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: UserTempleResponsiveGrid._horizontalPadding,
            top: UserTempleResponsiveGrid._topPadding,
            right: UserTempleResponsiveGrid._horizontalPadding,
            bottom: 0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: metrics.crossAxisCount,
              mainAxisSpacing: UserTempleResponsiveGrid._mainAxisSpacing,
              crossAxisSpacing: UserTempleResponsiveGrid._crossAxisSpacing,
              childAspectRatio: metrics.childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const _UserTempleSkeletonCard(),
              childCount: itemCount,
            ),
          ),
        );
      },
    );
  }
}

/// 用户圣殿骨架卡片
class _UserTempleSkeletonCard extends StatelessWidget {
  /// 创建用户圣殿骨架卡片
  const _UserTempleSkeletonCard();

  /// 构建用户圣殿骨架卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final coverHeight = width / 3 * 4;
        return Skeletonizer.zone(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone(
                width: width,
                height: coverHeight,
                borderRadius: BorderRadius.circular(24),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone(
                      width: width * 0.56,
                      height: 11,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 6),
                    Bone(
                      width: width - 8,
                      height: 4,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
