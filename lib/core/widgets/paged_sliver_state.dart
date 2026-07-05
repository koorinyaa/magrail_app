import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';

/// 分页二级页面状态页
class PagedSliverState extends StatelessWidget {
  /// 创建分页二级页面状态页
  ///
  /// [key] Flutter 组件标识
  /// [title] 状态标题
  /// [message] 状态说明
  /// [icon] 状态图标
  /// [actionLabel] 操作文案
  /// [onActionPressed] 操作点击回调
  const PagedSliverState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onActionPressed,
  });

  /// 状态标题
  final String title;

  /// 状态说明
  final String message;

  /// 状态图标
  final IconData icon;

  /// 操作文案
  final String? actionLabel;

  /// 操作点击回调
  final VoidCallback? onActionPressed;

  /// 构建分页二级页面状态页
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: AppSafeAreaInsets.symmetricHorizontal(
            context,
            horizontal: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: colorScheme.onSurfaceVariant,
                size: 34,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              if (actionLabel != null && onActionPressed != null) ...[
                const SizedBox(height: 18),
                FilledButton.tonalIcon(
                  onPressed: onActionPressed,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
