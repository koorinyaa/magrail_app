import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/widgets/snapping_horizontal_list_view.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_skeleton.dart';

/// 角色资产横向预览栏
class CharacterAssetPreviewCarousel<T> extends StatelessWidget {
  /// 创建角色资产横向预览栏
  ///
  /// [key] Flutter 组件标识
  /// [items] 角色预览条目
  /// [isLoading] 是否正在加载
  /// [emptyMessage] 空状态文案
  /// [itemBuilder] 条目构建器
  /// [skeletonTrailingWidth] 右侧骨架宽度
  /// [skeletonTrailingHeight] 右侧骨架高度
  const CharacterAssetPreviewCarousel({
    super.key,
    required this.items,
    required this.isLoading,
    required this.emptyMessage,
    required this.itemBuilder,
    this.skeletonTrailingWidth = 54,
    this.skeletonTrailingHeight = 18,
  });

  // 一级页固定预览 24 条，按每列 4 条呈现为 6 列
  static const int _rowsPerColumn = 4;
  static const int _previewItemCount = 24;
  static const int _skeletonColumnCount = _previewItemCount ~/ _rowsPerColumn;

  /// 角色预览条目
  final List<T>? items;

  /// 是否正在加载
  final bool isLoading;

  /// 空状态文案
  final String emptyMessage;

  /// 条目构建器
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// 右侧骨架宽度
  final double skeletonTrailingWidth;

  /// 右侧骨架高度
  final double skeletonTrailingHeight;

  /// 构建角色资产横向预览栏
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
        final resolvedItems = items ?? <T>[];
        final showSkeleton = isLoading && resolvedItems.isEmpty;

        if (!showSkeleton && resolvedItems.isEmpty) {
          return Padding(
            padding: AppSafeAreaInsets.symmetricHorizontal(
              context,
              horizontal: 24,
            ),
            child: _CharacterAssetPreviewEmpty(message: emptyMessage),
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
                        CharacterAssetRowSkeleton(
                          showTrailing: true,
                          trailingWidth: skeletonTrailingWidth,
                          trailingHeight: skeletonTrailingHeight,
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
  /// [items] 角色预览条目
  List<List<T>> _buildColumns(List<T> items) {
    final previewItems = items.take(_previewItemCount).toList();
    final result = <List<T>>[];

    for (var start = 0; start < previewItems.length; start += _rowsPerColumn) {
      final end = math.min(start + _rowsPerColumn, previewItems.length);
      result.add(previewItems.sublist(start, end));
    }

    return result;
  }
}

/// 角色资产横向预览空状态
class _CharacterAssetPreviewEmpty extends StatelessWidget {
  /// 创建角色资产横向预览空状态
  ///
  /// [message] 空状态文案
  const _CharacterAssetPreviewEmpty({
    required this.message,
  });

  final String message;

  /// 构建角色资产横向预览空状态
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
