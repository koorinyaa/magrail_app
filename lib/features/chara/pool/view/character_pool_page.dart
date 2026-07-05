import 'package:flutter/material.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/chara/auction/widgets/auction_bid_sheet.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/pool/controller/character_pool_controller.dart';
import 'package:magrail_app/features/chara/pool/widgets/character_pool_assets.dart';
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
class _CharacterPoolPageState extends State<CharacterPoolPage> {
  late final CharacterPoolPageController _controller;

  bool get _isAuctionEnabled => widget.rowType == CharacterPoolRowType.valhalla;

  /// 初始化角色池二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = CharacterPoolPageController(
      repository: widget.repository,
      username: widget.username,
      auctionRepository: _isAuctionEnabled ? widget.auctionRepository : null,
    )..initialize();
  }

  /// 释放角色池二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建角色池二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailPagedSliverPage(
      controller: _controller,
      title: widget.title,
      loadingSliver: CharacterPoolSkeletonSliverList(
        rowType: widget.rowType,
      ),
      emptySliverBuilder: (context, controller) {
        return PagedSliverState(
          title: widget.emptyTitle,
          message: widget.emptyMessage,
          icon: widget.emptyIcon,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          CharacterPoolSliverList(
            items: items,
            rowType: widget.rowType,
            auctionMap: _controller.auctionMap,
            onItemBuilt: onItemBuilt,
            onCharacterTap: _openCharacterDetail,
            onAuctionPressed: _isAuctionEnabled ? _openAuction : null,
          ),
        ];
      },
      completedLabel: widget.completedLabel,
    );
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
      AppToast.error(context, text: '请先登录');
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
        AppToast.error(context, text: '请先登录');
        return false;
      case UserAssetsFetchStatus.failure:
        AppToast.error(
          context,
          text: result.message ?? '用户资产加载失败',
        );
        return false;
    }
  }
}
