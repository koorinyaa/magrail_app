import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_link_card.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_temple_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 角色详情固定资产自适应网格
class CharacterDetailTempleGrid extends StatelessWidget {
  /// 创建角色详情固定资产自适应网格
  ///
  /// [key] Flutter 组件标识
  /// [items] 固定资产条目
  /// [fallbackCharacterName] 角色名称兜底文案
  /// [onCharacterTap] 角色点击回调
  /// [onOwnerTap] 拥有者点击回调
  /// [onAssetTap] 圣殿资产卡片入口回调
  /// [onLinkedAssetTap] LINK 圣殿资产卡片入口回调
  const CharacterDetailTempleGrid({
    super.key,
    required this.items,
    required this.fallbackCharacterName,
    this.onCharacterTap,
    this.onOwnerTap,
    this.onAssetTap,
    this.onLinkedAssetTap,
  });

  static const double _horizontalPadding = 12;
  static const double _mainAxisSpacing = 10;
  static const double _crossAxisSpacing = 10;
  static const double _minCardWidth = 156;

  /// 固定资产条目
  final List<CharacterDetailTempleItem> items;

  /// 角色名称兜底文案
  final String fallbackCharacterName;

  /// 角色点击回调
  final ValueChanged<CharacterDetailTempleItem>? onCharacterTap;

  /// 拥有者点击回调
  final ValueChanged<CharacterDetailTempleItem>? onOwnerTap;

  /// 圣殿资产卡片入口回调
  final ValueChanged<CharacterDetailTempleItem>? onAssetTap;

  /// LINK 圣殿资产卡片入口回调
  final void Function(
    CharacterDetailTempleItem ownerItem,
    CharacterDetailTempleItem linkedItem,
  )? onLinkedAssetTap;

  /// 构建角色详情固定资产自适应网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final layout = _resolveTempleLayout(
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
                return CharacterDetailTempleCard(
                  item: items[index],
                  fallbackCharacterName: fallbackCharacterName,
                  width: layout.cardWidth,
                  heroTagPrefix: 'character-temple-page-cover-$index',
                  onCharacterTap: onCharacterTap,
                  onOwnerTap: onOwnerTap,
                  onAssetTap: onAssetTap,
                  onLinkedAssetTap: onLinkedAssetTap,
                );
              },
              childCount: items.length,
            ),
          ),
        );
      },
    );
  }
}

/// 角色详情 LINK 自适应网格
class CharacterDetailLinkGrid extends StatelessWidget {
  /// 创建角色详情 LINK 自适应网格
  ///
  /// [key] Flutter 组件标识
  /// [items] LINK 条目
  /// [fallbackCharacterName] 当前角色名称兜底文案
  /// [onCharacterTap] 角色点击回调
  /// [onOwnerTap] 拥有者点击回调
  /// [onTempleAssetTap] 当前角色圣殿资产入口回调
  /// [onLinkedAssetTap] LINK 圣殿资产入口回调
  const CharacterDetailLinkGrid({
    super.key,
    required this.items,
    required this.fallbackCharacterName,
    this.onCharacterTap,
    this.onOwnerTap,
    this.onTempleAssetTap,
    this.onLinkedAssetTap,
  });

  static const double _horizontalPadding = 12;
  static const double _mainAxisSpacing = 14;
  static const double _crossAxisSpacing = 12;
  static const double _minCardWidth = 276;
  static const double _maxCardWidth = 320;
  static const int _maxColumnCount = 6;

  /// LINK 条目
  final List<CharacterDetailTempleItem> items;

  /// 当前角色名称兜底文案
  final String fallbackCharacterName;

  /// 角色点击回调
  final ValueChanged<CharacterDetailTempleItem>? onCharacterTap;

  /// 拥有者点击回调
  final ValueChanged<CharacterDetailTempleItem>? onOwnerTap;

  /// 当前角色圣殿资产入口回调
  final ValueChanged<CharacterDetailTempleItem>? onTempleAssetTap;

  /// LINK 圣殿资产入口回调
  final void Function(
    CharacterDetailTempleItem ownerItem,
    CharacterDetailTempleItem linkedItem,
  )? onLinkedAssetTap;

  /// 构建角色详情 LINK 自适应网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final layout = _resolveLinkLayout(
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
                  CharacterDetailLinkCard.heightForWidth(layout.cardWidth),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: CharacterDetailLinkCard(
                    item: items[index],
                    fallbackCharacterName: fallbackCharacterName,
                    width: layout.cardWidth,
                    heroTagPrefix: 'character-link-page-cover-$index',
                    onCharacterTap: onCharacterTap,
                    onOwnerTap: onOwnerTap,
                    onTempleAssetTap: onTempleAssetTap,
                    onLinkedAssetTap: onLinkedAssetTap,
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
}

/// 角色详情固定资产骨架网格
class CharacterDetailTempleSkeletonGrid extends StatelessWidget {
  /// 创建角色详情固定资产骨架网格
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架卡片数量
  const CharacterDetailTempleSkeletonGrid({
    super.key,
    this.itemCount = 12,
  });

  /// 骨架卡片数量
  final int itemCount;

  /// 构建角色详情固定资产骨架网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final layout = _resolveTempleLayout(
          constraints.crossAxisExtent,
          AppSafeAreaInsets.horizontalSum(context),
        );

        return SliverPadding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: CharacterDetailTempleGrid._horizontalPadding,
            top: 10,
            right: CharacterDetailTempleGrid._horizontalPadding,
            bottom: 0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.crossAxisCount,
              mainAxisSpacing: CharacterDetailTempleGrid._mainAxisSpacing,
              crossAxisSpacing: CharacterDetailTempleGrid._crossAxisSpacing,
              childAspectRatio: layout.childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return const _TempleSkeletonCard();
              },
              childCount: itemCount,
            ),
          ),
        );
      },
    );
  }
}

/// 角色详情 LINK 骨架网格
class CharacterDetailLinkSkeletonGrid extends StatelessWidget {
  /// 创建角色详情 LINK 骨架网格
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架卡片数量
  const CharacterDetailLinkSkeletonGrid({
    super.key,
    this.itemCount = 8,
  });

  /// 骨架卡片数量
  final int itemCount;

  /// 构建角色详情 LINK 骨架网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final layout = _resolveLinkLayout(
          constraints.crossAxisExtent,
          AppSafeAreaInsets.horizontalSum(context),
        );

        return SliverPadding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: CharacterDetailLinkGrid._horizontalPadding,
            top: 10,
            right: CharacterDetailLinkGrid._horizontalPadding,
            bottom: 0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.crossAxisCount,
              mainAxisSpacing: CharacterDetailLinkGrid._mainAxisSpacing,
              crossAxisSpacing: CharacterDetailLinkGrid._crossAxisSpacing,
              childAspectRatio: layout.cellWidth /
                  CharacterDetailLinkCard.heightForWidth(layout.cardWidth),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: _LinkSkeletonCard(width: layout.cardWidth),
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

/// 角色详情固定资产网格参数
class _TempleGridLayout {
  /// 创建角色详情固定资产网格参数
  ///
  /// [crossAxisCount] 横向列数
  /// [cardWidth] 卡片宽度
  /// [cardHeight] 卡片高度
  const _TempleGridLayout({
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

/// 角色详情 LINK 网格参数
class _LinkGridLayout {
  /// 创建角色详情 LINK 网格参数
  ///
  /// [crossAxisCount] 横向列数
  /// [cellWidth] 网格单元宽度
  /// [cardWidth] 卡片宽度
  const _LinkGridLayout({
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

/// 解析固定资产网格参数
///
/// [crossAxisExtent] Sliver 可用横向宽度
/// [horizontalSafeArea] 横向安全区总宽度
_TempleGridLayout _resolveTempleLayout(
  double crossAxisExtent,
  double horizontalSafeArea,
) {
  final contentWidth = math.max(
    0.0,
    crossAxisExtent -
        CharacterDetailTempleGrid._horizontalPadding * 2 -
        horizontalSafeArea,
  );
  if (contentWidth <= CharacterDetailTempleGrid._crossAxisSpacing) {
    final cardWidth = math.max(contentWidth, 1.0);
    return _TempleGridLayout(
      crossAxisCount: 1,
      cardWidth: cardWidth,
      cardHeight: CharacterDetailTempleCard.heightForWidth(cardWidth),
    );
  }

  final rawCount =
      ((contentWidth + CharacterDetailTempleGrid._crossAxisSpacing) /
              (CharacterDetailTempleGrid._minCardWidth +
                  CharacterDetailTempleGrid._crossAxisSpacing))
          .floor();
  final crossAxisCount = rawCount.clamp(1, 6).toInt();
  final cardWidth = math.max(
    0.0,
    (contentWidth -
            CharacterDetailTempleGrid._crossAxisSpacing *
                (crossAxisCount - 1)) /
        crossAxisCount,
  );

  return _TempleGridLayout(
    crossAxisCount: crossAxisCount,
    cardWidth: cardWidth,
    cardHeight: CharacterDetailTempleCard.heightForWidth(cardWidth),
  );
}

/// 解析 LINK 网格参数
///
/// [crossAxisExtent] Sliver 可用横向宽度
/// [horizontalSafeArea] 横向安全区总宽度
_LinkGridLayout _resolveLinkLayout(
  double crossAxisExtent,
  double horizontalSafeArea,
) {
  final contentWidth = math.max(
    0.0,
    crossAxisExtent -
        CharacterDetailLinkGrid._horizontalPadding * 2 -
        horizontalSafeArea,
  );
  if (contentWidth <= 0) {
    return const _LinkGridLayout(
      crossAxisCount: 1,
      cellWidth: CharacterDetailLinkGrid._maxCardWidth,
      cardWidth: CharacterDetailLinkGrid._maxCardWidth,
    );
  }

  final rawCount = ((contentWidth + CharacterDetailLinkGrid._crossAxisSpacing) /
          (CharacterDetailLinkGrid._minCardWidth +
              CharacterDetailLinkGrid._crossAxisSpacing))
      .floor();
  final crossAxisCount =
      rawCount.clamp(1, CharacterDetailLinkGrid._maxColumnCount).toInt();
  final cellWidth = math.max(
    0.0,
    (contentWidth -
            CharacterDetailLinkGrid._crossAxisSpacing * (crossAxisCount - 1)) /
        crossAxisCount,
  );
  final cardWidth = math.min(cellWidth, CharacterDetailLinkGrid._maxCardWidth);

  return _LinkGridLayout(
    crossAxisCount: crossAxisCount,
    cellWidth: cellWidth,
    cardWidth: cardWidth,
  );
}

/// 固定资产骨架卡片
class _TempleSkeletonCard extends StatelessWidget {
  /// 创建固定资产骨架卡片
  const _TempleSkeletonCard();

  /// 构建固定资产骨架卡片
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

/// LINK 骨架卡片
class _LinkSkeletonCard extends StatelessWidget {
  /// 创建 LINK 骨架卡片
  ///
  /// [width] 卡片宽度
  const _LinkSkeletonCard({
    required this.width,
  });

  /// 卡片宽度
  final double width;

  /// 构建 LINK 骨架卡片
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
            height: CharacterDetailLinkCard.imageHeight *
                width /
                CharacterDetailLinkCard.defaultWidth,
            borderRadius: BorderRadius.circular(24),
          ),
          const SizedBox(height: 8),
          Bone(
            width: 96,
            height: 22,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}
