import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_collections_controller.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_board_page_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_board_member.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_board_sliver_list.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_dialog.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 角色董事会二级页面
class CharacterDetailBoardPage extends StatefulWidget {
  /// 创建角色董事会二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  /// [totalShares] 角色流通股份
  /// [currentUserName] 当前登录用户名
  /// [collectionsController] 一级页面共享的公开展示区控制器
  const CharacterDetailBoardPage({
    super.key,
    required this.repository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
    required this.characterId,
    required this.characterName,
    required this.totalShares,
    required this.currentUserName,
    this.collectionsController,
  });

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// 圣殿仓库
  final TempleRepository templeRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository magicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 角色流通股份
  final int totalShares;

  /// 当前登录用户名
  final String currentUserName;

  /// 一级页面共享的公开展示区控制器
  final CharacterDetailCollectionsController? collectionsController;

  /// 创建角色董事会二级页面状态
  @override
  State<CharacterDetailBoardPage> createState() =>
      _CharacterDetailBoardPageState();
}

/// 角色董事会二级页面状态
class _CharacterDetailBoardPageState extends State<CharacterDetailBoardPage> {
  late final CharacterDetailBoardPageController _controller;

  /// 初始化角色董事会二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = CharacterDetailBoardPageController(
      repository: widget.repository,
      characterId: widget.characterId,
      collectionsController: widget.collectionsController,
    )..initialize();
  }

  /// 释放角色董事会二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建角色董事会二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailPagedSliverPage<CharacterDetailBoardMember,
        CharacterDetailBoardMember>(
      controller: _controller,
      title: _title,
      loadingSliver: const CharacterDetailBoardSkeletonSliverList(),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无持股用户',
          message: '当前角色没有可展示的持股用户',
          icon: Icons.groups_2_outlined,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          CharacterDetailBoardSliverList(
            items: items,
            totalShares: widget.totalShares,
            templeFor: _controller.templeFor,
            onItemBuilt: onItemBuilt,
            onMemberTap: _openUser,
            onTempleTap: _openTempleAssetCard,
          ),
        ];
      },
      completedLabel: '没有更多持股用户了',
    );
  }

  /// 打开圣殿资产卡片弹窗
  ///
  /// [temple] 董事会成员对应圣殿
  void _openTempleAssetCard(CharacterDetailTempleItem temple) {
    unawaited(
      showTempleAssetCardDialogFromSource(
        context,
        source: _sourceForTemple(temple),
        characterRepository: widget.repository,
        templeRepository: widget.templeRepository,
        magicRepository: widget.magicRepository,
        oosRepository: widget.oosRepository,
        userRepository: widget.userRepository,
        currentUserName: widget.currentUserName,
      ),
    );
  }

  /// 创建圣殿资产弹窗入口数据
  ///
  /// [temple] 董事会成员对应圣殿
  TempleAssetDialogSource _sourceForTemple(CharacterDetailTempleItem temple) {
    final characterId =
        temple.characterId > 0 ? temple.characterId : widget.characterId;

    return TempleAssetDialogSource(
      ownerName: temple.ownerName,
      ownerNickname: temple.ownerNickname,
      characterId: characterId,
    );
  }

  /// 打开用户详情
  ///
  /// [member] 董事会成员
  void _openUser(CharacterDetailBoardMember member) {
    final username = member.name.trim();
    if (username.isEmpty) {
      return;
    }

    context.pushNamed(
      'userDetail',
      queryParameters: {'username': username},
    );
  }

  /// 页面标题
  String get _title {
    final name = TinygrailFormatters.decodeHtmlEntities(
      widget.characterName,
    ).trim();
    return name.isEmpty ? '角色董事会' : '$name的董事会';
  }
}
