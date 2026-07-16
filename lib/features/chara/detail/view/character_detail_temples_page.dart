import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_collections_controller.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_temples_page_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_collections_grid.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_dialog.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 角色固定资产二级页面
class CharacterDetailTemplesPage extends StatefulWidget {
  /// 创建角色固定资产二级页面
  ///
  /// [key] Flutter 组件标识
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  /// [avatarUrl] 角色头像地址
  /// [repository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  /// [collectionsController] 一级页面共享的公开展示区控制器
  /// [currentUserName] 当前登录用户名
  const CharacterDetailTemplesPage({
    super.key,
    required this.characterId,
    required this.characterName,
    required this.avatarUrl,
    required this.repository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
    this.collectionsController,
    this.currentUserName = '',
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 角色头像地址
  final String avatarUrl;

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

  /// 一级页面共享的公开展示区控制器
  final CharacterDetailCollectionsController? collectionsController;

  /// 当前登录用户名
  final String currentUserName;

  /// 创建角色固定资产二级页面状态
  @override
  State<CharacterDetailTemplesPage> createState() =>
      _CharacterDetailTemplesPageState();
}

/// 角色固定资产二级页面状态
class _CharacterDetailTemplesPageState
    extends State<CharacterDetailTemplesPage> {
  late final CharacterDetailTemplesPageController _controller;

  /// 初始化角色固定资产二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = CharacterDetailTemplesPageController(
      collectionsController: widget.collectionsController,
    );
  }

  /// 释放角色固定资产二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建角色固定资产二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final isStateOnlyContent = _controller.items.isEmpty;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SecondaryPageSliverAppBar(title: _title),
              if (_controller.items.isEmpty)
                const PagedSliverState(
                  title: '暂无圣殿',
                  message: '当前角色没有可展示的圣殿',
                  icon: Icons.account_balance_outlined,
                )
              else
                CharacterDetailTempleGrid(
                  items: _controller.items,
                  fallbackCharacterName: widget.characterName,
                  onCharacterTap: _openCharacter,
                  onOwnerTap: _openOwner,
                  onAssetTap: _openTempleAssetCard,
                  onLinkedAssetTap: _openLinkedTempleAssetCard,
                ),
              if (!isStateOnlyContent)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 24 + MediaQuery.paddingOf(context).bottom,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// 页面标题
  String get _title {
    final name = TinygrailFormatters.decodeHtmlEntities(
      widget.characterName,
    ).trim();
    return name.isEmpty ? '角色圣殿' : '$name的圣殿';
  }

  /// 打开固定资产角色详情
  ///
  /// [item] 角色详情圣殿条目
  void _openCharacter(CharacterDetailTempleItem item) {
    if (item.characterId <= 0 || item.characterId == widget.characterId) {
      return;
    }

    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: _routeCharacterName(item),
      avatarUrl: item.avatar,
    );
  }

  /// 打开固定资产拥有者详情
  ///
  /// [item] 角色详情圣殿条目
  void _openOwner(CharacterDetailTempleItem item) {
    final username = item.ownerName.trim();
    if (username.isEmpty) {
      return;
    }

    context.pushNamed(
      'userDetail',
      queryParameters: {'username': username},
    );
  }

  /// 打开圣殿资产卡片弹窗
  ///
  /// [item] 角色详情圣殿条目
  void _openTempleAssetCard(CharacterDetailTempleItem item) {
    unawaited(
      showTempleAssetCardDialogFromSource(
        context,
        source: _sourceForTemple(item),
        characterRepository: widget.repository,
        templeRepository: widget.templeRepository,
        magicRepository: widget.magicRepository,
        oosRepository: widget.oosRepository,
        userRepository: widget.userRepository,
        currentUserName: widget.currentUserName,
      ),
    );
  }

  /// 打开 LINK 圣殿资产卡片弹窗
  ///
  /// [ownerItem] 提供拥有者字段的角色圣殿条目
  /// [linkedItem] 提供角色字段的 LINK 圣殿条目
  void _openLinkedTempleAssetCard(
    CharacterDetailTempleItem ownerItem,
    CharacterDetailTempleItem linkedItem,
  ) {
    unawaited(
      showTempleAssetCardDialogFromSource(
        context,
        source: _sourceForTemple(
          ownerItem,
          characterId: linkedItem.characterId,
        ),
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
  /// [item] 角色详情圣殿条目
  /// [characterId] 覆盖打开的角色 ID
  TempleAssetDialogSource _sourceForTemple(
    CharacterDetailTempleItem item, {
    int? characterId,
  }) {
    final resolvedCharacterId = characterId ??
        (item.characterId > 0 ? item.characterId : widget.characterId);

    return TempleAssetDialogSource(
      ownerName: item.ownerName,
      ownerNickname: item.ownerNickname,
      characterId: resolvedCharacterId,
    );
  }

  /// 获取角色跳转名称
  ///
  /// [item] 角色详情圣殿条目
  String? _routeCharacterName(CharacterDetailTempleItem item) {
    final name = item.characterName.trim();
    if (name.isNotEmpty) {
      return name;
    }

    if (item.characterId == widget.characterId) {
      final currentName = widget.characterName.trim();
      return currentName.isEmpty ? null : currentName;
    }

    return null;
  }
}
