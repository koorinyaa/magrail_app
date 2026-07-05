import 'package:flutter/material.dart';

/// 应用通用加载失败 Sliver
class AppLoadFailedSliver extends StatelessWidget {
  /// 创建应用通用加载失败 Sliver
  ///
  /// [key] Flutter 组件标识
  /// [title] 失败状态标题
  /// [message] 失败状态说明
  /// [icon] 顶部状态图标
  /// [actionLabel] 重试按钮文案
  /// [actionIcon] 操作按钮图标
  /// [onActionPressed] 重试按钮点击回调
  /// [hasScrollBody] Sliver 是否包含可滚动内容
  const AppLoadFailedSliver({
    super.key,
    this.title = '加载失败',
    required this.message,
    this.icon = Icons.wifi_off_rounded,
    this.actionLabel = '重试',
    this.actionIcon = Icons.refresh_rounded,
    this.onActionPressed,
    this.hasScrollBody = false,
  });

  /// 失败状态标题
  final String title;

  /// 失败状态说明
  final String message;

  /// 顶部状态图标
  final IconData icon;

  /// 重试按钮文案
  final String? actionLabel;

  /// 操作按钮图标
  final IconData? actionIcon;

  /// 重试按钮点击回调
  final VoidCallback? onActionPressed;

  /// Sliver 是否包含可滚动内容
  final bool hasScrollBody;

  /// 构建应用通用加载失败 Sliver
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: hasScrollBody,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: AppLoadFailedState(
            title: title,
            message: message,
            icon: icon,
            actionLabel: actionLabel,
            actionIcon: actionIcon,
            onActionPressed: onActionPressed,
          ),
        ),
      ),
    );
  }
}

/// 应用通用加载失败状态
class AppLoadFailedState extends StatelessWidget {
  /// 创建应用通用加载失败状态
  ///
  /// [key] Flutter 组件标识
  /// [title] 失败状态标题
  /// [message] 失败状态说明
  /// [icon] 顶部状态图标
  /// [actionLabel] 重试按钮文案
  /// [actionIcon] 操作按钮图标
  /// [onActionPressed] 重试按钮点击回调
  const AppLoadFailedState({
    super.key,
    this.title = '加载失败',
    required this.message,
    this.icon = Icons.wifi_off_rounded,
    this.actionLabel = '重试',
    this.actionIcon = Icons.refresh_rounded,
    this.onActionPressed,
  });

  /// 失败状态标题
  final String title;

  /// 失败状态说明
  final String message;

  /// 顶部状态图标
  final IconData icon;

  /// 重试按钮文案
  final String? actionLabel;

  /// 操作按钮图标
  final IconData? actionIcon;

  /// 重试按钮点击回调
  final VoidCallback? onActionPressed;

  /// 构建应用通用加载失败状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final actionLabel = this.actionLabel;
    final onActionPressed = this.onActionPressed;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 34),
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
              TextButton.icon(
                onPressed: onActionPressed,
                icon: Icon(actionIcon, size: 16),
                label: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
