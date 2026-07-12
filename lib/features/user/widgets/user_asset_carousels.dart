import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/widgets/snapping_horizontal_list_view.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_ico_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_rows.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_skeleton.dart';

/// 用户角色资产横向栏
class UserCharacterAssetCarousel extends StatelessWidget {
  /// 创建用户角色资产横向栏
  ///
  /// [key] Flutter 组件标识
  /// [characters] 用户角色预览
  /// [isLoading] 是否正在加载
  /// [onCharacterTap] 角色条目点击回调
  const UserCharacterAssetCarousel({
    super.key,
    required this.characters,
    required this.isLoading,
    this.onCharacterTap,
  });

  /// 用户角色预览
  final List<UserCharacterApiItem>? characters;

  /// 是否正在加载
  final bool isLoading;

  /// 角色条目点击回调
  final void Function(UserCharacterApiItem item, String? avatarHeroTag)?
      onCharacterTap;

  /// 构建用户角色资产横向栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _UserAssetCarousel<UserCharacterApiItem>(
      items: characters,
      isLoading: isLoading,
      emptyMessage: '暂无角色',
      skeletonMetricCount: 2,
      showTrailingSkeleton: true,
      itemBuilder: (context, item) {
        final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
        final avatarHeroTag = createCharacterDetailAvatarHeroTag(
          characterId: item.characterId,
          avatarUrl: avatarUrl,
          source: item,
        );

        return UserCharacterAssetRow(
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

/// 用户 ICO 资产横向栏
class UserIcoAssetCarousel extends StatelessWidget {
  /// 创建用户 ICO 资产横向栏
  ///
  /// [key] Flutter 组件标识
  /// [icos] 用户 ICO 预览
  /// [isLoading] 是否正在加载
  /// [onIcoTap] ICO 条目点击回调
  const UserIcoAssetCarousel({
    super.key,
    required this.icos,
    required this.isLoading,
    this.onIcoTap,
  });

  /// 用户 ICO 预览
  final List<UserIcoApiItem>? icos;

  /// 是否正在加载
  final bool isLoading;

  /// ICO 条目点击回调
  final void Function(UserIcoApiItem item, String? avatarHeroTag)? onIcoTap;

  /// 构建用户 ICO 资产横向栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _UserAssetCarousel<UserIcoApiItem>(
      items: icos,
      isLoading: isLoading,
      emptyMessage: '暂无ICO',
      showLevelSkeleton: false,
      skeletonMetricCount: 2,
      showTrailingSkeleton: true,
      itemBuilder: (context, item) {
        final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
        final avatarHeroTag = createCharacterDetailAvatarHeroTag(
          characterId: item.characterId,
          avatarUrl: avatarUrl,
          source: item,
        );

        return UserIcoAssetRow(
          item: item,
          avatarHeroTag: avatarHeroTag,
          onTap: onIcoTap == null
              ? null
              : () => onIcoTap?.call(item, avatarHeroTag),
        );
      },
    );
  }
}

/// 用户角色资产横向栏
class _UserAssetCarousel<T> extends StatelessWidget {
  /// 创建用户资产横向栏
  ///
  /// [items] 用户角色资产预览
  /// [isLoading] 是否正在加载
  /// [emptyMessage] 空状态文案
  /// [itemBuilder] 条目构建器
  /// [showLevelSkeleton] 是否显示等级骨架
  /// [skeletonMetricCount] 数据项骨架数量
  /// [showTrailingSkeleton] 是否显示右侧胶囊骨架
  const _UserAssetCarousel({
    required this.items,
    required this.isLoading,
    required this.emptyMessage,
    required this.itemBuilder,
    this.showLevelSkeleton = true,
    this.skeletonMetricCount = 2,
    this.showTrailingSkeleton = false,
  });

  // 预览接口每次取 24 条，按每列 4 条呈现为 6 列
  static const int _rowsPerColumn = 4;
  static const int _previewItemCount = 24;
  static const int _skeletonColumnCount = _previewItemCount ~/ _rowsPerColumn;

  /// 用户角色资产预览
  final List<T>? items;

  /// 是否正在加载
  final bool isLoading;

  /// 空状态文案
  final String emptyMessage;

  /// 条目构建器
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// 是否显示等级骨架
  final bool showLevelSkeleton;

  /// 数据项骨架数量
  final int skeletonMetricCount;

  /// 是否显示右侧胶囊骨架
  final bool showTrailingSkeleton;

  /// 构建用户角色资产横向栏
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
            child: _UserAssetInlineEmpty(message: emptyMessage),
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
                          showLevel: showLevelSkeleton,
                          metricCount: skeletonMetricCount,
                          showTrailing: showTrailingSkeleton,
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

  /// 按列拆分用户角色资产条目
  ///
  /// [items] 用户角色资产条目
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

/// 用户角色资产行内空状态
class _UserAssetInlineEmpty extends StatelessWidget {
  /// 创建用户资产行内空状态
  ///
  /// [message] 空状态文案
  const _UserAssetInlineEmpty({
    required this.message,
  });

  /// 空状态文案
  final String message;

  /// 构建用户角色资产行内空状态
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
