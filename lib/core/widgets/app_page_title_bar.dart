import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';

/// 应用页面标题栏
class AppPageTitleBar extends StatelessWidget {
  /// 创建应用页面标题栏
  ///
  /// [key] Flutter 组件标识
  /// [title] 页面标题
  /// [onSearchPressed] 搜索按钮点击回调
  /// [showBackButton] 是否显示返回按钮
  /// [onBackPressed] 返回按钮点击回调
  const AppPageTitleBar({
    super.key,
    required this.title,
    this.onSearchPressed,
    this.showBackButton = false,
    this.onBackPressed,
  });

  /// 标题栏整体高度
  static const double height = 72;

  /// 页面标题
  final String title;

  /// 搜索按钮点击回调
  final VoidCallback? onSearchPressed;

  /// 是否显示返回按钮
  final bool showBackButton;

  /// 返回按钮点击回调
  final VoidCallback? onBackPressed;

  /// 构建应用页面标题栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: showBackButton ? 6 : 24,
        top: 8,
        right: 18,
        bottom: 8,
      ),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            if (showBackButton) ...[
              IconButton(
                onPressed:
                    onBackPressed ?? () => Navigator.of(context).maybePop(),
                style: IconButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  backgroundColor: Colors.transparent,
                  minimumSize: const Size.square(42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: Align(
                  key: ValueKey(title),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.08,
                    ),
                  ),
                ),
              ),
            ),
            if (onSearchPressed case final onSearchPressed?)
              IconButton(
                onPressed: onSearchPressed,
                style: IconButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  backgroundColor: Colors.transparent,
                  minimumSize: const Size.square(42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.search_rounded, size: 22),
              ),
          ],
        ),
      ),
    );
  }
}
