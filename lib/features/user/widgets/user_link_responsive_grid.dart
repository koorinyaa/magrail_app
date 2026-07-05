import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/user/model/user_link_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_link_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 用户连接自适应网格
class UserLinkResponsiveGrid extends StatelessWidget {
  /// 创建用户连接自适应网格
  ///
  /// [key] Flutter 组件标识
  /// [items] 用户连接条目
  /// [onItemBuilt] 条目构建回调
  /// [onCharacterTap] 角色名称点击回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const UserLinkResponsiveGrid({
    super.key,
    required this.items,
    this.onItemBuilt,
    this.onCharacterTap,
    this.onAssetTap,
  });

  static const double _horizontalPadding = 12;
  static const double _mainAxisSpacing = 14;
  static const double _crossAxisSpacing = 12;
  static const double _minCardWidth = 276;
  static const double _maxCardWidth = 320;
  static const int _maxColumnCount = 6;

  /// 用户连接条目
  final List<UserLinkApiItem> items;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 角色名称点击回调
  final ValueChanged<UserTempleApiItem>? onCharacterTap;

  /// 圣殿资产入口点击回调
  final ValueChanged<UserTempleApiItem>? onAssetTap;

  /// 构建用户连接自适应网格
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
                  UserLinkCard.heightForWidth(layout.cardWidth),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                onItemBuilt?.call(index);
                return Align(
                  alignment: Alignment.topCenter,
                  child: UserLinkCard(
                    item: items[index],
                    width: layout.cardWidth,
                    heroTagPrefix: 'user-link-page-cover-$index',
                    onCharacterTap: onCharacterTap,
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
  static _UserLinkGridLayout _resolveLayout(
    double crossAxisExtent,
    double horizontalSafeArea,
  ) {
    final contentWidth = math.max(
      0.0,
      crossAxisExtent - _horizontalPadding * 2 - horizontalSafeArea,
    );
    if (contentWidth <= 0) {
      return const _UserLinkGridLayout(
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

    return _UserLinkGridLayout(
      crossAxisCount: crossAxisCount,
      cellWidth: cellWidth,
      cardWidth: cardWidth,
    );
  }
}

/// 用户连接自适应骨架网格
class UserLinkSkeletonGrid extends StatelessWidget {
  /// 创建用户连接自适应骨架网格
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架卡片数量
  const UserLinkSkeletonGrid({
    super.key,
    this.itemCount = 8,
  });

  /// 骨架卡片数量
  final int itemCount;

  /// 构建用户连接自适应骨架网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final layout = UserLinkResponsiveGrid._resolveLayout(
          constraints.crossAxisExtent,
          AppSafeAreaInsets.horizontalSum(context),
        );

        return SliverPadding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: UserLinkResponsiveGrid._horizontalPadding,
            top: 10,
            right: UserLinkResponsiveGrid._horizontalPadding,
            bottom: 0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.crossAxisCount,
              mainAxisSpacing: UserLinkResponsiveGrid._mainAxisSpacing,
              crossAxisSpacing: UserLinkResponsiveGrid._crossAxisSpacing,
              childAspectRatio: layout.cellWidth /
                  UserLinkCard.heightForWidth(layout.cardWidth),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: _UserLinkSkeletonCard(width: layout.cardWidth),
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

/// 用户连接网格布局参数
class _UserLinkGridLayout {
  /// 创建用户连接网格布局参数
  ///
  /// [crossAxisCount] 横向列数
  /// [cellWidth] 网格单元宽度
  /// [cardWidth] 卡片宽度
  const _UserLinkGridLayout({
    required this.crossAxisCount,
    required this.cellWidth,
    required this.cardWidth,
  });

  /// 横向列数
  final int crossAxisCount;

  /// 网格单元宽度
  final double cellWidth;

  /// 卡片宽度
  final double cardWidth;
}

/// 用户连接骨架卡片
class _UserLinkSkeletonCard extends StatelessWidget {
  /// 创建用户连接骨架卡片
  ///
  /// [width] 卡片宽度
  const _UserLinkSkeletonCard({
    required this.width,
  });

  /// 卡片宽度
  final double width;

  /// 构建用户连接骨架卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone(
            width: width,
            height:
                UserLinkCard.imageHeight * width / UserLinkCard.defaultWidth,
            borderRadius: BorderRadius.circular(24),
          ),
          const SizedBox(height: 8),
          Bone(
            width: 66,
            height: 22,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}
