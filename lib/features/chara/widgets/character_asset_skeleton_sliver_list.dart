import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_skeleton.dart';

/// 角色资产 sliver 骨架列表
class CharacterAssetSkeletonSliverList extends StatelessWidget {
  /// 创建角色资产 sliver 骨架列表
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  /// [showLevel] 是否显示等级骨架
  /// [metricCount] 数据项骨架数量
  /// [showTrailing] 是否显示右侧胶囊骨架
  /// [trailingWidth] 右侧骨架宽度
  /// [trailingHeight] 右侧骨架高度
  /// [itemHorizontalPadding] 条目外层水平间距
  /// [contentPadding] 骨架内容内边距
  const CharacterAssetSkeletonSliverList({
    super.key,
    this.itemCount = 24,
    this.showLevel = true,
    this.metricCount = 2,
    this.showTrailing = false,
    this.trailingWidth = 54,
    this.trailingHeight = 18,
    this.itemHorizontalPadding = 12,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 6),
  });

  /// 骨架条目数量
  final int itemCount;

  /// 是否显示等级骨架
  final bool showLevel;

  /// 数据项骨架数量
  final int metricCount;

  /// 是否显示右侧胶囊骨架
  final bool showTrailing;

  /// 右侧骨架宽度
  final double trailingWidth;

  /// 右侧骨架高度
  final double trailingHeight;

  /// 条目外层水平间距
  final double itemHorizontalPadding;

  /// 骨架内容内边距
  final EdgeInsetsGeometry contentPadding;

  /// 构建角色资产 sliver 骨架列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: _CharacterAssetSkeletonSliverListMetrics.itemExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _CharacterAssetSkeletonListItem(
            horizontalPadding: itemHorizontalPadding,
            child: CharacterAssetRowSkeleton(
              showLevel: showLevel,
              metricCount: metricCount,
              showTrailing: showTrailing,
              trailingWidth: trailingWidth,
              trailingHeight: trailingHeight,
              contentPadding: contentPadding,
            ),
          );
        },
        childCount: itemCount,
      ),
    );
  }
}

/// 角色资产骨架列表条目外层
class _CharacterAssetSkeletonListItem extends StatelessWidget {
  /// 创建角色资产骨架列表条目外层
  ///
  /// [child] 条目主体
  /// [horizontalPadding] 水平间距
  const _CharacterAssetSkeletonListItem({
    required this.child,
    this.horizontalPadding = 12,
  });

  /// 条目主体
  final Widget child;

  /// 水平间距
  final double horizontalPadding;

  /// 构建角色资产骨架列表条目外层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: horizontalPadding,
        top: 0,
        right: horizontalPadding,
        bottom: 4,
      ),
      child: child,
    );
  }
}

/// 角色资产骨架 sliver 列表尺寸
final class _CharacterAssetSkeletonSliverListMetrics {
  /// 禁止创建角色资产骨架 sliver 列表尺寸实例
  const _CharacterAssetSkeletonSliverListMetrics._();

  /// 列表条目高度
  static const double itemExtent = 68;
}
