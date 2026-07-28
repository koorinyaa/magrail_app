import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/snapping_horizontal_list_view.dart';
import 'package:magrail_app/features/chara/auction/model/auction_api_item.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/model/character_full_list_sort.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_skeleton.dart';
import 'package:magrail_app/features/chara/widgets/character_level_grouped_sliver_list.dart';

import 'character_pool_row.dart';

export 'character_pool_row.dart';

/// 角色池横向预览栏
class CharacterPoolCarousel extends StatelessWidget {
  /// 创建角色池横向预览栏
  ///
  /// [key] Flutter 组件标识
  /// [items] 角色池预览条目
  /// [rowType] 角色池资产行类型
  /// [auctionMap] 当前用户竞拍映射
  /// [isLoading] 是否正在加载
  /// [emptyMessage] 空状态文案
  /// [onCharacterTap] 角色条目点击回调
  /// [onAuctionPressed] 竞拍按钮点击回调
  const CharacterPoolCarousel({
    super.key,
    required this.items,
    required this.rowType,
    required this.auctionMap,
    required this.isLoading,
    required this.emptyMessage,
    this.onCharacterTap,
    this.onAuctionPressed,
  });

  /// 角色池预览条目
  final List<UserCharacterApiItem>? items;

  /// 角色池资产行类型
  final CharacterPoolRowType rowType;

  /// 当前用户竞拍映射
  final Map<int, AuctionApiItem> auctionMap;

  /// 是否正在加载
  final bool isLoading;

  /// 空状态文案
  final String emptyMessage;

  /// 角色条目点击回调
  final void Function(UserCharacterApiItem item, String? avatarHeroTag)?
      onCharacterTap;

  /// 竞拍按钮点击回调
  final ValueChanged<UserCharacterApiItem>? onAuctionPressed;

  /// 构建角色池横向预览栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _CharacterPoolCarouselBody(
      items: items,
      isLoading: isLoading,
      emptyMessage: emptyMessage,
      rowType: rowType,
      itemBuilder: (context, item) {
        final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
        final avatarHeroTag = createCharacterDetailAvatarHeroTag(
          characterId: item.characterId,
          avatarUrl: avatarUrl,
          source: item,
        );

        return CharacterPoolRow(
          item: item,
          rowType: rowType,
          auction: auctionMap[item.characterId],
          avatarHeroTag: avatarHeroTag,
          onTap: onCharacterTap == null
              ? null
              : () => onCharacterTap?.call(item, avatarHeroTag),
          onAuctionPressed: onAuctionPressed == null
              ? null
              : () => onAuctionPressed?.call(item),
        );
      },
    );
  }
}

/// 角色池 sliver 列表
class CharacterPoolSliverList extends StatelessWidget {
  /// 创建角色池 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 角色池条目
  /// [rowType] 角色池资产行类型
  /// [auctionMap] 当前用户竞拍映射
  /// [sort] 当前全量列表排序字段
  /// [showLevelHeaders] 是否显示等级标题
  /// [onItemBuilt] 条目构建回调
  /// [onCharacterTap] 角色条目点击回调
  /// [onAuctionPressed] 竞拍按钮点击回调
  const CharacterPoolSliverList({
    super.key,
    required this.items,
    required this.rowType,
    required this.auctionMap,
    this.sort,
    this.showLevelHeaders = false,
    this.onItemBuilt,
    this.onCharacterTap,
    this.onAuctionPressed,
  });

  /// 角色池条目
  final List<UserCharacterApiItem> items;

  /// 角色池资产行类型
  final CharacterPoolRowType rowType;

  /// 当前用户竞拍映射
  final Map<int, AuctionApiItem> auctionMap;

  /// 当前全量列表排序字段
  final CharacterFullListSort? sort;

  /// 是否显示等级标题
  final bool showLevelHeaders;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 角色条目点击回调
  final void Function(UserCharacterApiItem item, String? avatarHeroTag)?
      onCharacterTap;

  /// 竞拍按钮点击回调
  final ValueChanged<UserCharacterApiItem>? onAuctionPressed;

  /// 构建角色池 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (showLevelHeaders) {
      return CharacterLevelGroupedSliverList<UserCharacterApiItem>(
        items: items,
        levelOf: (item) => item.level,
        itemBuilder: (context, item, index) {
          return _buildItem(context, index, reserveLevelRail: true);
        },
      );
    }
    return SliverFixedExtentList(
      itemExtent: _CharacterPoolListMetrics.itemExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildItem(context, index),
        childCount: items.length,
      ),
    );
  }

  /// 构建角色池列表条目
  ///
  /// [context] 当前组件树上下文
  /// [index] 当前角色下标
  /// [reserveLevelRail] 是否为等级轨道预留右侧宽度
  Widget _buildItem(
    BuildContext context,
    int index, {
    bool reserveLevelRail = false,
  }) {
    final item = items[index];
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
    final avatarHeroTag = createCharacterDetailAvatarHeroTag(
      characterId: item.characterId,
      avatarUrl: avatarUrl,
      source: item,
    );

    onItemBuilt?.call(index);
    return _CharacterPoolListItem(
      reserveLevelRail: reserveLevelRail,
      child: CharacterPoolRow(
        item: item,
        rowType: rowType,
        sort: sort,
        auction: auctionMap[item.characterId],
        avatarHeroTag: avatarHeroTag,
        onTap: onCharacterTap == null
            ? null
            : () => onCharacterTap?.call(item, avatarHeroTag),
        onAuctionPressed: onAuctionPressed == null
            ? null
            : () => onAuctionPressed?.call(item),
      ),
    );
  }
}

/// 角色池 sliver 骨架列表
class CharacterPoolSkeletonSliverList extends StatelessWidget {
  /// 创建角色池 sliver 骨架列表
  ///
  /// [key] Flutter 组件标识
  /// [rowType] 角色池资产行类型
  /// [itemCount] 骨架条目数量
  const CharacterPoolSkeletonSliverList({
    super.key,
    required this.rowType,
    this.itemCount = 24,
  });

  /// 角色池资产行类型
  final CharacterPoolRowType rowType;

  /// 骨架条目数量
  final int itemCount;

  /// 构建角色池 sliver 骨架列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final trailingSize = _trailingSkeletonSize(rowType);

    return SliverFixedExtentList(
      itemExtent: _CharacterPoolListMetrics.itemExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _CharacterPoolListItem(
            child: CharacterAssetRowSkeleton(
              showTrailing: true,
              trailingWidth: trailingSize.width,
              trailingHeight: trailingSize.height,
            ),
          );
        },
        childCount: itemCount,
      ),
    );
  }
}

/// 角色池预览提示状态
class CharacterPoolOverviewMessage extends StatelessWidget {
  /// 创建角色池预览提示状态
  ///
  /// [key] Flutter 组件标识
  /// [message] 提示文案
  /// [onRetry] 重试回调
  const CharacterPoolOverviewMessage({
    super.key,
    required this.message,
    this.onRetry,
  });

  /// 提示文案
  final String message;

  /// 重试回调
  final Future<void> Function()? onRetry;

  /// 构建角色池预览提示状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final onRetry = this.onRetry;
    if (onRetry != null) {
      return AppLoadFailedState(
        message: message,
        onActionPressed: () {
          onRetry();
        },
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(
          alpha: colorScheme.brightness == Brightness.dark ? 0.72 : 0.82,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CharacterPoolCarouselBody extends StatelessWidget {
  const _CharacterPoolCarouselBody({
    required this.items,
    required this.isLoading,
    required this.emptyMessage,
    required this.rowType,
    required this.itemBuilder,
  });

  // 预览接口每次取 24 条，按每列 4 条呈现为 6 列
  static const int _rowsPerColumn = 4;
  static const int _previewItemCount = 24;
  static const int _skeletonColumnCount = _previewItemCount ~/ _rowsPerColumn;

  final List<UserCharacterApiItem>? items;
  final bool isLoading;
  final String emptyMessage;
  final CharacterPoolRowType rowType;
  final Widget Function(BuildContext context, UserCharacterApiItem item)
      itemBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final columnWidth = math.max(
          248.0,
          math.min(318.0, screenWidth - 72),
        );
        final resolvedItems = items ?? <UserCharacterApiItem>[];
        final showSkeleton = isLoading && resolvedItems.isEmpty;

        if (!showSkeleton && resolvedItems.isEmpty) {
          return Padding(
            padding: AppSafeAreaInsets.symmetricHorizontal(
              context,
              horizontal: 24,
            ),
            child: _CharacterPoolInlineEmpty(message: emptyMessage),
          );
        }

        final columns = _buildColumns(resolvedItems);
        final columnCount =
            showSkeleton ? _skeletonColumnCount : columns.length;
        final trailingSize = _trailingSkeletonSize(rowType);

        return SnappingHorizontalListView(
          height: 268,
          itemCount: columnCount,
          itemExtent: columnWidth,
          separatorExtent: 12,
          padding: AppSafeAreaInsets.symmetricHorizontal(
            context,
            horizontal: 24,
          ),
          clipBehavior: Clip.none,
          itemBuilder: (context, index) {
            return Column(
              children: showSkeleton
                  ? [
                      for (var row = 0; row < _rowsPerColumn; row++) ...[
                        CharacterAssetRowSkeleton(
                          showTrailing: true,
                          trailingWidth: trailingSize.width,
                          trailingHeight: trailingSize.height,
                        ),
                        if (row != _rowsPerColumn - 1)
                          const SizedBox(height: 4),
                      ],
                    ]
                  : [
                      for (var row = 0; row < columns[index].length; row++) ...[
                        itemBuilder(context, columns[index][row]),
                        if (row != columns[index].length - 1)
                          const SizedBox(height: 4),
                      ],
                    ],
            );
          },
        );
      },
    );
  }

  List<List<UserCharacterApiItem>> _buildColumns(
    List<UserCharacterApiItem> items,
  ) {
    final previewItems = items.take(_previewItemCount).toList();
    final result = <List<UserCharacterApiItem>>[];

    for (var start = 0; start < previewItems.length; start += _rowsPerColumn) {
      final end = math.min(start + _rowsPerColumn, previewItems.length);
      result.add(previewItems.sublist(start, end));
    }

    return result;
  }
}

class _CharacterPoolInlineEmpty extends StatelessWidget {
  const _CharacterPoolInlineEmpty({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 88,
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// 角色池列表条目外层
class _CharacterPoolListItem extends StatelessWidget {
  /// 创建角色池列表条目外层
  ///
  /// [child] 列表项内容
  /// [reserveLevelRail] 是否为等级轨道预留右侧宽度
  const _CharacterPoolListItem({
    required this.child,
    this.reserveLevelRail = false,
  });

  /// 列表项内容
  final Widget child;

  /// 是否为等级轨道预留右侧宽度
  final bool reserveLevelRail;

  /// 构建角色池列表条目外层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 12,
        top: 0,
        right: reserveLevelRail ? 32 : 12,
        bottom: 4,
      ),
      child: child,
    );
  }
}

/// 角色池列表尺寸
final class _CharacterPoolListMetrics {
  /// 禁止创建角色池列表尺寸实例
  const _CharacterPoolListMetrics._();

  /// 角色池列表条目高度
  static const double itemExtent = 68;
}

/// 读取角色池行尾骨架尺寸
///
/// [rowType] 角色池资产行类型
Size _trailingSkeletonSize(CharacterPoolRowType rowType) {
  return switch (rowType) {
    CharacterPoolRowType.valhalla => CharacterPoolRow.auctionButtonSize,
    CharacterPoolRowType.gensokyo => const Size(54, 18),
  };
}
