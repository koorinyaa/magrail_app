import 'package:flutter/material.dart';

/// 圣殿连接值标签
class TempleLinkValueChip extends StatelessWidget {
  /// 创建圣殿连接值标签
  ///
  /// [key] Flutter 组件标识
  /// [valueLabel] 连接值文本
  const TempleLinkValueChip({
    super.key,
    required this.valueLabel,
  });

  /// 连接值文本
  final String valueLabel;

  /// 构建圣殿连接值标签
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final accentColor = colorScheme.primary;

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.58 : 0.46),
          width: 1.1,
        ),
      ),
      child: Text(
        valueLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: accentColor.withValues(alpha: isDark ? 0.92 : 0.86),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
