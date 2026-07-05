import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/ico/controller/st_character_controller.dart';
import 'package:magrail_app/features/ico/model/st_character_entry.dart';
import 'package:magrail_app/features/ico/repository/st_character_repository.dart';
import 'package:magrail_app/features/ico/widgets/st_character_assets.dart';

/// ST 角色二级页面
class StCharacterPage extends StatefulWidget {
  /// 创建 ST 角色二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] ST 角色仓库
  const StCharacterPage({
    super.key,
    required this.repository,
  });

  /// ST 角色仓库
  final StCharacterRepository repository;

  /// 创建 ST 角色二级页面状态
  @override
  State<StCharacterPage> createState() => _StCharacterPageState();
}

/// ST 角色二级页面状态
class _StCharacterPageState extends State<StCharacterPage> {
  late final StCharacterPageController _controller;

  /// 初始化 ST 角色二级页面状态
  @override
  void initState() {
    super.initState();
    _controller = StCharacterPageController(
      repository: widget.repository,
    )..initialize();
  }

  /// 释放 ST 角色二级页面状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建 ST 角色二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailPagedSliverPage<StCharacterEntry, StCharacterEntry>(
      controller: _controller,
      title: 'ST',
      loadingSliver: const StCharacterSkeletonSliverList(),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无 ST 角色',
          message: '当前没有可展示的 ST 角色',
          icon: Icons.inbox_rounded,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          StCharacterSliverList(
            items: items,
            onItemBuilt: onItemBuilt,
            onCharacterTap: _openCharacterDetail,
          ),
        ];
      },
      completedLabel: '没有更多 ST 角色了',
    );
  }

  /// 打开角色详情页
  ///
  /// [item] ST 角色条目
  /// [avatarHeroTag] 头像转场标识
  void _openCharacterDetail(
    StCharacterEntry item,
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
