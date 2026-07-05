import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/auction/widgets/auction_bid_sheet.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/user/controller/user_auction_page_controller.dart';
import 'package:magrail_app/features/user/model/user_auction_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_sliver_list.dart';

/// 用户拍卖二级页面
class UserAuctionPage extends StatefulWidget {
  /// 创建用户拍卖二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 用户仓库
  const UserAuctionPage({
    super.key,
    required this.repository,
  });

  /// 用户仓库
  final UserRepository repository;

  /// 创建用户拍卖二级页面状态
  @override
  State<UserAuctionPage> createState() => _UserAuctionPageState();
}

/// 用户拍卖二级页面状态
class _UserAuctionPageState extends State<UserAuctionPage> {
  late final UserAuctionPageController _controller;
  bool _isCancellingAuction = false;
  bool _hideCharacterInfo = false;

  /// 初始化用户拍卖二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = UserAuctionPageController(
      repository: widget.repository,
    )..initialize();
  }

  /// 释放用户拍卖二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建用户拍卖二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailPagedSliverPage(
      controller: _controller,
      title: '我的拍卖',
      loadingSliver: const UserAuctionSkeletonSliverList(),
      appBarActions: [
        SizedBox(
          width: kToolbarHeight,
          child: Center(
            child: IconButton(
              onPressed: _toggleCharacterInfoVisibility,
              icon: Icon(
                _hideCharacterInfo
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 22,
              ),
            ),
          ),
        ),
      ],
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无拍卖',
          message: '当前没有可展示的拍卖记录',
          icon: LucideIcons.gavel,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          UserAuctionSliverList(
            items: items,
            onItemBuilt: onItemBuilt,
            onAuctionTap: _handleAuctionTap,
            onCharacterTap: _handleCharacterTap,
            onCancelAuction: _confirmCancelAuction,
            hideCharacterInfo: _hideCharacterInfo,
          ),
        ];
      },
      completedLabel: '没有更多拍卖了',
    );
  }

  /// 处理拍卖条目点击
  ///
  /// [item] 用户拍卖条目
  void _handleAuctionTap(UserAuctionApiItem item) {
    unawaited(
      showAuctionBidSheet(
        context,
        repository: widget.repository.auctionRepository,
        characterId: item.characterId,
        characterName: item.name,
        basePrice: item.start,
        maxAmount: item.type,
        initialAuction: item.auctionDetail,
        onChanged: _controller.refresh,
      ),
    );
  }

  /// 处理拍卖角色点击
  ///
  /// [item] 用户拍卖条目
  /// [avatarHeroTag] 头像转场标识
  void _handleCharacterTap(
    UserAuctionApiItem item,
    String? avatarHeroTag,
  ) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: _hideCharacterInfo ? null : item.name,
      avatarUrl: _hideCharacterInfo ? null : item.icon,
      avatarHeroTag: _hideCharacterInfo ? null : avatarHeroTag,
    );
  }

  /// 切换拍卖角色资料显示状态
  void _toggleCharacterInfoVisibility() {
    setState(() {
      _hideCharacterInfo = !_hideCharacterInfo;
    });
  }

  /// 确认取消竞拍
  ///
  /// [item] 用户拍卖条目
  Future<void> _confirmCancelAuction(UserAuctionApiItem item) async {
    if (_isCancellingAuction) {
      return;
    }

    final name = TinygrailFormatters.decodeHtmlEntities(item.name).trim();
    final displayName = name.isEmpty ? '#${item.characterId}' : name;
    final shouldCancel = await showAppConfirmDialog(
      context,
      title: '撤销竞拍',
      message: '确定要撤销「$displayName」的竞拍吗？',
      confirmText: '撤销竞拍',
      showCancelButton: false,
      icon: LucideIcons.gavel,
    );

    if (!shouldCancel || !mounted) {
      return;
    }

    setState(() {
      _isCancellingAuction = true;
    });

    try {
      final message = await widget.repository.cancelUserAuction(item.id);
      if (!mounted) {
        return;
      }

      AppToast.info(
        context,
        text: message,
      );

      final refreshed = await _controller.refresh();
      if (!mounted || refreshed) {
        return;
      }

      AppToast.error(
        context,
        text: '拍卖列表刷新失败，请下拉重试',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.error(
        context,
        text: _resolveErrorMessage(error, fallback: '撤销竞拍失败'),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancellingAuction = false;
        });
      }
    }
  }

  /// 解析错误提示文案
  ///
  /// [error] 原始错误
  /// [fallback] 兜底文案
  String _resolveErrorMessage(
    Object error, {
    required String fallback,
  }) {
    return resolveUserErrorMessage(error, fallback: fallback);
  }
}
