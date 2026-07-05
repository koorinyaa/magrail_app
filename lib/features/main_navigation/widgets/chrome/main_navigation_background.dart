import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/app_soft_background.dart';

/// 主导航页柔色背景
class MainNavigationBackground extends StatelessWidget {
  /// 创建主导航页柔色背景
  ///
  /// [key] Flutter 组件标识
  /// [isDark] 是否使用深色模式
  const MainNavigationBackground({
    super.key,
    required this.isDark,
  });

  /// 是否使用深色模式
  final bool isDark;

  /// 构建主导航页柔色背景
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return AppSoftBackground(isDark: isDark);
  }
}
