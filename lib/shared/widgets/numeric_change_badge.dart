import 'package:flutter/material.dart';

/// 带方向箭头的数值变化徽标
class NumericChangeBadge extends StatelessWidget {
  /// 创建数值变化徽标
  ///
  /// [key] Flutter 组件标识
  /// [text] 已格式化的变化绝对值
  /// [increased] 是否使用上升方向与强调色
  const NumericChangeBadge({
    super.key,
    required this.text,
    required this.increased,
  });

  /// 已格式化的变化绝对值
  final String text;

  /// 是否使用上升方向与强调色
  final bool increased;

  /// 构建变化方向和数值
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final color = increased ? const Color(0xFFFF5A91) : const Color(0xFF38A8E8);
    return Container(
      constraints: const BoxConstraints(minHeight: 16),
      margin: const EdgeInsets.only(left: 3),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            increased
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 1),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
