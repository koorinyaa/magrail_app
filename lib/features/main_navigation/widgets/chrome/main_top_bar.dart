import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/app_page_title_bar.dart';

/// 主顶部栏
class MainTopBar extends StatelessWidget {
  /// 创建主顶部栏
  ///
  /// [key] Flutter 组件标识
  /// [title] 页面标题
  /// [onSearchPressed] 搜索按钮点击回调
  const MainTopBar({
    super.key,
    required this.title,
    required this.onSearchPressed,
  });

  /// 顶部栏标题
  final String title;

  /// 搜索按钮点击回调
  final VoidCallback onSearchPressed;

  /// 构建主顶部栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return AppPageTitleBar(
      title: title,
      onSearchPressed: onSearchPressed,
    );
  }
}
