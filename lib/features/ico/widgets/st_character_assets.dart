import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/snapping_horizontal_list_view.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/ico/model/st_character_entry.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_chips.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_components.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_skeleton.dart';

/// ST 角色横向预览栏
class StCharacterCarousel extends StatelessWidget {
  /// 创建 ST 角色横向预览栏
  ///
  /// [key] Flutter 组件标识
  /// [items] ST 角色预览条目
  /// [isLoading] 是否正在加载
  /// [emptyMessage] 空状态文案
  /// [onCharacterTap] 角色条目点击回调
  const StCharacterCarousel({
    super.key,
    required this.items,
    required this.isLoading,
    required this.emptyMessage,
    this.onCharacterTap,
  });

  /// ST 角色预览条目
  final List<StCharacterEntry>? items;

  /// 是否正在加载
  final bool isLoading;

  /// 空状态文案
  final String emptyMessage;

  /// 角色条目点击回调
  final void Function(StCharacterEntry item, String? avatarHeroTag)?
      onCharacterTap;

  /// 构建 ST 角色横向预览栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _StCharacterCarouselBody(
      items: items,
      isLoading: isLoading,
      emptyMessage: emptyMessage,
      itemBuilder: (context, item) {
        final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
        final avatarHeroTag = createCharacterDetailAvatarHeroTag(
          characterId: item.characterId,
          avatarUrl: avatarUrl,
          source: item,
        );

        return StCharacterRow(
          item: item,
          avatarHeroTag: avatarHeroTag,
          onTap: onCharacterTap == null
              ? null
              : () => onCharacterTap?.call(item, avatarHeroTag),
        );
      },
    );
  }
}

/// ST 角色 sliver 列表
class StCharacterSliverList extends StatelessWidget {
  /// 创建 ST 角色 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] ST 角色条目
  /// [onItemBuilt] 条目构建回调
  /// [onCharacterTap] 角色条目点击回调
  const StCharacterSliverList({
    super.key,
    required this.items,
    this.onItemBuilt,
    this.onCharacterTap,
  });

  /// ST 角色条目
  final List<StCharacterEntry> items;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 角色条目点击回调
  final void Function(StCharacterEntry item, String? avatarHeroTag)?
      onCharacterTap;

  /// 构建 ST 角色 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: _StCharacterListMetrics.itemExtent,
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
          return _StCharacterListItem(
            child: StCharacterRow(
              item: item,
              avatarHeroTag: avatarHeroTag,
              onTap: onCharacterTap == null
                  ? null
                  : () => onCharacterTap?.call(item, avatarHeroTag),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}

/// ST 角色 sliver 骨架列表
class StCharacterSkeletonSliverList extends StatelessWidget {
  /// 创建 ST 角色 sliver 骨架列表
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  const StCharacterSkeletonSliverList({
    super.key,
    this.itemCount = 24,
  });

  /// 骨架条目数量
  final int itemCount;

  /// 构建 ST 角色 sliver 骨架列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: _StCharacterListMetrics.itemExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return const _StCharacterListItem(
            child: CharacterAssetRowSkeleton(
              showTrailing: true,
              trailingWidth: 54,
              trailingHeight: 18,
            ),
          );
        },
        childCount: itemCount,
      ),
    );
  }
}

/// ST 角色行
class StCharacterRow extends StatelessWidget {
  /// 创建 ST 角色行
  ///
  /// [key] Flutter 组件标识
  /// [item] ST 角色条目
  /// [avatarHeroTag] 头像转场标识
  /// [onTap] 条目点击回调
  const StCharacterRow({
    super.key,
    required this.item,
    this.avatarHeroTag,
    this.onTap,
  });

  /// ST 角色条目
  final StCharacterEntry item;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 条目点击回调
  final VoidCallback? onTap;

  /// 构建 ST 角色行
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
          label: '流通',
          value: _formatCount(item.total),
          isValueMuted: true,
        ),
        CharacterAssetMetric(
          label: '买卖',
          value: '${_formatCount(item.bids)} / ${_formatCount(item.asks)}',
          isValueMuted: true,
        ),
      ],
      trailing: CharacterAssetCurrentPriceChip(
        current: item.current,
        fluctuation: item.fluctuation,
      ),
      onTap: onTap,
    );
  }

  /// 格式化 ST 角色数量
  ///
  /// [value] 原始数量
  String _formatCount(int value) {
    if (value <= 0) {
      return '0';
    }

    return Formatters.groupedNumber(value);
  }
}

/// ST 角色预览提示状态
class StCharacterOverviewMessage extends StatelessWidget {
  /// 创建 ST 角色预览提示状态
  ///
  /// [key] Flutter 组件标识
  /// [message] 提示文案
  /// [onRetry] 重试回调
  const StCharacterOverviewMessage({
    super.key,
    required this.message,
    this.onRetry,
  });

  /// 提示文案
  final String message;

  /// 重试回调
  final Future<void> Function()? onRetry;

  /// 构建 ST 角色预览提示状态
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

/// ST 角色横向预览主体
class _StCharacterCarouselBody extends StatelessWidget {
  /// 创建 ST 角色横向预览主体
  ///
  /// [items] ST 角色预览条目
  /// [isLoading] 是否正在加载
  /// [emptyMessage] 空状态文案
  /// [itemBuilder] 条目构建器
  const _StCharacterCarouselBody({
    required this.items,
    required this.isLoading,
    required this.emptyMessage,
    required this.itemBuilder,
  });

  // 预览接口每次取 24 条，按每列 4 条呈现为 6 列
  static const int _rowsPerColumn = 4;
  static const int _previewItemCount = 24;
  static const int _skeletonColumnCount = _previewItemCount ~/ _rowsPerColumn;

  final List<StCharacterEntry>? items;
  final bool isLoading;
  final String emptyMessage;
  final Widget Function(BuildContext context, StCharacterEntry item)
      itemBuilder;

  /// 构建 ST 角色横向预览主体
  ///
  /// [context] 当前组件树上下文
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
        final resolvedItems = items ?? <StCharacterEntry>[];
        final showSkeleton = isLoading && resolvedItems.isEmpty;

        if (!showSkeleton && resolvedItems.isEmpty) {
          return Padding(
            padding: AppSafeAreaInsets.symmetricHorizontal(
              context,
              horizontal: 24,
            ),
            child: _StCharacterInlineEmpty(message: emptyMessage),
          );
        }

        final columns = _buildColumns(resolvedItems);
        final columnCount =
            showSkeleton ? _skeletonColumnCount : columns.length;

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
                        const CharacterAssetRowSkeleton(
                          showTrailing: true,
                          trailingWidth: 54,
                          trailingHeight: 18,
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

  /// 构建横向预览列数据
  ///
  /// [items] ST 角色预览条目
  List<List<StCharacterEntry>> _buildColumns(List<StCharacterEntry> items) {
    final previewItems = items.take(_previewItemCount).toList();
    final result = <List<StCharacterEntry>>[];

    for (var start = 0; start < previewItems.length; start += _rowsPerColumn) {
      final end = math.min(start + _rowsPerColumn, previewItems.length);
      result.add(previewItems.sublist(start, end));
    }

    return result;
  }
}

/// ST 角色横向预览内联空状态
class _StCharacterInlineEmpty extends StatelessWidget {
  /// 创建 ST 角色横向预览内联空状态
  ///
  /// [message] 空状态文案
  const _StCharacterInlineEmpty({
    required this.message,
  });

  final String message;

  /// 构建 ST 角色横向预览内联空状态
  ///
  /// [context] 当前组件树上下文
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

/// ST 角色列表项外层
class _StCharacterListItem extends StatelessWidget {
  /// 创建 ST 角色列表项外层
  ///
  /// [child] 列表项内容
  const _StCharacterListItem({
    required this.child,
  });

  final Widget child;

  /// 构建 ST 角色列表项外层
  ///
  /// [context] 当前组件树上下文
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

/// ST 角色列表尺寸
final class _StCharacterListMetrics {
  /// 禁用创建 ST 角色列表尺寸实例
  const _StCharacterListMetrics._();

  static const double itemExtent = 68;
}
