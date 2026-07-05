import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_dialog.dart';
import 'package:magrail_app/features/user/controller/user_link_page_controller.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_link_responsive_grid.dart';

/// 用户连接二级页面
class UserLinkPage extends StatefulWidget {
  /// 创建用户连接二级页面
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
  const UserLinkPage({
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

  /// 创建用户连接二级页面状态
  @override
  State<UserLinkPage> createState() => _UserLinkPageState();
}

/// 用户连接二级页面状态
class _UserLinkPageState extends State<UserLinkPage> {
  late final UserLinkPageController _controller;

  /// 初始化用户连接二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = UserLinkPageController(
      repository: widget.repository,
      username: widget.username,
    )..initialize();
  }

  /// 释放用户连接二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建用户连接二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailPagedSliverPage(
      controller: _controller,
      title: _title,
      loadingSliver: const UserLinkSkeletonGrid(),
      emptySliverBuilder: (context, controller) {
        final isSearchingMoreFromEmpty =
            controller.items.isEmpty && controller.isLoadingMore;
        final canContinueSearching = controller.items.isEmpty &&
            !isSearchingMoreFromEmpty &&
            controller.canLoadMore;
        final emptyTitle = isSearchingMoreFromEmpty
            ? '正在查找连接'
            : canContinueSearching
                ? '继续查找连接'
                : '暂无连接';
        final emptyMessage = isSearchingMoreFromEmpty
            ? '正在从后续数据中查找可展示连接'
            : canContinueSearching
                ? '当前已加载数据暂无可展示连接，可继续查找后续数据'
                : '当前用户没有可展示的角色连接';
        final emptyIcon = isSearchingMoreFromEmpty
            ? Icons.hourglass_top_rounded
            : canContinueSearching
                ? Icons.manage_search_rounded
                : Icons.hourglass_empty_rounded;

        return PagedSliverState(
          title: emptyTitle,
          message: emptyMessage,
          icon: emptyIcon,
          actionLabel: canContinueSearching ? '继续加载' : null,
          onActionPressed:
              canContinueSearching ? controller.loadNextPage : null,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          UserLinkResponsiveGrid(
            items: items,
            onItemBuilt: onItemBuilt,
            onCharacterTap: _openCharacterDetail,
            onAssetTap: _openTempleAssetDialog,
          ),
        ];
      },
      completedLabel: '没有更多连接了',
    );
  }

  /// 页面标题
  String get _title {
    final nickname = widget.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return '$nickname的连接';
    }

    if (widget.username.isNotEmpty) {
      return '${widget.username}的连接';
    }

    return '用户连接';
  }

  /// 打开连接角色详情
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
}
