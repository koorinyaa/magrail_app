import 'package:flutter/material.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/pagination_footer_sliver.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';

/// Tinygrail 分页页面内容构建器
///
/// [context] 当前组件树上下文
/// [items] 当前已加载的展示条目
/// [onItemBuilt] 展示条目构建回调
typedef TinygrailPagedContentSliversBuilder<T> = List<Widget> Function(
  BuildContext context,
  List<T> items,
  ValueChanged<int> onItemBuilt,
);

/// Tinygrail 分页二级页面通用壳层
class TinygrailPagedSliverPage<T, R> extends StatefulWidget {
  /// 创建 Tinygrail 分页二级页面通用壳层
  ///
  /// [key] Flutter 组件标识
  /// [controller] 分页控制器
  /// [title] 页面标题
  /// [loadingSliver] 首屏加载骨架
  /// [emptySliverBuilder] 空状态构建器
  /// [contentSliversBuilder] 内容 sliver 构建器
  /// [completedLabel] 全部加载完成文案
  /// [appBarActions] 顶部栏右侧操作组件
  /// [appBarBottom] 顶部栏下方的固定区域
  /// [scrollController] 页面滚动控制器
  const TinygrailPagedSliverPage({
    super.key,
    required this.controller,
    required this.title,
    required this.loadingSliver,
    required this.emptySliverBuilder,
    required this.contentSliversBuilder,
    required this.completedLabel,
    this.appBarActions,
    this.appBarBottom,
    this.scrollController,
  });

  /// 分页控制器
  final TinygrailPagedListController<T, R> controller;

  /// 页面标题
  final String title;

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

  /// 顶部栏右侧操作组件
  final List<Widget>? appBarActions;

  /// 顶部栏下方的固定区域
  final PreferredSizeWidget? appBarBottom;

  /// 页面滚动控制器
  final ScrollController? scrollController;

  /// 创建 Tinygrail 分页二级页面通用壳层状态
  @override
  State<TinygrailPagedSliverPage<T, R>> createState() =>
      _TinygrailPagedSliverPageState<T, R>();
}

/// Tinygrail 分页二级页面通用壳层状态
class _TinygrailPagedSliverPageState<T, R>
    extends State<TinygrailPagedSliverPage<T, R>> {
  /// 构建 Tinygrail 分页二级页面通用壳层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, child) {
          final items = widget.controller.items;
          final isStateOnlyContent = !widget.controller.isInitialLoading &&
              (widget.controller.initialError != null || items.isEmpty);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SecondaryPageSliverAppBar(
                  title: widget.title,
                  actions: widget.appBarActions,
                  bottom: widget.appBarBottom,
                ),
                if (widget.controller.isInitialLoading)
                  widget.loadingSliver
                else if (widget.controller.initialError != null)
                  AppLoadFailedSliver(
                    message: '请检查网络后重试',
                    onActionPressed: widget.controller.refresh,
                  )
                else if (items.isEmpty)
                  widget.emptySliverBuilder(context, widget.controller)
                else ...[
                  ...widget.contentSliversBuilder(
                    context,
                    items,
                    _handleItemBuilt,
                  ),
                  PaginationFooterSliver(
                    isLoadingMore: widget.controller.isLoadingMore,
                    hasLoadMoreError: widget.controller.loadMoreError != null,
                    canLoadMore: widget.controller.canLoadMore,
                    completedLabel: widget.completedLabel,
                    onRetry: widget.controller.loadNextPage,
                  ),
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

  /// 处理条目构建触发的分页预加载
  ///
  /// [index] 当前构建的展示条目下标
  void _handleItemBuilt(int index) {
    // 条目构建发生在 build 阶段，分页请求需要延后到帧结束后
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      widget.controller.handleItemBuilt(index);
    });
  }

  /// 下拉刷新分页列表
  Future<void> _refresh() async {
    final isSuccess = await widget.controller.refresh();
    if (!mounted || isSuccess) {
      return;
    }

    AppToast.error(
      context,
      text: '刷新失败，请检查网络后重试',
    );
  }
}
