import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/widgets/app_soft_background.dart';
import 'package:magrail_app/features/auth/view/tinygrail_auth_page.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/rank/repository/character_rank_repository.dart';
import 'package:magrail_app/features/chara/search/view/character_search_page.dart';
import 'package:magrail_app/features/chara/tower/repository/tower_repository.dart';
import 'package:magrail_app/features/chara/top_week/repository/top_week_repository.dart';
import 'package:magrail_app/features/chara/view/character_page.dart';
import 'package:magrail_app/features/home/view/main_home_view.dart';
import 'package:magrail_app/features/ico/repository/ico_character_repository.dart';
import 'package:magrail_app/features/ico/repository/st_character_repository.dart';
import 'package:magrail_app/features/ico/view/ico_page.dart';
import 'package:magrail_app/features/main_navigation/model/main_tab.dart';
import 'package:magrail_app/features/main_navigation/widgets/chrome/main_top_bar.dart';
import 'package:magrail_app/features/main_navigation/widgets/navigation/main_mobile_navigation_dock.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/ranking/repository/ranking_repository.dart';
import 'package:magrail_app/features/ranking/view/ranking_page.dart';
import 'package:magrail_app/features/scratch_ticket/repository/scratch_ticket_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/user/model/user_assets_fetch_result.dart';
import 'package:magrail_app/features/user/model/user_detail_entry_mode.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/view/user_detail_page.dart';

/// 主导航页面
class MainNavigationPage extends StatefulWidget {
  /// 创建主导航页面
  ///
  /// [key] Flutter 组件标识
  /// [authRepository] Tinygrail 授权仓库
  /// [preferences] 本地偏好设置
  /// [topWeekRepository] 每周萌王仓库
  /// [auctionRepository] 拍卖仓库
  /// [characterDetailRepository] 角色详情仓库
  /// [towerRepository] 通天塔仓库
  /// [characterRankRepository] 角色排序仓库
  /// [templeRepository] 圣殿仓库
  /// [templeAssetMagicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户资产仓库
  /// [scratchTicketRepository] 刮刮乐仓库
  /// [rankingRepository] 排行榜仓库
  /// [icoCharacterRepository] ICO 角色仓库
  /// [stCharacterRepository] ST 角色仓库
  const MainNavigationPage({
    super.key,
    required this.authRepository,
    required this.preferences,
    required this.topWeekRepository,
    required this.rankingRepository,
    required this.auctionRepository,
    required this.characterDetailRepository,
    required this.towerRepository,
    required this.icoCharacterRepository,
    required this.stCharacterRepository,
    required this.characterRankRepository,
    required this.templeRepository,
    required this.templeAssetMagicRepository,
    required this.oosRepository,
    required this.userRepository,
    required this.scratchTicketRepository,
  });

  /// Tinygrail 授权仓库
  final TinygrailAuthRepository authRepository;

  /// 本地偏好设置
  final AppPreferences preferences;

  /// 每周萌王仓库
  final TopWeekRepository topWeekRepository;

  /// 角色排行榜仓库
  final RankingRepository rankingRepository;

  /// 拍卖仓库
  final AuctionRepository auctionRepository;

  /// 角色详情仓库
  final CharacterDetailRepository characterDetailRepository;

  /// 通天塔仓库
  final TowerRepository towerRepository;

  /// ICO 角色仓库
  final IcoCharacterRepository icoCharacterRepository;

  /// ST 角色仓库
  final StCharacterRepository stCharacterRepository;

  /// 角色排序仓库
  final CharacterRankRepository characterRankRepository;

  /// 圣殿仓库
  final TempleRepository templeRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository templeAssetMagicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 用户资产仓库
  final UserRepository userRepository;

  /// 刮刮乐仓库
  final ScratchTicketRepository scratchTicketRepository;

  /// 创建主导航页面状态
  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

/// 主导航页面状态
class _MainNavigationPageState extends State<MainNavigationPage> {
  MainTab _currentTab = MainTab.home;
  final ScrollController _homeScrollController = ScrollController();
  final ScrollController _characterScrollController = ScrollController();
  final ScrollController _icoScrollController = ScrollController();
  final ScrollController _profileScrollController = ScrollController();
  // 排行榜用独立 token 区分切换重置与当前标签平滑回顶
  int _rankingScrollResetToken = 0;
  int _rankingScrollToTopToken = 0;
  bool _isOpeningProfile = false;

  /// 释放主导航页面状态
  @override
  void dispose() {
    _homeScrollController.dispose();
    _characterScrollController.dispose();
    _icoScrollController.dispose();
    _profileScrollController.dispose();
    super.dispose();
  }

  /// 构建主导航页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111318) : const Color(0xFFF5F7FB),
      extendBody: true,
      body: Stack(
        children: [
          AppSoftBackground(isDark: isDark),
          _buildMainContent(),
          Align(
            alignment: Alignment.bottomCenter,
            child: MainMobileNavigationDock(
              currentTab: _currentTab,
              onTabSelected: _selectTab,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建主导航内容区域
  Widget _buildMainContent() {
    if (_currentTab == MainTab.profile || _currentTab == MainTab.ranking) {
      return Positioned.fill(child: _buildTabContent());
    }

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          MainTopBar(
            title: _topBarTitle,
            onSearchPressed: _handleSearchPressed,
          ),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  /// 构建标签页内容
  Widget _buildTabContent() {
    return switch (_currentTab) {
      MainTab.home => MainHomeView(
          scrollController: _homeScrollController,
          authRepository: widget.authRepository,
          preferences: widget.preferences,
          topWeekRepository: widget.topWeekRepository,
          auctionRepository: widget.auctionRepository,
          characterDetailRepository: widget.characterDetailRepository,
          towerRepository: widget.towerRepository,
          templeRepository: widget.templeRepository,
          templeAssetMagicRepository: widget.templeAssetMagicRepository,
          oosRepository: widget.oosRepository,
          userRepository: widget.userRepository,
        ),
      MainTab.ranking => RankingPage(
          repository: widget.rankingRepository,
          characterDetailRepository: widget.characterDetailRepository,
          templeRepository: widget.templeRepository,
          magicRepository: widget.templeAssetMagicRepository,
          oosRepository: widget.oosRepository,
          userRepository: widget.userRepository,
          bottomContentPadding: 92,
          scrollResetToken: _rankingScrollResetToken,
          scrollToTopToken: _rankingScrollToTopToken,
        ),
      MainTab.character => CharacterPage(
          scrollController: _characterScrollController,
          authRepository: widget.authRepository,
          userRepository: widget.userRepository,
          auctionRepository: widget.auctionRepository,
          rankRepository: widget.characterRankRepository,
        ),
      MainTab.ico => IcoPage(
          scrollController: _icoScrollController,
          icoCharacterRepository: widget.icoCharacterRepository,
          stCharacterRepository: widget.stCharacterRepository,
        ),
      MainTab.profile => UserDetailPage(
          entryMode: UserDetailEntryMode.primary,
          authRepository: widget.authRepository,
          preferences: widget.preferences,
          repository: widget.userRepository,
          characterDetailRepository: widget.characterDetailRepository,
          templeRepository: widget.templeRepository,
          templeAssetMagicRepository: widget.templeAssetMagicRepository,
          oosRepository: widget.oosRepository,
          scratchTicketRepository: widget.scratchTicketRepository,
          scrollController: _profileScrollController,
          reserveDockPadding: true,
          onOpenSecondary: _openUserDetailPage,
          onSignedOut: _switchToHomeAfterSignOut,
        ),
    };
  }

  /// 顶部栏标题
  String get _topBarTitle {
    if (_currentTab != MainTab.home) {
      return _currentTab.title;
    }

    final cachedUser = widget.userRepository.readCachedCurrentUserAssets();
    final nickname = cachedUser?.nickname.trim();
    if (nickname == null || nickname.isEmpty) {
      return MainTab.home.title;
    }

    return 'Hi! $nickname';
  }

  /// 退出登录后切换到首页
  void _switchToHomeAfterSignOut() {
    if (!mounted || _currentTab == MainTab.home) {
      return;
    }

    setState(() {
      _currentTab = MainTab.home;
    });
  }

  /// 切换主导航标签
  ///
  /// [tab] 目标导航标签
  Future<void> _selectTab(MainTab tab) async {
    if (tab == MainTab.profile) {
      await _openProfileTab();
      return;
    }

    if (tab == _currentTab) {
      _scrollCurrentTabToTop();
      return;
    }

    setState(() {
      if (tab == MainTab.ranking) {
        _rankingScrollResetToken += 1;
      }
      _currentTab = tab;
    });
  }

  /// 打开个人资产一级页面
  Future<void> _openProfileTab() async {
    if (_currentTab == MainTab.profile) {
      _scrollCurrentTabToTop();
      return;
    }

    if (_isOpeningProfile) {
      return;
    }

    _isOpeningProfile = true;
    try {
      // 用户资产页保护正式会话边界：无 Cookie 时先授权，取消授权则保持当前标签页
      final hasCookie = await widget.authRepository.hasTinygrailCookie();
      if (!mounted) {
        return;
      }

      if (!hasCookie) {
        final isAuthorized = await _openAuthPage(
          onAuthenticated: _loadProfileAndSwitchAfterAuth,
        );
        if (!mounted || isAuthorized != true) {
          return;
        }

        return;
      }

      final cached = widget.userRepository.readCachedCurrentUserAssets();
      if (cached != null) {
        if (!mounted) {
          return;
        }

        setState(() {
          _currentTab = MainTab.profile;
        });
        return;
      }

      final result = await widget.userRepository.fetchUserAssets();
      switch (result.status) {
        case UserAssetsFetchStatus.success:
          if (!mounted) {
            return;
          }
          setState(() {
            _currentTab = MainTab.profile;
          });
        case UserAssetsFetchStatus.authExpired:
          if (!mounted) {
            return;
          }
          AppToast.error(
            context,
            text: '登录已过期',
          );
          final isAuthorized = await _openAuthPage(
            onAuthenticated: _loadProfileAndSwitchAfterAuth,
          );
          if (!mounted || isAuthorized != true) {
            return;
          }
        case UserAssetsFetchStatus.failure:
          if (!mounted) {
            return;
          }
          AppToast.error(
            context,
            text: result.message ?? '用户资产加载失败',
          );
      }
    } finally {
      _isOpeningProfile = false;
    }
  }

  /// 打开 Tinygrail 授权页面
  ///
  /// [onAuthenticated] 授权成功并写入 Cookie 后关闭授权页前执行的回调
  Future<bool?> _openAuthPage({
    Future<void> Function()? onAuthenticated,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) {
          return TinygrailAuthPage(
            authRepository: widget.authRepository,
            preferences: widget.preferences,
            onAuthenticated: onAuthenticated,
          );
        },
      ),
    );
  }

  /// 授权成功后加载当前用户资产并切换到一级用户页
  Future<void> _loadProfileAndSwitchAfterAuth() async {
    if (!mounted) {
      return;
    }

    // 授权页关闭前预取用户资产，避免底层先露出旧页面再切换
    final result = await widget.userRepository.fetchUserAssets();
    if (!mounted) {
      return;
    }

    switch (result.status) {
      case UserAssetsFetchStatus.success:
        setState(() {
          _currentTab = MainTab.profile;
        });
      case UserAssetsFetchStatus.authExpired:
        AppToast.error(
          context,
          text: '登录已过期',
        );
      case UserAssetsFetchStatus.failure:
        AppToast.error(
          context,
          text: result.message ?? '用户资产加载失败',
        );
    }
  }

  /// 将当前导航标签滚动到顶部
  void _scrollCurrentTabToTop() {
    switch (_currentTab) {
      case MainTab.home:
        _scrollToTop(_homeScrollController);
      case MainTab.profile:
        _scrollToTop(_profileScrollController);
      case MainTab.ranking:
        _scrollRankingToTop();
      case MainTab.character:
        _scrollToTop(_characterScrollController);
      case MainTab.ico:
        _scrollToTop(_icoScrollController);
    }
  }

  /// 平滑滚动排行榜到顶部
  void _scrollRankingToTop() {
    setState(() {
      _rankingScrollToTopToken += 1;
    });
  }

  /// 将指定滚动区域滚动到顶部
  ///
  /// [controller] 需要滚动到顶部的控制器
  void _scrollToTop(ScrollController controller) {
    if (!controller.hasClients) {
      return;
    }

    final position = controller.position;
    if (position.pixels <= position.minScrollExtent) {
      return;
    }

    controller.animateTo(
      position.minScrollExtent,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  /// 处理搜索按钮点击
  Future<void> _handleSearchPressed() {
    return showCharacterSearchPage(
      context,
      repository: widget.characterDetailRepository,
      templeRepository: widget.templeRepository,
      magicRepository: widget.templeAssetMagicRepository,
      oosRepository: widget.oosRepository,
      userRepository: widget.userRepository,
    );
  }

  /// 打开用户详情二级页面
  void _openUserDetailPage() {
    context.pushNamed('userDetail');
  }
}
