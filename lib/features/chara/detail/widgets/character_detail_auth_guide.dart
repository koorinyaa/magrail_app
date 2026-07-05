import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';

/// 角色详情授权引导区
class CharacterDetailAuthGuideSection extends StatelessWidget {
  /// 创建角色详情授权引导区
  ///
  /// [key] Flutter 组件标识
  /// [onAuthorize] 打开 Tinygrail 授权页回调
  const CharacterDetailAuthGuideSection({
    super.key,
    required this.onAuthorize,
  });

  /// 打开 Tinygrail 授权页回调
  final VoidCallback onAuthorize;

  /// 构建角色详情授权引导区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return AppLoadFailedState(
      title: '未授权',
      message: '部分功能需要授权才能使用',
      icon: Icons.shield_outlined,
      actionLabel: '点击授权',
      actionIcon: Icons.open_in_new_rounded,
      onActionPressed: onAuthorize,
    );
  }
}
