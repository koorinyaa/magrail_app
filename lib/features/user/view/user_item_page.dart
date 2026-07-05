import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:magrail_app/features/user/controller/user_item_page_controller.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_sliver_list.dart';

/// 用户道具二级页面
class UserItemPage extends StatefulWidget {
  /// 创建用户道具二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 用户仓库
  const UserItemPage({
    super.key,
    required this.repository,
  });

  /// 用户仓库
  final UserRepository repository;

  /// 创建用户道具二级页面状态
  @override
  State<UserItemPage> createState() => _UserItemPageState();
}

/// 用户道具二级页面状态
class _UserItemPageState extends State<UserItemPage> {
  late final UserItemPageController _controller;

  /// 初始化用户道具二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = UserItemPageController(
      repository: widget.repository,
    )..initialize();
  }

  /// 释放用户道具二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建用户道具二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          final isStateOnlyContent =
              !_controller.isLoading && _controller.items.isEmpty;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SecondaryPageSliverAppBar(title: '我的道具'),
                if (_controller.isLoading)
                  const UserItemSkeletonSliverList()
                else if (_controller.errorMessage != null &&
                    _controller.items.isEmpty)
                  AppLoadFailedSliver(
                    message: _controller.errorMessage ?? '请检查网络后重试',
                    onActionPressed: _retry,
                  )
                else if (_controller.items.isEmpty)
                  const PagedSliverState(
                    title: '暂无道具',
                    message: '当前没有可展示的道具',
                    icon: Icons.inventory_2_outlined,
                  )
                else
                  UserItemSliverList(items: _controller.items),
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

  /// 下拉刷新用户道具列表
  Future<void> _refresh() async {
    final isSuccess = await _controller.refresh();
    if (!mounted || isSuccess) {
      return;
    }

    AppToast.error(
      context,
      text: '刷新失败，请检查网络后重试',
    );
  }

  /// 重试加载用户道具列表
  void _retry() {
    unawaited(_refresh());
  }
}
