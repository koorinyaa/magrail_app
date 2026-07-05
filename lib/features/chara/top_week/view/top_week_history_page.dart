import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:magrail_app/features/chara/top_week/controller/top_week_history_controller.dart';
import 'package:magrail_app/features/chara/top_week/repository/top_week_repository.dart';
import 'package:magrail_app/features/chara/top_week/widgets/top_week_history_pager.dart';

/// 往期萌王二级页面
class TopWeekHistoryPage extends StatefulWidget {
  /// 创建往期萌王二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 每周萌王仓库
  const TopWeekHistoryPage({
    super.key,
    required this.repository,
  });

  /// 每周萌王仓库
  final TopWeekRepository repository;

  /// 创建往期萌王二级页面状态
  @override
  State<TopWeekHistoryPage> createState() => _TopWeekHistoryPageState();
}

/// 往期萌王二级页面状态
class _TopWeekHistoryPageState extends State<TopWeekHistoryPage> {
  late final TopWeekHistoryController _controller;

  /// 初始化往期萌王二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = TopWeekHistoryController(
      repository: widget.repository,
    )..initialize();
  }

  /// 释放往期萌王二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建往期萌王二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final padding = MediaQuery.paddingOf(context);
    const pageTopSpacing = 12.0;
    final appBarHeight = padding.top +
        SecondaryPageSliverAppBar.defaultToolbarHeight +
        TopWeekHistoryPageIndicator.height;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          final title = resolveTopWeekHistoryPageTitle(
            _controller.pageAt(_controller.currentPage),
          );

          return Stack(
            children: [
              Positioned.fill(
                child: TopWeekHistoryPager(
                  controller: _controller,
                  contentPadding: EdgeInsets.fromLTRB(
                    0,
                    appBarHeight + pageTopSpacing,
                    0,
                    16 + padding.bottom,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: appBarHeight,
                child: CustomScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  slivers: [
                    SecondaryPageSliverAppBar(
                      title: title,
                      bottom: TopWeekHistoryPageIndicator(
                        currentPage: _controller.currentPage,
                        totalPages: _controller.totalPages,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
