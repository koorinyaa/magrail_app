import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/widgets/page_section_sliver.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/ico/controller/ico_character_controller.dart';
import 'package:magrail_app/features/ico/controller/st_character_controller.dart';
import 'package:magrail_app/features/ico/model/ico_character_entry.dart';
import 'package:magrail_app/features/ico/model/st_character_entry.dart';
import 'package:magrail_app/features/ico/repository/ico_character_repository.dart';
import 'package:magrail_app/features/ico/repository/st_character_repository.dart';
import 'package:magrail_app/features/ico/widgets/ico_character_assets.dart';
import 'package:magrail_app/features/ico/widgets/st_character_assets.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_skeleton_sliver_list.dart';

/// ICO 一级页面
class IcoPage extends StatefulWidget {
  /// 创建 ICO 一级页面
  ///
  /// [key] Flutter 组件标识
  /// [scrollController] ICO 页滚动控制器
  /// [icoCharacterRepository] ICO 角色仓库
  /// [stCharacterRepository] ST 角色仓库
  const IcoPage({
    super.key,
    required this.scrollController,
    required this.icoCharacterRepository,
    required this.stCharacterRepository,
  });

  /// ICO 页滚动控制器
  final ScrollController scrollController;

  /// ICO 角色仓库
  final IcoCharacterRepository icoCharacterRepository;

  /// ST 角色仓库
  final StCharacterRepository stCharacterRepository;

  /// 创建 ICO 一级页面状态
  @override
  State<IcoPage> createState() => _IcoPageState();
}

/// ICO 一级页面状态
class _IcoPageState extends State<IcoPage> {
  late final StCharacterPreviewController _stController;
  late final IcoCharacterController _icoController;
  late final Listenable _contentListenable;

  /// 初始化 ICO 一级页面状态
  @override
  void initState() {
    super.initState();
    _stController = StCharacterPreviewController(
      repository: widget.stCharacterRepository,
    )..initialize();
    _icoController = IcoCharacterController(
      repository: widget.icoCharacterRepository,
    )..initialize();
    _contentListenable = Listenable.merge([
      _stController,
      _icoController,
    ]);
  }

  /// 释放 ICO 一级页面状态
  @override
  void dispose() {
    _stController.dispose();
    _icoController.dispose();
    super.dispose();
  }

  /// 构建 ICO 一级页面
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
              PageSectionSliver(
                title: 'ST',
                trailing: _buildCountTrailing(context),
                onHeaderTap: _openStCharactersPage,
                child: _buildStContent(context),
              ),
              IcoCharacterHeaderSliver(
                selectedType: _icoController.selectedType,
                onSelected: _icoController.selectType,
              ),
              ..._buildIcoSlivers(context),
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 刷新 ICO 一级页面
  Future<void> _refresh() async {
    await Future.wait([
      _stController.refresh(),
      _icoController.refresh(),
    ]);
  }

  /// 构建 ST 角色内容
  ///
  /// [context] 当前组件树上下文
  Widget _buildStContent(BuildContext context) {
    final items = _stController.items ?? const <StCharacterEntry>[];
    final showFailed = _stController.isLoadFailed && items.isEmpty;
    if (showFailed) {
      return Padding(
        padding: AppSafeAreaInsets.fromLTRB(
          context,
          left: 24,
          top: 0,
          right: 24,
          bottom: 0,
        ),
        child: StCharacterOverviewMessage(
          message: 'ST 加载失败',
          onRetry: _stController.refresh,
        ),
      );
    }

    return StCharacterCarousel(
      items: _stController.items,
      isLoading: _stController.isLoading,
      emptyMessage: '暂无 ST 角色',
      onCharacterTap: _openCharacterDetail,
    );
  }

  /// 构建 ICO 角色内容
  ///
  /// [context] 当前组件树上下文
  List<Widget> _buildIcoSlivers(BuildContext context) {
    final items = _icoController.items;
    final isLoadingInitial =
        _icoController.isLoading && !_icoController.hasLoadedCurrentType;
    if (isLoadingInitial) {
      return const [
        CharacterAssetSkeletonSliverList(
          showLevel: true,
          metricCount: 2,
          showTrailing: true,
          trailingWidth: 84,
          itemHorizontalPadding: 0,
          contentPadding: EdgeInsets.only(left: 30, right: 16),
        ),
      ];
    }

    if (_icoController.isLoadFailed && items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
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
          ),
        ),
      ];
    }

    if (items.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: AppLoadFailedState(
            title: '暂无 ICO 角色',
            message: '当前没有可展示的 ICO 角色',
            icon: Icons.hourglass_empty_rounded,
            actionLabel: null,
          ),
        ),
      ];
    }

    return [
      IcoCharacterSliverList(
        items: items,
        onIcoTap: _openIcoCharacterDetail,
      ),
    ];
  }

  /// 打开 ST 角色二级页面
  void _openStCharactersPage() {
    context.pushNamed('stCharacters');
  }

  /// 打开角色详情页
  ///
  /// [item] ST 角色条目
  /// [avatarHeroTag] 头像转场标识
  void _openCharacterDetail(
    StCharacterEntry item,
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

  /// 构建 ST 角色数量文本
  ///
  /// [context] 当前组件树上下文
  Widget? _buildCountTrailing(BuildContext context) {
    final count = _resolveCount();
    if (count == null) {
      return null;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: Text(
        '${Formatters.groupedNumber(count)} 个角色',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }

  /// 解析 ST 角色数量
  int? _resolveCount() {
    final visibleCount = _stController.items?.length ?? 0;
    final totalItems = _stController.totalItems;
    if (totalItems == null && visibleCount <= 0) {
      return null;
    }

    return totalItems != null && totalItems > 0 ? totalItems : visibleCount;
  }
}
