import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/controller/latest_link_page_controller.dart';
import 'package:magrail_app/features/temple/model/latest_link_api_item.dart';
import 'package:magrail_app/features/temple/model/latest_link_pair.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_dialog.dart';
import 'package:magrail_app/features/temple/widgets/latest_link_responsive_grid.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 最新连接二级页面
class LatestLinkPage extends StatefulWidget {
  /// 创建最新连接二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 圣殿仓库
  /// [characterDetailRepository] 角色详情仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  const LatestLinkPage({
    super.key,
    required this.repository,
    required this.characterDetailRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
  });

  /// 圣殿页面使用的仓库
  final TempleRepository repository;

  /// 角色详情仓库
  final CharacterDetailRepository characterDetailRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository magicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 创建最新连接二级页面状态
  @override
  State<LatestLinkPage> createState() => _LatestLinkPageState();
}

/// 最新连接二级页面状态
class _LatestLinkPageState extends State<LatestLinkPage> {
  late final LatestLinkPageController _controller;

  /// 初始化最新连接二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = LatestLinkPageController(
      repository: widget.repository,
    )..initialize();
  }

  /// 释放最新连接二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建最新连接二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailPagedSliverPage(
      controller: _controller,
      title: '最新连接',
      loadingSliver: const LatestLinkSkeletonGrid(),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无最新连接',
          message: '当前没有可展示的角色连接',
          icon: Icons.hourglass_empty_rounded,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          LatestLinkResponsiveGrid(
            items: items,
            onCharacterTap: _openCharacter,
            onUserTap: _openUser,
            onItemBuilt: onItemBuilt,
            onAssetTap: _openTempleAssetDialog,
          ),
        ];
      },
      completedLabel: '没有更多连接了',
    );
  }

  /// 打开最新连接角色详情
  ///
  /// [item] 最新连接接口条目
  void _openCharacter(LatestLinkApiItem item) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.characterName,
    );
  }

  /// 打开最新连接用户详情
  ///
  /// [pair] 最新连接展示组
  void _openUser(LatestLinkPair pair) {
    context.pushNamed(
      'userDetail',
      queryParameters: {'username': pair.ownerName},
    );
  }

  /// 打开圣殿资产弹窗
  ///
  /// [pair] 最新连接展示组
  /// [item] 被点击的连接侧圣殿条目
  void _openTempleAssetDialog(
    LatestLinkPair pair,
    LatestLinkApiItem item,
  ) {
    unawaited(
      showTempleAssetCardDialogFromSource(
        context,
        source: TempleAssetDialogSource(
          ownerName: pair.ownerName,
          ownerNickname: pair.ownerNickname,
          characterId: item.characterId,
        ),
        characterRepository: widget.characterDetailRepository,
        templeRepository: widget.repository,
        magicRepository: widget.magicRepository,
        oosRepository: widget.oosRepository,
        userRepository: widget.userRepository,
        currentUserName: _currentUserName,
      ),
    );
  }

  /// 当前登录用户名
  String get _currentUserName {
    return widget.userRepository.readCachedCurrentUserAssets()?.name ?? '';
  }
}
