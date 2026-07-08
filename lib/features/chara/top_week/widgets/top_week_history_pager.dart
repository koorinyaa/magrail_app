import 'package:flutter/material.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/features/chara/top_week/controller/top_week_history_controller.dart';
import 'package:magrail_app/features/chara/top_week/model/top_week_history_api_item.dart';
import 'package:magrail_app/features/chara/top_week/widgets/top_week_history_list.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 往期萌王分页浏览组件
class TopWeekHistoryPager extends StatefulWidget {
  /// 创建往期萌王分页浏览组件
  ///
  /// [key] Flutter 组件标识
  /// [controller] 往期萌王分页控制器
  /// [contentPadding] 分页内容滚动内边距
  const TopWeekHistoryPager({
    super.key,
    required this.controller,
    this.contentPadding = EdgeInsets.zero,
  });

  /// 往期萌王分页控制器
  final TopWeekHistoryController controller;

  /// 分页内容滚动内边距
  final EdgeInsetsGeometry contentPadding;

  /// 创建往期萌王分页浏览组件状态
  @override
  State<TopWeekHistoryPager> createState() => _TopWeekHistoryPagerState();
}

/// 往期萌王分页浏览组件状态
class _TopWeekHistoryPagerState extends State<TopWeekHistoryPager> {
  late final PageController _pageController;

  /// 初始化往期萌王分页浏览组件状态
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  /// 释放往期萌王分页浏览组件状态
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 构建往期萌王分页浏览组件
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.controller.pageCount,
                onPageChanged: (index) {
                  widget.controller.setCurrentPage(index + 1);
                },
                itemBuilder: (context, index) {
                  final page = index + 1;
                  return _TopWeekHistoryPageContent(
                    page: page,
                    controller: widget.controller,
                    contentPadding: widget.contentPadding,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 解析往期萌王分页标题
///
/// [currentPageData] 当前页数据
String resolveTopWeekHistoryPageTitle(
  TinygrailPage<TopWeekHistoryApiItem>? currentPageData,
) {
  final firstItem = currentPageData?.items.isNotEmpty == true
      ? currentPageData!.items.first
      : null;
  if (firstItem == null) {
    return '往期萌王';
  }

  final parsed = DateTime.tryParse(firstItem.create.trim());
  if (parsed == null) {
    return '往期萌王';
  }

  final start = DateTime(parsed.year, 1, 1);
  final days = parsed.difference(start).inDays + 1;
  final week = (days / 7).ceil();
  return '${parsed.year}年第$week周';
}

/// 往期萌王分页指示器
class TopWeekHistoryPageIndicator extends StatelessWidget
    implements PreferredSizeWidget {
  /// 创建往期萌王分页指示器
  ///
  /// [currentPage] 当前页码
  /// [totalPages] 总页数
  const TopWeekHistoryPageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  static const int _dotCount = 5;

  /// 分页指示器高度
  static const double height = 22;

  /// 当前页码
  final int currentPage;

  /// 总页数
  final int? totalPages;

  /// 分页指示器首选尺寸
  @override
  Size get preferredSize => const Size.fromHeight(height);

  /// 构建往期萌王分页指示器
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeIndex = _resolveActiveIndex();
    final activeColor = isDark
        ? Colors.white.withValues(alpha: 0.88)
        : Colors.black.withValues(alpha: 0.72);
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.16);

    return SizedBox(
      height: height,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(_dotCount, (index) {
            final isActive = index == activeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                right: index == _dotCount - 1 ? 0 : 6,
              ),
              width: isActive ? 8 : 6,
              height: isActive ? 8 : 6,
              decoration: BoxDecoration(
                color: isActive ? activeColor : inactiveColor,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }

  /// 解析当前高亮圆点索引
  int _resolveActiveIndex() {
    if (currentPage <= 1) {
      return 0;
    }

    final totalPages = this.totalPages;
    if (totalPages != null && currentPage >= totalPages) {
      return _dotCount - 1;
    }

    if (currentPage == 2) {
      return 1;
    }

    if (totalPages != null && currentPage == totalPages - 1) {
      return _dotCount - 2;
    }

    return 2;
  }
}

/// 往期萌王分页内容
class _TopWeekHistoryPageContent extends StatefulWidget {
  /// 创建往期萌王分页内容
  ///
  /// [page] 目标页码
  /// [controller] 往期萌王分页控制器
  /// [contentPadding] 分页内容滚动内边距
  const _TopWeekHistoryPageContent({
    required this.page,
    required this.controller,
    required this.contentPadding,
  });

  final int page;
  final TopWeekHistoryController controller;
  final EdgeInsetsGeometry contentPadding;

  /// 创建往期萌王分页内容状态
  @override
  State<_TopWeekHistoryPageContent> createState() =>
      _TopWeekHistoryPageContentState();
}

/// 往期萌王分页内容状态
class _TopWeekHistoryPageContentState
    extends State<_TopWeekHistoryPageContent> {
  bool _requested = false;

  /// 依赖变更后确保当前页开始加载
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureRequested();
  }

  /// 组件更新后确保目标页开始加载
  ///
  /// [oldWidget] 更新前的分页内容组件
  @override
  void didUpdateWidget(covariant _TopWeekHistoryPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) {
      _requested = false;
      _ensureRequested();
    }
  }

  /// 构建往期萌王分页内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final pageData = widget.controller.pageAt(widget.page);
    final isLoading = widget.controller.isPageLoading(widget.page);
    final error = widget.controller.pageErrorAt(widget.page);

    if (pageData != null) {
      return TopWeekHistoryList(
        page: pageData,
        padding: widget.contentPadding,
      );
    }

    if (error != null) {
      return _TopWeekHistoryErrorState(
        onRetry: () {
          widget.controller.loadPage(widget.page, force: true);
        },
      );
    }

    if (isLoading || widget.controller.isInitialLoading) {
      return _TopWeekHistorySkeletonPage(
        padding: widget.contentPadding,
      );
    }

    _requestMissingPage();
    return _TopWeekHistorySkeletonPage(
      padding: widget.contentPadding,
    );
  }

  /// 触发当前页数据加载
  void _ensureRequested() {
    if (_requested) {
      return;
    }

    _requested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      widget.controller.ensurePageReady(widget.page);
    });
  }

  /// 重新请求没有数据的当前页
  void _requestMissingPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      widget.controller.ensurePageReady(widget.page);
    });
  }
}

/// 往期萌王骨架页
class _TopWeekHistorySkeletonPage extends StatelessWidget {
  /// 创建往期萌王骨架页
  ///
  /// [padding] 骨架列表滚动内边距
  const _TopWeekHistorySkeletonPage({
    required this.padding,
  });

  final EdgeInsetsGeometry padding;

  /// 构建往期萌王骨架页
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      primary: false,
      itemCount: 6,
      separatorBuilder: (context, index) {
        return const TopWeekHistoryDivider();
      },
      itemBuilder: (context, index) {
        return const _TopWeekHistorySkeletonRow();
      },
    );
  }
}

/// 往期萌王条目骨架
class _TopWeekHistorySkeletonRow extends StatelessWidget {
  /// 创建往期萌王条目骨架
  const _TopWeekHistorySkeletonRow();

  /// 构建往期萌王条目骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: SizedBox(
        height: 78,
        child: Padding(
          padding: AppSafeAreaInsets.symmetricHorizontal(
            context,
            horizontal: 12,
            vertical: 12,
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 34,
                height: 48,
                child: Center(
                  child: Bone(
                    width: 24,
                    height: 22,
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                ),
              ),
              SizedBox(width: 6),
              Bone(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Bone(
                            width: 92,
                            height: 15,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                        SizedBox(width: 6),
                        Bone(
                          width: 34,
                          height: 16,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Bone(
                      width: 82,
                      height: 11,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    SizedBox(height: 3),
                    Bone(
                      width: 66,
                      height: 10,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 52,
                height: 48,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Bone(
                        width: 14,
                        height: 14,
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                      ),
                      SizedBox(width: 3),
                      Bone(
                        width: 24,
                        height: 13,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 20,
                child: Center(
                  child: Bone(
                    width: 16,
                    height: 16,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 往期萌王错误页
class _TopWeekHistoryErrorState extends StatelessWidget {
  /// 创建往期萌王错误页
  ///
  /// [onRetry] 重试回调
  const _TopWeekHistoryErrorState({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  /// 构建往期萌王错误页
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppLoadFailedState(
        title: '往期萌王加载失败',
        message: '请检查网络后重试',
        icon: Icons.error_outline_rounded,
        onActionPressed: onRetry,
      ),
    );
  }
}
