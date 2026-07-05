import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/user/controller/user_trade_log_page_controller.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_trade_log_sliver_list.dart';

/// 用户交易记录二级页面
class UserTradeLogPage extends StatefulWidget {
  /// 创建用户交易记录二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 用户仓库
  /// [userId] 用户 ID
  /// [username] 用户名
  /// [nickname] 用户昵称
  const UserTradeLogPage({
    super.key,
    required this.repository,
    required this.userId,
    required this.username,
    this.nickname,
  });

  /// 用户仓库
  final UserRepository repository;

  /// 用户 ID
  final int userId;

  /// 用户名
  final String username;

  /// 用户昵称
  final String? nickname;

  /// 创建用户交易记录二级页面状态
  @override
  State<UserTradeLogPage> createState() => _UserTradeLogPageState();
}

/// 用户交易记录二级页面状态
class _UserTradeLogPageState extends State<UserTradeLogPage> {
  late final UserTradeLogPageController _controller;

  /// 初始化用户交易记录二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = UserTradeLogPageController(
      repository: widget.repository,
      userId: widget.userId,
    )..initialize();
  }

  /// 释放用户交易记录二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建用户交易记录二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailPagedSliverPage(
      controller: _controller,
      title: _title,
      loadingSliver: const UserTradeLogSkeletonSliverList(),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无交易记录',
          message: '当前没有可展示的交易记录',
          icon: Icons.receipt_long_outlined,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          UserTradeLogSliverList(
            items: items,
            ownerUsername: widget.username,
            onItemBuilt: onItemBuilt,
            onUserTap: _openUserDetail,
            onCharacterTap: _openCharacterDetail,
          ),
        ];
      },
      completedLabel: '没有更多交易记录了',
    );
  }

  /// 页面标题
  String get _title {
    final nickname = widget.nickname?.trim();
    if (nickname == null || nickname.isEmpty) {
      return '交易记录';
    }

    return '$nickname 的交易记录';
  }

  /// 打开用户详情页
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

  /// 打开角色详情页
  ///
  /// [characterId] 角色 ID
  void _openCharacterDetail(int characterId) {
    openCharacterDetail(
      context,
      characterId: characterId,
    );
  }
}
