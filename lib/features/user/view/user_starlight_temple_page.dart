import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_dialog.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_database.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_repository.dart';
import 'package:magrail_app/features/user/controller/user_starlight_temple_page_controller.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_temple_responsive_grid.dart';

/// 用户星光圣殿二级页面
class UserStarlightTemplePage extends StatefulWidget {
  /// 创建用户星光圣殿二级页面
  ///
  /// [key] Flutter 组件标识
  /// [userRepository] 用户仓库
  /// [characterDetailRepository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [templeAssetMagicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [currentUserName] 当前登录用户名
  const UserStarlightTemplePage({
    super.key,
    required this.userRepository,
    required this.characterDetailRepository,
    required this.templeRepository,
    required this.templeAssetMagicRepository,
    required this.oosRepository,
    required this.username,
    this.nickname,
    this.currentUserName = '',
  });

  /// 用户仓库
  final UserRepository userRepository;

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

  /// 创建用户星光圣殿二级页面状态
  @override
  State<UserStarlightTemplePage> createState() =>
      _UserStarlightTemplePageState();
}

/// 用户星光圣殿二级页面状态
class _UserStarlightTemplePageState extends State<UserStarlightTemplePage> {
  late final UserStarlightTemplePageController _controller;

  /// 初始化用户星光圣殿二级页面状态
  @override
  void initState() {
    super.initState();
    final snapshotDatabase = UserAssetSnapshotDatabase();
    _controller = UserStarlightTemplePageController(
      snapshotRepository: UserAssetSnapshotRepository(
        userRepository: widget.userRepository,
        database: snapshotDatabase,
      ),
      username: widget.username,
    )..initialize();
  }

  /// 释放用户星光圣殿二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建用户星光圣殿二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailPagedSliverPage(
      controller: _controller,
      title: _title,
      loadingSliver: const UserTempleSkeletonGrid(),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无星光圣殿',
          message: '当前用户没有星光圣殿',
          icon: Icons.hourglass_empty_rounded,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          UserTempleResponsiveGrid(
            items: items,
            ownerLabel: _ownerLabel,
            onItemBuilt: onItemBuilt,
            onCharacterTap: _openCharacterDetail,
            onAssetTap: _openTempleAssetDialog,
          ),
        ];
      },
      completedLabel: '没有更多星光圣殿了',
      initialErrorMessage: '圣殿快照已失效，请返回资产分析刷新',
      refreshErrorText: '圣殿快照已失效，请返回资产分析刷新',
    );
  }

  /// 页面标题
  String get _title {
    final nickname = widget.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return '$nickname的星光圣殿';
    }
    if (widget.username.isNotEmpty) {
      return '${widget.username}的星光圣殿';
    }

    return '星光圣殿';
  }

  /// 用户展示文案
  String get _ownerLabel {
    final nickname = widget.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return '@$nickname';
    }

    return '@${widget.username}';
  }

  /// 打开星光圣殿角色详情
  ///
  /// [item] 用户圣殿条目
  void _openCharacterDetail(UserTempleApiItem item) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.name,
    );
  }

  /// 打开星光圣殿资产弹窗
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
        userRepository: widget.userRepository,
        currentUserName: widget.currentUserName,
      ),
    );
  }
}
