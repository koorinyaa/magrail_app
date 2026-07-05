import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_collections_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_board_section.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_collections_section.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 角色详情公开展示区
class CharacterDetailPublicSections extends StatefulWidget {
  /// 创建角色详情公开展示区
  ///
  /// [key] Flutter 组件标识
  /// [repository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  /// [header] 角色详情已上市头部资料
  /// [currentUserName] 当前登录用户名
  /// [collectionsRefreshSignal] 连接与圣殿预览刷新信号
  /// [boardRefreshSignal] 董事会预览刷新信号
  const CharacterDetailPublicSections({
    super.key,
    required this.repository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
    required this.header,
    required this.currentUserName,
    required this.collectionsRefreshSignal,
    required this.boardRefreshSignal,
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

  /// 角色详情已上市头部资料
  final CharacterDetailTradeHeader header;

  /// 当前登录用户名
  final String currentUserName;

  /// 连接与圣殿预览刷新信号
  final ValueListenable<int> collectionsRefreshSignal;

  /// 董事会预览刷新信号
  final ValueListenable<int> boardRefreshSignal;

  /// 创建角色详情公开展示区状态
  @override
  State<CharacterDetailPublicSections> createState() =>
      _CharacterDetailPublicSectionsState();
}

/// 角色详情公开展示区状态
class _CharacterDetailPublicSectionsState
    extends State<CharacterDetailPublicSections> {
  late CharacterDetailCollectionsController _controller;
  late final ValueNotifier<int> _boardRefreshSignal;

  /// 初始化角色详情公开展示区状态
  @override
  void initState() {
    super.initState();
    _boardRefreshSignal = ValueNotifier<int>(0);
    _controller = _createController();
    widget.collectionsRefreshSignal.addListener(_handleCollectionsRefresh);
    widget.boardRefreshSignal.addListener(_handleBoardRefresh);
  }

  /// 处理角色详情公开展示区配置变化
  ///
  /// [oldWidget] 更新前的公开展示区配置
  @override
  void didUpdateWidget(covariant CharacterDetailPublicSections oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collectionsRefreshSignal != widget.collectionsRefreshSignal) {
      oldWidget.collectionsRefreshSignal.removeListener(
        _handleCollectionsRefresh,
      );
      widget.collectionsRefreshSignal.addListener(_handleCollectionsRefresh);
    }
    if (oldWidget.boardRefreshSignal != widget.boardRefreshSignal) {
      oldWidget.boardRefreshSignal.removeListener(_handleBoardRefresh);
      widget.boardRefreshSignal.addListener(_handleBoardRefresh);
    }

    if (widget.header.characterId == oldWidget.header.characterId &&
        widget.repository == oldWidget.repository) {
      if (!identical(widget.header, oldWidget.header)) {
        _notifyBoardRefresh();
      }
      return;
    }

    _controller.dispose();
    _controller = _createController();
    _notifyBoardRefresh();
  }

  /// 释放角色详情公开展示区状态
  @override
  void dispose() {
    widget.collectionsRefreshSignal.removeListener(_handleCollectionsRefresh);
    widget.boardRefreshSignal.removeListener(_handleBoardRefresh);
    _controller.dispose();
    _boardRefreshSignal.dispose();
    super.dispose();
  }

  /// 构建角色详情公开展示区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        CharacterDetailBoardSection(
          repository: widget.repository,
          templeRepository: widget.templeRepository,
          magicRepository: widget.magicRepository,
          oosRepository: widget.oosRepository,
          userRepository: widget.userRepository,
          header: widget.header,
          collectionsController: _controller,
          currentUserName: widget.currentUserName,
          boardRefreshSignal: _boardRefreshSignal,
        ),
        CharacterDetailCollectionsSection(
          controller: _controller,
          repository: widget.repository,
          templeRepository: widget.templeRepository,
          magicRepository: widget.magicRepository,
          oosRepository: widget.oosRepository,
          userRepository: widget.userRepository,
          header: widget.header,
          currentUserName: widget.currentUserName,
        ),
      ],
    );
  }

  /// 创建公开展示区控制器
  CharacterDetailCollectionsController _createController() {
    return CharacterDetailCollectionsController(
      repository: widget.repository,
      characterId: widget.header.characterId,
    )..initialize();
  }

  /// 通知董事会刷新
  void _notifyBoardRefresh() {
    _boardRefreshSignal.value += 1;
  }

  /// 处理连接与圣殿预览刷新信号
  void _handleCollectionsRefresh() {
    unawaited(_controller.loadLinks());
    unawaited(_controller.loadTemples());
    _notifyBoardRefresh();
  }

  /// 处理董事会预览刷新信号
  void _handleBoardRefresh() {
    _notifyBoardRefresh();
  }
}
