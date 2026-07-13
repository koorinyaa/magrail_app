import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/search/widgets/character_search_input_bar.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_dialog.dart';
import 'package:magrail_app/features/user/assets/model/user_character_snapshot_query.dart';
import 'package:magrail_app/features/user/assets/model/user_temple_snapshot_query.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_database.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_repository.dart';
import 'package:magrail_app/features/user/controller/current_user_temple_page_controller.dart';
import 'package:magrail_app/features/user/controller/user_temple_page_controller.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_character_level_rail.dart';
import 'package:magrail_app/features/user/widgets/user_temple_card.dart';
import 'package:magrail_app/features/user/widgets/user_temple_responsive_grid.dart';
import 'package:magrail_app/features/user/widgets/user_temple_sort_toolbar.dart';

part 'user_temple_page_scroll.dart';
part 'user_temple_page_search.dart';

/// 用户圣殿二级页面
class UserTemplePage extends StatefulWidget {
  /// 创建用户圣殿二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 用户仓库
  /// [characterDetailRepository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [templeAssetMagicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [currentUserName] 当前登录用户名
  const UserTemplePage({
    super.key,
    required this.repository,
    required this.characterDetailRepository,
    required this.templeRepository,
    required this.templeAssetMagicRepository,
    required this.oosRepository,
    required this.username,
    this.nickname,
    this.currentUserName = '',
  });

  /// 用户仓库
  final UserRepository repository;

  /// 角色详情仓库
  final CharacterDetailRepository characterDetailRepository;

  /// 圣殿仓库
  final TempleRepository templeRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository templeAssetMagicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 用户名
  final String username;

  /// 用户昵称
  final String? nickname;

  /// 当前登录用户名
  final String currentUserName;

  /// 创建用户圣殿二级页面状态
  @override
  State<UserTemplePage> createState() => _UserTemplePageState();
}

/// 用户圣殿二级页面状态
class _UserTemplePageState extends State<UserTemplePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  UserTemplePageController? _otherUserController;
  CurrentUserTemplePageController? _currentUserController;
  bool _isLoadingPreviousPage = false;
  bool _isProgrammaticLevelJump = false;
  int _levelJumpGeneration = 0;
  int _scrollAdjustmentGeneration = 0;
  Completer<void>? _scrollIdleCompleter;
  VoidCallback? _scrollIdleListener;
  ValueNotifier<bool>? _scrollIdleNotifier;
  Timer? _searchDebounce;

  /// 初始化用户圣殿二级页面状态
  @override
  void initState() {
    super.initState();
    if (_isCurrentUser) {
      final controller = CurrentUserTemplePageController(
        snapshotRepository: UserAssetSnapshotRepository(
          userRepository: widget.repository,
          database: UserAssetSnapshotDatabase(),
        ),
        username: widget.username,
        nickname: widget.nickname ?? '',
        onAutomaticRefreshSucceeded: _showAutomaticRefreshSucceeded,
        onAutomaticRefreshFailed: _showAutomaticRefreshFailed,
        readVisibleTempleIndex: _readVisibleTempleIndex,
        waitForScrollIdle: _waitForScrollIdle,
        onBeforeTempleDataReplaced: _restoreVisibleTemplePosition,
      );
      _currentUserController = controller;
      controller.initialize();
    } else {
      final controller = UserTemplePageController(
        repository: widget.repository,
        username: widget.username,
      );
      _otherUserController = controller;
      controller.initialize();
    }
    _scrollController.addListener(_handleScroll);
  }

  /// 释放用户圣殿二级页面状态
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
    _currentUserController?.dispose();
    _otherUserController?.dispose();
    super.dispose();
  }

  /// 构建用户圣殿二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final currentController = _currentUserController;
    if (currentController != null) {
      return _buildCurrentUserPage(currentController);
    }
    return _buildOtherUserPage(_otherUserController!);
  }

  /// 构建其他用户圣殿页面
  ///
  /// [controller] 其他用户圣殿分页控制器
  Widget _buildOtherUserPage(UserTemplePageController controller) {
    return TinygrailPagedSliverPage<UserTempleApiItem, UserTempleApiItem>(
      controller: controller,
      title: _title,
      loadingSliver: const UserTempleSkeletonGrid(),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无圣殿',
          message: '当前用户没有可展示的圣殿',
          icon: Icons.hourglass_empty_rounded,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          UserTempleResponsiveGrid(
            items: items,
            ownerLabel: _ownerLabel,
            onItemBuilt: onItemBuilt,
            onCharacterTap: _openCharacterDetail,
            onAssetTap: _openTempleAssetDialog,
          ),
        ];
      },
      completedLabel: '没有更多圣殿了',
    );
  }

  /// 构建当前用户圣殿页面
  ///
  /// [controller] 当前用户圣殿分页控制器
  Widget _buildCurrentUserPage(CurrentUserTemplePageController controller) {
    final page = TinygrailPagedSliverPage<UserTempleSnapshotEntry,
        UserTempleSnapshotEntry>(
      controller: controller,
      title: _title,
      appBarBottom: UserTempleSortToolbar(
        controller: controller,
        onSortSelected: (sort) {
          unawaited(_selectSort(sort));
        },
      ),
      scrollController: _scrollController,
      loadingSliver: const UserTempleSkeletonGrid(),
      emptySliverBuilder: (context, pagedController) {
        final isFiltering = controller.searchKeyword.isNotEmpty;
        return PagedSliverState(
          title: isFiltering ? '未找到圣殿' : '暂无圣殿',
          message: isFiltering ? '没有符合搜索条件的圣殿' : '当前用户没有可展示的圣殿',
          icon: isFiltering
              ? Icons.search_off_rounded
              : Icons.hourglass_empty_rounded,
        );
      },
      contentSliversBuilder: (context, entries, onItemBuilt) {
        final items = [for (final entry in entries) entry.item];
        final showLevelHeaders =
            controller.sort == UserTempleSnapshotSort.characterLevel;
        return [
          UserTempleResponsiveGrid(
            items: items,
            ownerLabel: _ownerLabel,
            showLevelHeaders: showLevelHeaders,
            rightContentInset: showLevelHeaders
                ? UserTempleResponsiveGrid.levelRailReservedWidth
                : 0,
            sortValues: _buildSortValues(entries, controller.sort),
            onItemBuilt: onItemBuilt,
            onCharacterTap: _openCharacterDetail,
            onAssetTap: _openTempleAssetDialog,
          ),
        ];
      },
      completedLabel: '没有更多圣殿了',
      bottomContentPadding: CharacterSearchInputBar.height + 48,
    );
    return ListenableBuilder(
      listenable: controller,
      child: page,
      builder: (context, child) {
        final showLevelRail =
            controller.sort == UserTempleSnapshotSort.characterLevel &&
                controller.levelPositions.isNotEmpty &&
                !controller.isInitialLoading &&
                controller.items.isNotEmpty;
        final mediaPadding = MediaQuery.paddingOf(context);
        final viewInsets = MediaQuery.viewInsetsOf(context);
        final bottomInset =
            viewInsets.bottom > 0 ? viewInsets.bottom : mediaPadding.bottom;
        final railAreaTop = mediaPadding.top +
            SecondaryPageSliverAppBar.defaultToolbarHeight +
            UserTempleSortToolbar.toolbarHeight +
            8;
        final railAreaBottom =
            bottomInset + CharacterSearchInputBar.height + 26;
        final availableRailHeight =
            (MediaQuery.sizeOf(context).height - railAreaTop - railAreaBottom)
                .clamp(0.0, double.infinity);
        final railHeight = (controller.levelPositions.length *
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
                width: UserTempleResponsiveGrid.levelRailWidth,
                child: UserCharacterLevelRail(
                  positions: [
                    for (final position in controller.levelPositions)
                      UserCharacterLevelPosition(
                        level: position.level,
                        absoluteIndex: position.absoluteIndex,
                      ),
                  ],
                  onLevelSelected: (level) {
                    unawaited(_jumpToLevel(level));
                  },
                ),
              ),
            Positioned(
              key: const ValueKey<String>('user-temple-search-bar'),
              left: mediaPadding.left + 20,
              right: mediaPadding.right + 20,
              bottom: bottomInset + 14,
              child: TextFieldTapRegion(
                child: CharacterSearchInputBar(
                  controller: _searchController,
                  placeholder: '搜索角色 ID 或名称',
                  onChanged: _handleTempleSearchChanged,
                  onSubmitted: _submitTempleSearch,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 切换圣殿排序并回到页面顶部
  ///
  /// [sort] 目标排序字段
  Future<void> _selectSort(UserTempleSnapshotSort sort) async {
    final controller = _currentUserController;
    if (controller == null) {
      return;
    }
    final adjustmentGeneration = ++_scrollAdjustmentGeneration;
    _levelJumpGeneration += 1;
    _isProgrammaticLevelJump = false;
    _isLoadingPreviousPage = false;
    final success = await controller.selectSort(sort);
    if (!mounted || adjustmentGeneration != _scrollAdjustmentGeneration) {
      return;
    }
    if (!success) {
      _restoreTempleSearchInput();
      AppToast.error(context, text: '排序失败，请重试');
      return;
    }
    _scrollToTopAfterLayout();
  }

  /// 构建当前排序字段的卡片补充值
  ///
  /// [entries] 当前分页圣殿条目
  /// [sort] 当前排序字段
  Map<int, UserTempleSortValue> _buildSortValues(
    List<UserTempleSnapshotEntry> entries,
    UserTempleSnapshotSort sort,
  ) {
    return switch (sort) {
      UserTempleSnapshotSort.singleDividend => {
          for (final entry in entries)
            entry.item.id: UserTempleSortValue(
              label: sort.label,
              value: Formatters.tinygrailCurrency(entry.singleDividend),
            ),
        },
      UserTempleSnapshotSort.totalDividend => {
          for (final entry in entries)
            entry.item.id: UserTempleSortValue(
              label: sort.label,
              value: Formatters.tinygrailCompactValue(
                entry.totalDividend,
                prefix: '₵',
              ),
            ),
        },
      UserTempleSnapshotSort.starForces => {
          for (final entry in entries)
            entry.item.id: UserTempleSortValue(
              icon: Icons.auto_awesome_rounded,
              value: Formatters.groupedNumber(entry.item.starForces),
            ),
        },
      UserTempleSnapshotSort.create => {
          for (final entry in entries)
            entry.item.id: UserTempleSortValue(
              value: _formatCreateDate(entry.item.create),
            ),
        },
      _ => const <int, UserTempleSortValue>{},
    };
  }

  /// 格式化建塔日期
  ///
  /// [value] 接口返回的建塔时间
  String _formatCreateDate(String value) {
    final parsed = TinygrailFormatters.parseServerTime(value);
    return parsed == null
        ? '--'
        : DateFormat('yyyy-MM-dd').format(parsed.toLocal());
  }

  /// 打开圣殿角色详情
  ///
  /// [item] 用户圣殿条目
  void _openCharacterDetail(UserTempleApiItem item) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.name,
      avatarUrl: item.avatar,
    );
  }

  /// 打开圣殿资产弹窗
  ///
  /// [item] 用户圣殿条目
  void _openTempleAssetDialog(UserTempleApiItem item) {
    unawaited(
      showTempleAssetCardDialogFromSource(
        context,
        source: TempleAssetDialogSource(
          ownerName: widget.username,
          ownerNickname: widget.nickname ?? '',
          characterId: item.characterId,
        ),
        characterRepository: widget.characterDetailRepository,
        templeRepository: widget.templeRepository,
        magicRepository: widget.templeAssetMagicRepository,
        oosRepository: widget.oosRepository,
        userRepository: widget.repository,
        currentUserName: widget.currentUserName,
      ),
    );
  }

  /// 显示当前用户圣殿后台刷新成功提示
  void _showAutomaticRefreshSucceeded() {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) {
      return;
    }
    AppToast.info(context, text: '圣殿数据刷新成功');
  }

  /// 显示当前用户圣殿后台刷新失败提示
  void _showAutomaticRefreshFailed() {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) {
      return;
    }
    AppToast.error(context, text: '圣殿数据刷新失败');
  }

  /// 是否展示当前登录用户的本地圣殿快照
  bool get _isCurrentUser {
    final username = widget.username.trim().toLowerCase();
    final currentUserName = widget.currentUserName.trim().toLowerCase();
    return username.isNotEmpty && username == currentUserName;
  }

  /// 页面标题
  String get _title {
    final nickname = widget.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return '$nickname的圣殿';
    }
    if (widget.username.isNotEmpty) {
      return '${widget.username}的圣殿';
    }
    return '用户圣殿';
  }

  /// 用户展示文案
  String get _ownerLabel {
    final nickname = widget.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return '@$nickname';
    }
    return '@${widget.username}';
  }
}
