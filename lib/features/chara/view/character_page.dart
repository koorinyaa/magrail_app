import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/widgets/page_section_sliver.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/chara/auction/widgets/auction_bid_sheet.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/pool/controller/character_pool_controller.dart';
import 'package:magrail_app/features/chara/pool/widgets/character_pool_assets.dart';
import 'package:magrail_app/features/chara/rank/controller/character_rank_controller.dart';
import 'package:magrail_app/features/chara/rank/model/character_rank_entry.dart';
import 'package:magrail_app/features/chara/rank/repository/character_rank_repository.dart';
import 'package:magrail_app/features/chara/rank/widgets/character_rank_section.dart';
import 'package:magrail_app/features/user/model/user_assets_fetch_result.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 角色一级页面
class CharacterPage extends StatefulWidget {
  /// 创建角色一级页面
  ///
  /// [key] Flutter 组件标识
  /// [scrollController] 角色页滚动控制器
  /// [authRepository] Tinygrail 授权仓库
  /// [userRepository] 用户资产仓库
  /// [auctionRepository] 拍卖仓库
  /// [rankRepository] 角色排序仓库
  const CharacterPage({
    super.key,
    required this.scrollController,
    required this.authRepository,
    required this.userRepository,
    required this.auctionRepository,
    required this.rankRepository,
  });

  /// 角色页滚动控制器
  final ScrollController scrollController;

  /// Tinygrail 授权仓库
  final TinygrailAuthRepository authRepository;

  /// 用户资产仓库
  final UserRepository userRepository;

  /// 拍卖仓库
  final AuctionRepository auctionRepository;

  /// 角色排序仓库
  final CharacterRankRepository rankRepository;

  /// 创建角色一级页面状态
  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

/// 角色一级页面状态
class _CharacterPageState extends State<CharacterPage> {
  late final CharacterPoolPreviewController _valhallaController;
  late final CharacterPoolPreviewController _gensokyoController;
  late final CharacterRankPageController _allCharactersController;
  late final Listenable _contentListenable;

  /// 初始化角色一级页面状态
  @override
  void initState() {
    super.initState();
    _valhallaController = CharacterPoolPreviewController(
      repository: widget.userRepository,
      username: characterPoolValhallaUsername,
      auctionRepository: widget.auctionRepository,
    )..initialize();
    _gensokyoController = CharacterPoolPreviewController(
      repository: widget.userRepository,
      username: characterPoolGensokyoUsername,
    )..initialize();
    _allCharactersController = CharacterRankPageController(
      repository: widget.rankRepository,
      sortType: CharacterRankSortType.highestRate,
    )..initialize();
    _contentListenable = Listenable.merge([
      _valhallaController,
      _gensokyoController,
      _allCharactersController,
    ]);
  }

  /// 释放角色一级页面状态
  @override
  void dispose() {
    _valhallaController.dispose();
    _gensokyoController.dispose();
    _allCharactersController.dispose();
    super.dispose();
  }

  /// 构建角色一级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _contentListenable,
      builder: (context, child) {
        return RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              PageSectionSliver(
                title: '英灵殿',
                trailing: _buildCountTrailing(context, _valhallaController),
                onHeaderTap: _openValhallaPage,
                child: _buildPoolContent(
                  context,
                  controller: _valhallaController,
                  rowType: CharacterPoolRowType.valhalla,
                  emptyMessage: '暂无英灵殿角色',
                  loadFailedMessage: '英灵殿加载失败',
                  onRetry: _valhallaController.refresh,
                  onAuctionPressed: _openValhallaAuction,
                ),
              ),
              PageSectionSliver(
                topSpacing: 22,
                title: '幻想乡',
                trailing: _buildCountTrailing(context, _gensokyoController),
                onHeaderTap: _openGensokyoPage,
                child: _buildPoolContent(
                  context,
                  controller: _gensokyoController,
                  rowType: CharacterPoolRowType.gensokyo,
                  emptyMessage: '暂无幻想乡角色',
                  loadFailedMessage: '幻想乡加载失败',
                  onRetry: _gensokyoController.refresh,
                ),
              ),
              PageSectionSliver(
                topSpacing: 22,
                title: '所有角色',
                onHeaderTap: _openAllCharactersPage,
                child: _buildRankPreview(context),
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

  /// 刷新角色一级页面
  Future<void> _refresh() async {
    await Future.wait([
      _valhallaController.refresh(),
      _gensokyoController.refresh(),
      _allCharactersController.refresh(),
    ]);
  }

  /// 构建角色池内容
  ///
  /// [context] 当前组件树上下文
  /// [controller] 角色池预览控制器
  /// [rowType] 角色池资产行类型
  /// [emptyMessage] 空状态文案
  /// [loadFailedMessage] 加载失败文案
  /// [onRetry] 重试回调
  /// [onAuctionPressed] 竞拍按钮点击回调
  Widget _buildPoolContent(
    BuildContext context, {
    required CharacterPoolPreviewController controller,
    required CharacterPoolRowType rowType,
    required String emptyMessage,
    required String loadFailedMessage,
    required Future<void> Function() onRetry,
    ValueChanged<UserCharacterApiItem>? onAuctionPressed,
  }) {
    final items = controller.items ?? const <UserCharacterApiItem>[];
    final showFailed = controller.isLoadFailed && items.isEmpty;
    if (showFailed) {
      return Padding(
        padding: AppSafeAreaInsets.fromLTRB(
          context,
          left: 24,
          top: 0,
          right: 24,
          bottom: 0,
        ),
        child: CharacterPoolOverviewMessage(
          message: loadFailedMessage,
          onRetry: onRetry,
        ),
      );
    }

    return CharacterPoolCarousel(
      items: controller.items,
      rowType: rowType,
      auctionMap: controller.auctionMap,
      isLoading: controller.isLoading,
      emptyMessage: emptyMessage,
      onCharacterTap: _openCharacterDetail,
      onAuctionPressed: onAuctionPressed,
    );
  }

  /// 构建所有角色预览
  ///
  /// [context] 当前组件树上下文
  Widget _buildRankPreview(BuildContext context) {
    final items = _allCharactersController.items;
    if (_allCharactersController.initialError != null && items.isEmpty) {
      return Padding(
        padding: AppSafeAreaInsets.fromLTRB(
          context,
          left: 24,
          top: 0,
          right: 24,
          bottom: 0,
        ),
        child: CharacterPoolOverviewMessage(
          message: '所有角色加载失败',
          onRetry: _allCharactersController.refresh,
        ),
      );
    }

    return CharacterRankCarousel(
      items: items,
      selectedType: CharacterRankSortType.highestRate,
      isLoading: _allCharactersController.isInitialLoading,
      emptyMessage: '暂无所有角色',
      onCharacterTap: _openRankCharacterDetail,
    );
  }

  /// 打开英灵殿二级页面
  void _openValhallaPage() {
    context.pushNamed('valhallaCharacters');
  }

  /// 打开幻想乡二级页面
  void _openGensokyoPage() {
    context.pushNamed('gensokyoCharacters');
  }

  /// 打开所有角色二级页面
  void _openAllCharactersPage() {
    context.pushNamed('allCharacters');
  }

  /// 打开角色详情页
  ///
  /// [item] 角色池条目
  /// [avatarHeroTag] 头像转场标识
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

  /// 打开角色排序条目的角色详情页
  ///
  /// [item] 角色排序条目
  /// [avatarHeroTag] 头像转场标识
  void _openRankCharacterDetail(
    CharacterRankEntry item,
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

  /// 打开英灵殿竞拍底部抽屉
  ///
  /// [item] 英灵殿角色条目
  Future<void> _openValhallaAuction(UserCharacterApiItem item) async {
    final isAuthorized = await _ensureTinygrailAuthorized();
    if (!mounted || !isAuthorized) {
      return;
    }

    await showAuctionBidSheet(
      context,
      repository: widget.auctionRepository,
      characterId: item.characterId,
      characterName: item.name,
      basePrice: item.price,
      maxAmount: item.state,
      initialAuction: _valhallaController.auctionMap[item.characterId],
      onChanged: () {
        return _valhallaController.refreshAuctionStatusForCharacter(
          item.characterId,
        );
      },
    );
  }

  /// 确保 Tinygrail 会话可用于拍卖操作
  Future<bool> _ensureTinygrailAuthorized() async {
    final hasCookie = await widget.authRepository.hasTinygrailCookie();
    if (!mounted) {
      return false;
    }

    if (!hasCookie) {
      AppToast.error(context, text: '请先登录');
      return false;
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
          text: '请先登录',
        );
        return false;
      case UserAssetsFetchStatus.failure:
        AppToast.error(
          context,
          text: result.message ?? '用户资产加载失败',
        );
        return false;
    }
  }

  /// 构建角色池右侧数量文本
  ///
  /// [context] 当前组件树上下文
  /// [controller] 角色池预览控制器
  Widget? _buildCountTrailing(
    BuildContext context,
    CharacterPoolPreviewController controller,
  ) {
    final count = _resolveCount(controller);
    if (count == null) {
      return null;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: Text(
        '${Formatters.groupedNumber(count)} 个角色',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }

  /// 解析角色池角色数量
  ///
  /// [controller] 角色池预览控制器
  int? _resolveCount(CharacterPoolPreviewController controller) {
    final visibleCount = controller.items?.length ?? 0;
    final totalItems = controller.totalItems;
    if (totalItems == null && visibleCount <= 0) {
      return null;
    }

    return totalItems != null && totalItems > 0 ? totalItems : visibleCount;
  }
}
