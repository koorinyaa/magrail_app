import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/trade_history/controller/character_gm_trade_history_page_controller.dart';
import 'package:magrail_app/features/chara/trade_history/repository/character_trade_history_repository.dart';
import 'package:magrail_app/features/chara/trade_history/widgets/character_gm_trade_history_sliver_list.dart';

/// 角色 GM 交易记录二级页面
class CharacterGmTradeHistoryPage extends StatefulWidget {
  /// 创建角色 GM 交易记录二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 角色交易记录仓库
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  const CharacterGmTradeHistoryPage({
    super.key,
    required this.repository,
    required this.characterId,
    this.characterName,
  });

  /// 角色交易记录仓库
  final CharacterTradeHistoryRepository repository;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String? characterName;

  /// 创建角色 GM 交易记录二级页面状态
  @override
  State<CharacterGmTradeHistoryPage> createState() =>
      _CharacterGmTradeHistoryPageState();
}

/// 角色 GM 交易记录二级页面状态
class _CharacterGmTradeHistoryPageState
    extends State<CharacterGmTradeHistoryPage> {
  late final CharacterGmTradeHistoryPageController _controller;

  /// 初始化角色 GM 交易记录二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = CharacterGmTradeHistoryPageController(
      repository: widget.repository,
      characterId: widget.characterId,
    )..initialize();
  }

  /// 释放角色 GM 交易记录二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建角色 GM 交易记录二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailPagedSliverPage(
      controller: _controller,
      title: _title,
      loadingSliver: const CharacterGmTradeHistorySkeletonSliverList(),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无交易记录',
          message: '当前角色没有可展示的交易记录',
          icon: Icons.receipt_long_outlined,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          CharacterGmTradeHistorySliverList(
            items: items,
            onItemBuilt: onItemBuilt,
            onUserTap: _openUserDetail,
          ),
        ];
      },
      completedLabel: '没有更多交易记录了',
    );
  }

  /// 页面标题
  String get _title {
    final name = TinygrailFormatters.decodeHtmlEntities(
      widget.characterName ?? '',
    ).trim();
    if (name.isEmpty) {
      return '交易记录(GM)';
    }

    return '$name 的交易记录(GM)';
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
}
