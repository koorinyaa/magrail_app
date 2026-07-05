import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_temple_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 用户圣殿自适应瀑布网格
class UserTempleResponsiveGrid extends StatelessWidget {
  /// 创建用户圣殿自适应瀑布网格
  ///
  /// [key] Flutter 组件标识
  /// [items] 用户圣殿条目
  /// [ownerLabel] 用户展示文案
  /// [onItemBuilt] 条目构建回调
  /// [onCharacterTap] 角色区域点击回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const UserTempleResponsiveGrid({
    super.key,
    required this.items,
    required this.ownerLabel,
    this.onItemBuilt,
    this.onCharacterTap,
    this.onAssetTap,
  });

  static const double _horizontalPadding = 12;
  static const double _mainAxisSpacing = 10;
  static const double _crossAxisSpacing = 10;
  static const double _minCardWidth = 156;

  /// 用户圣殿条目
  final List<UserTempleApiItem> items;

  /// 用户展示文案
  final String ownerLabel;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 角色区域点击回调
  final ValueChanged<UserTempleApiItem>? onCharacterTap;

  /// 圣殿资产入口点击回调
  final ValueChanged<UserTempleApiItem>? onAssetTap;

  /// 构建用户圣殿自适应瀑布网格
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
              childAspectRatio: layout.childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                onItemBuilt?.call(index);
                return UserTempleCard(
                  item: items[index],
                  ownerLabel: ownerLabel,
                  width: layout.cardWidth,
                  heroTagPrefix: 'user-temple-page-cover-$index',
                  onCharacterTap: onCharacterTap,
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
  static _UserTempleGridLayout _resolveLayout(
    double crossAxisExtent,
    double horizontalSafeArea,
  ) {
    final contentWidth = math.max(
      0.0,
      crossAxisExtent - _horizontalPadding * 2 - horizontalSafeArea,
    );
    if (contentWidth <= _crossAxisSpacing) {
      final cardWidth = math.max(contentWidth, 1.0);
      return _UserTempleGridLayout(
        crossAxisCount: 1,
        cardWidth: cardWidth,
        cardHeight: UserTempleCard.heightForWidth(cardWidth),
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

    return _UserTempleGridLayout(
      crossAxisCount: crossAxisCount,
      cardWidth: cardWidth,
      cardHeight: UserTempleCard.heightForWidth(cardWidth),
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
        final layout = UserTempleResponsiveGrid._resolveLayout(
          constraints.crossAxisExtent,
          AppSafeAreaInsets.horizontalSum(context),
        );

        return SliverPadding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: UserTempleResponsiveGrid._horizontalPadding,
            top: 10,
            right: UserTempleResponsiveGrid._horizontalPadding,
            bottom: 0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.crossAxisCount,
              mainAxisSpacing: UserTempleResponsiveGrid._mainAxisSpacing,
              crossAxisSpacing: UserTempleResponsiveGrid._crossAxisSpacing,
              childAspectRatio: layout.childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return const _UserTempleSkeletonCard();
              },
              childCount: itemCount,
            ),
          ),
        );
      },
    );
  }
}

/// 用户圣殿网格布局参数
class _UserTempleGridLayout {
  /// 创建用户圣殿网格布局参数
  ///
  /// [crossAxisCount] 横向列数
  /// [cardWidth] 卡片宽度
  /// [cardHeight] 卡片高度
  const _UserTempleGridLayout({
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
