import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/widgets/app_soft_background.dart';
import 'package:magrail_app/features/auth/view/tinygrail_auth_page.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_basic_info.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_history_item.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_sacrifice_result.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_floating_toolbar.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_history_bar.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_ico_invest_bar.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_page_body.dart';
import 'package:magrail_app/features/chara/search/view/character_search_page.dart';
import 'package:magrail_app/features/chara/trade_history/repository/character_trade_history_repository.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 角色详情页
class CharacterDetailPage extends StatefulWidget {
  /// 创建角色详情页
  ///
  /// [key] Flutter 组件标识
  /// [preferences] 本地偏好设置
  /// [authRepository] Tinygrail 授权仓库
  /// [repository] 角色详情仓库
  /// [userRepository] 用户仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [auctionRepository] 拍卖仓库
  /// [tradeHistoryRepository] 角色交易记录仓库
  /// [characterId] 初始角色 ID
  /// [initialName] 初始角色名称
  /// [initialAvatarUrl] 初始角色头像地址
  /// [initialAvatarHeroTag] 初始入口头像转场标识
  const CharacterDetailPage({
    super.key,
    required this.preferences,
    required this.authRepository,
    required this.repository,
    required this.userRepository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.auctionRepository,
    required this.tradeHistoryRepository,
    required this.characterId,
    this.initialName,
    this.initialAvatarUrl,
    this.initialAvatarHeroTag,
  });

  /// 本地偏好设置
  final AppPreferences preferences;

  /// Tinygrail 授权仓库
  final TinygrailAuthRepository authRepository;

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 圣殿仓库
  final TempleRepository templeRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository magicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 拍卖仓库
  final AuctionRepository auctionRepository;

  /// 角色交易记录仓库
  final CharacterTradeHistoryRepository tradeHistoryRepository;

  /// 初始角色 ID
  final int? characterId;

  /// 初始角色名称
  final String? initialName;

  /// 初始角色头像地址
  final String? initialAvatarUrl;

  /// 初始入口头像转场标识
  final String? initialAvatarHeroTag;

  /// 创建角色详情页状态
  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

/// 角色详情页状态
class _CharacterDetailPageState extends State<CharacterDetailPage> {
  static const double _topToolbarHeight = 48;
  static const double _topActionBlurExtent = 72;
  static const double _historyBarHeight = 104;
  static const double _topIdentityFadeExtent = 24;
  // 紧凑角色信息需要在标题栏遮挡角色信息卡片前完成淡入
  static const double _topIdentityStartOffset =
      _historyBarHeight - _topIdentityFadeExtent;

  late final CharacterDetailController _controller;
  late final ScrollController _scrollController;
  // 顶部浮层只跟随滚动进度刷新，避免整页内容频繁重建
  late final ValueNotifier<double> _topActionBlurProgress;
  late final ValueNotifier<double> _topIdentityProgress;
  late final ValueNotifier<int> _publicCollectionsRefreshSignal;
  late final ValueNotifier<int> _publicBoardRefreshSignal;

  /// 初始化角色详情页状态
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(_handleScrollOffsetChanged);
    _topActionBlurProgress = ValueNotifier<double>(0);
    _topIdentityProgress = ValueNotifier<double>(0);
    _publicCollectionsRefreshSignal = ValueNotifier<int>(0);
    _publicBoardRefreshSignal = ValueNotifier<int>(0);
    _controller = CharacterDetailController(
      preferences: widget.preferences,
      repository: widget.repository,
      userRepository: widget.userRepository,
      initialCharacterId: widget.characterId,
      initialName: widget.initialName,
      initialAvatarUrl: widget.initialAvatarUrl,
      initialAvatarHeroTag: widget.initialAvatarHeroTag,
    )..initialize();
  }

  /// 释放角色详情页状态
  @override
  void dispose() {
    _scrollController.removeListener(_handleScrollOffsetChanged);
    _scrollController.dispose();
    _topActionBlurProgress.dispose();
    _topIdentityProgress.dispose();
    _publicCollectionsRefreshSignal.dispose();
    _publicBoardRefreshSignal.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// 构建角色详情页
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
                  final current = _controller.current;
                  final currentUser = _controller.currentUser;
                  final currentUserName = currentUser?.name.trim() ?? '';
                  final currentUserDisplayName = currentUser == null
                      ? ''
                      : currentUser.nickname.trim().isNotEmpty
                          ? currentUser.nickname.trim()
                          : currentUser.name.trim();
                  final currentPageType = _controller.currentPageType;
                  final currentIcoInfo = _controller.currentIcoInfo;
                  final showIcoInvestBar =
                      currentPageType == CharacterDetailPageType.ico &&
                          currentIcoInfo != null &&
                          _controller.isAuthorized;
                  final bottomPadding = MediaQuery.paddingOf(context).bottom +
                      (showIcoInvestBar ? 156 : 24);

                  return CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(
                        child: SizedBox(height: _topToolbarHeight),
                      ),
                      if (_controller.hasValidCharacter)
                        SliverToBoxAdapter(
                          child: CharacterDetailHistoryBar(
                            items: _controller.history,
                            selectedCharacterId: current?.characterId,
                            selectedAvatarHeroTag:
                                _controller.currentAvatarHeroTag,
                            onItemPressed: _selectHistoryItem,
                          ),
                        ),
                      CharacterDetailPageBody(
                        current: current,
                        pageType: currentPageType,
                        tradeHeader: _controller.currentTradeHeader,
                        icoInfo: currentIcoInfo,
                        userAssets: _controller.currentUserAssets,
                        showAuthGuide: _controller.hasResolvedCurrentUser &&
                            !_controller.isAuthorized,
                        showTradeSection: _controller.isAuthorized,
                        currentUserName: currentUserName,
                        currentUserDisplayName: currentUserDisplayName,
                        currentUserBalance: currentUser?.balance.toDouble(),
                        repository: widget.repository,
                        templeRepository: widget.templeRepository,
                        magicRepository: widget.magicRepository,
                        oosRepository: widget.oosRepository,
                        userRepository: widget.userRepository,
                        auctionRepository: widget.auctionRepository,
                        tradeHistoryRepository: widget.tradeHistoryRepository,
                        isGameMaster: _controller.isGameMaster,
                        collectionsRefreshSignal:
                            _publicCollectionsRefreshSignal,
                        boardRefreshSignal: _publicBoardRefreshSignal,
                        onSacrificeChanged: _handleSacrificeChanged,
                        onAuctionChanged: _controller.refreshCurrentCharacter,
                        onAvatarChanged: _controller.refreshCurrentCharacter,
                        onUserAssetsRetry: _controller.retryCurrentUserAssets,
                        onAuthorize: _openAuthPage,
                        onIcoStarted: _controller.refreshCurrentCharacter,
                        onVoteKill: _controller.voteKillCurrentCharacter,
                        onRevokeVote: _controller.revokeCurrentKillVote,
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: bottomPadding),
                      ),
                    ],
                  );
                },
              ),
            ),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final currentIcoInfo = _controller.currentIcoInfo;
                final showIcoInvestBar = _controller.currentPageType ==
                        CharacterDetailPageType.ico &&
                    currentIcoInfo != null &&
                    _controller.isAuthorized;

                if (showIcoInvestBar) {
                  return CharacterDetailIcoInvestBar(
                    key: ValueKey<String>('ico-invest-${currentIcoInfo.id}'),
                    repository: widget.repository,
                    icoInfo: currentIcoInfo,
                    userBalance: _controller.currentUser?.balance.toDouble(),
                    onInvested: _controller.refreshCurrentCharacter,
                  );
                }

                return const SizedBox.shrink();
              },
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
                        return CharacterDetailFloatingToolbar(
                          toolbarHeight: _topToolbarHeight,
                          progress: progress,
                          identityProgress: identityProgress,
                          current: _controller.current,
                          onSearchPressed: _openCharacterSearchPage,
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

  /// 平滑切换历史角色并恢复顶部浏览位置
  ///
  /// [item] 历史角色条目
  Future<void> _selectHistoryItem(CharacterDetailHistoryItem item) async {
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _scrollController.jumpTo(0);
      } else {
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    }

    if (!mounted) {
      return;
    }

    _controller.selectHistoryItem(item);
  }

  /// 根据滚动位置更新顶部浮层状态
  void _handleScrollOffsetChanged() {
    if (!_scrollController.hasClients) {
      return;
    }

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

  /// 处理资产重组或股权融资成功后的刷新
  ///
  /// [mode] 本次提交类型
  Future<void> _handleSacrificeChanged(
    CharacterDetailSacrificeMode mode,
  ) async {
    await _controller.refreshCurrentCharacter();
    if (!mounted) {
      return;
    }

    switch (mode) {
      case CharacterDetailSacrificeMode.restructure:
        _publicCollectionsRefreshSignal.value += 1;
      case CharacterDetailSacrificeMode.financing:
        _publicBoardRefreshSignal.value += 1;
    }
  }

  /// 打开 Tinygrail 授权页并刷新角色详情登录状态
  Future<void> _openAuthPage() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) {
          return TinygrailAuthPage(
            authRepository: widget.authRepository,
            preferences: widget.preferences,
            onAuthenticated: _controller.refreshCurrentUserSession,
          );
        },
      ),
    );
  }

  /// 打开角色搜索页
  Future<void> _openCharacterSearchPage() {
    return showCharacterSearchPage(
      context,
      repository: widget.repository,
      templeRepository: widget.templeRepository,
      magicRepository: widget.magicRepository,
      oosRepository: widget.oosRepository,
      userRepository: widget.userRepository,
    );
  }
}
