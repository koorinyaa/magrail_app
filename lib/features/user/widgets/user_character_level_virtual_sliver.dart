import 'package:flutter/material.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_skeleton.dart';
import 'package:magrail_app/features/user/assets/model/user_asset_level_layout.dart';
import 'package:magrail_app/features/user/assets/model/user_character_snapshot_query.dart';
import 'package:magrail_app/features/user/controller/user_character_snapshot_page_controller.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_level_sliver_controller.dart';
import 'package:magrail_app/features/user/widgets/user_asset_sliver_lists.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

/// 用户角色等级虚拟列表
class UserCharacterLevelVirtualSliver extends StatelessWidget {
  /// 创建用户角色等级虚拟列表
  ///
  /// [key] Flutter 组件标识
  /// [controller] 用户角色快照页面控制器
  /// [scrollController] 页面滚动控制器
  /// [levelSliverController] 等级虚拟列表滚动控制器
  /// [onCharacterTap] 角色条目点击回调
  const UserCharacterLevelVirtualSliver({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.levelSliverController,
    this.onCharacterTap,
  });

  /// 用户角色快照页面控制器
  final UserCharacterSnapshotPageController controller;

  /// 页面滚动控制器
  final ScrollController scrollController;

  /// 等级虚拟列表滚动控制器
  final UserAssetLevelSliverController levelSliverController;

  /// 角色条目点击回调
  final void Function(UserCharacterApiItem item, String? avatarHeroTag)?
      onCharacterTap;

  /// 构建用户角色等级虚拟列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final layout = UserAssetLevelLayout(
      groups: controller.levelGroups,
      crossAxisCount: 1,
      version: controller.levelLayoutVersion,
    );
    levelSliverController.updateLayout(layout, scrollController);
    return SuperSliverList.builder(
      listController: levelSliverController.listController,
      itemCount: layout.virtualItemCount,
      extentEstimation: (index, crossAxisExtent) {
        if (index == null) {
          return UserCharacterAssetSliverList.itemExtent;
        }
        return layout.entryAt(index)?.isHeader ?? false
            ? UserCharacterAssetSliverList.levelHeaderExtent
            : UserCharacterAssetSliverList.itemExtent;
      },
      itemBuilder: (context, virtualIndex) {
        final entry = layout.entryAt(virtualIndex);
        if (entry == null) {
          return const SizedBox.shrink();
        }
        if (entry.isHeader) {
          return UserCharacterLevelHeader(level: entry.level);
        }
        final absoluteIndex = entry.firstAbsoluteIndex;
        final item = controller.levelItemAt(absoluteIndex);
        controller.handleLevelItemBuilt(absoluteIndex);
        if (item == null) {
          return const SizedBox(
            height: UserCharacterAssetSliverList.itemExtent,
            child: CharacterAssetRowSkeleton(
              showTrailing: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 18),
            ),
          );
        }
        return UserCharacterAssetListItem(
          key: ValueKey<int>(item.characterId),
          item: item,
          sort: UserCharacterSnapshotSort.level,
          reserveLevelRail: true,
          showDivider: absoluteIndex + 1 < controller.levelItemCount,
          onCharacterTap: onCharacterTap,
        );
      },
    );
  }
}
