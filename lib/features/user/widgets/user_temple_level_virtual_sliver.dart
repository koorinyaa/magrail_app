import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/user/assets/model/user_asset_level_layout.dart';
import 'package:magrail_app/features/user/controller/user_temple_snapshot_page_controller.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_level_sliver_controller.dart';
import 'package:magrail_app/features/user/widgets/user_temple_card.dart';
import 'package:magrail_app/features/user/widgets/user_temple_responsive_grid.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

/// 用户圣殿等级虚拟网格
class UserTempleLevelVirtualSliver extends StatelessWidget {
  /// 创建用户圣殿等级虚拟网格
  ///
  /// [key] Flutter 组件标识
  /// [controller] 用户圣殿快照页面控制器
  /// [scrollController] 页面滚动控制器
  /// [levelSliverController] 等级虚拟列表滚动控制器
  /// [ownerLabel] 用户展示文案
  /// [onCharacterTap] 角色区域点击回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const UserTempleLevelVirtualSliver({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.levelSliverController,
    required this.ownerLabel,
    this.onCharacterTap,
    this.onAssetTap,
  });

  /// 用户圣殿快照页面控制器
  final UserTempleSnapshotPageController controller;

  /// 页面滚动控制器
  final ScrollController scrollController;

  /// 等级虚拟列表滚动控制器
  final UserAssetLevelSliverController levelSliverController;

  /// 用户展示文案
  final String ownerLabel;

  /// 角色区域点击回调
  final ValueChanged<UserTempleApiItem>? onCharacterTap;

  /// 圣殿资产入口点击回调
  final ValueChanged<UserTempleApiItem>? onAssetTap;

  /// 构建用户圣殿等级虚拟网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final metrics = UserTempleResponsiveGrid.resolveMetrics(
          constraints.crossAxisExtent,
          AppSafeAreaInsets.horizontalSum(context),
          rightContentInset: UserTempleResponsiveGrid.levelRailReservedWidth,
        );
        final layout = UserAssetLevelLayout(
          groups: controller.levelGroups,
          crossAxisCount: metrics.crossAxisCount,
          version: controller.levelLayoutVersion,
        );
        levelSliverController.updateLayout(layout, scrollController);
        return SliverPadding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: UserTempleResponsiveGrid.horizontalPadding,
            top: UserTempleResponsiveGrid.topPadding,
            right:
                UserTempleResponsiveGrid.horizontalPadding +
                UserTempleResponsiveGrid.levelRailReservedWidth,
            bottom: 0,
          ),
          sliver: SuperSliverList.builder(
            listController: levelSliverController.listController,
            itemCount: layout.virtualItemCount,
            extentEstimation: (index, crossAxisExtent) {
              if (index == null) {
                return metrics.cardHeight +
                    UserTempleResponsiveGrid.mainAxisSpacing;
              }
              final entry = layout.entryAt(index);
              if (entry == null || entry.isHeader) {
                return UserTempleResponsiveGrid.levelHeaderExtent;
              }
              return metrics.cardHeight +
                  (entry.isLastRow
                      ? 0
                      : UserTempleResponsiveGrid.mainAxisSpacing);
            },
            itemBuilder: (context, virtualIndex) {
              final entry = layout.entryAt(virtualIndex);
              if (entry == null) {
                return const SizedBox.shrink();
              }
              if (entry.isHeader) {
                return UserTempleLevelHeader(level: entry.level);
              }
              return _TempleLevelRow(
                entry: entry,
                metrics: metrics,
                controller: controller,
                ownerLabel: ownerLabel,
                onCharacterTap: onCharacterTap,
                onAssetTap: onAssetTap,
              );
            },
          ),
        );
      },
    );
  }
}

/// 用户圣殿等级虚拟网格行
class _TempleLevelRow extends StatelessWidget {
  /// 创建用户圣殿等级虚拟网格行
  ///
  /// [entry] 当前虚拟布局行
  /// [metrics] 当前网格尺寸
  /// [controller] 用户圣殿快照页面控制器
  /// [ownerLabel] 用户展示文案
  /// [onCharacterTap] 角色区域点击回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const _TempleLevelRow({
    required this.entry,
    required this.metrics,
    required this.controller,
    required this.ownerLabel,
    required this.onCharacterTap,
    required this.onAssetTap,
  });

  /// 当前虚拟布局行
  final UserAssetLevelLayoutEntry entry;

  /// 当前网格尺寸
  final UserTempleGridMetrics metrics;

  /// 用户圣殿快照页面控制器
  final UserTempleSnapshotPageController controller;

  /// 用户展示文案
  final String ownerLabel;

  /// 角色区域点击回调
  final ValueChanged<UserTempleApiItem>? onCharacterTap;

  /// 圣殿资产入口点击回调
  final ValueChanged<UserTempleApiItem>? onAssetTap;

  /// 构建用户圣殿等级虚拟网格行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: entry.isLastRow ? 0 : UserTempleResponsiveGrid.mainAxisSpacing,
      ),
      child: SizedBox(
        height: metrics.cardHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var column = 0; column < entry.itemCount; column += 1) ...[
              if (column > 0)
                const SizedBox(
                  width: UserTempleResponsiveGrid.crossAxisSpacing,
                ),
              _buildCard(entry.firstAbsoluteIndex + column),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建指定绝对位置的圣殿卡片
  ///
  /// [absoluteIndex] 当前排序下的绝对条目下标
  Widget _buildCard(int absoluteIndex) {
    final entry = controller.levelItemAt(absoluteIndex);
    controller.handleLevelItemBuilt(absoluteIndex);
    if (entry == null) {
      return SizedBox(
        width: metrics.cardWidth,
        height: metrics.cardHeight,
        child: const UserTempleCardSkeleton(),
      );
    }
    final item = entry.item;
    return UserTempleCard(
      key: ValueKey<int>(item.id),
      item: item,
      ownerLabel: ownerLabel,
      width: metrics.cardWidth,
      heroTagPrefix: 'user-temple-level-cover-$absoluteIndex',
      onCharacterTap: onCharacterTap,
      onAssetTap: onAssetTap,
    );
  }
}
