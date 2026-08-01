import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/page_section_sliver.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/pool/widgets/character_pool_assets.dart';
import 'package:magrail_app/features/chara/rank/controller/character_rank_controller.dart';
import 'package:magrail_app/features/chara/rank/model/character_rank_entry.dart';
import 'package:magrail_app/features/chara/rank/repository/character_rank_repository.dart';
import 'package:magrail_app/features/chara/rank/widgets/character_rank_section.dart';
import 'package:magrail_app/features/chara/widgets/character_quick_entry_bar.dart';
import 'package:magrail_app/features/ico/controller/ico_character_controller.dart';
import 'package:magrail_app/features/ico/model/ico_character_entry.dart';
import 'package:magrail_app/features/ico/repository/ico_character_repository.dart';
import 'package:magrail_app/features/ico/view/ico_character_list_page.dart';
import 'package:magrail_app/features/ico/widgets/ico_character_assets.dart';

/// 角色一级页面
class CharacterPage extends StatefulWidget {
  /// 创建角色一级页面
  ///
  /// [key] Flutter 组件标识
  /// [scrollController] 角色页滚动控制器
  /// [rankRepository] 角色排序仓库
  /// [icoCharacterRepository] ICO 角色仓库
  const CharacterPage({
    super.key,
    required this.scrollController,
    required this.rankRepository,
    required this.icoCharacterRepository,
  });

  /// 角色页滚动控制器
  final ScrollController scrollController;

  /// 角色排序仓库
  final CharacterRankRepository rankRepository;

  /// ICO 角色仓库
  final IcoCharacterRepository icoCharacterRepository;

  /// 创建角色一级页面状态
  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

/// 角色一级页面状态
class _CharacterPageState extends State<CharacterPage> {
  late final IcoCharacterController _icoController;
  late final CharacterRankPageController _allCharactersController;
  late final Listenable _contentListenable;

  /// 初始化角色一级页面状态
  @override
  void initState() {
    super.initState();
    _icoController = IcoCharacterController(
      repository: widget.icoCharacterRepository,
    )..initialize();
    _allCharactersController = CharacterRankPageController(
      repository: widget.rankRepository,
      sortType: CharacterRankSortType.highestRate,
    )..initialize();
    _contentListenable = Listenable.merge([
      _icoController,
      _allCharactersController,
    ]);
  }

  /// 释放角色一级页面状态
  @override
  void dispose() {
    _icoController.dispose();
    _allCharactersController.dispose();
    super.dispose();
  }

  /// 构建角色一级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _contentListenable,
      builder: (context, child) {
        return RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: CharacterQuickEntryBar(
                  onValhallaTap: _openValhallaPage,
                  onGensokyoTap: _openGensokyoPage,
                  onStTap: _openStCharactersPage,
                ),
              ),
              PageSectionSliver(
                topSpacing: 12,
                title: 'ICO',
                onHeaderTap: _icoController.hasLoadedData
                    ? _openIcoCharactersPage
                    : null,
                child: _buildIcoContent(context),
              ),
              PageSectionSliver(
                topSpacing: 22,
                title: '所有角色',
                onHeaderTap: _openAllCharactersPage,
                child: _buildRankPreview(context),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 刷新角色一级页面
  Future<void> _refresh() async {
    await Future.wait([
      _icoController.refresh(),
      _allCharactersController.refresh(),
    ]);
  }

  /// 构建 ICO 角色预览
  ///
  /// [context] 当前组件树上下文
  Widget _buildIcoContent(BuildContext context) {
    final items = _icoController.previewItems;
    if (_icoController.isLoadFailed && items.isEmpty) {
      return Padding(
        padding: AppSafeAreaInsets.fromLTRB(
          context,
          left: 24,
          top: 0,
          right: 24,
          bottom: 0,
        ),
        child: AppLoadFailedState(
          message: 'ICO 角色加载失败',
          onActionPressed: _icoController.refresh,
        ),
      );
    }

    return IcoCharacterCarousel(
      items: _icoController.hasLoadedData ? items : null,
      isLoading: _icoController.isLoading,
      emptyMessage: '暂无 ICO 角色',
      onIcoTap: _openIcoCharacterDetail,
    );
  }

  /// 构建所有角色预览
  ///
  /// [context] 当前组件树上下文
  Widget _buildRankPreview(BuildContext context) {
    final items = _allCharactersController.items;
    if (_allCharactersController.initialError != null && items.isEmpty) {
      return Padding(
        padding: AppSafeAreaInsets.fromLTRB(
          context,
          left: 24,
          top: 0,
          right: 24,
          bottom: 0,
        ),
        child: CharacterPoolOverviewMessage(
          message: '所有角色加载失败',
          onRetry: _allCharactersController.refresh,
        ),
      );
    }

    return CharacterRankCarousel(
      items: items,
      selectedType: CharacterRankSortType.highestRate,
      isLoading: _allCharactersController.isInitialLoading,
      emptyMessage: '暂无所有角色',
      onCharacterTap: _openRankCharacterDetail,
    );
  }

  /// 打开英灵殿二级页面
  void _openValhallaPage() {
    context.pushNamed('valhallaCharacters');
  }

  /// 打开幻想乡二级页面
  void _openGensokyoPage() {
    context.pushNamed('gensokyoCharacters');
  }

  /// 打开 ST 角色二级页面
  void _openStCharactersPage() {
    context.pushNamed('stCharacters');
  }

  /// 打开所有角色二级页面
  void _openAllCharactersPage() {
    context.pushNamed('allCharacters');
  }

  /// 打开 ICO 角色全量二级页面
  void _openIcoCharactersPage() {
    if (!_icoController.hasLoadedData) {
      return;
    }
    _icoController.prepareSecondaryPage();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) {
          return IcoCharacterListPage(controller: _icoController);
        },
      ),
    );
  }

  /// 打开 ICO 角色详情页
  ///
  /// [item] ICO 角色条目
  /// [avatarHeroTag] 头像转场标识
  void _openIcoCharacterDetail(
    IcoCharacterEntry item,
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

  /// 打开角色排序条目的角色详情页
  ///
  /// [item] 角色排序条目
  /// [avatarHeroTag] 头像转场标识
  void _openRankCharacterDetail(
    CharacterRankEntry item,
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
}
