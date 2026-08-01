import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/secondary_page_refresh_view.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/search/widgets/character_search_input_bar.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_skeleton_sliver_list.dart';
import 'package:magrail_app/features/ico/controller/ico_character_controller.dart';
import 'package:magrail_app/features/ico/model/ico_character_entry.dart';
import 'package:magrail_app/features/ico/model/ico_character_sort.dart';
import 'package:magrail_app/features/ico/widgets/ico_character_assets.dart';
import 'package:magrail_app/features/ico/widgets/ico_character_sort_toolbar.dart';

// ICO 角色搜索输入防抖，避免连续输入时反复重排完整列表
const Duration _icoCharacterSearchDebounceDelay = Duration(milliseconds: 450);

/// ICO 角色全量二级页面
class IcoCharacterListPage extends StatefulWidget {
  /// 创建 ICO 角色全量二级页面
  ///
  /// [key] Flutter 组件标识
  /// [controller] 一级页共享的 ICO 角色控制器
  const IcoCharacterListPage({
    super.key,
    required this.controller,
  });

  /// 一级页共享的 ICO 角色控制器
  final IcoCharacterController controller;

  /// 创建 ICO 角色全量二级页面状态
  @override
  State<IcoCharacterListPage> createState() => _IcoCharacterListPageState();
}

/// ICO 角色全量二级页面状态
class _IcoCharacterListPageState extends State<IcoCharacterListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  /// 释放 ICO 角色全量二级页面状态
  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 构建 ICO 角色全量二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, child) {
          return Stack(
            children: [
              SecondaryPageRefreshView(
                title: 'ICO',
                titleSupplement: _buildTitleSupplement(),
                bottom: IcoCharacterSortToolbar(
                  selectedSort: widget.controller.selectedSort,
                  onSortSelected: _selectSort,
                ),
                onRefresh: _refresh,
                scrollController: _scrollController,
                slivers: _buildSlivers(),
              ),
              _buildSearchBar(),
            ],
          );
        },
      ),
    );
  }

  /// 构建完整列表总数标题辅助文本
  String? _buildTitleSupplement() {
    final count = widget.controller.totalItems;
    if (count == null) {
      return null;
    }
    return '(${Formatters.groupedNumber(count)} 个角色)';
  }

  /// 构建当前 ICO 列表状态
  List<Widget> _buildSlivers() {
    final controller = widget.controller;
    final items = controller.items;
    if (controller.isInitialLoading) {
      return const <Widget>[
        CharacterAssetSkeletonSliverList(
          showTrailing: true,
          trailingWidth: 84,
        ),
      ];
    }
    if (controller.isLoadFailed && !controller.hasLoadedData) {
      return <Widget>[
        AppLoadFailedSliver(
          message: '请检查网络后重试',
          onActionPressed: () => unawaited(_refresh()),
        ),
      ];
    }
    if (items.isEmpty) {
      final isFiltering = controller.searchKeyword.isNotEmpty;
      return <Widget>[
        PagedSliverState(
          title: isFiltering ? '未找到角色' : '暂无 ICO 角色',
          message: isFiltering ? '没有符合搜索条件的角色' : '当前没有可展示的 ICO 角色',
          icon: isFiltering
              ? Icons.search_off_rounded
              : Icons.hourglass_empty_rounded,
        ),
      ];
    }
    return <Widget>[
      IcoCharacterSliverList(
        items: items,
        onIcoTap: _openIcoCharacterDetail,
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: CharacterSearchInputBar.height +
              48 +
              MediaQuery.paddingOf(context).bottom,
        ),
      ),
    ];
  }

  /// 构建底部 ICO 角色搜索框
  Widget _buildSearchBar() {
    final mediaPadding = MediaQuery.paddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final bottomInset =
        viewInsets.bottom > 0 ? viewInsets.bottom : mediaPadding.bottom;
    return Positioned(
      left: mediaPadding.left + 20,
      right: mediaPadding.right + 20,
      bottom: bottomInset + 14,
      child: TextFieldTapRegion(
        child: CharacterSearchInputBar(
          controller: _searchController,
          placeholder: '搜索角色 ID 或名称',
          onChanged: _handleSearchChanged,
          onSubmitted: _submitSearch,
        ),
      ),
    );
  }

  /// 选择 ICO 本地排序并回到顶部
  ///
  /// [sort] 目标排序字段
  void _selectSort(IcoCharacterSort sort) {
    widget.controller.selectSort(sort);
    _scrollToTopAfterLayout();
  }

  /// 处理 ICO 角色搜索输入变化
  ///
  /// [keyword] 角色 ID 或名称筛选词
  void _handleSearchChanged(String keyword) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_icoCharacterSearchDebounceDelay, () {
      _applySearch(keyword);
    });
  }

  /// 提交 ICO 角色搜索
  ///
  /// [keyword] 角色 ID 或名称筛选词
  void _submitSearch(String keyword) {
    _searchDebounce?.cancel();
    _applySearch(keyword);
  }

  /// 应用 ICO 角色搜索并回到顶部
  ///
  /// [keyword] 角色 ID 或名称筛选词
  void _applySearch(String keyword) {
    widget.controller.applySearchFilter(keyword);
    _scrollToTopAfterLayout();
  }

  /// 下拉刷新完整 ICO 数据
  Future<void> _refresh() async {
    final success = await widget.controller.refresh();
    if (!mounted || success) {
      return;
    }
    AppToast.error(context, text: '数据刷新失败');
  }

  /// 在列表布局完成后回到顶部
  void _scrollToTopAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    });
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
}
