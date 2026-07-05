import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_skeleton_sliver_list.dart';
import 'package:magrail_app/features/user/controller/user_character_page_controller.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_chara_asset_sliver_list.dart';

/// 用户角色二级页面
class UserCharacterPage extends StatefulWidget {
  /// 创建用户角色二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 用户仓库
  /// [username] 用户名
  /// [nickname] 用户昵称
  const UserCharacterPage({
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

  /// 创建用户角色二级页面状态
  @override
  State<UserCharacterPage> createState() => _UserCharacterPageState();
}

/// 用户角色二级页面状态
class _UserCharacterPageState extends State<UserCharacterPage> {
  late final UserCharacterPageController _controller;

  /// 初始化用户角色二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = UserCharacterPageController(
      repository: widget.repository,
      username: widget.username,
    )..initialize();
  }

  /// 释放用户角色二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建用户角色二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailPagedSliverPage(
      controller: _controller,
      title: _title,
      loadingSliver: const CharacterAssetSkeletonSliverList(
        showTrailing: true,
      ),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无角色',
          message: '当前用户没有可展示的角色',
          icon: Icons.hourglass_empty_rounded,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          UserCharacterAssetSliverList(
            items: items,
            onItemBuilt: onItemBuilt,
            onCharacterTap: _openCharacterDetail,
          ),
        ];
      },
      completedLabel: '没有更多角色了',
    );
  }

  /// 打开角色详情页
  ///
  /// [item] 用户角色条目
  /// [avatarHeroTag] 入口头像转场标识
  void _openCharacterDetail(
    UserCharacterApiItem item,
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

  /// 页面标题
  String get _title {
    final nickname = widget.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return '$nickname的角色';
    }

    if (widget.username.isNotEmpty) {
      return '${widget.username}的角色';
    }

    return '用户角色';
  }
}
