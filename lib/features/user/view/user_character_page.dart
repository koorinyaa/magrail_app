import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_skeleton_sliver_list.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_database.dart';
import 'package:magrail_app/features/user/assets/model/user_character_snapshot_query.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_repository.dart';
import 'package:magrail_app/features/user/controller/current_user_character_page_controller.dart';
import 'package:magrail_app/features/user/controller/other_user_character_page_controller.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_chara_asset_sliver_list.dart';
import 'package:magrail_app/features/user/widgets/user_character_level_rail.dart';
import 'package:magrail_app/features/user/widgets/user_character_sort_toolbar.dart';

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
  late final TinygrailPagedListController<UserCharacterApiItem,
      UserCharacterApiItem> _controller;
  UserAssetSnapshotDatabase? _snapshotDatabase;
  CurrentUserCharacterPageController? _currentUserController;
  bool _isLoadingPreviousPage = false;
  bool _isProgrammaticLevelJump = false;
  int _levelJumpGeneration = 0;
  int _scrollAdjustmentGeneration = 0;

  /// 初始化用户角色二级页面状态
  @override
  void initState() {
    super.initState();
    if (_isCurrentUser) {
      final database = UserAssetSnapshotDatabase();
      _snapshotDatabase = database;
      final controller = CurrentUserCharacterPageController(
        snapshotRepository: UserAssetSnapshotRepository(
          userRepository: widget.repository,
          characterDetailRepository: widget.characterDetailRepository,
          database: database,
        ),
        username: widget.username,
        nickname: widget.nickname ?? '',
        onAutomaticRefreshFailed: _showAutomaticRefreshFailed,
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
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _controller.dispose();
    unawaited(_closeSnapshotDatabase());
    super.dispose();
  }

  /// 构建用户角色二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final page = TinygrailPagedSliverPage(
      controller: _controller,
      title: _title,
      appBarBottom: _currentUserController == null
          ? null
          : UserCharacterSortToolbar(
              controller: _currentUserController!,
              onSortSelected: (sort) {
                unawaited(_selectSort(sort));
              },
            ),
      scrollController: _scrollController,
      loadingSliver: const CharacterAssetSkeletonSliverList(
        showTrailing: true,
      ),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无角色',
          message: '当前用户没有可展示的角色',
          icon: Icons.hourglass_empty_rounded,
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
    );
    final currentController = _currentUserController;
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
        final railAreaTop = mediaPadding.top +
            SecondaryPageSliverAppBar.defaultToolbarHeight +
            UserCharacterSortToolbar.toolbarHeight +
            8;
        final railAreaBottom = mediaPadding.bottom + 12;
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
    final previousOffset = _scrollController.offset;
    final previousListExtent =
        UserCharacterAssetSliverList.levelListExtent(controller.items);
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
    final currentListExtent =
        UserCharacterAssetSliverList.levelListExtent(controller.items);
    final prependedExtent = currentListExtent - previousListExtent;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          adjustmentGeneration == _scrollAdjustmentGeneration &&
          _scrollController.hasClients) {
        _scrollController.jumpTo(
          previousOffset + prependedExtent,
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

  /// 显示当前用户角色后台刷新失败提示
  void _showAutomaticRefreshFailed() {
    if (!mounted) {
      return;
    }
    AppToast.error(
      context,
      text: '角色数据刷新失败',
    );
  }

  /// 等待当前用户角色任务结束后关闭数据库
  Future<void> _closeSnapshotDatabase() async {
    final database = _snapshotDatabase;
    if (database == null) {
      return;
    }
    await _currentUserController?.waitForPendingOperations();
    try {
      await database.close();
    } catch (_) {
      // 页面销毁阶段不再展示数据库关闭错误
    }
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
