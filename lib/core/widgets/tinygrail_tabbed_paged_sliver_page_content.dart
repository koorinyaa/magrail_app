part of 'tinygrail_tabbed_paged_sliver_page.dart';

/// Tinygrail 分页标签页内容
class _TinygrailPagedTabContent<T, R> extends StatefulWidget {
  /// 创建 Tinygrail 分页标签页内容
  ///
  /// [key] Flutter 组件标识
  /// [scrollStorageKey] 列表滚动位置存储标识
  /// [tab] 标签页配置
  /// [topContentPadding] 滚动内容顶部额外预留高度
  /// [bottomContentPadding] 滚动内容底部额外预留高度
  /// [scrollToTopToken] 平滑滚动到顶部信号
  const _TinygrailPagedTabContent({
    super.key,
    required this.scrollStorageKey,
    required this.tab,
    required this.topContentPadding,
    required this.bottomContentPadding,
    required this.scrollToTopToken,
  });

  /// 列表滚动位置存储标识
  final PageStorageKey<String> scrollStorageKey;

  /// 标签页配置
  final TinygrailPagedTab<T, R> tab;

  /// 滚动内容顶部额外预留高度
  final double topContentPadding;

  /// 滚动内容底部额外预留高度
  final double bottomContentPadding;

  /// 平滑滚动到顶部信号
  final int scrollToTopToken;

  /// 创建 Tinygrail 分页标签页内容状态
  @override
  State<_TinygrailPagedTabContent<T, R>> createState() =>
      _TinygrailPagedTabContentState<T, R>();
}

/// Tinygrail 分页标签页内容状态
class _TinygrailPagedTabContentState<T, R>
    extends State<_TinygrailPagedTabContent<T, R>> {
  final ScrollController _scrollController = ScrollController();

  /// 更新 Tinygrail 分页标签页内容配置
  ///
  /// [oldWidget] 更新前的组件配置
  @override
  void didUpdateWidget(covariant _TinygrailPagedTabContent<T, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollToTopToken == widget.scrollToTopToken) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _scrollToTop();
    });
  }

  /// 释放 Tinygrail 分页标签页内容状态
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 构建 Tinygrail 分页标签页内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.tab.controller,
      builder: (context, child) {
        final controller = widget.tab.controller;
        final items = controller.items;
        final isStateOnlyContent = !controller.isInitialLoading &&
            (controller.initialError != null || items.isEmpty);

        return RefreshIndicator(
          edgeOffset: widget.topContentPadding,
          displacement: 40,
          onRefresh: _refresh,
          child: CustomScrollView(
            key: widget.scrollStorageKey,
            controller: _scrollController,
            primary: false,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (widget.topContentPadding > 0)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: widget.topContentPadding,
                  ),
                ),
              if (controller.isInitialLoading)
                widget.tab.loadingSliver
              else if (controller.initialError != null)
                AppLoadFailedSliver(
                  message: '请检查网络后重试',
                  onActionPressed: controller.refresh,
                )
              else if (items.isEmpty)
                widget.tab.emptySliverBuilder(context, controller)
              else ...[
                ...widget.tab.contentSliversBuilder(
                  context,
                  items,
                  _handleItemBuilt,
                ),
                PaginationFooterSliver(
                  isLoadingMore: controller.isLoadingMore,
                  hasLoadMoreError: controller.loadMoreError != null,
                  canLoadMore: controller.canLoadMore,
                  completedLabel: widget.tab.completedLabel,
                  onRetry: controller.loadNextPage,
                ),
              ],
              if (!isStateOnlyContent)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 24 +
                        widget.bottomContentPadding +
                        MediaQuery.paddingOf(context).bottom,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// 处理条目构建触发的分页预加载
  ///
  /// [index] 当前构建的展示条目下标
  void _handleItemBuilt(int index) {
    // 条目构建发生在 build 阶段，分页请求需要延后到帧结束后
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      widget.tab.controller.handleItemBuilt(index);
    });
  }

  /// 下拉刷新分页列表
  Future<void> _refresh() async {
    final isSuccess = await widget.tab.controller.refresh();
    if (!mounted || isSuccess) {
      return;
    }

    AppToast.error(
      context,
      text: '刷新失败，请检查网络后重试',
    );
  }

  /// 将当前标签页滚动到顶部
  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels <= position.minScrollExtent) {
      return;
    }

    _scrollController.animateTo(
      position.minScrollExtent,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }
}
