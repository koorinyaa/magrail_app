import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';

/// 二级页面固定顶部栏
class SecondaryPageSliverAppBar extends StatelessWidget {
  /// 二级页面顶部栏默认工具栏高度
  static const double defaultToolbarHeight = 48;

  /// 创建二级页面固定顶部栏
  ///
  /// [key] Flutter 组件标识
  /// [title] 页面标题
  /// [onBackPressed] 返回按钮点击回调
  /// [actions] 右侧操作组件
  /// [bottom] 顶部栏下方的固定区域
  const SecondaryPageSliverAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.bottom,
  });

  /// 页面标题
  final String title;

  /// 返回按钮点击回调
  final VoidCallback? onBackPressed;

  /// 右侧操作组件
  final List<Widget>? actions;

  /// 顶部栏下方的固定区域
  final PreferredSizeWidget? bottom;

  /// 构建二级页面固定顶部栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final systemOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );

    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      toolbarHeight: defaultToolbarHeight,
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      forceMaterialTransparency: true,
      systemOverlayStyle: systemOverlayStyle,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: AppBlurStyle.filter,
          child: SizedBox.expand(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppBlurStyle.surfaceColor(context),
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
        icon: const Icon(
          Icons.chevron_left_rounded,
          size: 30,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      actions: actions ?? const [SizedBox(width: kToolbarHeight)],
      bottom: bottom,
    );
  }
}
