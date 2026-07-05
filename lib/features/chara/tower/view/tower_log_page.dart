import 'package:flutter/material.dart';
import 'package:magrail_app/features/chara/tower/controller/tower_log_controller.dart';
import 'package:magrail_app/features/chara/tower/repository/tower_repository.dart';
import 'package:magrail_app/features/chara/tower/widgets/tower_log_panel.dart';

/// 通天塔日志二级页面
class TowerLogPage extends StatefulWidget {
  /// 创建通天塔日志二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 通天塔仓库
  const TowerLogPage({
    super.key,
    required this.repository,
  });

  /// 通天塔仓库
  final TowerRepository repository;

  /// 创建通天塔日志二级页面状态
  @override
  State<TowerLogPage> createState() => _TowerLogPageState();
}

/// 通天塔日志二级页面状态
class _TowerLogPageState extends State<TowerLogPage> {
  late final TowerLogController _controller;
  final ScrollController _scrollController = ScrollController();

  /// 初始化通天塔日志二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = TowerLogController(
      repository: widget.repository,
    )..initialize();
  }

  /// 释放通天塔日志二级页面状态
  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// 构建通天塔日志二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _controller.refreshLatest,
        child: TowerLogPanel(
          controller: _controller,
          scrollController: _scrollController,
          onHistoryItemBuilt: _handleHistoryItemBuilt,
        ),
      ),
    );
  }

  /// 处理历史日志条目构建触发的分页预加载
  ///
  /// [index] 当前构建的历史日志下标
  void _handleHistoryItemBuilt(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _controller.handleHistoryItemBuilt(index);
    });
  }
}
