import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/snapping_horizontal_list_view.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/rank/model/character_rank_entry.dart';
import 'package:magrail_app/features/chara/rank/repository/character_rank_repository.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_chips.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_components.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_skeleton.dart';

/// 角色排序横向预览栏
class CharacterRankCarousel extends StatelessWidget {
  /// 创建角色排序横向预览栏
  ///
  /// [key] Flutter 组件标识
  /// [items] 角色排序预览条目
  /// [selectedType] 当前排序类型
  /// [isLoading] 是否正在加载
  /// [emptyMessage] 空状态文案
  /// [onCharacterTap] 角色条目点击回调
  const CharacterRankCarousel({
    super.key,
    required this.items,
    required this.selectedType,
    required this.isLoading,
    required this.emptyMessage,
    this.onCharacterTap,
  });

  /// 角色排序预览条目
  final List<CharacterRankEntry>? items;

  /// 当前排序类型
  final CharacterRankSortType selectedType;

  /// 是否正在加载
  final bool isLoading;

  /// 空状态文案
  final String emptyMessage;

  /// 角色条目点击回调
  final void Function(CharacterRankEntry item, String? avatarHeroTag)?
      onCharacterTap;

  /// 构建角色排序横向预览栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _CharacterRankCarouselBody(
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

        return CharacterRankRow(
          item: item,
          selectedType: selectedType,
          avatarHeroTag: avatarHeroTag,
          onTap: onCharacterTap == null
              ? null
              : () => onCharacterTap?.call(item, avatarHeroTag),
        );
      },
    );
  }
}

/// 角色排序 sliver 列表
class CharacterRankSliverList extends StatelessWidget {
  /// 创建角色排序 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 角色排序条目
  /// [selectedType] 当前排序类型
  /// [onItemBuilt] 条目构建回调
  /// [onCharacterTap] 角色条目点击回调
  const CharacterRankSliverList({
    super.key,
    required this.items,
    required this.selectedType,
    this.onItemBuilt,
    this.onCharacterTap,
  });

  /// 角色排序条目
  final List<CharacterRankEntry> items;

  /// 当前排序类型
  final CharacterRankSortType selectedType;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 角色条目点击回调
  final void Function(CharacterRankEntry item, String? avatarHeroTag)?
      onCharacterTap;

  /// 构建角色排序 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: _CharacterRankListMetrics.itemExtent,
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
          return _CharacterRankListItem(
            child: CharacterRankRow(
              item: item,
              selectedType: selectedType,
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

/// 角色排序骨架 sliver 列表
class CharacterRankSkeletonSliverList extends StatelessWidget {
  /// 创建角色排序骨架 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  const CharacterRankSkeletonSliverList({
    super.key,
    this.itemCount = 20,
  });

  /// 骨架条目数量
  final int itemCount;

  /// 构建角色排序骨架 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: _CharacterRankListMetrics.itemExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return const _CharacterRankListItem(
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

/// 角色排序行
class CharacterRankRow extends StatelessWidget {
  /// 创建角色排序行
  ///
  /// [key] Flutter 组件标识
  /// [item] 角色排序条目
  /// [selectedType] 当前排序类型
  /// [avatarHeroTag] 头像转场标识
  /// [onTap] 条目点击回调
  const CharacterRankRow({
    super.key,
    required this.item,
    required this.selectedType,
    this.avatarHeroTag,
    this.onTap,
  });

  /// 角色排序条目
  final CharacterRankEntry item;

  /// 当前排序类型
  final CharacterRankSortType selectedType;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 条目点击回调
  final VoidCallback? onTap;

  /// 构建角色排序行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
    final fluctuationColor =
        CharacterAssetCurrentPriceChip.resolveCurrentPriceColor(
      item.fluctuation,
    );

    return CharacterAssetRowShell(
      name: TinygrailFormatters.decodeHtmlEntities(item.name),
      avatarUrl: avatarUrl,
      avatarHeroTag: avatarHeroTag,
      level: item.level,
      zeroCount: item.zeroCount,
      metrics: [
        _buildPrimaryMetric(),
        CharacterAssetMetric(
          label: '涨跌',
          value: _formatFluctuation(item.fluctuation),
          isValueMuted: true,
          valueColor: fluctuationColor,
        ),
      ],
      trailing: CharacterAssetCurrentPriceChip(
        current: item.current,
        fluctuation: item.fluctuation,
      ),
      onTap: onTap,
    );
  }

  /// 构建排序主数据行
  CharacterAssetMetric _buildPrimaryMetric() {
    if (selectedType == CharacterRankSortType.highestMarketValue) {
      return CharacterAssetMetric(
        label: '市值',
        value: _formatMarketValue(item.marketValue),
        isValueMuted: true,
      );
    }

    return CharacterAssetMetric(
      label: '股息',
      value: '+${Formatters.tinygrailCurrency(item.rate)}',
      isValueMuted: true,
    );
  }

  /// 格式化市值文本
  ///
  /// [value] 市值
  String _formatMarketValue(double value) {
    if (value.abs() >= 10000) {
      return Formatters.tinygrailCompactValue(
        value.truncate(),
        prefix: '₵',
      );
    }

    return Formatters.tinygrailCurrency(value);
  }

  /// 格式化涨跌幅文本
  ///
  /// [value] 涨跌幅
  String _formatFluctuation(double value) {
    final percent = Formatters.groupedNumber(value * 100);
    if (value > 0) {
      return '+$percent%';
    }

    return '$percent%';
  }
}

class _CharacterRankCarouselBody extends StatelessWidget {
  /// 创建角色排序横向预览主体
  ///
  /// [items] 角色排序预览条目
  /// [isLoading] 是否正在加载
  /// [emptyMessage] 空状态文案
  /// [itemBuilder] 预览条目构建器
  const _CharacterRankCarouselBody({
    required this.items,
    required this.isLoading,
    required this.emptyMessage,
    required this.itemBuilder,
  });

  static const int _rowsPerColumn = 4;
  static const int _previewItemCount = 20;
  static const int _skeletonColumnCount = _previewItemCount ~/ _rowsPerColumn;

  final List<CharacterRankEntry>? items;
  final bool isLoading;
  final String emptyMessage;
  final Widget Function(BuildContext context, CharacterRankEntry item)
      itemBuilder;

  /// 构建角色排序横向预览主体
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
        final resolvedItems = items ?? <CharacterRankEntry>[];
        final showSkeleton = isLoading && resolvedItems.isEmpty;

        if (!showSkeleton && resolvedItems.isEmpty) {
          return Padding(
            padding: AppSafeAreaInsets.symmetricHorizontal(
              context,
              horizontal: 24,
            ),
            child: _CharacterRankInlineEmpty(message: emptyMessage),
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

  /// 构建横向预览分列数据
  ///
  /// [items] 角色排序条目
  List<List<CharacterRankEntry>> _buildColumns(List<CharacterRankEntry> items) {
    final previewItems = items.take(_previewItemCount).toList();
    final result = <List<CharacterRankEntry>>[];

    for (var start = 0; start < previewItems.length; start += _rowsPerColumn) {
      final end = math.min(start + _rowsPerColumn, previewItems.length);
      result.add(previewItems.sublist(start, end));
    }

    return result;
  }
}

class _CharacterRankInlineEmpty extends StatelessWidget {
  /// 创建角色排序预览空状态
  ///
  /// [message] 空状态文案
  const _CharacterRankInlineEmpty({
    required this.message,
  });

  final String message;

  /// 构建角色排序预览空状态
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

class _CharacterRankListItem extends StatelessWidget {
  /// 创建角色排序列表条目外层
  ///
  /// [child] 条目内容
  const _CharacterRankListItem({
    required this.child,
  });

  final Widget child;

  /// 构建角色排序列表条目外层
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

final class _CharacterRankListMetrics {
  /// 禁止创建角色排序列表尺寸实例
  const _CharacterRankListMetrics._();

  static const double itemExtent = 68;
}
