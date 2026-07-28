import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:magrail_app/features/chara/controller/character_full_list_page_controller.dart';
import 'package:magrail_app/features/chara/model/character_full_list_sort.dart';
import 'package:magrail_app/features/chara/search/widgets/character_search_input_bar.dart';
import 'package:magrail_app/features/chara/widgets/character_full_list_level_rail.dart';
import 'package:magrail_app/features/chara/widgets/character_full_list_sort_toolbar.dart';
import 'package:magrail_app/features/chara/widgets/character_level_grouped_sliver_list.dart';

// 角色筛选输入防抖，避免每次输入都立即重排完整列表
const Duration _characterFullListSearchDebounceDelay =
    Duration(milliseconds: 450);

/// 角色全量列表二级页面交互
mixin CharacterFullListPageStateMixin<ItemType,
    WidgetType extends StatefulWidget> on State<WidgetType> {
  /// 当前页面角色全量列表控制器
  CharacterFullListPageController<ItemType> get fullListController;

  /// 页面滚动控制器
  @protected
  final ScrollController fullListScrollController = ScrollController();

  /// 底部搜索输入控制器
  @protected
  final TextEditingController fullListSearchController =
      TextEditingController();

  Timer? _fullListSearchDebounce;
  int _fullListScrollAdjustmentGeneration = 0;
  Completer<void>? _fullListScrollIdleCompleter;
  VoidCallback? _fullListScrollIdleListener;
  ValueNotifier<bool>? _fullListScrollIdleNotifier;

  /// 全量模式下的页面底部留白
  @protected
  double get fullListBottomContentPadding =>
      fullListController.hasFullData ? CharacterSearchInputBar.height + 48 : 24;

  /// 释放角色全量列表页面交互
  @protected
  void disposeFullListPageState() {
    _fullListSearchDebounce?.cancel();
    final scrollIdleListener = _fullListScrollIdleListener;
    final scrollIdleNotifier = _fullListScrollIdleNotifier;
    if (scrollIdleListener != null && scrollIdleNotifier != null) {
      scrollIdleNotifier.removeListener(scrollIdleListener);
    }
    _fullListScrollIdleListener = null;
    _fullListScrollIdleNotifier = null;
    final scrollIdleCompleter = _fullListScrollIdleCompleter;
    if (scrollIdleCompleter != null && !scrollIdleCompleter.isCompleted) {
      scrollIdleCompleter.complete();
    }
    _fullListScrollIdleCompleter = null;
    fullListSearchController.dispose();
    fullListScrollController.dispose();
  }

  /// 等待全量列表拖动和惯性滚动结束
  @protected
  Future<void> waitForFullListScrollIdle() {
    if (!fullListScrollController.hasClients) {
      return Future<void>.value();
    }
    final scrollingNotifier =
        fullListScrollController.position.isScrollingNotifier;
    if (!scrollingNotifier.value) {
      return Future<void>.value();
    }
    final existingCompleter = _fullListScrollIdleCompleter;
    if (existingCompleter != null) {
      return existingCompleter.future;
    }

    final completer = Completer<void>();
    late final VoidCallback listener;
    listener = () {
      if (scrollingNotifier.value) {
        return;
      }
      scrollingNotifier.removeListener(listener);
      _fullListScrollIdleListener = null;
      _fullListScrollIdleNotifier = null;
      _fullListScrollIdleCompleter = null;
      if (!completer.isCompleted) {
        completer.complete();
      }
    };
    _fullListScrollIdleCompleter = completer;
    _fullListScrollIdleListener = listener;
    _fullListScrollIdleNotifier = scrollingNotifier;
    scrollingNotifier.addListener(listener);
    listener();
    return completer.future;
  }

  /// 构建角色全量列表排序工具栏
  @protected
  PreferredSizeWidget? buildFullListSortToolbar() {
    if (!fullListController.hasFullData) {
      return null;
    }
    return CharacterFullListSortToolbar(
      options: fullListController.availableSorts,
      selectedSort: fullListController.sort,
      direction: fullListController.direction,
      onSortSelected: (sort) {
        unawaited(selectFullListSort(sort));
      },
    );
  }

  /// 在页面上叠加等级轨道与底部搜索栏
  ///
  /// [child] 分页页面主体
  @protected
  Widget buildFullListOverlay({required Widget child}) {
    if (!fullListController.hasFullData) {
      return child;
    }
    final showLevelRail = fullListController.showsLevelHeaders &&
        fullListController.levelPositions.isNotEmpty &&
        fullListController.items.isNotEmpty;
    final mediaPadding = MediaQuery.paddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final bottomInset =
        viewInsets.bottom > 0 ? viewInsets.bottom : mediaPadding.bottom;
    final railAreaTop = mediaPadding.top +
        SecondaryPageSliverAppBar.defaultToolbarHeight +
        CharacterFullListSortToolbar.toolbarHeight +
        8;
    final railAreaBottom = bottomInset + CharacterSearchInputBar.height + 26;
    final availableRailHeight =
        (MediaQuery.sizeOf(context).height - railAreaTop - railAreaBottom)
            .clamp(0.0, double.infinity);
    final railHeight = (fullListController.levelPositions.length *
            CharacterFullListLevelRail.itemExtent)
        .clamp(0.0, availableRailHeight);
    final railTop = railAreaTop + (availableRailHeight - railHeight) / 2;

    return Stack(
      children: [
        child,
        if (showLevelRail && railHeight > 0)
          Positioned(
            top: railTop,
            right: mediaPadding.right,
            height: railHeight,
            width: 24,
            child: CharacterFullListLevelRail(
              positions: fullListController.levelPositions,
              onLevelSelected: jumpToFullListLevel,
            ),
          ),
        Positioned(
          key: ValueKey<Object>(fullListController),
          left: mediaPadding.left + 20,
          right: mediaPadding.right + 20,
          bottom: bottomInset + 14,
          child: TextFieldTapRegion(
            child: CharacterSearchInputBar(
              controller: fullListSearchController,
              placeholder: '搜索角色 ID 或名称',
              onChanged: handleFullListSearchChanged,
              onSubmitted: submitFullListSearch,
            ),
          ),
        ),
      ],
    );
  }

  /// 切换角色全量列表排序并回到顶部
  ///
  /// [sort] 目标排序字段
  @protected
  Future<void> selectFullListSort(CharacterFullListSort sort) async {
    _fullListScrollAdjustmentGeneration += 1;
    final success = await fullListController.selectSort(sort);
    if (!mounted) {
      return;
    }
    if (!success) {
      AppToast.error(context, text: '排序失败，请重试');
      return;
    }
    scrollFullListToTopAfterLayout();
  }

  /// 处理角色筛选输入变化
  ///
  /// [keyword] 角色 ID 或名称筛选词
  @protected
  void handleFullListSearchChanged(String keyword) {
    _fullListSearchDebounce?.cancel();
    _fullListSearchDebounce = Timer(_characterFullListSearchDebounceDelay, () {
      unawaited(_applyFullListSearch(keyword));
    });
  }

  /// 提交角色筛选输入
  ///
  /// [keyword] 角色 ID 或名称筛选词
  @protected
  void submitFullListSearch(String keyword) {
    _fullListSearchDebounce?.cancel();
    unawaited(_applyFullListSearch(keyword));
  }

  /// 跳转到指定角色等级标题
  ///
  /// [level] 目标角色等级
  @protected
  void jumpToFullListLevel(int level) {
    if (!fullListScrollController.hasClients ||
        !fullListController.showsLevelHeaders) {
      return;
    }
    CharacterFullListLevelPosition? targetPosition;
    for (final position in fullListController.levelPositions) {
      if (position.level == level) {
        targetPosition = position;
        break;
      }
    }
    if (targetPosition == null) {
      return;
    }
    _fullListScrollAdjustmentGeneration += 1;
    final position = fullListScrollController.position;
    final offset = CharacterLevelListMetrics.levelHeaderOffsetForIndex(
      fullListController.items,
      targetPosition.itemIndex,
      levelOf: fullListController.characterLevelOf,
    );
    fullListScrollController.jumpTo(
      offset.clamp(position.minScrollExtent, position.maxScrollExtent),
    );
  }

  /// 在全量数据替换后保持当前可视角色位置
  ///
  /// [previousItems] 替换前正在展示的角色
  /// [replacementItems] 即将展示的新角色
  /// [previousHasLevelHeaders] 替换前是否包含等级标题
  /// [replacementHasLevelHeaders] 替换后是否包含等级标题
  @protected
  void preserveFullListVisibleItem(
    List<ItemType> previousItems,
    List<ItemType> replacementItems, {
    required bool previousHasLevelHeaders,
    required bool replacementHasLevelHeaders,
  }) {
    if (!mounted ||
        !fullListScrollController.hasClients ||
        previousItems.isEmpty ||
        replacementItems.isEmpty) {
      return;
    }
    final oldPixels = fullListScrollController.offset;
    final oldIndex = CharacterLevelListMetrics.itemIndexAtOffset(
      previousItems,
      oldPixels,
      showLevelHeaders: previousHasLevelHeaders,
      levelOf: fullListController.characterLevelOf,
    );
    if (oldIndex == null) {
      return;
    }
    final oldItemOffset = CharacterLevelListMetrics.itemOffsetForIndex(
      previousItems,
      oldIndex,
      showLevelHeaders: previousHasLevelHeaders,
      levelOf: fullListController.characterLevelOf,
    );
    final oldCharacterId =
        fullListController.characterIdOf(previousItems[oldIndex]);
    var newIndex = replacementItems.indexWhere(
      (item) => fullListController.characterIdOf(item) == oldCharacterId,
    );
    if (newIndex < 0) {
      final ratio = previousItems.length <= 1
          ? 0.0
          : oldIndex / (previousItems.length - 1);
      newIndex = (ratio * (replacementItems.length - 1))
          .round()
          .clamp(0, replacementItems.length - 1);
    }
    final newItemOffset = CharacterLevelListMetrics.itemOffsetForIndex(
      replacementItems,
      newIndex,
      showLevelHeaders: replacementHasLevelHeaders,
      levelOf: fullListController.characterLevelOf,
    );
    final generation = ++_fullListScrollAdjustmentGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          generation != _fullListScrollAdjustmentGeneration ||
          !fullListScrollController.hasClients) {
        return;
      }
      final position = fullListScrollController.position;
      final correctedPixels = (oldPixels + newItemOffset - oldItemOffset)
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble();
      fullListScrollController.jumpTo(correctedPixels);
    });
  }

  /// 显示角色全量数据刷新成功提示
  @protected
  void showFullListRefreshSucceeded() {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) {
      return;
    }
    AppToast.info(context, text: '数据刷新成功');
  }

  /// 显示角色全量数据刷新失败提示
  @protected
  void showFullListRefreshFailed() {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) {
      return;
    }
    AppToast.error(context, text: '数据刷新失败');
  }

  /// 应用角色筛选并回到列表顶部
  ///
  /// [keyword] 角色 ID 或名称筛选词
  Future<void> _applyFullListSearch(String keyword) async {
    _fullListScrollAdjustmentGeneration += 1;
    final success = await fullListController.applySearchFilter(keyword);
    if (!mounted) {
      return;
    }
    if (!success) {
      _restoreFullListSearchInput();
      AppToast.error(context, text: '搜索失败，请重试');
      return;
    }
    scrollFullListToTopAfterLayout();
  }

  /// 恢复控制器已提交的角色筛选词
  void _restoreFullListSearchInput() {
    final keyword = fullListController.searchKeyword;
    fullListSearchController.value = TextEditingValue(
      text: keyword,
      selection: TextSelection.collapsed(offset: keyword.length),
    );
  }

  /// 在列表布局完成后回到顶部
  @protected
  void scrollFullListToTopAfterLayout() {
    final generation = ++_fullListScrollAdjustmentGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          generation != _fullListScrollAdjustmentGeneration ||
          !fullListScrollController.hasClients) {
        return;
      }
      fullListScrollController.jumpTo(
        fullListScrollController.position.minScrollExtent,
      );
    });
  }
}
