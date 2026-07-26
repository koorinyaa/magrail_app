import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/search/widgets/character_search_input_bar.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_skeleton_sliver_list.dart';
import 'package:magrail_app/features/user/assets/controller/user_asset_snapshot_coordinator.dart';
import 'package:magrail_app/features/user/assets/model/user_character_snapshot_query.dart';
import 'package:magrail_app/features/user/controller/user_character_snapshot_page_controller.dart';
import 'package:magrail_app/features/user/controller/other_user_character_page_controller.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_asset_sliver_lists.dart';
import 'package:magrail_app/features/user/widgets/user_asset_level_sliver_controller.dart';
import 'package:magrail_app/features/user/widgets/user_character_level_virtual_sliver.dart';
import 'package:magrail_app/features/user/widgets/user_character_level_rail.dart';
import 'package:magrail_app/features/user/widgets/user_character_sort_toolbar.dart';
import 'package:magrail_app/features/user/widgets/user_private_asset_visibility_button.dart';

part 'user_character_page_search.dart';
part 'user_character_page_snapshot.dart';
part 'user_character_page_actions.dart';

/// 用户角色二级页面
class UserCharacterPage extends StatefulWidget {
  /// 创建用户角色二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 用户仓库
  /// [snapshotCoordinator] 用户资产快照全局协调器
  /// [characterDetailRepository] 角色详情仓库
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [currentUserName] 当前登录用户名
  /// [characterTotalItems] 用户页预览返回的角色总数
  /// [initiallyHideHoldings] 是否初始隐藏持股数量
  /// [revealPrivateUserHoldings] 是否允许查询其他用户未公开持股
  const UserCharacterPage({
    super.key,
    required this.repository,
    required this.snapshotCoordinator,
    required this.characterDetailRepository,
    required this.username,
    this.nickname,
    this.currentUserName = '',
    this.characterTotalItems,
    this.initiallyHideHoldings = false,
    this.revealPrivateUserHoldings = false,
  });

  /// 用户仓库
  final UserRepository repository;

  /// 用户资产快照全局协调器
  final UserAssetSnapshotCoordinator snapshotCoordinator;

  /// 角色详情仓库
  final CharacterDetailRepository characterDetailRepository;

  /// 用户名
  final String username;

  /// 用户昵称
  final String? nickname;

  /// 当前登录用户名
  final String currentUserName;

  /// 用户页预览返回的角色总数
  final int? characterTotalItems;

  /// 是否初始隐藏持股数量
  final bool initiallyHideHoldings;

  /// 是否允许查询其他用户未公开持股
  final bool revealPrivateUserHoldings;

  /// 创建用户角色二级页面状态
  @override
  State<UserCharacterPage> createState() => _UserCharacterPageState();
}

/// 用户角色二级页面状态
class _UserCharacterPageState extends State<UserCharacterPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final UserAssetLevelSliverController _levelSliverController =
      UserAssetLevelSliverController();
  late TinygrailPagedListController<UserCharacterApiItem, UserCharacterApiItem>
      _controller;
  UserCharacterSnapshotPageController? _snapshotController;
  OtherUserCharacterPageController? _backendController;
  bool _isLoadingPreviousPage = false;
  bool _isProgrammaticLevelJump = false;
  int _levelJumpGeneration = 0;
  int _scrollAdjustmentGeneration = 0;
  Completer<void>? _scrollIdleCompleter;
  VoidCallback? _scrollIdleListener;
  ValueNotifier<bool>? _scrollIdleNotifier;
  Timer? _searchDebounce;
  bool _isAwaitingSnapshot = false;
  late bool _hideHoldings;

  /// 初始化用户角色二级页面状态
  @override
  void initState() {
    super.initState();
    _hideHoldings = widget.initiallyHideHoldings;
    final backendController = OtherUserCharacterPageController(
      repository: widget.repository,
      username: widget.username,
    );
    _backendController = backendController;
    _controller = backendController;
    if (!_isCurrentUser) {
      widget.snapshotCoordinator.retainOtherUser(widget.username);
    }
    widget.snapshotCoordinator.addListener(_handleSnapshotCoordinatorChanged);
    _scrollController.addListener(_handleScroll);
    _controller.initialize();
    unawaited(_prepareSnapshotMode());
  }

  /// 释放用户角色二级页面状态
  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    final scrollIdleListener = _scrollIdleListener;
    final scrollIdleNotifier = _scrollIdleNotifier;
    if (scrollIdleListener != null && scrollIdleNotifier != null) {
      scrollIdleNotifier.removeListener(scrollIdleListener);
    }
    _scrollIdleListener = null;
    _scrollIdleNotifier = null;
    _scrollIdleCompleter?.complete();
    _scrollIdleCompleter = null;
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _levelSliverController.dispose();
    widget.snapshotCoordinator.removeListener(
      _handleSnapshotCoordinatorChanged,
    );
    if (!_isCurrentUser) {
      widget.snapshotCoordinator.releaseOtherUser(widget.username);
    }
    _snapshotController?.dispose();
    _backendController?.dispose();
    super.dispose();
  }

  /// 构建用户角色二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final currentController = _snapshotController;
    final onRevealHoldings = !_isCurrentUser && widget.revealPrivateUserHoldings
        ? _revealCharacterHoldings
        : null;
    final page = TinygrailPagedSliverPage(
      controller: _controller,
      title: _title,
      appBarActions: [
        UserPrivateAssetVisibilityButton(
          isHidden: _hideHoldings,
          onPressed: _toggleHoldingsVisibility,
        ),
      ],
      appBarBottom: currentController == null
          ? null
          : UserCharacterSortToolbar(
              controller: currentController,
              isCurrentUser: _isCurrentUser,
              onSortSelected: (sort) {
                unawaited(_selectSort(sort));
              },
            ),
      scrollController: _scrollController,
      loadingSliver: const CharacterAssetSkeletonSliverList(
        showTrailing: true,
        titleMetricSpacing: 4,
        metricSpacing: 4,
        primaryMetricAsPill: true,
      ),
      emptySliverBuilder: (context, controller) {
        final isFiltering =
            currentController?.searchKeyword.isNotEmpty ?? false;
        return PagedSliverState(
          title: isFiltering ? '未找到角色' : '暂无角色',
          message: isFiltering ? '没有符合搜索条件的角色' : '该用户没有可展示的角色',
          icon: isFiltering
              ? Icons.search_off_rounded
              : Icons.hourglass_empty_rounded,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        if (currentController?.usesVirtualLevelList ?? false) {
          return [
            UserCharacterLevelVirtualSliver(
              controller: currentController!,
              scrollController: _scrollController,
              levelSliverController: _levelSliverController,
              hideHoldings: _hideHoldings,
              onRevealHoldings: onRevealHoldings,
              onCharacterTap: _openCharacterDetail,
            ),
          ];
        }
        return [
          UserCharacterAssetSliverList(
            items: items,
            sort:
                _snapshotController?.sort ?? UserCharacterSnapshotSort.holdings,
            showLevelHeaders:
                _snapshotController?.sort == UserCharacterSnapshotSort.level,
            hideHoldings: _hideHoldings,
            onRevealHoldings: onRevealHoldings,
            onItemBuilt: onItemBuilt,
            onCharacterTap: _openCharacterDetail,
          ),
        ];
      },
      completedLabel: '没有更多角色了',
      showPaginationFooter: () =>
          !(currentController?.usesVirtualLevelList ?? false),
      bottomContentPadding:
          currentController == null ? 24 : CharacterSearchInputBar.height + 48,
    );
    if (currentController == null) {
      return page;
    }
    return ListenableBuilder(
      listenable: currentController,
      child: page,
      builder: (context, child) {
        final showLevelRail =
            currentController.sort == UserCharacterSnapshotSort.level &&
                currentController.levelPositions.isNotEmpty &&
                !currentController.isInitialLoading &&
                currentController.items.isNotEmpty;
        final mediaPadding = MediaQuery.paddingOf(context);
        final viewInsets = MediaQuery.viewInsetsOf(context);
        final bottomInset =
            viewInsets.bottom > 0 ? viewInsets.bottom : mediaPadding.bottom;
        final railAreaTop = mediaPadding.top +
            SecondaryPageSliverAppBar.defaultToolbarHeight +
            UserCharacterSortToolbar.toolbarHeight +
            8;
        final railAreaBottom =
            bottomInset + CharacterSearchInputBar.height + 26;
        final availableRailHeight =
            (MediaQuery.sizeOf(context).height - railAreaTop - railAreaBottom)
                .clamp(0.0, double.infinity);
        final railHeight = (currentController.levelPositions.length *
                UserCharacterLevelRail.itemExtent)
            .clamp(0.0, availableRailHeight);
        final railTop = railAreaTop + (availableRailHeight - railHeight) / 2;
        return Stack(
          children: [
            child!,
            if (showLevelRail && railHeight > 0)
              Positioned(
                top: railTop,
                right: mediaPadding.right,
                height: railHeight,
                width: 24,
                child: UserCharacterLevelRail(
                  positions: currentController.levelPositions,
                  onLevelSelected: (level) {
                    unawaited(_jumpToLevel(level));
                  },
                ),
              ),
            // 等级索引显隐会改变 Stack 子节点位置，固定 Key 保持输入焦点
            Positioned(
              key: const ValueKey<String>('user-character-search-bar'),
              left: mediaPadding.left + 20,
              right: mediaPadding.right + 20,
              bottom: bottomInset + 14,
              child: TextFieldTapRegion(
                child: CharacterSearchInputBar(
                  controller: _searchController,
                  placeholder: '搜索角色 ID 或名称',
                  onChanged: _handleCharacterSearchChanged,
                  onSubmitted: _submitCharacterSearch,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 提交角色快照模式切换后的页面重建
  void _rebuildAfterSnapshotActivation() {
    setState(() {});
  }

  /// 切换持股数量显示状态
  void _toggleHoldingsVisibility() {
    setState(() {
      _hideHoldings = !_hideHoldings;
    });
  }

  /// 切换角色排序并回到列表顶部
  ///
  /// [sort] 目标排序字段
  Future<void> _selectSort(UserCharacterSnapshotSort sort) async {
    final controller = _snapshotController;
    if (controller == null) {
      return;
    }
    final adjustmentGeneration = ++_scrollAdjustmentGeneration;
    _levelJumpGeneration += 1;
    _isProgrammaticLevelJump = false;
    _isLoadingPreviousPage = false;
    _levelSliverController.reset();
    final success = await controller.selectSort(sort);
    if (!mounted || adjustmentGeneration != _scrollAdjustmentGeneration) {
      return;
    }
    if (!success) {
      _restoreCharacterSearchInput();
      AppToast.error(context, text: '排序失败，请重试');
      return;
    }
    _scrollToTopAfterLayout();
  }

  /// 跳转到指定角色等级
  ///
  /// [level] 目标角色等级
  Future<void> _jumpToLevel(int level) async {
    final generation = ++_levelJumpGeneration;
    _scrollAdjustmentGeneration += 1;
    _isLoadingPreviousPage = false;
    _isProgrammaticLevelJump = true;
    int? absoluteIndex;
    try {
      absoluteIndex = await _snapshotController?.prepareLevelJump(level);
    } catch (_) {
      if (mounted && generation == _levelJumpGeneration) {
        _isProgrammaticLevelJump = false;
        AppToast.error(context, text: '等级跳转失败，请重试');
      }
      return;
    }
    if (!mounted || generation != _levelJumpGeneration) {
      return;
    }
    if (absoluteIndex == null) {
      _isProgrammaticLevelJump = false;
      AppToast.error(context, text: '等级跳转失败，请重试');
      return;
    }
    _levelSliverController.jumpToLevel(
      level,
      _scrollController,
    );
    _isProgrammaticLevelJump = false;
  }

  /// 读取当前视口顶部角色在当前排序中的下标
  int? _readVisibleCharacterIndex() {
    final controller = _snapshotController;
    if (!mounted ||
        controller == null ||
        !_scrollController.hasClients ||
        controller.items.isEmpty) {
      return null;
    }
    if (controller.usesVirtualLevelList) {
      return _levelSliverController.visibleAbsoluteIndex;
    }
    final listOffset =
        _scrollController.offset.clamp(0.0, double.infinity).toDouble();
    final itemIndex = UserCharacterAssetSliverList.itemIndexAtListOffset(
      controller.items,
      listOffset,
      showLevelHeaders: controller.sort == UserCharacterSnapshotSort.level,
    );
    if (itemIndex == null) {
      return null;
    }
    return itemIndex;
  }

  /// 等待角色列表拖动和惯性滚动结束
  Future<void> _waitForScrollIdle() {
    if (!_scrollController.hasClients) {
      return Future<void>.value();
    }
    final scrollingNotifier = _scrollController.position.isScrollingNotifier;
    if (!scrollingNotifier.value) {
      return Future<void>.value();
    }
    final existingCompleter = _scrollIdleCompleter;
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
      _scrollIdleListener = null;
      _scrollIdleNotifier = null;
      _scrollIdleCompleter = null;
      if (!completer.isCompleted) {
        completer.complete();
      }
    };
    _scrollIdleCompleter = completer;
    _scrollIdleListener = listener;
    _scrollIdleNotifier = scrollingNotifier;
    scrollingNotifier.addListener(listener);
    listener();
    return completer.future;
  }

  /// 在分页替换前恢复当前数据位置
  ///
  /// [previousItemIndex] 旧分页窗口中的可视条目下标
  /// [replacementItemIndex] 新分页窗口中的目标条目下标
  /// [replacementItems] 即将提交的角色条目
  void _restoreVisibleCharacterPosition(
    int previousItemIndex,
    int replacementItemIndex,
    List<UserCharacterApiItem> replacementItems,
  ) {
    final controller = _snapshotController;
    if (!mounted ||
        controller == null ||
        !_scrollController.hasClients ||
        controller.items.isEmpty ||
        replacementItems.isEmpty) {
      return;
    }
    // 使分页加载完成后尚未执行的旧滚动校正失效
    _scrollAdjustmentGeneration += 1;
    _isLoadingPreviousPage = true;
    try {
      // 本地分页读取期间仍允许滚动，提交前以最新可视下标为准
      final currentItemIndex =
          _readVisibleCharacterIndex() ?? previousItemIndex;
      final replacementIndexOffset = replacementItemIndex - previousItemIndex;
      final oldIndex =
          currentItemIndex.clamp(0, controller.items.length - 1).toInt();
      final newIndex = (currentItemIndex + replacementIndexOffset)
          .clamp(0, replacementItems.length - 1)
          .toInt();
      final showLevelHeaders =
          controller.sort == UserCharacterSnapshotSort.level;
      final oldItemOffset = UserCharacterAssetSliverList.itemOffsetForIndex(
        controller.items,
        oldIndex,
        showLevelHeaders: showLevelHeaders,
      );
      final newItemOffset = UserCharacterAssetSliverList.itemOffsetForIndex(
        replacementItems,
        newIndex,
        showLevelHeaders: showLevelHeaders,
      );
      final position = _scrollController.position;
      final correctedPixels = (position.pixels + newItemOffset - oldItemOffset)
          .clamp(position.minScrollExtent, double.infinity)
          .toDouble();
      // 在分页状态提交前直接修正像素，避免先闪现新位置再滚回锚点
      _scrollController.jumpTo(position.pixels);
      position.correctPixels(correctedPixels);
    } finally {
      _isLoadingPreviousPage = false;
    }
  }

  /// 在等级快照刷新后恢复顶部角色
  ///
  /// [absoluteIndex] 新快照中的角色绝对下标
  void _restoreCharacterLevelAnchor(int absoluteIndex) {
    if (!mounted) {
      return;
    }
    _levelSliverController.restoreAfterNextLayout(absoluteIndex);
  }

  /// 监听列表顶部并按需加载目标页前一页
  void _handleScroll() {
    final controller = _snapshotController;
    if (controller == null ||
        controller.usesVirtualLevelList ||
        _isProgrammaticLevelJump ||
        _isLoadingPreviousPage ||
        !_scrollController.hasClients ||
        _scrollController.offset >
            UserCharacterAssetSliverList.itemExtent / 2 ||
        !controller.canLoadPreviousPage) {
      return;
    }
    _isLoadingPreviousPage = true;
    unawaited(_loadPreviousPage(controller));
  }

  /// 加载目标窗口前一页并保持当前条目位置
  ///
  /// [controller] 用户角色快照控制器
  Future<void> _loadPreviousPage(
    UserCharacterSnapshotPageController controller,
  ) async {
    final showLevelHeaders = controller.sort == UserCharacterSnapshotSort.level;
    final previousListExtent = UserCharacterAssetSliverList.listExtent(
      controller.items,
      showLevelHeaders: showLevelHeaders,
    );
    final adjustmentGeneration = _scrollAdjustmentGeneration;
    late final int count;
    try {
      count = await controller.loadPreviousPage(
        beforeItemsPrepended: (items) {
          if (!mounted ||
              adjustmentGeneration != _scrollAdjustmentGeneration ||
              !_scrollController.hasClients) {
            return;
          }
          final currentListExtent = UserCharacterAssetSliverList.listExtent(
            items,
            showLevelHeaders: showLevelHeaders,
          );
          final position = _scrollController.position;
          // 在分页状态提交前校正像素，避免先闪现前一页再滚回锚点
          _scrollController.jumpTo(position.pixels);
          position.correctPixels(
            position.pixels + currentListExtent - previousListExtent,
          );
        },
      );
    } catch (_) {
      _isLoadingPreviousPage = false;
      if (mounted) {
        AppToast.error(context, text: '加载上一页失败，请重试');
      }
      return;
    }
    if (!mounted || count <= 0) {
      _isLoadingPreviousPage = false;
      return;
    }
    if (adjustmentGeneration == _scrollAdjustmentGeneration) {
      _isLoadingPreviousPage = false;
    }
  }

  /// 在布局更新后回到角色列表顶部
  void _scrollToTopAfterLayout() {
    final adjustmentGeneration = _scrollAdjustmentGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          adjustmentGeneration == _scrollAdjustmentGeneration &&
          _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }
}
