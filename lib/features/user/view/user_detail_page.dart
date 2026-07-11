import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/core/widgets/app_soft_background.dart';
import 'package:magrail_app/features/auth/view/tinygrail_auth_page.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/scratch_ticket/repository/scratch_ticket_repository.dart';
import 'package:magrail_app/features/scratch_ticket/widgets/scratch_ticket_sheet.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_dialog.dart';
import 'package:magrail_app/features/user/controller/user_detail_controller.dart';
import 'package:magrail_app/features/user/model/user_action_entry.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_detail_entry_mode.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';
import 'package:magrail_app/features/user/model/user_ico_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_action_grid_card.dart';
import 'package:magrail_app/features/user/widgets/user_chara_overview_section.dart';
import 'package:magrail_app/features/user/widgets/user_chara_overview_states.dart';
import 'package:magrail_app/features/user/widgets/user_detail_states.dart';
import 'package:magrail_app/features/user/widgets/user_detail_top_actions.dart';
import 'package:magrail_app/features/user/widgets/user_profile_card.dart';
import 'package:magrail_app/features/user/widgets/user_red_packet_send_sheet.dart';
import 'package:magrail_app/features/user/widgets/user_share_bonus_forecast_sheet.dart';
import 'package:magrail_app/features/user/view/user_settings_page.dart';

part 'user_detail_page_actions.dart';
part 'user_detail_page_navigation.dart';

/// 用户详情页
class UserDetailPage extends StatefulWidget {
  /// 创建用户详情页
  ///
  /// [key] Flutter 组件标识
  /// [entryMode] 页面入口层级
  /// [authRepository] Tinygrail 授权仓库
  /// [preferences] 本地偏好设置
  /// [repository] 用户仓库
  /// [characterDetailRepository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [templeAssetMagicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [scratchTicketRepository] 刮刮乐仓库
  /// [username] 用户名，不传时展示当前登录用户
  /// [scrollController] 外部滚动控制器，不传时页面内部创建
  /// [reserveDockPadding] 是否为底部 Dock 预留滚动底部空间
  /// [onSignedOut] 当前用户退出登录后的回调
  /// [onLiquidGlassChanged] 液态玻璃开关变化回调
  const UserDetailPage({
    super.key,
    required this.entryMode,
    required this.authRepository,
    required this.preferences,
    required this.repository,
    required this.characterDetailRepository,
    required this.templeRepository,
    required this.templeAssetMagicRepository,
    required this.oosRepository,
    required this.scratchTicketRepository,
    this.username,
    this.scrollController,
    this.reserveDockPadding = false,
    this.onSignedOut,
    this.onLiquidGlassChanged,
  });

  /// 页面入口层级
  final UserDetailEntryMode entryMode;

  /// Tinygrail 授权仓库
  final TinygrailAuthRepository authRepository;

  /// 本地偏好设置
  final AppPreferences preferences;

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

  /// 刮刮乐仓库
  final ScratchTicketRepository scratchTicketRepository;

  /// 用户名，不传时展示当前登录用户
  final String? username;

  /// 外部滚动控制器，不传时页面内部创建
  final ScrollController? scrollController;

  /// 是否为底部 Dock 预留滚动底部空间
  final bool reserveDockPadding;

  /// 当前用户退出登录后的回调
  final VoidCallback? onSignedOut;

  /// 液态玻璃开关变化回调
  final ValueChanged<bool>? onLiquidGlassChanged;

  /// 创建用户详情页状态
  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

/// 用户详情页状态
class _UserDetailPageState extends State<UserDetailPage> {
  static const double _horizontalPadding = 10;
  static const double _topToolbarHeight = 48;
  // 工具栏下方保留资料卡头像向上溢出的视觉空间
  static const double _profileTopGap = 62;
  static const double _profileAvatarSize = 68;
  // 资料卡头像向上溢出白卡顶部的距离
  static const double _profileAvatarOverflow = 20;
  // 顶部操作区在滚动 72 像素后达到通用二级页的模糊强度
  static const double _topActionBlurExtent = 72;
  // 顶部操作区完全遮挡资料卡头像时显示紧凑用户标识
  static const double _topIdentityStartOffset =
      _profileTopGap - _profileAvatarOverflow + _profileAvatarSize;
  // 紧凑用户标识在短距离滚动内完成淡入，避免贴边时突然出现
  static const double _topIdentityFadeExtent = 24;

  late final UserDetailController _controller;
  late final ScrollController _scrollController;
  late final bool _ownsScrollController;
  // 滚动时只刷新顶部浮层，避免整页内容随透明度重建
  late final ValueNotifier<double> _topActionBlurProgress;
  late final ValueNotifier<double> _topIdentityProgress;
  bool _isBalanceAndAssetsHidden = false;
  bool _isClaimingWeeklyBonus = false;
  bool _isClaimingDailyBonus = false;
  bool _isClaimingHolidayBonus = false;
  bool _isUpdatingUserBanState = false;
  int _shownFailureNotificationToken = 0;

  bool get _isSecondary => widget.entryMode == UserDetailEntryMode.secondary;

  /// 初始化用户详情页状态
  @override
  void initState() {
    super.initState();
    _topActionBlurProgress = ValueNotifier<double>(0);
    _topIdentityProgress = ValueNotifier<double>(0);
    _ownsScrollController = widget.scrollController == null;
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_handleScrollOffsetChanged);
    _controller = UserDetailController(
      repository: widget.repository,
      username: widget.username,
    );
    _controller.addListener(_handleControllerChanged);
    unawaited(_controller.initialize());
  }

  /// 释放用户详情页状态
  @override
  void dispose() {
    _scrollController.removeListener(_handleScrollOffsetChanged);
    if (_ownsScrollController) {
      _scrollController.dispose();
    }
    _topActionBlurProgress.dispose();
    _topIdentityProgress.dispose();
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  /// 构建用户详情页
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final systemOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF111318) : const Color(0xFFF5F7FB),
        body: Stack(
          children: [
            AppSoftBackground(isDark: isDark),
            SafeArea(
              bottom: false,
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return RefreshIndicator(
                    onRefresh: _controller.refresh,
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        ..._buildContentSlivers(context),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: (widget.reserveDockPadding ? 116 : 24) +
                                MediaQuery.paddingOf(context).bottom,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return ValueListenableBuilder<double>(
                  valueListenable: _topActionBlurProgress,
                  builder: (context, progress, _) {
                    return ValueListenableBuilder<double>(
                      valueListenable: _topIdentityProgress,
                      builder: (context, identityProgress, _) {
                        return UserDetailFloatingTopActions(
                          toolbarHeight: _topToolbarHeight,
                          progress: progress,
                          profile: _controller.profile,
                          identityProgress: identityProgress,
                          showBackButton: _isSecondary,
                          showSettingsButton: _controller.isCurrentUser,
                          hideBalanceAndAssets: _isBalanceAndAssetsHidden,
                          onBalanceAndAssetsVisibilityPressed:
                              _toggleBalanceAndAssetsVisibility,
                          onSettingsPressed: _openSettingsPage,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 根据滚动位置更新顶部操作区状态
  void _handleScrollOffsetChanged() {
    final scrollOffset = _scrollController.offset;
    final nextBlurProgress =
        (scrollOffset / _topActionBlurExtent).clamp(0.0, 1.0).toDouble();
    if ((nextBlurProgress - _topActionBlurProgress.value).abs() >= 0.01) {
      _topActionBlurProgress.value = nextBlurProgress;
    }

    final nextIdentityProgress =
        ((scrollOffset - _topIdentityStartOffset) / _topIdentityFadeExtent)
            .clamp(0.0, 1.0)
            .toDouble();
    if ((nextIdentityProgress - _topIdentityProgress.value).abs() >= 0.01) {
      _topIdentityProgress.value = nextIdentityProgress;
    }
  }

  /// 处理用户详情控制器状态变化
  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }

    final token = _controller.failureNotificationToken;
    if (token == 0 || token == _shownFailureNotificationToken) {
      return;
    }

    final message = _controller.errorMessage;
    if (_controller.profile == null || message == null || message.isEmpty) {
      return;
    }

    _shownFailureNotificationToken = token;
    AppToast.error(context, text: message);
  }

  /// 构建用户详情内容 sliver
  ///
  /// [context] 当前组件树上下文
  List<Widget> _buildContentSlivers(BuildContext context) {
    final profile = _controller.profile;
    if (_controller.isLoading && profile == null) {
      return [
        _buildTopContentSliver(
          child: const UserDetailSkeleton(),
        ),
        const UserCharaOverviewSkeletonSection(),
      ];
    }

    if (profile == null) {
      return [
        _buildTopContentSliver(
          child: UserDetailErrorState(
            title: _controller.isAuthExpired ? '未授权' : '加载失败',
            icon: _controller.isAuthExpired
                ? Icons.login_rounded
                : Icons.wifi_off_rounded,
            message: _controller.errorMessage ?? '用户资产加载失败',
            actionLabel: _controller.isAuthExpired ? '点击授权' : '重试',
            onActionPressed: _controller.isAuthExpired
                ? _openAuthPage
                : () {
                    _controller.refresh();
                  },
          ),
        ),
      ];
    }

    final actions = _controller.visibleActions().where((action) {
      return widget.preferences.showBotAction ||
          action.type != UserActionType.bot;
    }).toList(growable: false);

    return [
      _buildTopContentSliver(
        child: Column(
          children: [
            UserProfileCard(
              profile: profile,
              isCurrentUser: _controller.isCurrentUser,
              hideBalanceAndAssets: _isBalanceAndAssetsHidden,
              onRecordPressed: () => _openRedPacketLogs(profile),
              onSendPressed: () => _openSendRedPacket(profile),
              onCopyPressed: () => _copyUserId(context),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              UserActionGridCard(
                actions: actions,
                onActionPressed: (action) =>
                    _handleActionPressed(context, action),
              ),
            ],
          ],
        ),
      ),
      UserCharaOverviewSection(
        profile: profile,
        links: _controller.links,
        temples: _controller.temples,
        characters: _controller.characters,
        icos: _controller.icos,
        linkTotalItems: _controller.linkTotalItems,
        templeTotalItems: _controller.templeTotalItems,
        characterTotalItems: _controller.characterTotalItems,
        icoTotalItems: _controller.icoTotalItems,
        isLoading: _controller.isCharaLoading,
        isLoadFailed: _controller.isCharaLoadFailed,
        onRetry: _controller.refreshCharaOverview,
        onLinksHeaderTap: () => _openUserLinks(profile),
        onTemplesHeaderTap: () => _openUserTemples(profile),
        onCharactersHeaderTap: () => _openUserCharacters(profile),
        onIcosHeaderTap: () => _openUserIcos(profile),
        onTempleCharacterTap: _openTempleCharacterDetail,
        onTempleAssetTap: _openTempleAssetDialog,
        onCharacterTap: _openCharacterDetail,
        onIcoTap: _openIcoDetail,
      ),
    ];
  }

  /// 构建用户详情顶部内容 sliver
  ///
  /// [child] 顶部内容主体
  Widget _buildTopContentSliver({
    required Widget child,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          _horizontalPadding,
          0,
          _horizontalPadding,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: _topToolbarHeight + _profileTopGap),
            child,
          ],
        ),
      ),
    );
  }

  /// 切换余额和资产显示状态
  void _toggleBalanceAndAssetsVisibility() {
    setState(() {
      _isBalanceAndAssetsHidden = !_isBalanceAndAssetsHidden;
    });
  }

  /// 刷新用户操作入口显示状态
  void _refreshVisibleActions() {
    setState(() {});
  }

  /// 打开 Tinygrail 授权页并刷新用户详情
  Future<void> _openAuthPage() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) {
          return TinygrailAuthPage(
            authRepository: widget.authRepository,
            preferences: widget.preferences,
            onAuthenticated: _controller.refresh,
          );
        },
      ),
    );
  }

  /// 更新用户菜单操作中状态
  ///
  /// [type] 用户菜单入口类型
  /// [value] 是否操作中
  void _setActionBusyState(
    UserActionType type, {
    required bool value,
  }) {
    if (!mounted) {
      return;
    }

    setState(() {
      switch (type) {
        case UserActionType.weeklyBonus:
          _isClaimingWeeklyBonus = value;
          break;
        case UserActionType.dailyBonus:
          _isClaimingDailyBonus = value;
          break;
        case UserActionType.holidayBonus:
          _isClaimingHolidayBonus = value;
          break;
        case UserActionType.balanceLog:
        case UserActionType.myAuction:
        case UserActionType.marketOrder:
        case UserActionType.myItems:
        case UserActionType.scratch:
        case UserActionType.dividendForecast:
        case UserActionType.assetAnalysis:
        case UserActionType.bot:
        case UserActionType.tradeLog:
          break;
        case UserActionType.block:
        case UserActionType.unblock:
          _isUpdatingUserBanState = value;
          break;
      }
    });
  }
}
