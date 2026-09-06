import 'package:flutter/material.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
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
import 'package:magrail_app/features/main_navigation/model/main_tab.dart';
import 'package:magrail_app/features/main_navigation/widgets/chrome/main_navigation_search_header.dart';
import 'package:magrail_app/features/main_navigation/widgets/navigation/main_mobile_navigation_dock.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/ranking/repository/ranking_repository.dart';
import 'package:magrail_app/features/ranking/view/ranking_page.dart';
import 'package:magrail_app/features/ranking/widgets/ranking_tab_bar.dart';
import 'package:magrail_app/features/scratch_ticket/repository/scratch_ticket_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/user/model/user_assets_fetch_result.dart';
import 'package:magrail_app/features/user/assets/controller/user_asset_snapshot_coordinator.dart';
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
  /// [userAssetSnapshotCoordinator] 用户资产快照全局协调器
  /// [scratchTicketRepository] 刮刮乐仓库
  /// [rankingRepository] 排行榜仓库
  /// [icoCharacterRepository] ICO 角色仓库
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
    required this.characterRankRepository,
    required this.templeRepository,
    required this.templeAssetMagicRepository,
    required this.oosRepository,
    required this.userRepository,
    required this.userAssetSnapshotCoordinator,
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

  /// 用户资产快照全局协调器
  final UserAssetSnapshotCoordinator userAssetSnapshotCoordinator;

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
  final ScrollController _profileScrollController = ScrollController();
  // 排行榜用独立 token 区分切换重置与当前标签平滑回顶
  int _rankingScrollResetToken = 0;
  int _rankingScrollToTopToken = 0;
  bool _isOpeningProfile = false;
  // 切换标签或结束头像入口任务后，旧异步结果不能重新发起导航
  int _profileNavigationGeneration = 0;
  late bool _useLiquidGlass;

  /// 初始化主导航页面状态
  @override
  void initState() {
    super.initState();
    _useLiquidGlass = widget.preferences.useLiquidGlass;
  }

  /// 释放主导航页面状态
  @override
  void dispose() {
    _homeScrollController.dispose();
    _characterScrollController.dispose();
    _profileScrollController.dispose();
    super.dispose();
  }

  /// 构建主导航页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mainNavigationBackgroundColor(context),
      extendBody: true,
      body: Stack(
        children: [
          _buildMainContent(),
          Align(
            alignment: Alignment.bottomCenter,
            child: MainMobileNavigationDock(
              currentTab: _currentTab,
              useLiquidGlass: _useLiquidGlass,
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

    final searchHeaderHeight = MainNavigationSearchHeader.occupiedHeight(
      context,
    );
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildTabContent(topContentPadding: searchHeaderHeight),
          Positioned(top: 0, left: 0, right: 0, child: _buildSearchHeader()),
        ],
      ),
    );
  }

  /// 构建随用户资料更新的主导航搜索头部
  ///
  /// [bottom] 与搜索框共用渐变背景的底部标签栏
  Widget _buildSearchHeader({PreferredSizeWidget? bottom}) {
    return ListenableBuilder(
      listenable: widget.userRepository,
      builder: (context, child) {
        return MainNavigationSearchHeader(
          backgroundColor: _mainNavigationBackgroundColor(context),
          onSearchPressed: _handleSearchPressed,
          onProfilePressed: _openProfileTab,
          profile: widget.userRepository.readCachedCurrentUserAssets(),
          bottom: bottom,
        );
      },
    );
  }

  /// 构建排行榜一体化悬浮头部
  ///
  /// [context] 当前组件树上下文
  /// [labels] 榜单标签文案
  /// [selectedIndex] 当前榜单索引
  /// [pageController] 提供页面连续滑动进度的控制器
  /// [onSelected] 分页页面的榜单切换回调
  PreferredSizeWidget _buildRankingHeader(
    BuildContext context,
    List<String> labels,
    int selectedIndex,
    PageController pageController,
    ValueChanged<int> onSelected,
  ) {
    final tabBar = RankingTabBar(
      labels: labels,
      selectedIndex: selectedIndex,
      pageController: pageController,
      onSelected: onSelected,
    );

    return PreferredSize(
      preferredSize: Size.fromHeight(
        MainNavigationSearchHeader.occupiedHeight(context, bottom: tabBar),
      ),
      child: _buildSearchHeader(bottom: tabBar),
    );
  }

  /// 构建标签页内容
  ///
  /// [topContentPadding] 顶部搜索栏占用的滚动内容高度
  Widget _buildTabContent({double topContentPadding = 0}) {
    return switch (_currentTab) {
      MainTab.home => MainHomeView(
        scrollController: _homeScrollController,
        topContentPadding: topContentPadding,
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
        headerBuilder: _buildRankingHeader,
        scrollResetToken: _rankingScrollResetToken,
        scrollToTopToken: _rankingScrollToTopToken,
      ),
      MainTab.character => CharacterPage(
        scrollController: _characterScrollController,
        topContentPadding: topContentPadding,
        rankRepository: widget.characterRankRepository,
        icoCharacterRepository: widget.icoCharacterRepository,
      ),
      MainTab.profile => UserDetailPage(
        entryMode: UserDetailEntryMode.primary,
        authRepository: widget.authRepository,
        preferences: widget.preferences,
        repository: widget.userRepository,
        snapshotCoordinator: widget.userAssetSnapshotCoordinator,
        characterDetailRepository: widget.characterDetailRepository,
        templeRepository: widget.templeRepository,
        templeAssetMagicRepository: widget.templeAssetMagicRepository,
        oosRepository: widget.oosRepository,
        scratchTicketRepository: widget.scratchTicketRepository,
        scrollController: _profileScrollController,
        reserveDockPadding: true,
        onSignedOut: _switchToHomeAfterSignOut,
        onLiquidGlassChanged: _handleLiquidGlassChanged,
      ),
    };
  }

  /// 退出登录后切换到首页
  void _switchToHomeAfterSignOut() {
    _profileNavigationGeneration += 1;
    _isOpeningProfile = false;
    if (!mounted || _currentTab == MainTab.home) {
      return;
    }

    setState(() {
      _currentTab = MainTab.home;
    });
  }

  /// 处理液态玻璃开关变化
  ///
  /// [enabled] 是否启用液态玻璃
  void _handleLiquidGlassChanged(bool enabled) {
    if (!mounted || _useLiquidGlass == enabled) {
      return;
    }

    setState(() {
      _useLiquidGlass = enabled;
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

    _profileNavigationGeneration += 1;
    _isOpeningProfile = false;
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

  /// 读取主导航页面背景色
  ///
  /// [context] 当前组件树上下文
  Color _mainNavigationBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF111318)
        : const Color(0xFFF5F7FB);
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
    final generation = ++_profileNavigationGeneration;
    try {
      // 用户资产页保护正式会话边界：无 Cookie 时先授权，取消授权则保持当前标签页
      final hasCookie = await widget.authRepository.hasTinygrailCookie();
      if (!_isProfileNavigationCurrent(generation)) {
        return;
      }

      if (!hasCookie) {
        final isAuthorized = await _openAuthPage(
          onAuthenticated: () => _loadProfileAndSwitchAfterAuth(generation),
        );
        if (!_isProfileNavigationCurrent(generation) || isAuthorized != true) {
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
      if (!_isProfileNavigationCurrent(generation)) {
        return;
      }
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
          AppToast.error(context, text: '登录已过期');
          final isAuthorized = await _openAuthPage(
            onAuthenticated: () => _loadProfileAndSwitchAfterAuth(generation),
          );
          if (!_isProfileNavigationCurrent(generation) ||
              isAuthorized != true) {
            return;
          }
        case UserAssetsFetchStatus.failure:
          if (!mounted) {
            return;
          }
          AppToast.error(context, text: result.message ?? '用户资产加载失败');
      }
    } catch (_) {
      if (mounted && _isProfileNavigationCurrent(generation)) {
        AppToast.error(context, text: '用户资产加载失败，请稍后重试');
      }
    } finally {
      if (generation == _profileNavigationGeneration) {
        _isOpeningProfile = false;
        _profileNavigationGeneration += 1;
      }
    }
  }

  /// 判断头像入口任务是否仍对应用户最后的导航操作
  ///
  /// [generation] 任务开始时捕获的页面代际
  bool _isProfileNavigationCurrent(int generation) {
    return mounted && generation == _profileNavigationGeneration;
  }

  /// 打开 Tinygrail 授权页面
  ///
  /// [onAuthenticated] 授权成功并写入 Cookie 后关闭授权页前执行的回调
  Future<bool?> _openAuthPage({Future<void> Function()? onAuthenticated}) {
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
  ///
  /// [generation] 头像入口任务的页面代际
  Future<void> _loadProfileAndSwitchAfterAuth(int generation) async {
    if (!_isProfileNavigationCurrent(generation)) {
      return;
    }

    // 授权页关闭前预取用户资产，避免底层先露出旧页面再切换
    final result = await widget.userRepository.fetchUserAssets();
    if (!mounted || !_isProfileNavigationCurrent(generation)) {
      return;
    }

    switch (result.status) {
      case UserAssetsFetchStatus.success:
        setState(() {
          _currentTab = MainTab.profile;
        });
      case UserAssetsFetchStatus.authExpired:
        AppToast.error(context, text: '登录已过期');
      case UserAssetsFetchStatus.failure:
        AppToast.error(context, text: result.message ?? '用户资产加载失败');
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

  /// 处理搜索入口点击
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
}
