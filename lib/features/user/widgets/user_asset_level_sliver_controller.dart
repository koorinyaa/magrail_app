import 'package:flutter/material.dart';
import 'package:magrail_app/features/user/assets/model/user_asset_level_layout.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

/// 用户资产等级虚拟列表滚动控制器
class UserAssetLevelSliverController {
  /// 创建用户资产等级虚拟列表滚动控制器
  UserAssetLevelSliverController();

  /// 虚拟列表索引控制器
  final ListController listController = ListController();

  UserAssetLevelLayout? _layout;
  int? _pendingRestoreAbsoluteIndex;
  int _restoreGeneration = 0;

  /// 当前虚拟布局
  UserAssetLevelLayout? get layout => _layout;

  /// 更新当前屏幕对应的虚拟布局并保持顶部资产位置
  ///
  /// [layout] 当前宽度与快照对应的虚拟布局
  /// [scrollController] 页面滚动控制器
  void updateLayout(
    UserAssetLevelLayout layout,
    ScrollController scrollController,
  ) {
    final previousLayout = _layout;
    if (previousLayout != null && previousLayout.hasSameMapping(layout)) {
      return;
    }
    final anchorAbsoluteIndex =
        _pendingRestoreAbsoluteIndex ??
        (listController.isAttached && previousLayout != null
            ? _visibleAbsoluteIndex(previousLayout)
            : null);
    _pendingRestoreAbsoluteIndex = null;
    _layout = layout;
    if (anchorAbsoluteIndex != null) {
      restoreAbsoluteIndex(anchorAbsoluteIndex, scrollController);
    }
  }

  /// 读取当前可视区域顶部资产的绝对下标
  int? get visibleAbsoluteIndex {
    final layout = _layout;
    if (!listController.isAttached || layout == null) {
      return null;
    }
    return _visibleAbsoluteIndex(layout);
  }

  /// 跳转到指定绝对条目位置
  ///
  /// [absoluteIndex] 当前排序下的绝对条目下标
  /// [scrollController] 页面滚动控制器
  void jumpToAbsoluteIndex(
    int absoluteIndex,
    ScrollController scrollController,
  ) {
    final layout = _layout;
    final virtualIndex = layout?.virtualIndexForAbsoluteIndex(absoluteIndex);
    if (!listController.isAttached ||
        virtualIndex == null ||
        !scrollController.hasClients) {
      return;
    }
    _restoreGeneration += 1;
    listController.jumpToItem(
      index: virtualIndex,
      scrollController: scrollController,
      alignment: 0,
    );
  }

  /// 跳转到指定等级标题
  ///
  /// [level] 目标角色等级
  /// [scrollController] 页面滚动控制器
  void jumpToLevel(int level, ScrollController scrollController) {
    final virtualIndex = _layout?.virtualIndexForLevel(level);
    if (!listController.isAttached ||
        virtualIndex == null ||
        !scrollController.hasClients) {
      return;
    }
    _restoreGeneration += 1;
    listController.jumpToItem(
      index: virtualIndex,
      scrollController: scrollController,
      alignment: 0,
    );
  }

  /// 在布局完成后恢复指定绝对条目位置
  ///
  /// [absoluteIndex] 当前排序下的绝对条目下标
  /// [scrollController] 页面滚动控制器
  void restoreAbsoluteIndex(
    int absoluteIndex,
    ScrollController scrollController,
  ) {
    final generation = ++_restoreGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (generation != _restoreGeneration) {
        return;
      }
      jumpToAbsoluteIndex(absoluteIndex, scrollController);
    });
  }

  /// 在下一次布局映射更新后恢复指定资产位置
  ///
  /// [absoluteIndex] 新快照中的绝对条目下标
  void restoreAfterNextLayout(int absoluteIndex) {
    _restoreGeneration += 1;
    _pendingRestoreAbsoluteIndex = absoluteIndex;
  }

  /// 重置布局切换锚点
  void reset() {
    _restoreGeneration += 1;
    _layout = null;
    _pendingRestoreAbsoluteIndex = null;
  }

  /// 释放虚拟列表滚动控制器
  void dispose() {
    listController.dispose();
  }

  /// 根据指定布局读取当前可视资产绝对下标
  ///
  /// [layout] 当前虚拟布局
  int? _visibleAbsoluteIndex(UserAssetLevelLayout layout) {
    final range =
        listController.unobstructedVisibleRange ?? listController.visibleRange;
    if (range == null) {
      return null;
    }
    return layout.entryAt(range.$1)?.firstAbsoluteIndex;
  }
}
