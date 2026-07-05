import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/temple/model/temple_api_item.dart';
import 'package:magrail_app/features/temple/widgets/latest_temple_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 最新圣殿自适应瀑布网格
class LatestTempleResponsiveGrid extends StatelessWidget {
  /// 创建最新圣殿自适应瀑布网格
  ///
  /// [items] 最新圣殿条目
  /// [onCharacterTap] 角色区域点击回调
  /// [onUserTap] 用户区域点击回调
  /// [onItemBuilt] 条目构建回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const LatestTempleResponsiveGrid({
    super.key,
    required this.items,
    required this.onCharacterTap,
    required this.onUserTap,
    this.onItemBuilt,
    this.onAssetTap,
  });

  static const double _horizontalPadding = 12;
  static const double _mainAxisSpacing = 10;
  static const double _crossAxisSpacing = 10;
  static const double _minCardWidth = 156;

  /// 最新圣殿条目
  final List<TempleApiItem> items;

  /// 角色区域点击回调
  final ValueChanged<TempleApiItem> onCharacterTap;

  /// 用户区域点击回调
  final ValueChanged<TempleApiItem> onUserTap;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 圣殿资产入口点击回调
  final ValueChanged<TempleApiItem>? onAssetTap;

  /// 构建最新圣殿自适应瀑布网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final layout = _resolveLayout(
          constraints.crossAxisExtent,
          AppSafeAreaInsets.horizontalSum(context),
        );

        return SliverPadding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: _horizontalPadding,
            top: 10,
            right: _horizontalPadding,
            bottom: 0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.crossAxisCount,
              mainAxisSpacing: _mainAxisSpacing,
              crossAxisSpacing: _crossAxisSpacing,
              childAspectRatio: 3 / 4,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                onItemBuilt?.call(index);
                return LatestTempleCard(
                  item: items[index],
                  width: layout.cardWidth,
                  heroTagPrefix: 'latest-temple-page-cover',
                  onCharacterTap: onCharacterTap,
                  onUserTap: onUserTap,
                  onAssetTap: onAssetTap,
                );
              },
              childCount: items.length,
            ),
          ),
        );
      },
    );
  }

  /// 解析当前屏幕宽度下的网格参数
  ///
  /// [crossAxisExtent] Sliver 可用横向宽度
  /// [horizontalSafeArea] 横向安全区总宽度
  static _LatestTempleGridLayout _resolveLayout(
    double crossAxisExtent,
    double horizontalSafeArea,
  ) {
    final contentWidth = math.max(
      0.0,
      crossAxisExtent - _horizontalPadding * 2 - horizontalSafeArea,
    );
    final rawCount = ((contentWidth + _crossAxisSpacing) /
            (_minCardWidth + _crossAxisSpacing))
        .floor();
    final crossAxisCount = rawCount.clamp(2, 6).toInt();
    final cardWidth = math.max(
      0.0,
      (contentWidth - _crossAxisSpacing * (crossAxisCount - 1)) /
          crossAxisCount,
    );

    return _LatestTempleGridLayout(
      crossAxisCount: crossAxisCount,
      cardWidth: cardWidth,
    );
  }
}

/// 最新圣殿自适应骨架网格
class LatestTempleSkeletonGrid extends StatelessWidget {
  /// 创建最新圣殿自适应骨架网格
  ///
  /// [itemCount] 骨架卡片数量
  const LatestTempleSkeletonGrid({
    super.key,
    this.itemCount = 12,
  });

  /// 骨架卡片数量
  final int itemCount;

  /// 构建最新圣殿自适应骨架网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final layout = LatestTempleResponsiveGrid._resolveLayout(
          constraints.crossAxisExtent,
          AppSafeAreaInsets.horizontalSum(context),
        );

        return SliverPadding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: LatestTempleResponsiveGrid._horizontalPadding,
            top: 10,
            right: LatestTempleResponsiveGrid._horizontalPadding,
            bottom: 0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.crossAxisCount,
              mainAxisSpacing: LatestTempleResponsiveGrid._mainAxisSpacing,
              crossAxisSpacing: LatestTempleResponsiveGrid._crossAxisSpacing,
              childAspectRatio: 3 / 4,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return const _LatestTempleSkeletonCard();
              },
              childCount: itemCount,
            ),
          ),
        );
      },
    );
  }
}

/// 最新圣殿网格布局参数
class _LatestTempleGridLayout {
  /// 创建最新圣殿网格布局参数
  ///
  /// [crossAxisCount] 横向列数
  /// [cardWidth] 卡片宽度
  const _LatestTempleGridLayout({
    required this.crossAxisCount,
    required this.cardWidth,
  });

  final int crossAxisCount;
  final double cardWidth;
}

/// 最新圣殿骨架卡片
class _LatestTempleSkeletonCard extends StatelessWidget {
  /// 创建最新圣殿骨架卡片
  const _LatestTempleSkeletonCard();

  /// 构建最新圣殿骨架卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Skeletonizer.zone(
          child: Bone(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            borderRadius: BorderRadius.circular(24),
          ),
        );
      },
    );
  }
}
