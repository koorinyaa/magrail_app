import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/snapping_horizontal_list_view.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/tower/model/tower_entry.dart';
import 'package:magrail_app/features/chara/tower/widgets/tower_ranking_row.dart';
import 'package:magrail_app/features/chara/tower/widgets/tower_ranking_skeleton_row.dart';

/// 通天塔横向栏卡
class TowerRankingCarousel extends StatelessWidget {
  /// 创建通天塔横向栏卡
  ///
  /// [entries] 通天塔条目
  /// [isLoading] 是否正在加载
  /// [isLoadFailed] 是否加载失败
  /// [onRetry] 重试回调
  /// [onEntryTap] 条目点击回调
  const TowerRankingCarousel({
    super.key,
    required this.entries,
    required this.isLoading,
    required this.isLoadFailed,
    required this.onRetry,
    this.onEntryTap,
  });

  static const int _rowsPerColumn = 4;

  /// 通天塔条目
  final List<TowerEntry>? entries;

  /// 是否正在加载
  final bool isLoading;

  /// 是否加载失败
  final bool isLoadFailed;

  /// 重试回调
  final Future<void> Function() onRetry;

  /// 条目点击回调
  final void Function(TowerEntry entry, String? avatarHeroTag)? onEntryTap;

  /// 构建通天塔横向栏卡
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
        final showSkeleton = isLoading && (entries == null || entries!.isEmpty);

        if (isLoadFailed &&
            !showSkeleton &&
            (entries == null || entries!.isEmpty)) {
          return Padding(
            padding: AppSafeAreaInsets.symmetricHorizontal(
              context,
              horizontal: 24,
            ),
            child: _TowerRankingErrorState(
              onRetry: onRetry,
            ),
          );
        }

        if (!showSkeleton && entries != null && entries!.isEmpty) {
          return Padding(
            padding: AppSafeAreaInsets.symmetricHorizontal(
              context,
              horizontal: 24,
            ),
            child: const _TowerRankingEmptyState(),
          );
        }

        final columns = _buildColumns(_rowsPerColumn);
        final columnCount = showSkeleton ? 2 : columns.length;

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
                        const TowerRankingSkeletonRow(),
                        if (row != _rowsPerColumn - 1)
                          const SizedBox(height: 4),
                      ],
                    ]
                  : [
                      for (var row = 0; row < columns[index].length; row++) ...[
                        _buildEntryRow(columns[index][row]),
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

  /// 构建通天塔角色条目
  ///
  /// [entry] 通天塔条目
  Widget _buildEntryRow(TowerEntry entry) {
    final avatarHeroTag = createCharacterDetailAvatarHeroTag(
      characterId: entry.characterId,
      avatarUrl: entry.avatarUrl,
      source: entry,
    );

    return TowerRankingRow(
      entry: entry,
      avatarHeroTag: avatarHeroTag,
      onTap: onEntryTap == null || entry.characterId <= 0
          ? null
          : () => onEntryTap!(entry, avatarHeroTag),
    );
  }

  /// 按列拆分通天塔条目
  ///
  /// [rowsPerColumn] 每列显示行数
  List<List<TowerEntry>> _buildColumns(int rowsPerColumn) {
    final resolvedEntries = entries ?? const <TowerEntry>[];
    final result = <List<TowerEntry>>[];

    for (var start = 0;
        start < resolvedEntries.length;
        start += rowsPerColumn) {
      final end = math.min(start + rowsPerColumn, resolvedEntries.length);
      result.add(resolvedEntries.sublist(start, end));
    }

    return result;
  }
}

/// 首页通天塔加载失败状态
class _TowerRankingErrorState extends StatelessWidget {
  /// 创建首页通天塔加载失败状态
  ///
  /// [onRetry] 重试回调
  const _TowerRankingErrorState({
    required this.onRetry,
  });

  /// 重试回调
  final Future<void> Function() onRetry;

  /// 构建首页通天塔加载失败状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 268,
      child: Center(
        child: AppLoadFailedState(
          message: '请检查网络后重试',
          onActionPressed: onRetry,
        ),
      ),
    );
  }
}

/// 通天塔空状态
class _TowerRankingEmptyState extends StatelessWidget {
  /// 创建通天塔空状态
  const _TowerRankingEmptyState();

  /// 构建通天塔空状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 268,
      child: Center(
        child: Text(
          '暂无通天塔数据',
          textAlign: TextAlign.center,
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
