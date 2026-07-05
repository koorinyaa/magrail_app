import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/user/controller/user_balance_log_page_controller.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_sliver_list.dart';

/// 用户资金日志二级页面
class UserBalanceLogPage extends StatefulWidget {
  /// 创建用户资金日志二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 用户仓库
  const UserBalanceLogPage({
    super.key,
    required this.repository,
  });

  /// 用户仓库
  final UserRepository repository;

  /// 创建用户资金日志二级页面状态
  @override
  State<UserBalanceLogPage> createState() => _UserBalanceLogPageState();
}

/// 用户资金日志二级页面状态
class _UserBalanceLogPageState extends State<UserBalanceLogPage> {
  late final UserBalanceLogPageController _controller;

  /// 初始化用户资金日志二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = UserBalanceLogPageController(
      repository: widget.repository,
    )..initialize();
  }

  /// 释放用户资金日志二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建用户资金日志二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailPagedSliverPage(
      controller: _controller,
      title: '资金日志',
      loadingSliver: const UserBalanceLogSkeletonSliverList(),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无资金日志',
          message: '当前没有可展示的资金变动记录',
          icon: Icons.receipt_long_outlined,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          UserBalanceLogSliverList(
            items: items,
            onItemBuilt: onItemBuilt,
            onCharacterTap: _handleCharacterTap,
          ),
        ];
      },
      completedLabel: '没有更多资金日志了',
    );
  }

  /// 处理资金日志角色 ID 点击
  ///
  /// [characterId] 角色 ID
  void _handleCharacterTap(int characterId) {
    openCharacterDetail(
      context,
      characterId: characterId,
    );
  }
}
