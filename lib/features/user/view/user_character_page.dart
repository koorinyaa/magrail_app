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
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_database.dart';
import 'package:magrail_app/features/user/assets/model/user_character_snapshot_query.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_repository.dart';
import 'package:magrail_app/features/user/controller/current_user_character_page_controller.dart';
import 'package:magrail_app/features/user/controller/other_user_character_page_controller.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_asset_sliver_lists.dart';
import 'package:magrail_app/features/user/widgets/user_character_level_rail.dart';
import 'package:magrail_app/features/user/widgets/user_character_sort_toolbar.dart';

part 'user_character_page_search.dart';

/// 用户角色二级页面
class UserCharacterPage extends StatefulWidget {
  /// 创建用户角色二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 用户仓库
  /// [characterDetailRepository] 角色详情仓库
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [currentUserName] 当前登录用户名
  const UserCharacterPage({
    super.key,
    required this.repository,
    required this.characterDetailRepository,
    required this.username,
    this.nickname,
    this.currentUserName = '',
  });

  /// 用户仓库
  final UserRepository repository;

  /// 角色详情仓库
  final CharacterDetailRepository characterDetailRepository;

  /// 用户名
  final String username;

  /// 用户昵称
  final String? nickname;

  /// 当前登录用户名
  final String currentUserName;

  /// 创建用户角色二级页面状态
  @override
  State<UserCharacterPage> createState() => _UserCharacterPageState();
}

/// 用户角色二级页面状态
class _UserCharacterPageState extends State<UserCharacterPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late final TinygrailPagedListController<UserCharacterApiItem,
      UserCharacterApiItem> _controller;
  CurrentUserCharacterPageController? _currentUserController;
  bool _isLoadingPreviousPage = false;
  bool _isProgrammaticLevelJump = false;
  int _levelJumpGeneration = 0;
  int _scrollAdjustmentGeneration = 0;
  Completer<void>? _scrollIdleCompleter;
  VoidCallback? _scrollIdleListener;
  ValueNotifier<bool>? _scrollIdleNotifier;
  Timer? _searchDebounce;

  /// 初始化用户角色二级页面状态
  @override
  void initState() {
    super.initState();
    if (_isCurrentUser) {
      final database = UserAssetSnapshotDatabase();
      final controller = CurrentUserCharacterPageController(
        snapshotRepository: UserAssetSnapshotRepository(
          userRepository: widget.repository,
          characterDetailRepository: widget.characterDetailRepository,
          database: database,
        ),
        username: widget.username,
        nickname: widget.nickname ?? '',
        onAutomaticRefreshSucceeded: _showAutomaticRefreshSucceeded,
        onAutomaticRefreshFailed: _showAutomaticRefreshFailed,
        readVisibleCharacterIndex: _readVisibleCharacterIndex,
        waitForScrollIdle: _waitForScrollIdle,
        onBeforeCharacterDataReplaced: _restoreVisibleCharacterPosition,
      );
      _currentUserController = controller;
      _controller = controller;
    } else {
      _controller = OtherUserCharacterPageController(
        repository: widget.repository,
        username: widget.username,
      );
    }
    _scrollController.addListener(_handleScroll);
    _controller.initialize();
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
    _controller.dispose();
    super.dispose();
  }

  /// 构建用户角色二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final currentController = _currentUserController;
    final page = TinygrailPagedSliverPage(
      controller: _controller,
      title: _title,
      appBarBottom: currentController == null
          ? null
          : UserCharacterSortToolbar(
              controller: currentController,
              onSortSelected: (sort) {
                unawaited(_selectSort(sort));
              },
            ),
      scrollController: _scrollController,
      loadingSliver: const CharacterAssetSkeletonSliverList(
        showTrailing: true,
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
        return [
          UserCharacterAssetSliverList(
            items: items,
            sort: _currentUserController?.sort ??
                UserCharacterSnapshotSort.holdings,
            showLevelHeaders:
                _currentUserController?.sort == UserCharacterSnapshotSort.level,
            onItemBuilt: onItemBuilt,
            onCharacterTap: _openCharacterDetail,
          ),
        ];
      },
      completedLabel: '没有更多角色了',
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

  /// 切换角色排序并回到列表顶部
  ///
  /// [sort] 目标排序字段
  Future<void> _selectSort(UserCharacterSnapshotSort sort) async {
    final controller = _currentUserController;
    if (controller == null) {
      return;
    }
    final adjustmentGeneration = ++_scrollAdjustmentGeneration;
    _isLoadingPreviousPage = false;
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
    bool success;
    try {
      success = await _currentUserController?.jumpToLevel(
            level,
            beforeItemsReplaced: (itemIndex, items) {
              if (!mounted ||
                  generation != _levelJumpGeneration ||
                  !_scrollController.hasClients) {
                return;
              }
              final position = _scrollController.position;
              // 先停止旧列表滚动，再静默校正像素，使新窗口首帧直接位于目标等级
              _scrollController.jumpTo(position.pixels);
              position.correctPixels(
                UserCharacterAssetSliverList.levelGroupOffsetForItem(
                  items,
                  itemIndex,
                ),
              );
            },
          ) ??
          false;
    } catch (_) {
      if (mounted && generation == _levelJumpGeneration) {
        _isProgrammaticLevelJump = false;
        AppToast.error(context, text: '等级跳转失败，请重试');
      }
      return;
    }
    if (!mounted || !success || generation != _levelJumpGeneration) {
      if (generation == _levelJumpGeneration) {
        _isProgrammaticLevelJump = false;
      }
      return;
    }
    _isProgrammaticLevelJump = false;
  }

  /// 读取当前视口顶部角色在本地分页窗口中的下标
  int? _readVisibleCharacterIndex() {
    final controller = _currentUserController;
    if (!mounted ||
        controller == null ||
        !_scrollController.hasClients ||
        controller.items.isEmpty) {
      return null;
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
    final controller = _currentUserController;
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

  /// 监听列表顶部并按需加载目标页前一页
  void _handleScroll() {
    final controller = _currentUserController;
    if (controller == null ||
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
  /// [controller] 当前用户角色控制器
  Future<void> _loadPreviousPage(
    CurrentUserCharacterPageController controller,
  ) async {
    final showLevelHeaders = controller.sort == UserCharacterSnapshotSort.level;
    final previousListExtent = UserCharacterAssetSliverList.listExtent(
      controller.items,
      showLevelHeaders: showLevelHeaders,
    );
    final adjustmentGeneration = _scrollAdjustmentGeneration;
    late final int count;
    try {
      count = await controller.loadPreviousPage();
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
    final currentListExtent = UserCharacterAssetSliverList.listExtent(
      controller.items,
      showLevelHeaders: showLevelHeaders,
    );
    final prependedExtent = currentListExtent - previousListExtent;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          adjustmentGeneration == _scrollAdjustmentGeneration &&
          _scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.offset + prependedExtent,
        );
      }
      if (adjustmentGeneration == _scrollAdjustmentGeneration) {
        _isLoadingPreviousPage = false;
      }
    });
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

  /// 打开角色详情页
  ///
  /// [item] 用户角色条目
  /// [avatarHeroTag] 入口头像转场标识
  void _openCharacterDetail(
    UserCharacterApiItem item,
    String? avatarHeroTag,
  ) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.name,
      avatarUrl: item.icon,
      avatarHeroTag: avatarHeroTag,
    );
  }

  /// 显示当前用户角色后台刷新成功提示
  void _showAutomaticRefreshSucceeded() {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) {
      return;
    }
    AppToast.info(
      context,
      text: '角色数据刷新成功',
    );
  }

  /// 显示当前用户角色后台刷新失败提示
  void _showAutomaticRefreshFailed() {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) {
      return;
    }
    AppToast.error(
      context,
      text: '角色数据刷新失败',
    );
  }

  /// 是否展示当前登录用户的本地角色快照
  bool get _isCurrentUser {
    final username = widget.username.trim().toLowerCase();
    final currentUserName = widget.currentUserName.trim().toLowerCase();
    return username.isNotEmpty && username == currentUserName;
  }

  /// 页面标题
  String get _title {
    final nickname = widget.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return '$nickname的角色';
    }
    if (widget.username.isNotEmpty) {
      return '${widget.username}的角色';
    }
    return '用户角色';
  }
}
