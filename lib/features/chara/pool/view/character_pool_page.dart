import 'package:flutter/material.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/chara/auction/widgets/auction_bid_sheet.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/pool/controller/character_pool_controller.dart';
import 'package:magrail_app/features/chara/pool/widgets/character_pool_assets.dart';
import 'package:magrail_app/features/chara/view/character_full_list_page_state_mixin.dart';
import 'package:magrail_app/features/user/model/user_assets_fetch_result.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 角色池二级页面
class CharacterPoolPage extends StatefulWidget {
  /// 创建角色池二级页面
  ///
  /// [key] Flutter 组件标识
  /// [title] 页面标题
  /// [username] 角色池账号
  /// [rowType] 角色池资产行类型
  /// [authRepository] Tinygrail 授权仓库
  /// [repository] 用户资产仓库
  /// [auctionRepository] 拍卖仓库
  /// [emptyTitle] 空状态标题
  /// [emptyMessage] 空状态说明
  /// [emptyIcon] 空状态图标
  /// [completedLabel] 分页完成文案
  const CharacterPoolPage({
    super.key,
    required this.title,
    required this.username,
    required this.rowType,
    required this.authRepository,
    required this.repository,
    required this.auctionRepository,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.completedLabel,
  });

  /// 页面标题
  final String title;

  /// 角色池账号
  final String username;

  /// 角色池资产行类型
  final CharacterPoolRowType rowType;

  /// Tinygrail 授权仓库
  final TinygrailAuthRepository authRepository;

  /// 用户资产仓库
  final UserRepository repository;

  /// 拍卖仓库
  final AuctionRepository auctionRepository;

  /// 空状态标题
  final String emptyTitle;

  /// 空状态说明
  final String emptyMessage;

  /// 空状态图标
  final IconData emptyIcon;

  /// 分页完成文案
  final String completedLabel;

  /// 创建角色池二级页面状态
  @override
  State<CharacterPoolPage> createState() => _CharacterPoolPageState();
}

/// 角色池二级页面状态
class _CharacterPoolPageState extends State<CharacterPoolPage>
    with
        CharacterFullListPageStateMixin<
          UserCharacterApiItem,
          CharacterPoolPage
        > {
  late final CharacterPoolPageController _controller;

  /// 当前角色池全量列表控制器
  @override
  CharacterPoolPageController get fullListController => _controller;

  /// 判断当前角色池是否启用拍卖操作
  bool get _isAuctionEnabled => widget.rowType == CharacterPoolRowType.valhalla;

  /// 初始化角色池二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = CharacterPoolPageController(
      repository: widget.repository,
      username: widget.username,
      auctionRepository: _isAuctionEnabled ? widget.auctionRepository : null,
      waitForScrollIdle: waitForFullListScrollIdle,
      onBeforeFullItemsReplaced: preserveFullListVisibleItem,
      onDataRefreshFailed: showFullListRefreshFailed,
    )..initialize();
  }

  /// 释放角色池二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    disposeFullListPageState();
    super.dispose();
  }

  /// 构建角色池二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final page = TinygrailPagedSliverPage(
          controller: _controller,
          title: widget.title,
          titleSupplement: _buildTitleSupplement(),
          appBarBottom: buildFullListSortToolbar(),
          scrollController: fullListScrollController,
          loadingSliver: CharacterPoolSkeletonSliverList(
            rowType: widget.rowType,
          ),
          emptySliverBuilder: (context, controller) {
            final isFiltering = _controller.searchKeyword.isNotEmpty;
            return PagedSliverState(
              title: isFiltering ? '未找到角色' : widget.emptyTitle,
              message: isFiltering ? '没有符合搜索条件的角色' : widget.emptyMessage,
              icon: isFiltering ? Icons.search_off_rounded : widget.emptyIcon,
            );
          },
          contentSliversBuilder: (context, items, onItemBuilt) {
            return [
              CharacterPoolSliverList(
                items: items,
                rowType: widget.rowType,
                auctionMap: _controller.auctionMap,
                sort: _controller.hasFullData ? _controller.sort : null,
                showLevelHeaders: _controller.showsLevelHeaders,
                onItemBuilt: onItemBuilt,
                onCharacterTap: _openCharacterDetail,
                onAuctionPressed: _isAuctionEnabled ? _openAuction : null,
              ),
            ];
          },
          completedLabel: widget.completedLabel,
          bottomContentPadding: fullListBottomContentPadding,
          refreshErrorText: '数据刷新失败',
        );
        return buildFullListOverlay(child: page);
      },
    );
  }

  /// 构建接口总数标题辅助文本
  String? _buildTitleSupplement() {
    final count = _controller.totalItems;
    if (count == null) {
      return null;
    }
    return '(${Formatters.groupedNumber(count)} 个角色)';
  }

  /// 打开角色详情页
  ///
  /// [item] 角色池条目
  /// [avatarHeroTag] 头像转场标识
  void _openCharacterDetail(UserCharacterApiItem item, String? avatarHeroTag) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.name,
      avatarUrl: item.icon,
      avatarHeroTag: avatarHeroTag,
    );
  }

  /// 打开竞拍底部抽屉
  ///
  /// [item] 角色池条目
  Future<void> _openAuction(UserCharacterApiItem item) async {
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
      initialAuction: _controller.auctionMap[item.characterId],
      onChanged: () {
        return _controller.refreshAuctionStatusForCharacter(item.characterId);
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
      AppToast.error(context, text: '该功能需要授权后才能使用');
      return false;
    }

    final cached = widget.repository.readCachedCurrentUserAssets();
    if (cached != null) {
      return true;
    }

    final result = await widget.repository.fetchUserAssets();
    if (!mounted) {
      return false;
    }

    switch (result.status) {
      case UserAssetsFetchStatus.success:
        return true;
      case UserAssetsFetchStatus.authExpired:
        AppToast.error(context, text: '该功能需要授权后才能使用');
        return false;
      case UserAssetsFetchStatus.failure:
        AppToast.error(context, text: result.message ?? '用户资产加载失败');
        return false;
    }
  }
}
