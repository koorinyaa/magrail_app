import 'package:flutter/material.dart';

/// 首页区块操作按钮
class HomeSectionActionButton extends StatelessWidget {
  /// 创建首页区块操作按钮
  ///
  /// [icon] 按钮图标
  /// [label] 按钮文案
  /// [onPressed] 点击回调
  const HomeSectionActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  /// 按钮图标
  final IconData icon;

  /// 按钮文案
  final String label;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建首页区块操作按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colorScheme.primary, size: 16),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
