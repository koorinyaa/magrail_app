import 'package:flutter/material.dart';

/// 每周萌王刷新状态按钮
class TopWeekRefreshStatusButton extends StatelessWidget {
  /// 创建每周萌王刷新状态按钮
  ///
  /// [label] 刷新状态文案
  /// [onPressed] 刷新按钮点击回调
  const TopWeekRefreshStatusButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  /// 刷新状态文案
  final String label;

  /// 刷新按钮点击回调
  final VoidCallback onPressed;

  /// 构建每周萌王刷新状态按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
              const SizedBox(width: 1),
              Icon(
                Icons.refresh_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 11,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
