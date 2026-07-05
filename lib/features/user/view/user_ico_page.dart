import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_skeleton_sliver_list.dart';
import 'package:magrail_app/features/user/controller/user_ico_page_controller.dart';
import 'package:magrail_app/features/user/model/user_ico_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_chara_asset_sliver_list.dart';

/// 用户 ICO 二级页面
class UserIcoPage extends StatefulWidget {
  /// 创建用户 ICO 二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 用户仓库
  /// [username] 用户名
  /// [nickname] 用户昵称
  const UserIcoPage({
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

  /// 创建用户 ICO 二级页面状态
  @override
  State<UserIcoPage> createState() => _UserIcoPageState();
}

/// 用户 ICO 二级页面状态
class _UserIcoPageState extends State<UserIcoPage> {
  late final UserIcoPageController _controller;

  /// 初始化用户 ICO 二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = UserIcoPageController(
      repository: widget.repository,
      username: widget.username,
    )..initialize();
  }

  /// 释放用户 ICO 二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建用户 ICO 二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailPagedSliverPage(
      controller: _controller,
      title: _title,
      loadingSliver: const CharacterAssetSkeletonSliverList(
        showLevel: false,
        metricCount: 2,
        showTrailing: true,
      ),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无ICO',
          message: '当前用户没有可展示的ICO',
          icon: Icons.hourglass_empty_rounded,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          UserIcoAssetSliverList(
            items: items,
            onItemBuilt: onItemBuilt,
            onIcoTap: _openCharacterDetail,
          ),
        ];
      },
      completedLabel: '没有更多ICO了',
    );
  }

  /// 页面标题
  String get _title {
    final nickname = widget.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return '$nickname的ICO';
    }

    if (widget.username.isNotEmpty) {
      return '${widget.username}的ICO';
    }

    return '用户ICO';
  }

  /// 打开角色详情页
  ///
  /// [item] 用户 ICO 条目
  /// [avatarHeroTag] 入口头像转场标识
  void _openCharacterDetail(
    UserIcoApiItem item,
    String? avatarHeroTag,
  ) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.name,
      avatarUrl: item.icon,
      avatarHeroTag: avatarHeroTag,
    );
  }
}
