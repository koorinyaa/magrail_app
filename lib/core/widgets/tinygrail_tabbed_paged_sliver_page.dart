import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/app_page_title_bar.dart';
import 'package:magrail_app/core/widgets/pagination_footer_sliver.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';

part 'tinygrail_tabbed_paged_sliver_page_content.dart';
part 'tinygrail_tabbed_paged_sliver_page_header.dart';

/// Tinygrail 分页标签页配置
class TinygrailPagedTab<T, R> {
  /// 创建 Tinygrail 分页标签页配置
  ///
  /// [label] 标签文案
  /// [controller] 分页控制器
  /// [loadingSliver] 首屏加载骨架
  /// [emptySliverBuilder] 空状态构建器
  /// [contentSliversBuilder] 内容 sliver 构建器
  /// [completedLabel] 全部加载完成文案
  const TinygrailPagedTab({
    required this.label,
    required this.controller,
    required this.loadingSliver,
    required this.emptySliverBuilder,
    required this.contentSliversBuilder,
    required this.completedLabel,
  });

  /// 标签文案
  final String label;

  /// 分页控制器
  final TinygrailPagedListController<T, R> controller;

  /// 首屏加载骨架
  final Widget loadingSliver;

  /// 空状态构建器
  final Widget Function(
    BuildContext context,
    TinygrailPagedListController<T, R> controller,
  ) emptySliverBuilder;

  /// 内容 sliver 构建器
  final TinygrailPagedContentSliversBuilder<T> contentSliversBuilder;

  /// 全部加载完成文案
  final String completedLabel;
}

/// Tinygrail 标签分页二级页面通用壳层
class TinygrailTabbedPagedSliverPage<T, R> extends StatefulWidget {
  /// 创建 Tinygrail 标签分页二级页面通用壳层
  ///
  /// [key] Flutter 组件标识
  /// [title] 页面标题
  /// [tabs] 标签页配置
  /// [initialIndex] 初始标签索引
  /// [onTabSelected] 标签选中回调
  /// [onTabPrepared] 标签即将展示回调
  /// [showBackButton] 是否显示返回按钮
  /// [onSearchPressed] 搜索按钮点击回调
  /// [bottomContentPadding] 滚动内容底部额外预留高度
  /// [scrollResetToken] 滚动位置重置信号
  /// [scrollToTopToken] 平滑滚动到顶部信号
  /// [useBlurHeader] 是否使用模糊顶部栏
  /// [useSecondaryTitleStyle] 是否使用二级页面标题样式
  const TinygrailTabbedPagedSliverPage({
    super.key,
    required this.title,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabSelected,
    this.onTabPrepared,
    this.showBackButton = true,
    this.onSearchPressed,
    this.bottomContentPadding = 0,
    this.scrollResetToken = 0,
    this.scrollToTopToken = 0,
    this.useBlurHeader = true,
    this.useSecondaryTitleStyle = false,
  })  : assert(tabs.length > 0),
        assert(initialIndex >= 0),
        assert(initialIndex < tabs.length),
        assert(bottomContentPadding >= 0);

  /// 页面标题
  final String title;

  /// 标签页配置
  final List<TinygrailPagedTab<T, R>> tabs;

  /// 初始标签索引
  final int initialIndex;

  /// 标签选中回调
  final ValueChanged<int>? onTabSelected;

  /// 标签即将展示回调
  final ValueChanged<int>? onTabPrepared;

  /// 是否显示返回按钮
  final bool showBackButton;

  /// 搜索按钮点击回调
  final VoidCallback? onSearchPressed;

  /// 滚动内容底部额外预留高度
  final double bottomContentPadding;

  /// 滚动位置重置信号
  final int scrollResetToken;

  /// 平滑滚动到顶部信号
  final int scrollToTopToken;

  /// 是否使用模糊顶部栏
  final bool useBlurHeader;

  /// 是否使用二级页面标题样式
  final bool useSecondaryTitleStyle;

  /// 创建 Tinygrail 标签分页二级页面通用壳层状态
  @override
  State<TinygrailTabbedPagedSliverPage<T, R>> createState() =>
      _TinygrailTabbedPagedSliverPageState<T, R>();
}

/// Tinygrail 标签分页二级页面通用壳层状态
class _TinygrailTabbedPagedSliverPageState<T, R>
    extends State<TinygrailTabbedPagedSliverPage<T, R>> {
  late final PageController _pageController;
  late int _selectedIndex;
  final Set<int> _preparedIndexes = <int>{};

  /// 初始化 Tinygrail 标签分页二级页面通用壳层状态
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex)
      ..addListener(_handlePageScroll);
    _prepareTab(_selectedIndex);
  }

  /// 更新 Tinygrail 标签分页二级页面通用壳层配置
  ///
  /// [oldWidget] 更新前的组件配置
  @override
  void didUpdateWidget(
      covariant TinygrailTabbedPagedSliverPage<T, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedIndex >= widget.tabs.length) {
      _selectedIndex = widget.tabs.length - 1;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_selectedIndex);
      }
    }
  }

  /// 释放 Tinygrail 标签分页二级页面通用壳层状态
  @override
  void dispose() {
    _pageController
      ..removeListener(_handlePageScroll)
      ..dispose();
    super.dispose();
  }

  /// 构建 Tinygrail 标签分页二级页面通用壳层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor =
        widget.useBlurHeader ? colorScheme.surface : Colors.transparent;
    final headerHeight = _TinygrailTabbedPageHeader.visibleHeight(
      context,
      useSecondaryTitleStyle: widget.useSecondaryTitleStyle,
    );
    final header = _TinygrailTabbedPageHeader(
      title: widget.title,
      labels: [for (final tab in widget.tabs) tab.label],
      selectedIndex: _selectedIndex,
      pageController: _pageController,
      onSelected: _selectTab,
      showBackButton: widget.showBackButton,
      onSearchPressed: widget.onSearchPressed,
      useBlurHeader: widget.useBlurHeader,
      useSecondaryTitleStyle: widget.useSecondaryTitleStyle,
    );
    final pageView = PageView.builder(
      controller: _pageController,
      itemCount: widget.tabs.length,
      onPageChanged: _handlePageChanged,
      itemBuilder: (context, index) {
        return _TinygrailPagedTabContent<T, R>(
          key: PageStorageKey<String>('tinygrail-tab-$index'),
          scrollStorageKey: PageStorageKey<String>(
            'tinygrail-tab-scroll-$index-${widget.scrollResetToken}',
          ),
          tab: widget.tabs[index],
          topContentPadding: widget.useBlurHeader ? headerHeight : 0,
          bottomContentPadding: widget.bottomContentPadding,
          scrollToTopToken: widget.scrollToTopToken,
        );
      },
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: widget.useBlurHeader
          ? Stack(
              children: [
                Positioned.fill(child: pageView),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: header,
                ),
              ],
            )
          : Column(
              children: [
                header,
                Expanded(child: pageView),
              ],
            ),
    );
  }

  /// 选择指定标签
  ///
  /// [index] 标签索引
  void _selectTab(int index) {
    if (index == _selectedIndex) {
      return;
    }

    _prepareTab(index);
    _setSelectedIndex(index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// 处理页面切换完成
  ///
  /// [index] 标签索引
  void _handlePageChanged(int index) {
    _prepareTab(index);
    _setSelectedIndex(index);
  }

  /// 处理页面拖动过程
  void _handlePageScroll() {
    if (!_pageController.hasClients) {
      return;
    }

    final page = _pageController.page;
    if (page == null) {
      return;
    }

    _prepareTab(page.floor());
    _prepareTab(page.ceil());
  }

  /// 设置当前选中标签
  ///
  /// [index] 标签索引
  void _setSelectedIndex(int index) {
    if (index == _selectedIndex || index < 0 || index >= widget.tabs.length) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
    widget.onTabSelected?.call(index);
  }

  /// 准备指定标签数据
  ///
  /// [index] 标签索引
  void _prepareTab(int index) {
    if (index < 0 || index >= widget.tabs.length) {
      return;
    }

    if (!_preparedIndexes.add(index)) {
      return;
    }

    widget.onTabPrepared?.call(index);
  }
}
