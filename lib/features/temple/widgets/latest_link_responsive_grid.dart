import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/temple/model/latest_link_api_item.dart';
import 'package:magrail_app/features/temple/model/latest_link_pair.dart';
import 'package:magrail_app/features/temple/widgets/latest_link_card.dart';
import 'package:magrail_app/features/temple/widgets/latest_link_skeleton_card.dart';

/// 最新连接自适应网格
class LatestLinkResponsiveGrid extends StatelessWidget {
  /// 创建最新连接自适应网格
  ///
  /// [items] 最新连接展示组
  /// [onCharacterTap] 角色名称点击回调
  /// [onUserTap] 用户名称点击回调
  /// [onItemBuilt] 条目构建回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const LatestLinkResponsiveGrid({
    super.key,
    required this.items,
    required this.onCharacterTap,
    required this.onUserTap,
    this.onItemBuilt,
    this.onAssetTap,
  });

  static const double _horizontalPadding = 12;
  static const double _mainAxisSpacing = 14;
  static const double _crossAxisSpacing = 12;
  static const double _minCardWidth = 276;
  static const double _maxCardWidth = 320;
  static const int _maxColumnCount = 6;

  /// 最新连接展示组
  final List<LatestLinkPair> items;

  /// 角色名称点击回调
  final ValueChanged<LatestLinkApiItem> onCharacterTap;

  /// 用户名称点击回调
  final ValueChanged<LatestLinkPair> onUserTap;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 圣殿资产入口点击回调
  final void Function(LatestLinkPair pair, LatestLinkApiItem item)? onAssetTap;

  /// 构建最新连接自适应网格
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
              childAspectRatio: layout.cellWidth /
                  LatestLinkCard.heightForWidth(
                    layout.cardWidth,
                  ),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                onItemBuilt?.call(index);
                return Align(
                  alignment: Alignment.topCenter,
                  child: LatestLinkCard(
                    pair: items[index],
                    width: layout.cardWidth,
                    heroTagPrefix: 'latest-link-page-cover',
                    onCharacterTap: onCharacterTap,
                    onUserTap: onUserTap,
                    onAssetTap: onAssetTap,
                  ),
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
  static _LatestLinkGridLayout _resolveLayout(
    double crossAxisExtent,
    double horizontalSafeArea,
  ) {
    final contentWidth = math.max(
      0.0,
      crossAxisExtent - _horizontalPadding * 2 - horizontalSafeArea,
    );
    if (contentWidth <= 0) {
      return const _LatestLinkGridLayout(
        crossAxisCount: 1,
        cellWidth: _maxCardWidth,
        cardWidth: _maxCardWidth,
      );
    }

    final rawCount = ((contentWidth + _crossAxisSpacing) /
            (_minCardWidth + _crossAxisSpacing))
        .floor();
    final crossAxisCount = rawCount.clamp(1, _maxColumnCount).toInt();
    final cellWidth = math.max(
      0.0,
      (contentWidth - _crossAxisSpacing * (crossAxisCount - 1)) /
          crossAxisCount,
    );
    final cardWidth = math.min(cellWidth, _maxCardWidth);

    return _LatestLinkGridLayout(
      crossAxisCount: crossAxisCount,
      cellWidth: cellWidth,
      cardWidth: cardWidth,
    );
  }
}

/// 最新连接自适应骨架网格
class LatestLinkSkeletonGrid extends StatelessWidget {
  /// 创建最新连接自适应骨架网格
  ///
  /// [itemCount] 骨架卡片数量
  const LatestLinkSkeletonGrid({
    super.key,
    this.itemCount = 8,
  });

  /// 骨架卡片数量
  final int itemCount;

  /// 构建最新连接自适应骨架网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final layout = LatestLinkResponsiveGrid._resolveLayout(
          constraints.crossAxisExtent,
          AppSafeAreaInsets.horizontalSum(context),
        );

        return SliverPadding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: LatestLinkResponsiveGrid._horizontalPadding,
            top: 10,
            right: LatestLinkResponsiveGrid._horizontalPadding,
            bottom: 0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.crossAxisCount,
              mainAxisSpacing: LatestLinkResponsiveGrid._mainAxisSpacing,
              crossAxisSpacing: LatestLinkResponsiveGrid._crossAxisSpacing,
              childAspectRatio: layout.cellWidth /
                  LatestLinkCard.heightForWidth(
                    layout.cardWidth,
                  ),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: LatestLinkSkeletonCard(width: layout.cardWidth),
                );
              },
              childCount: itemCount,
            ),
          ),
        );
      },
    );
  }
}

/// 最新连接网格布局参数
class _LatestLinkGridLayout {
  /// 创建最新连接网格布局参数
  ///
  /// [crossAxisCount] 横向列数
  /// [cellWidth] 网格单元宽度
  /// [cardWidth] 卡片宽度
  const _LatestLinkGridLayout({
    required this.crossAxisCount,
    required this.cellWidth,
    required this.cardWidth,
  });

  final int crossAxisCount;
  final double cellWidth;
  final double cardWidth;
}
