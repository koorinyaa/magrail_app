import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/tower/controller/tower_ranking_page_controller.dart';
import 'package:magrail_app/features/chara/tower/model/tower_entry.dart';
import 'package:magrail_app/features/chara/tower/repository/tower_repository.dart';
import 'package:magrail_app/features/chara/tower/widgets/tower_ranking_range_header.dart';
import 'package:magrail_app/features/chara/tower/widgets/tower_ranking_row.dart';
import 'package:magrail_app/features/chara/tower/widgets/tower_ranking_skeleton_row.dart';

/// 通天塔二级榜单页面
class TowerRankingPage extends StatefulWidget {
  /// 创建通天塔二级榜单页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 通天塔仓库
  const TowerRankingPage({
    super.key,
    required this.repository,
  });

  /// 通天塔页面使用的仓库
  final TowerRepository repository;

  /// 创建通天塔二级榜单页面状态
  @override
  State<TowerRankingPage> createState() => _TowerRankingPageState();
}

/// 通天塔二级榜单页面状态
class _TowerRankingPageState extends State<TowerRankingPage> {
  static const double _listItemExtent = 68;

  // 距离当前已加载内容底部约 6 条时预加载下一页
  static const double _preloadExtent = 420;

  late final TowerRankingPageController _controller;
  final ScrollController _scrollController = ScrollController();

  /// 初始化通天塔二级榜单页面状态
  @override
  void initState() {
    super.initState();
    _controller = TowerRankingPageController(
      repository: widget.repository,
    )..initialize();
    _scrollController.addListener(_handleScroll);
  }

  /// 释放通天塔二级榜单页面状态
  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// 构建通天塔二级榜单页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          final entries = _controller.entries;
          final isStateOnlyContent = !_controller.isInitialLoading &&
              (_controller.initialError != null || entries.isEmpty);

          return RefreshIndicator(
            onRefresh: _controller.refresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SecondaryPageSliverAppBar(
                  title: '通天塔(β)',
                  bottom: TowerRankingRangeHeader(
                    selectedIndex: _controller.selectedSegmentIndex,
                    segmentCount: _controller.segmentCount,
                    onSelected: _selectSegment,
                  ),
                ),
                if (_controller.isInitialLoading)
                  const _TowerRankingSkeletonList()
                else if (_controller.initialError != null)
                  AppLoadFailedSliver(
                    message: '请检查网络后重试',
                    onActionPressed: () {
                      _controller.loadPage(
                        _controller.selectedStartPage,
                        force: true,
                      );
                    },
                  )
                else if (entries.isEmpty)
                  const _TowerRankingStateSliver(
                    title: '暂无通天塔数据',
                    message: '当前没有可展示的榜单角色',
                    icon: Icons.hourglass_empty_rounded,
                  )
                else ...[
                  SliverFixedExtentList(
                    itemExtent: _listItemExtent,
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _TowerRankingEntryItem(entry: entries[index]);
                      },
                      childCount: entries.length,
                    ),
                  ),
                  _TowerRankingFooter(controller: _controller),
                ],
                if (!isStateOnlyContent)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 24 + MediaQuery.paddingOf(context).bottom,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 处理榜单滚动预加载
  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.extentAfter > _preloadExtent) {
      return;
    }

    _controller.loadNextPage();
  }

  /// 选择榜单分段
  ///
  /// [index] 分段索引
  void _selectSegment(int index) {
    _controller.selectSegment(index);

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }
}

/// 通天塔榜单条目外层
class _TowerRankingEntryItem extends StatelessWidget {
  /// 创建通天塔榜单条目外层
  ///
  /// [entry] 通天塔榜单条目
  const _TowerRankingEntryItem({
    required this.entry,
  });

  final TowerEntry entry;

  /// 构建通天塔榜单条目外层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(entry.avatarUrl);
    final avatarHeroTag = createCharacterDetailAvatarHeroTag(
      characterId: entry.characterId,
      avatarUrl: avatarUrl,
      source: entry,
    );

    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 12,
        top: 0,
        right: 12,
        bottom: 4,
      ),
      child: TowerRankingRow(
        entry: entry,
        avatarHeroTag: avatarHeroTag,
        onTap: entry.characterId <= 0
            ? null
            : () => openCharacterDetail(
                  context,
                  characterId: entry.characterId,
                  name: entry.name,
                  avatarUrl: avatarUrl,
                  avatarHeroTag: avatarHeroTag,
                ),
      ),
    );
  }
}

/// 通天塔榜单底部状态
class _TowerRankingFooter extends StatelessWidget {
  /// 创建通天塔榜单底部状态
  ///
  /// [controller] 通天塔二级榜单控制器
  const _TowerRankingFooter({
    required this.controller,
  });

  final TowerRankingPageController controller;

  /// 构建通天塔榜单底部状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (controller.isLoadingMore) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }

    if (controller.loadMoreError != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: TextButton.icon(
              onPressed: controller.loadNextPage,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('加载失败，点击重试'),
            ),
          ),
        ),
      );
    }

    if (!controller.canLoadMore) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              '没有更多角色了',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(
      child: SizedBox(height: 16),
    );
  }
}

/// 通天塔榜单骨架列表
class _TowerRankingSkeletonList extends StatelessWidget {
  /// 创建通天塔榜单骨架列表
  const _TowerRankingSkeletonList();

  /// 构建通天塔榜单骨架列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: _TowerRankingPageState._listItemExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: AppSafeAreaInsets.fromLTRB(
              context,
              left: 12,
              top: 0,
              right: 12,
              bottom: 4,
            ),
            child: const TowerRankingSkeletonRow(),
          );
        },
        childCount: 9,
      ),
    );
  }
}

/// 通天塔榜单状态页
class _TowerRankingStateSliver extends StatelessWidget {
  /// 创建通天塔榜单状态页
  ///
  /// [title] 状态标题
  /// [message] 状态说明
  /// [icon] 状态图标
  const _TowerRankingStateSliver({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  /// 构建通天塔榜单状态页
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: AppSafeAreaInsets.symmetricHorizontal(
            context,
            horizontal: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: colorScheme.onSurfaceVariant,
                size: 34,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
