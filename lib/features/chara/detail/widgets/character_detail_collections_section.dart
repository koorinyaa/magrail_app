import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/page_section_sliver.dart';
import 'package:magrail_app/core/widgets/snapping_horizontal_list_view.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_collections_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_collections_route_extra.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_link_card.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_temple_card.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_dialog.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 角色详情 LINK 与固定资产预览区
class CharacterDetailCollectionsSection extends StatefulWidget {
  /// 创建角色详情 LINK 与固定资产预览区
  ///
  /// [key] Flutter 组件标识
  /// [controller] 公开展示区控制器
  /// [repository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  /// [header] 角色详情已上市头部资料
  /// [currentUserName] 当前登录用户名
  const CharacterDetailCollectionsSection({
    super.key,
    required this.controller,
    required this.repository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
    required this.header,
    required this.currentUserName,
  });

  /// 公开展示区控制器
  final CharacterDetailCollectionsController controller;

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

  /// 创建角色详情 LINK 与固定资产预览区状态
  @override
  State<CharacterDetailCollectionsSection> createState() =>
      _CharacterDetailCollectionsSectionState();
}

/// 角色详情 LINK 与固定资产预览区状态
class _CharacterDetailCollectionsSectionState
    extends State<CharacterDetailCollectionsSection> {
  /// 公开展示区控制器
  CharacterDetailCollectionsController get _controller => widget.controller;

  /// 构建角色详情 LINK 与固定资产预览区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final slivers = <Widget>[
          if (_shouldShowLinksSection)
            PageSectionSliver(
              title: _linksTitle,
              topSpacing: 18,
              onHeaderTap:
                  _controller.isLoadingLinks || _controller.hasLinkError
                      ? null
                      : _openLinksPage,
              child: _buildLinksPreview(context),
            ),
          if (_shouldShowTemplesSection)
            PageSectionSliver(
              title: _templesTitle,
              topSpacing: 18,
              onHeaderTap:
                  _isTempleNavigationDisabled ? null : _openTemplesPage,
              child: _buildTemplesPreview(context),
            ),
        ];

        if (slivers.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverMainAxisGroup(
          slivers: slivers,
        );
      },
    );
  }

  /// 构建 LINK 预览内容
  ///
  /// [context] 当前组件树上下文
  Widget _buildLinksPreview(BuildContext context) {
    if (_controller.isLoadingLinks && _controller.links.isEmpty) {
      return const _LinkPreviewSkeleton();
    }

    if (_controller.hasLinkError) {
      return _PreviewFailedState(
        message: _controller.linkErrorMessage,
        onRetry: _controller.loadLinks,
      );
    }

    final links = _controller.previewLinks;
    return SnappingHorizontalListView(
      height: CharacterDetailLinkCard.heightForWidth(
        CharacterDetailLinkCard.defaultWidth,
      ),
      itemCount: links.length,
      itemExtent: CharacterDetailLinkCard.defaultWidth,
      separatorExtent: 12,
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 24,
        top: 0,
        right: 24,
        bottom: 0,
      ),
      itemBuilder: (context, index) {
        return CharacterDetailLinkCard(
          item: links[index],
          fallbackCharacterName: widget.header.name,
          heroTagPrefix: 'character-link-preview-$index',
          onCharacterTap: _openCharacter,
          onOwnerTap: _openOwner,
          onLeftAssetTap: _openTempleAssetCard,
          onRightAssetTap: _openLinkedTempleAssetCard,
        );
      },
    );
  }

  /// 构建固定资产预览内容
  ///
  /// [context] 当前组件树上下文
  Widget _buildTemplesPreview(BuildContext context) {
    if ((_controller.isLoadingTemples || _controller.isLoadingLinks) &&
        _controller.mergedTemples.isEmpty) {
      return const _TemplePreviewSkeleton();
    }

    if (_controller.hasTempleError) {
      return _PreviewFailedState(
        message: _controller.templeErrorMessage,
        onRetry: _controller.loadTemples,
      );
    }

    final temples = _controller.previewTemples;
    const itemWidth = 156.0;
    return SnappingHorizontalListView(
      height: CharacterDetailTempleCard.heightForWidth(itemWidth),
      itemCount: temples.length,
      itemExtent: itemWidth,
      separatorExtent: 12,
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 24,
        top: 0,
        right: 24,
        bottom: 0,
      ),
      itemBuilder: (context, index) {
        return CharacterDetailTempleCard(
          item: temples[index],
          fallbackCharacterName: widget.header.name,
          width: itemWidth,
          heroTagPrefix: 'character-temple-preview-$index',
          onCharacterTap: _openCharacter,
          onOwnerTap: _openOwner,
          onAssetTap: _openTempleAssetCard,
        );
      },
    );
  }

  /// 打开 LINK 二级页面
  void _openLinksPage() {
    final links = _controller.validLinks;
    if (links.isEmpty) {
      return;
    }

    context.pushNamed(
      'characterLinks',
      queryParameters: _routeQueryParameters,
      extra: _routeExtra,
    );
  }

  /// 打开固定资产二级页面
  void _openTemplesPage() {
    final temples = _controller.mergedTemples;
    if (temples.isEmpty) {
      return;
    }

    context.pushNamed(
      'characterTemples',
      queryParameters: _routeQueryParameters,
      extra: _routeExtra,
    );
  }

  /// 打开角色详情
  ///
  /// [item] 角色详情圣殿条目
  void _openCharacter(CharacterDetailTempleItem item) {
    if (item.characterId <= 0 ||
        item.characterId == widget.header.characterId) {
      return;
    }

    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.displayCharacterName(widget.header.name),
      avatarUrl: item.avatar,
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

  /// 打开 LINK 右侧圣殿资产卡片弹窗
  ///
  /// [ownerItem] 拥有者字段来源条目
  /// [linkedItem] LINK 右侧圣殿条目
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

  /// 打开拥有者详情
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

  /// 二级页面路由参数
  Map<String, String> get _routeQueryParameters {
    final characterName = widget.header.name.trim();
    final avatarUrl = widget.header.icon.trim();

    return {
      'characterId': widget.header.characterId.toString(),
      if (characterName.isNotEmpty) 'name': characterName,
      if (avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
    };
  }

  /// 二级页面路由附加数据
  CharacterDetailCollectionsRouteExtra get _routeExtra {
    return CharacterDetailCollectionsRouteExtra(
      controller: _controller,
      header: widget.header,
      currentUserName: widget.currentUserName,
      userRepository: widget.userRepository,
      templeRepository: widget.templeRepository,
      magicRepository: widget.magicRepository,
      oosRepository: widget.oosRepository,
    );
  }

  /// 创建圣殿资产弹窗入口数据
  ///
  /// [item] 拥有者字段来源条目
  /// [characterId] 覆盖打开的角色 ID
  TempleAssetDialogSource _sourceForTemple(
    CharacterDetailTempleItem item, {
    int? characterId,
  }) {
    final resolvedCharacterId = characterId ??
        (item.characterId > 0 ? item.characterId : widget.header.characterId);

    return TempleAssetDialogSource(
      ownerName: item.ownerName,
      ownerNickname: item.ownerNickname,
      characterId: resolvedCharacterId,
    );
  }

  /// 固定资产二级页面入口是否不可用
  bool get _isTempleNavigationDisabled {
    return _controller.isLoadingTemples ||
        _controller.isLoadingLinks ||
        _controller.hasTempleError;
  }

  /// 是否显示 LINK 预览区
  bool get _shouldShowLinksSection {
    return _controller.isLoadingLinks ||
        _controller.hasLinkError ||
        _controller.previewLinks.isNotEmpty;
  }

  /// 是否显示固定资产预览区
  bool get _shouldShowTemplesSection {
    return _controller.isLoadingTemples ||
        _controller.isLoadingLinks ||
        _controller.hasTempleError ||
        _controller.previewTemples.isNotEmpty;
  }

  /// 连接区标题
  String get _linksTitle {
    if (_controller.isLoadingLinks || _controller.hasLinkError) {
      return '连接';
    }

    return '${_controller.validLinks.length}组连接';
  }

  /// 圣殿区标题
  String get _templesTitle {
    if (_controller.isLoadingTemples ||
        _controller.isLoadingLinks ||
        _controller.hasTempleError) {
      return '圣殿';
    }

    return '${_controller.mergedTemples.length}座圣殿';
  }
}

/// 预览区失败状态
class _PreviewFailedState extends StatelessWidget {
  /// 创建预览区失败状态
  ///
  /// [message] 失败状态说明
  /// [onRetry] 重试回调
  const _PreviewFailedState({
    required this.message,
    required this.onRetry,
  });

  /// 失败状态说明
  final String message;

  /// 重试回调
  final VoidCallback onRetry;

  /// 构建预览区失败状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSafeAreaInsets.symmetricHorizontal(
        context,
        horizontal: 12,
      ),
      child: AppLoadFailedState(
        message: message,
        onActionPressed: onRetry,
      ),
    );
  }
}

/// LINK 预览骨架
class _LinkPreviewSkeleton extends StatelessWidget {
  /// 创建 LINK 预览骨架
  const _LinkPreviewSkeleton();

  /// 构建 LINK 预览骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SnappingHorizontalListView(
      height: CharacterDetailLinkCard.heightForWidth(
        CharacterDetailLinkCard.defaultWidth,
      ),
      itemCount: 2,
      itemExtent: CharacterDetailLinkCard.defaultWidth,
      separatorExtent: 12,
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 24,
        top: 0,
        right: 24,
        bottom: 0,
      ),
      itemBuilder: (context, index) {
        return const _LinkSkeletonCard(
          width: CharacterDetailLinkCard.defaultWidth,
        );
      },
    );
  }
}

/// 固定资产预览骨架
class _TemplePreviewSkeleton extends StatelessWidget {
  /// 创建固定资产预览骨架
  const _TemplePreviewSkeleton();

  /// 构建固定资产预览骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    const itemWidth = 156.0;

    return SnappingHorizontalListView(
      height: CharacterDetailTempleCard.heightForWidth(itemWidth),
      itemCount: 4,
      itemExtent: itemWidth,
      separatorExtent: 12,
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 24,
        top: 0,
        right: 24,
        bottom: 0,
      ),
      itemBuilder: (context, index) {
        return const _TempleSkeletonCard(width: itemWidth);
      },
    );
  }
}

/// LINK 预览骨架卡片
class _LinkSkeletonCard extends StatelessWidget {
  /// 创建 LINK 预览骨架卡片
  ///
  /// [width] 卡片宽度
  const _LinkSkeletonCard({
    required this.width,
  });

  /// 卡片宽度
  final double width;

  /// 构建 LINK 预览骨架卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone(
            width: width,
            height: CharacterDetailLinkCard.imageHeight *
                width /
                CharacterDetailLinkCard.defaultWidth,
            borderRadius: BorderRadius.circular(24),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Bone(
                width: 92,
                height: 20,
                borderRadius: BorderRadius.circular(999),
              ),
              const Spacer(),
              Bone(
                width: 66,
                height: 22,
                borderRadius: BorderRadius.circular(999),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 固定资产预览骨架卡片
class _TempleSkeletonCard extends StatelessWidget {
  /// 创建固定资产预览骨架卡片
  ///
  /// [width] 卡片宽度
  const _TempleSkeletonCard({
    required this.width,
  });

  /// 卡片宽度
  final double width;

  /// 构建固定资产预览骨架卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final coverHeight = width / 3 * 4;

    return Skeletonizer.zone(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone(
            width: width,
            height: coverHeight,
            borderRadius: BorderRadius.circular(24),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone(
                  width: width * 0.56,
                  height: 11,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 6),
                Bone(
                  width: width - 8,
                  height: 4,
                  borderRadius: BorderRadius.circular(999),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
