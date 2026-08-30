import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/rank/controller/character_rank_controller.dart';
import 'package:magrail_app/features/chara/rank/model/character_rank_entry.dart';
import 'package:magrail_app/features/chara/rank/repository/character_rank_repository.dart';
import 'package:magrail_app/features/chara/rank/widgets/character_rank_section.dart';
import 'package:magrail_app/features/chara/view/character_full_list_page_state_mixin.dart';

/// 所有角色排序二级页面
class AllCharacterRankPage extends StatefulWidget {
  /// 创建所有角色排序二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 角色排序仓库
  const AllCharacterRankPage({super.key, required this.repository});

  /// 角色排序仓库
  final CharacterRankRepository repository;

  /// 创建所有角色排序二级页面状态
  @override
  State<AllCharacterRankPage> createState() => _AllCharacterRankPageState();
}

/// 所有角色排序二级页面状态
class _AllCharacterRankPageState extends State<AllCharacterRankPage>
    with
        CharacterFullListPageStateMixin<
          CharacterRankEntry,
          AllCharacterRankPage
        > {
  late final AllCharacterFullListPageController _controller;

  /// 当前所有角色全量列表控制器
  @override
  AllCharacterFullListPageController get fullListController => _controller;

  /// 初始化所有角色排序二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = AllCharacterFullListPageController(
      repository: widget.repository,
      waitForScrollIdle: waitForFullListScrollIdle,
      onBeforeFullItemsReplaced: preserveFullListVisibleItem,
      onDataRefreshFailed: showFullListRefreshFailed,
    )..initialize();
  }

  /// 释放所有角色排序二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    disposeFullListPageState();
    super.dispose();
  }

  /// 构建所有角色排序二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final page =
            TinygrailPagedSliverPage<CharacterRankEntry, CharacterRankEntry>(
              controller: _controller,
              scrollController: fullListScrollController,
              title: '所有角色',
              titleSupplement: _buildTitleSupplement(),
              appBarBottom: buildFullListSortToolbar(),
              loadingSliver: const CharacterRankSkeletonSliverList(),
              emptySliverBuilder: (context, controller) {
                final isFiltering = _controller.searchKeyword.isNotEmpty;
                return PagedSliverState(
                  title: isFiltering ? '未找到角色' : '暂无角色',
                  message: isFiltering ? '没有符合搜索条件的角色' : '当前没有可展示的角色',
                  icon: isFiltering
                      ? Icons.search_off_rounded
                      : Icons.inbox_rounded,
                );
              },
              contentSliversBuilder: (context, items, onItemBuilt) {
                return [
                  CharacterRankSliverList(
                    items: items,
                    selectedType: CharacterRankSortType.maxRise,
                    localSort: _controller.hasFullData
                        ? _controller.sort
                        : null,
                    showLevelHeaders: _controller.showsLevelHeaders,
                    onItemBuilt: onItemBuilt,
                    onCharacterTap: _openCharacterDetail,
                  ),
                ];
              },
              completedLabel: '没有更多角色了',
              bottomContentPadding: fullListBottomContentPadding,
              refreshErrorText: '数据刷新失败',
            );
        return buildFullListOverlay(child: page);
      },
    );
  }

  /// 构建完整列表总数标题辅助文本
  String? _buildTitleSupplement() {
    final count = _controller.fullItemCount;
    if (count == null) {
      return null;
    }
    return '(${Formatters.groupedNumber(count)} 个角色)';
  }

  /// 打开角色详情页
  ///
  /// [item] 角色排序条目
  /// [avatarHeroTag] 头像转场标识
  void _openCharacterDetail(CharacterRankEntry item, String? avatarHeroTag) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.name,
      avatarUrl: item.icon,
      avatarHeroTag: avatarHeroTag,
    );
  }
}
