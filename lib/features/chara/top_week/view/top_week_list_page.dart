import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/secondary_page_refresh_view.dart';
import 'package:magrail_app/features/chara/top_week/controller/top_week_controller.dart';
import 'package:magrail_app/features/chara/top_week/model/top_week_entry.dart';
import 'package:magrail_app/features/chara/top_week/widgets/top_week_list.dart';

/// 当前每周萌王二级列表页面
class TopWeekListPage extends StatefulWidget {
  /// 创建当前每周萌王二级列表页面
  ///
  /// [key] Flutter 组件标识
  /// [controller] 首页共享的每周萌王控制器
  /// [onCharacterPressed] 角色详情点击回调
  /// [onAuctionPressed] 拍卖按钮点击回调
  const TopWeekListPage({
    super.key,
    required this.controller,
    required this.onCharacterPressed,
    required this.onAuctionPressed,
  });

  /// 首页共享的每周萌王控制器
  final TopWeekController controller;

  /// 角色详情点击回调
  final void Function(TopWeekEntry entry, String? avatarHeroTag)
  onCharacterPressed;

  /// 拍卖按钮点击回调
  final ValueChanged<TopWeekEntry> onAuctionPressed;

  /// 创建当前每周萌王二级列表页面状态
  @override
  State<TopWeekListPage> createState() => _TopWeekListPageState();
}

/// 当前每周萌王二级列表页面状态
class _TopWeekListPageState extends State<TopWeekListPage> {
  final ScrollController _scrollController = ScrollController();

  /// 释放当前每周萌王二级列表页面状态
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 构建当前每周萌王二级列表页面
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
          final controller = widget.controller;
          return SecondaryPageRefreshView(
            title: '每周萌王',
            titleSupplement: '(${controller.refreshLabel})',
            onRefresh: controller.refresh,
            scrollController: _scrollController,
            slivers: _buildSlivers(controller),
          );
        },
      ),
    );
  }

  /// 构建当前每周萌王列表内容
  ///
  /// [controller] 首页共享的每周萌王控制器
  List<Widget> _buildSlivers(TopWeekController controller) {
    final entries = controller.entries;
    if (controller.isLoading && entries == null) {
      return const <Widget>[TopWeekListSkeleton()];
    }

    if (controller.isLoadFailed && (entries == null || entries.isEmpty)) {
      return <Widget>[
        AppLoadFailedSliver(
          message: '请检查网络后重试',
          onActionPressed: () => unawaited(controller.refresh()),
        ),
      ];
    }

    if (entries == null || entries.isEmpty) {
      return const <Widget>[
        PagedSliverState(
          title: '暂无每周萌王',
          message: '当前没有可展示的每周萌王',
          icon: Icons.inbox_rounded,
        ),
      ];
    }

    return <Widget>[
      TopWeekList(
        entries: entries,
        onCharacterPressed: widget.onCharacterPressed,
        onAuctionPressed: widget.onAuctionPressed,
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 24 + MediaQuery.paddingOf(context).bottom,
        ),
      ),
    ];
  }
}
