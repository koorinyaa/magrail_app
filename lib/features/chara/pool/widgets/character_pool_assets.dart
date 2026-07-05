import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/snapping_horizontal_list_view.dart';
import 'package:magrail_app/features/chara/auction/model/auction_api_item.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_chips.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_components.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_skeleton.dart';

/// 角色池资产行类型
enum CharacterPoolRowType {
  /// 英灵殿角色行
  valhalla,

  /// 幻想乡角色行
  gensokyo,
}

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
  /// [onItemBuilt] 条目构建回调
  /// [onCharacterTap] 角色条目点击回调
  /// [onAuctionPressed] 竞拍按钮点击回调
  const CharacterPoolSliverList({
    super.key,
    required this.items,
    required this.rowType,
    required this.auctionMap,
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
    return SliverFixedExtentList(
      itemExtent: _CharacterPoolListMetrics.itemExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
          final avatarHeroTag = createCharacterDetailAvatarHeroTag(
            characterId: item.characterId,
            avatarUrl: avatarUrl,
            source: item,
          );

          onItemBuilt?.call(index);
          return _CharacterPoolListItem(
            child: CharacterPoolRow(
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
            ),
          );
        },
        childCount: items.length,
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

/// 角色池资产行
class CharacterPoolRow extends StatelessWidget {
  /// 创建角色池资产行
  ///
  /// [key] Flutter 组件标识
  /// [item] 角色池条目
  /// [rowType] 角色池资产行类型
  /// [auction] 当前用户拍卖详情
  /// [avatarHeroTag] 头像转场标识
  /// [onTap] 条目点击回调
  /// [onAuctionPressed] 竞拍按钮点击回调
  const CharacterPoolRow({
    super.key,
    required this.item,
    required this.rowType,
    this.auction,
    this.avatarHeroTag,
    this.onTap,
    this.onAuctionPressed,
  });

  /// 角色池条目
  final UserCharacterApiItem item;

  /// 角色池资产行类型
  final CharacterPoolRowType rowType;

  /// 当前用户拍卖详情
  final AuctionApiItem? auction;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 条目点击回调
  final VoidCallback? onTap;

  /// 竞拍按钮点击回调
  final VoidCallback? onAuctionPressed;

  /// 构建角色池资产行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);

    return CharacterAssetRowShell(
      name: TinygrailFormatters.decodeHtmlEntities(item.name),
      avatarUrl: avatarUrl,
      avatarHeroTag: avatarHeroTag,
      level: item.level,
      zeroCount: item.zeroCount,
      metrics: [
        CharacterAssetMetric(
          label: '数量',
          value: _formatCount(item.state),
          isValueMuted: true,
        ),
        _buildSecondaryMetric(),
      ],
      trailing: _buildTrailing(),
      onTap: onTap,
    );
  }

  CharacterAssetMetric _buildSecondaryMetric() {
    return switch (rowType) {
      CharacterPoolRowType.valhalla => CharacterAssetMetric(
          label: '底价',
          value: Formatters.tinygrailCurrency(item.price),
          isValueMuted: true,
        ),
      CharacterPoolRowType.gensokyo => CharacterAssetMetric(
          label: '股息',
          value: '+${Formatters.tinygrailCurrency(item.rate)}',
          isValueMuted: true,
        ),
    };
  }

  Widget _buildTrailing() {
    return switch (rowType) {
      CharacterPoolRowType.valhalla => _CharacterPoolAuctionButton(
          hasUserBid: auction != null,
          onPressed: onAuctionPressed,
        ),
      CharacterPoolRowType.gensokyo => CharacterAssetCurrentPriceChip(
          current: item.current,
          fluctuation: item.fluctuation,
        ),
    };
  }

  /// 格式化角色池数量
  ///
  /// [value] 原始数量
  String _formatCount(int value) {
    if (value <= 0) {
      return '0';
    }

    return Formatters.groupedNumber(value);
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

class _CharacterPoolAuctionButton extends StatelessWidget {
  const _CharacterPoolAuctionButton({
    required this.hasUserBid,
    required this.onPressed,
  });

  static const double width = 46;
  static const double height = 22;

  final bool hasUserBid;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onPressed = this.onPressed;
    final isEnabled = onPressed != null;
    final foregroundColor = hasUserBid
        ? Colors.white
        : colorScheme.onSurfaceVariant.withValues(
            alpha: isEnabled ? (isDark ? 0.86 : 0.76) : 0.38,
          );
    final backgroundColor = hasUserBid
        ? colorScheme.primary.withValues(alpha: isEnabled ? 0.92 : 0.38)
        : colorScheme.onSurfaceVariant.withValues(
            alpha: isEnabled ? (isDark ? 0.12 : 0.08) : 0.05,
          );

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Center(
            child: Text(
              hasUserBid ? '改价' : '竞拍',
              style: TextStyle(
                color: foregroundColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterPoolListItem extends StatelessWidget {
  const _CharacterPoolListItem({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 12,
        top: 0,
        right: 12,
        bottom: 4,
      ),
      child: child,
    );
  }
}

final class _CharacterPoolListMetrics {
  const _CharacterPoolListMetrics._();

  static const double itemExtent = 68;
}

Size _trailingSkeletonSize(CharacterPoolRowType rowType) {
  return switch (rowType) {
    CharacterPoolRowType.valhalla => const Size(
        _CharacterPoolAuctionButton.width,
        _CharacterPoolAuctionButton.height,
      ),
    CharacterPoolRowType.gensokyo => const Size(54, 18),
  };
}
