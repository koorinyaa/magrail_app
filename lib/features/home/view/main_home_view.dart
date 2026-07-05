import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/features/auth/view/tinygrail_auth_page.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/chara/auction/widgets/auction_bid_sheet.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/top_week/controller/top_week_controller.dart';
import 'package:magrail_app/features/chara/top_week/model/top_week_entry.dart';
import 'package:magrail_app/features/chara/top_week/repository/top_week_repository.dart';
import 'package:magrail_app/features/chara/top_week/widgets/top_week_refresh_status_button.dart';
import 'package:magrail_app/features/chara/top_week/widgets/top_week_section.dart';
import 'package:magrail_app/features/chara/tower/controller/tower_controller.dart';
import 'package:magrail_app/features/chara/tower/model/tower_entry.dart';
import 'package:magrail_app/features/chara/tower/repository/tower_repository.dart';
import 'package:magrail_app/features/chara/tower/widgets/tower_ranking_section.dart';
import 'package:magrail_app/core/widgets/page_section_sliver.dart';
import 'package:magrail_app/features/home/widgets/home_section_action_button.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/controller/latest_link_controller.dart';
import 'package:magrail_app/features/temple/controller/latest_temple_controller.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/latest_link_section.dart';
import 'package:magrail_app/features/temple/widgets/latest_temple_section.dart';
import 'package:magrail_app/features/user/model/user_assets_fetch_result.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 首页主视图
class MainHomeView extends StatefulWidget {
  /// 创建首页主视图
  ///
  /// [key] Flutter 组件标识
  /// [scrollController] 首页滚动控制器
  /// [authRepository] Tinygrail 授权仓库
  /// [preferences] 本地偏好设置
  /// [topWeekRepository] 每周萌王仓库
  /// [auctionRepository] 拍卖仓库
  /// [characterDetailRepository] 角色详情仓库
  /// [towerRepository] 通天塔仓库
  /// [templeRepository] 圣殿仓库
  /// [templeAssetMagicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户资产仓库
  const MainHomeView({
    super.key,
    required this.scrollController,
    required this.authRepository,
    required this.preferences,
    required this.topWeekRepository,
    required this.auctionRepository,
    required this.characterDetailRepository,
    required this.towerRepository,
    required this.templeRepository,
    required this.templeAssetMagicRepository,
    required this.oosRepository,
    required this.userRepository,
  });

  /// 首页滚动控制器
  final ScrollController scrollController;

  /// Tinygrail 授权仓库
  final TinygrailAuthRepository authRepository;

  /// 本地偏好设置
  final AppPreferences preferences;

  /// 每周萌王仓库
  final TopWeekRepository topWeekRepository;

  /// 拍卖仓库
  final AuctionRepository auctionRepository;

  /// 角色详情仓库
  final CharacterDetailRepository characterDetailRepository;

  /// 通天塔仓库
  final TowerRepository towerRepository;

  /// 圣殿仓库
  final TempleRepository templeRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository templeAssetMagicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 用户资产仓库
  final UserRepository userRepository;

  /// 创建首页主视图状态
  @override
  State<MainHomeView> createState() => _MainHomeViewState();
}

/// 首页主视图状态
class _MainHomeViewState extends State<MainHomeView> {
  late final TopWeekController _topWeekController;
  late final TowerController _towerController;
  late final LatestTempleController _latestTempleController;
  late final LatestLinkController _latestLinkController;

  /// 初始化首页主视图状态
  @override
  void initState() {
    super.initState();
    _topWeekController = TopWeekController(
      repository: widget.topWeekRepository,
      auctionRepository: widget.auctionRepository,
    )..initialize();
    _towerController = TowerController(
      repository: widget.towerRepository,
    )..initialize();
    _latestTempleController = LatestTempleController(
      repository: widget.templeRepository,
    )..initialize();
    _latestLinkController = LatestLinkController(
      repository: widget.templeRepository,
    )..initialize();
  }

  /// 释放首页主视图状态
  @override
  void dispose() {
    _topWeekController.dispose();
    _towerController.dispose();
    _latestTempleController.dispose();
    _latestLinkController.dispose();
    super.dispose();
  }

  /// 构建首页主视图
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _topWeekController,
        _towerController,
        _latestTempleController,
        _latestLinkController,
      ]),
      builder: (context, child) {
        return RefreshIndicator(
          onRefresh: _refreshHome,
          child: CustomScrollView(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              PageSectionSliver(
                title: '每周萌王',
                titleTrailing: TopWeekRefreshStatusButton(
                  label: _topWeekController.refreshLabel,
                  onPressed: _topWeekController.refresh,
                ),
                trailing: HomeSectionActionButton(
                  icon: Icons.history_rounded,
                  label: '往期',
                  onPressed: () => _openTopWeekHistory(context),
                ),
                child: TopWeekCarousel(
                  entries: _topWeekController.entries,
                  isLoading: _topWeekController.isLoading,
                  onCharacterPressed: _openTopWeekCharacter,
                  onAuctionPressed: _openTopWeekAuction,
                ),
              ),
              PageSectionSliver(
                topSpacing: 22,
                title: '通天塔(β)',
                trailing: HomeSectionActionButton(
                  icon: Icons.list_alt_rounded,
                  label: '日志',
                  onPressed: () => _openTowerLog(context),
                ),
                onHeaderTap: () => _openTowerRanking(context),
                child: TowerRankingCarousel(
                  entries: _towerController.entries,
                  isLoading: _towerController.isLoading,
                  isLoadFailed: _towerController.isLoadFailed,
                  onRetry: _towerController.refresh,
                  onEntryTap: _openTowerCharacter,
                ),
              ),
              PageSectionSliver(
                topSpacing: 22,
                title: '最新连接',
                onHeaderTap: _openLatestLinks,
                child: LatestLinkCarousel(
                  pairs: _latestLinkController.pairs,
                  isLoading: _latestLinkController.isLoading,
                  isLoadFailed: _latestLinkController.isLoadFailed,
                  onRetry: _latestLinkController.refresh,
                  characterDetailRepository: widget.characterDetailRepository,
                  templeRepository: widget.templeRepository,
                  magicRepository: widget.templeAssetMagicRepository,
                  oosRepository: widget.oosRepository,
                  userRepository: widget.userRepository,
                ),
              ),
              PageSectionSliver(
                topSpacing: 22,
                title: '最新圣殿',
                onHeaderTap: _openLatestTemples,
                child: LatestTempleCarousel(
                  items: _latestTempleController.items,
                  isLoading: _latestTempleController.isLoading,
                  isLoadFailed: _latestTempleController.isLoadFailed,
                  onRetry: _latestTempleController.refresh,
                  characterDetailRepository: widget.characterDetailRepository,
                  templeRepository: widget.templeRepository,
                  magicRepository: widget.templeAssetMagicRepository,
                  oosRepository: widget.oosRepository,
                  userRepository: widget.userRepository,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 刷新首页全部区块
  Future<void> _refreshHome() {
    return Future.wait([
      _topWeekController.refresh(),
      _towerController.refresh(),
      _latestTempleController.refresh(),
      _latestLinkController.refresh(),
    ]);
  }

  /// 打开每周萌王拍卖底部抽屉
  ///
  /// [entry] 每周萌王条目
  Future<void> _openTopWeekAuction(TopWeekEntry entry) async {
    final isAuthorized = await _ensureTinygrailAuthorized();
    if (!mounted || !isAuthorized) {
      return;
    }

    await showAuctionBidSheet(
      context,
      repository: widget.auctionRepository,
      characterId: entry.characterId,
      characterName: entry.name,
      basePrice: entry.basePrice,
      maxAmount: entry.maxAuctionAmount,
      initialAuction: entry.auction,
      onChanged: _topWeekController.refreshAuctionStatuses,
    );
  }

  /// 确保 Tinygrail 会话可用于拍卖操作
  Future<bool> _ensureTinygrailAuthorized() async {
    final hasCookie = await widget.authRepository.hasTinygrailCookie();
    if (!mounted) {
      return false;
    }

    if (!hasCookie) {
      final isAuthorized = await _openAuthPage();
      return isAuthorized == true;
    }

    final cached = widget.userRepository.readCachedCurrentUserAssets();
    if (cached != null) {
      return true;
    }

    final result = await widget.userRepository.fetchUserAssets();
    if (!mounted) {
      return false;
    }

    switch (result.status) {
      case UserAssetsFetchStatus.success:
        return true;
      case UserAssetsFetchStatus.authExpired:
        AppToast.error(
          context,
          text: '登录已过期',
        );
        final isAuthorized = await _openAuthPage();
        return isAuthorized == true;
      case UserAssetsFetchStatus.failure:
        AppToast.error(
          context,
          text: result.message ?? '用户资产加载失败',
        );
        return false;
    }
  }

  /// 打开 Tinygrail 授权页面
  Future<bool?> _openAuthPage() {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) {
          return TinygrailAuthPage(
            authRepository: widget.authRepository,
            preferences: widget.preferences,
            onAuthenticated: () async {
              if (!mounted) {
                return;
              }
              await widget.userRepository.fetchUserAssets();
              if (!mounted) {
                return;
              }
              await _topWeekController.refreshAuctionStatuses();
            },
          );
        },
      ),
    );
  }

  /// 打开往期萌王二级页面
  ///
  /// [context] 当前组件树上下文
  void _openTopWeekHistory(BuildContext context) {
    context.pushNamed('topWeekHistory');
  }

  /// 打开通天塔二级页面
  ///
  /// [context] 当前组件树上下文
  void _openTowerRanking(BuildContext context) {
    context.pushNamed('towerRanking');
  }

  /// 打开通天塔日志二级页面
  ///
  /// [context] 当前组件树上下文
  void _openTowerLog(BuildContext context) {
    context.pushNamed('towerLog');
  }

  /// 打开通天塔角色详情页
  ///
  /// [entry] 通天塔条目
  /// [avatarHeroTag] 入口头像转场标识
  void _openTowerCharacter(TowerEntry entry, String? avatarHeroTag) {
    openCharacterDetail(
      context,
      characterId: entry.characterId,
      name: entry.name,
      avatarUrl: entry.avatarUrl,
      avatarHeroTag: avatarHeroTag,
    );
  }

  /// 打开每周萌王角色详情页
  ///
  /// [entry] 每周萌王条目
  void _openTopWeekCharacter(TopWeekEntry entry) {
    openCharacterDetail(
      context,
      characterId: entry.characterId,
      name: entry.name,
      avatarUrl: entry.avatarUrl,
    );
  }

  /// 打开最新圣殿二级页面
  void _openLatestTemples() {
    context.pushNamed('latestTemples');
  }

  /// 打开最新连接二级页面
  void _openLatestLinks() {
    context.pushNamed('latestLinks');
  }
}
