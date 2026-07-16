import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_collections_controller.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_links_page_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_collections_grid.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_dialog.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 角色 LINK 二级页面
class CharacterDetailLinksPage extends StatefulWidget {
  /// 创建角色 LINK 二级页面
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
  const CharacterDetailLinksPage({
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

  /// 创建角色 LINK 二级页面状态
  @override
  State<CharacterDetailLinksPage> createState() =>
      _CharacterDetailLinksPageState();
}

/// 角色 LINK 二级页面状态
class _CharacterDetailLinksPageState extends State<CharacterDetailLinksPage> {
  late final CharacterDetailLinksPageController _controller;
  late final ScrollController _scrollController;
  final _groupKeys = <GlobalKey>[];
  var _currentGroupIndex = 0;
  var _isGroupUpdateScheduled = false;

  /// 初始化角色 LINK 二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = CharacterDetailLinksPageController(
      collectionsController: widget.collectionsController,
    );
    _scrollController = ScrollController()
      ..addListener(_scheduleCurrentGroupUpdate);
  }

  /// 释放角色 LINK 二级页面状态
  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// 构建角色 LINK 二级页面
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
          final groups = _controller.groups;
          final isStateOnlyContent = groups.isEmpty;
          _syncGroupKeys(groups.length);
          _scheduleCurrentGroupUpdate();

          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SecondaryPageSliverAppBar(
                title: _title,
                bottom: groups.isEmpty
                    ? null
                    : _LinkGroupAppBarBottom(
                        group: groups[_resolvedCurrentGroupIndex(groups)],
                        fallbackName: '连接角色',
                        rank: _resolvedCurrentGroupIndex(groups) + 1,
                      ),
              ),
              if (groups.isEmpty)
                const PagedSliverState(
                  title: '暂无连接',
                  message: '当前角色没有可展示的连接',
                  icon: Icons.link_off_rounded,
                )
              else
                for (var index = 0; index < groups.length; index++) ...[
                  SliverToBoxAdapter(
                    child: SizedBox(
                      key: _groupKeys[index],
                      height: 0,
                    ),
                  ),
                  CharacterDetailLinkGrid(
                    items: groups[index].items,
                    fallbackCharacterName: widget.characterName,
                    onCharacterTap: _openCharacter,
                    onOwnerTap: _openOwner,
                    onTempleAssetTap: _openTempleAssetCard,
                    onLinkedAssetTap: _openLinkedTempleAssetCard,
                  ),
                ],
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

  /// 同步分组锚点数量
  ///
  /// [groupCount] 当前连接分组数量
  void _syncGroupKeys(int groupCount) {
    while (_groupKeys.length < groupCount) {
      _groupKeys.add(GlobalKey());
    }

    if (_groupKeys.length > groupCount) {
      _groupKeys.removeRange(groupCount, _groupKeys.length);
    }

    if (_currentGroupIndex >= groupCount) {
      _currentGroupIndex = groupCount <= 0 ? 0 : groupCount - 1;
    }
  }

  /// 解析当前分组下标
  ///
  /// [groups] 当前连接分组
  int _resolvedCurrentGroupIndex(List<CharacterDetailLinkGroup> groups) {
    if (groups.isEmpty) {
      return 0;
    }

    return _currentGroupIndex.clamp(0, groups.length - 1).toInt();
  }

  /// 安排当前分组刷新
  void _scheduleCurrentGroupUpdate() {
    if (_isGroupUpdateScheduled) {
      return;
    }

    _isGroupUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isGroupUpdateScheduled = false;
      if (!mounted) {
        return;
      }

      _updateCurrentGroupIndex();
    });
  }

  /// 根据分组锚点刷新顶部连接标题
  void _updateCurrentGroupIndex() {
    if (_groupKeys.isEmpty) {
      return;
    }

    final triggerY = MediaQuery.paddingOf(context).top +
        SecondaryPageSliverAppBar.defaultToolbarHeight +
        _LinkGroupAppBarBottom.height +
        1;
    var nextIndex = 0;

    for (var index = 0; index < _groupKeys.length; index++) {
      final keyContext = _groupKeys[index].currentContext;
      final renderObject = keyContext?.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        continue;
      }

      final offset = renderObject.localToGlobal(Offset.zero);
      if (offset.dy <= triggerY) {
        nextIndex = index;
        continue;
      }

      break;
    }

    if (nextIndex == _currentGroupIndex) {
      return;
    }

    setState(() {
      _currentGroupIndex = nextIndex;
    });
  }

  /// 页面标题
  String get _title {
    final name = TinygrailFormatters.decodeHtmlEntities(
      widget.characterName,
    ).trim();
    return name.isEmpty ? '角色连接' : '$name的连接';
  }

  /// 打开 LINK 角色详情
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

  /// 打开 LINK 拥有者详情
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

  /// 打开左侧圣殿资产卡片弹窗
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

  /// 打开右侧圣殿资产卡片弹窗
  ///
  /// [ownerItem] 拥有者字段来源条目
  /// [linkedItem] LINK 圣殿条目
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
  /// [item] 拥有者字段来源条目
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

/// LINK 分组顶部栏标题
class _LinkGroupAppBarBottom extends StatelessWidget
    implements PreferredSizeWidget {
  /// 创建 LINK 分组顶部栏标题
  ///
  /// [group] LINK 分组
  /// [fallbackName] LINK 角色名称兜底文案
  /// [rank] 分组排名
  const _LinkGroupAppBarBottom({
    required this.group,
    required this.fallbackName,
    required this.rank,
  });

  /// 顶部栏分组标题高度
  static const double height = 36;

  /// LINK 分组
  final CharacterDetailLinkGroup group;

  /// LINK 角色名称兜底文案
  final String fallbackName;

  /// 分组排名
  final int rank;

  /// 顶部栏分组标题尺寸
  @override
  Size get preferredSize => const Size.fromHeight(height);

  /// 构建 LINK 分组顶部栏标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.36),
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: 24,
            top: 7,
            right: 24,
            bottom: 7,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  group.linkedCharacterName(fallbackName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '第$rank位',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
