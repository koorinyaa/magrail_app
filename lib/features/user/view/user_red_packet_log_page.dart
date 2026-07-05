import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/user/controller/user_red_packet_log_page_controller.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_red_packet_log_sliver_list.dart';

/// 用户红包记录二级页面
class UserRedPacketLogPage extends StatefulWidget {
  /// 创建用户红包记录二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 用户仓库
  /// [username] 用户名
  /// [nickname] 用户昵称
  const UserRedPacketLogPage({
    super.key,
    required this.repository,
    required this.username,
    this.nickname,
  });

  /// 用户仓库
  final UserRepository repository;

  /// 用户名
  final String username;

  /// 用户昵称
  final String? nickname;

  /// 创建用户红包记录二级页面状态
  @override
  State<UserRedPacketLogPage> createState() => _UserRedPacketLogPageState();
}

/// 用户红包记录二级页面状态
class _UserRedPacketLogPageState extends State<UserRedPacketLogPage> {
  late final UserRedPacketLogPageController _controller;

  /// 初始化用户红包记录二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = UserRedPacketLogPageController(
      repository: widget.repository,
      username: widget.username,
    )..initialize();
  }

  /// 释放用户红包记录二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建用户红包记录二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailPagedSliverPage(
      controller: _controller,
      title: _title,
      loadingSliver: const UserRedPacketLogSkeletonSliverList(),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无红包记录',
          message: '当前没有可展示的红包记录',
          icon: Icons.card_giftcard_outlined,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          UserRedPacketLogSliverList(
            items: items,
            onItemBuilt: onItemBuilt,
            onUserTap: _openUserDetail,
          ),
        ];
      },
      completedLabel: '没有更多红包记录了',
    );
  }

  /// 页面标题
  String get _title {
    final nickname = widget.nickname?.trim();
    if (nickname == null || nickname.isEmpty) {
      return '红包记录';
    }

    return '$nickname 的红包记录';
  }

  /// 打开关联用户详情页
  ///
  /// [username] 用户名
  void _openUserDetail(String username) {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      return;
    }

    context.pushNamed(
      'userDetail',
      queryParameters: {'username': resolvedUsername},
    );
  }
}
