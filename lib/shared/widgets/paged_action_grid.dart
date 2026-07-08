import 'package:flutter/material.dart';

/// 动作入口分页网格
class PagedActionGrid extends StatefulWidget {
  /// 创建两行动作入口分页网格
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 动作入口数量
  /// [itemBuilder] 动作入口构建回调
  /// [minItemWidth] 动作入口最小宽度
  /// [maxColumnCount] 单页最大列数
  /// [itemHeight] 动作入口固定高度
  /// [horizontalSpacing] 动作入口横向间距
  /// [verticalSpacing] 动作入口纵向间距
  /// [indicatorSpacing] 分页圆点与网格的间距
  const PagedActionGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.minItemWidth = 88,
    this.maxColumnCount = 6,
    this.itemHeight = 56,
    this.horizontalSpacing = 0,
    this.verticalSpacing = 8,
    this.indicatorSpacing = 10,
  });

  /// 动作入口数量
  final int itemCount;

  /// 动作入口构建回调
  final IndexedWidgetBuilder itemBuilder;

  /// 动作入口最小宽度
  final double minItemWidth;

  /// 单页最大列数
  final int maxColumnCount;

  /// 动作入口固定高度
  final double itemHeight;

  /// 动作入口横向间距
  final double horizontalSpacing;

  /// 动作入口纵向间距
  final double verticalSpacing;

  /// 分页圆点与网格的间距
  final double indicatorSpacing;

  /// 创建两行动作入口分页网格状态
  @override
  State<PagedActionGrid> createState() => _PagedActionGridState();
}

/// 两行动作入口分页网格状态
class _PagedActionGridState extends State<PagedActionGrid> {
  static const int _maxRowCount = 2;

  late final PageController _pageController;
  int _currentPage = 0;

  /// 初始化分页控制器
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  /// 释放分页控制器
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 入口数量变化时回到第一页
  ///
  /// [oldWidget] 更新前的两行动作入口分页网格
  @override
  void didUpdateWidget(covariant PagedActionGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      _resetToFirstPage();
    }
  }

  /// 构建两行动作入口分页网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (widget.itemCount <= 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = _resolveColumnCount(constraints.maxWidth);
        final itemWidth = _resolveItemWidth(
          constraints.maxWidth,
          columnCount,
        );
        final pageItemCount = columnCount * _maxRowCount;
        final pageCount = (widget.itemCount / pageItemCount).ceil();
        final rowCount = _resolveRowCount(columnCount, pageItemCount);
        final gridHeight = rowCount * widget.itemHeight +
            (rowCount - 1) * widget.verticalSpacing;
        final safeCurrentPage = _currentPage.clamp(0, pageCount - 1).toInt();
        if (safeCurrentPage != _currentPage) {
          _jumpToPageAfterBuild(safeCurrentPage);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: gridHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: pageCount,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, pageIndex) {
                  return _PagedActionGridPage(
                    firstItemIndex: pageIndex * pageItemCount,
                    itemCount: widget.itemCount,
                    itemWidth: itemWidth,
                    itemHeight: widget.itemHeight,
                    horizontalSpacing: widget.horizontalSpacing,
                    verticalSpacing: widget.verticalSpacing,
                    pageItemCount: pageItemCount,
                    itemBuilder: widget.itemBuilder,
                  );
                },
              ),
            ),
            if (pageCount > 1) ...[
              SizedBox(height: widget.indicatorSpacing),
              _PagedActionGridIndicator(
                currentPage: safeCurrentPage,
                pageCount: pageCount,
              ),
            ],
          ],
        );
      },
    );
  }

  /// 计算当前宽度下的列数
  ///
  /// [maxWidth] 可用最大宽度
  int _resolveColumnCount(double maxWidth) {
    final rawColumnCount = ((maxWidth + widget.horizontalSpacing) /
            (widget.minItemWidth + widget.horizontalSpacing))
        .floor();
    return rawColumnCount.clamp(1, widget.maxColumnCount).toInt();
  }

  /// 计算入口实际宽度
  ///
  /// [maxWidth] 可用最大宽度
  /// [columnCount] 当前列数
  double _resolveItemWidth(double maxWidth, int columnCount) {
    final spacingWidth = widget.horizontalSpacing * (columnCount - 1);
    return (maxWidth - spacingWidth) / columnCount;
  }

  /// 计算网格显示行数
  ///
  /// [columnCount] 当前列数
  /// [pageItemCount] 单页入口数量
  int _resolveRowCount(int columnCount, int pageItemCount) {
    final visibleCount = widget.itemCount.clamp(0, pageItemCount).toInt();
    return (visibleCount / columnCount).ceil().clamp(1, _maxRowCount).toInt();
  }

  /// 下一帧跳转到有效页码
  ///
  /// [page] 目标页索引
  void _jumpToPageAfterBuild(int page) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      _pageController.jumpToPage(page);
      if (_currentPage != page) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  /// 回到第一页
  void _resetToFirstPage() {
    _currentPage = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      _pageController.jumpToPage(0);
    });
  }
}

/// 两行动作入口分页页内容
class _PagedActionGridPage extends StatelessWidget {
  /// 创建两行动作入口分页页内容
  ///
  /// [firstItemIndex] 当前页第一个入口索引
  /// [itemCount] 动作入口总数
  /// [itemWidth] 动作入口宽度
  /// [itemHeight] 动作入口高度
  /// [horizontalSpacing] 动作入口横向间距
  /// [verticalSpacing] 动作入口纵向间距
  /// [pageItemCount] 单页入口数量
  /// [itemBuilder] 动作入口构建回调
  const _PagedActionGridPage({
    required this.firstItemIndex,
    required this.itemCount,
    required this.itemWidth,
    required this.itemHeight,
    required this.horizontalSpacing,
    required this.verticalSpacing,
    required this.pageItemCount,
    required this.itemBuilder,
  });

  /// 当前页第一个入口索引
  final int firstItemIndex;

  /// 动作入口总数
  final int itemCount;

  /// 动作入口宽度
  final double itemWidth;

  /// 动作入口高度
  final double itemHeight;

  /// 动作入口横向间距
  final double horizontalSpacing;

  /// 动作入口纵向间距
  final double verticalSpacing;

  /// 单页入口数量
  final int pageItemCount;

  /// 动作入口构建回调
  final IndexedWidgetBuilder itemBuilder;

  /// 构建两行动作入口分页页内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final lastItemIndex = (firstItemIndex + pageItemCount)
        .clamp(
          firstItemIndex,
          itemCount,
        )
        .toInt();

    return Wrap(
      alignment: WrapAlignment.start,
      spacing: horizontalSpacing,
      runSpacing: verticalSpacing,
      children: [
        for (var index = firstItemIndex; index < lastItemIndex; index++)
          SizedBox(
            width: itemWidth,
            height: itemHeight,
            child: itemBuilder(context, index),
          ),
      ],
    );
  }
}

/// 动作入口分页圆点
class _PagedActionGridIndicator extends StatelessWidget {
  /// 创建动作入口分页圆点
  ///
  /// [currentPage] 当前页索引
  /// [pageCount] 总页数
  const _PagedActionGridIndicator({
    required this.currentPage,
    required this.pageCount,
  });

  /// 当前页索引
  final int currentPage;

  /// 总页数
  final int pageCount;

  /// 构建动作入口分页圆点
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.onSurface.withValues(alpha: 0.72);
    final inactiveColor = colorScheme.onSurface.withValues(alpha: 0.18);

    return SizedBox(
      height: 8,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < pageCount; index++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(right: index == pageCount - 1 ? 0 : 6),
                width: index == currentPage ? 8 : 6,
                height: index == currentPage ? 8 : 6,
                decoration: BoxDecoration(
                  color: index == currentPage ? activeColor : inactiveColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
