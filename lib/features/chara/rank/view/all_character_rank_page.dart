import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/rank/controller/character_rank_controller.dart';
import 'package:magrail_app/features/chara/rank/model/character_rank_entry.dart';
import 'package:magrail_app/features/chara/rank/repository/character_rank_repository.dart';
import 'package:magrail_app/features/chara/rank/widgets/character_rank_section.dart';
import 'package:magrail_app/features/chara/rank/widgets/character_rank_sort_header.dart';

/// 所有角色排序二级页面
class AllCharacterRankPage extends StatefulWidget {
  /// 创建所有角色排序二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 角色排序仓库
  const AllCharacterRankPage({
    super.key,
    required this.repository,
  });

  /// 角色排序仓库
  final CharacterRankRepository repository;

  /// 创建所有角色排序二级页面状态
  @override
  State<AllCharacterRankPage> createState() => _AllCharacterRankPageState();
}

/// 所有角色排序二级页面状态
class _AllCharacterRankPageState extends State<AllCharacterRankPage> {
  late final Map<CharacterRankSortType, CharacterRankPageController>
      _controllers;
  final ScrollController _scrollController = ScrollController();
  CharacterRankSortType _selectedType = CharacterRankSortType.highestRate;

  /// 初始化所有角色排序二级页面状态
  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final type in CharacterRankSortType.values)
        type: CharacterRankPageController(
          repository: widget.repository,
          sortType: type,
        ),
    };
    _currentController.initialize();
  }

  /// 释放所有角色排序二级页面状态
  @override
  void dispose() {
    _scrollController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 构建所有角色排序二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailPagedSliverPage<CharacterRankEntry, CharacterRankEntry>(
      controller: _currentController,
      scrollController: _scrollController,
      title: '所有角色',
      appBarBottom: CharacterRankSortHeader(
        selectedType: _selectedType,
        onSelected: _selectType,
      ),
      loadingSliver: const CharacterRankSkeletonSliverList(),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无角色',
          message: '当前没有可展示的角色',
          icon: Icons.inbox_rounded,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          CharacterRankSliverList(
            items: items,
            selectedType: _selectedType,
            onItemBuilt: onItemBuilt,
            onCharacterTap: _openCharacterDetail,
          ),
        ];
      },
      completedLabel: '没有更多角色了',
    );
  }

  CharacterRankPageController get _currentController {
    return _controllers[_selectedType]!;
  }

  /// 切换角色排序类型
  ///
  /// [type] 目标排序类型
  void _selectType(CharacterRankSortType type) {
    if (_selectedType == type) {
      return;
    }

    setState(() {
      _selectedType = type;
    });
    _currentController.initialize();

    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  /// 打开角色详情页
  ///
  /// [item] 角色排序条目
  /// [avatarHeroTag] 头像转场标识
  void _openCharacterDetail(
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
