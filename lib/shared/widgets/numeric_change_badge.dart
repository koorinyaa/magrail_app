import 'package:flutter/material.dart';

/// 带方向箭头的数值变化徽标
class NumericChangeBadge extends StatelessWidget {
  /// 创建数值变化徽标
  ///
  /// [key] Flutter 组件标识
  /// [text] 已格式化的变化绝对值
  /// [increased] 是否使用上升方向与强调色
  /// [compact] 是否使用紧凑尺寸
  const NumericChangeBadge({
    super.key,
    required this.text,
    required this.increased,
    this.compact = false,
  });

  /// 已格式化的变化绝对值
  final String text;

  /// 是否使用上升方向与强调色
  final bool increased;

  /// 是否使用紧凑尺寸
  final bool compact;

  /// 构建变化方向和数值
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final color = increased ? const Color(0xFFFF5A91) : const Color(0xFF38A8E8);
    final iconSize = compact ? 8.0 : 10.0;
    final fontSize = compact ? 8.0 : 10.0;
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 12 : 16),
      margin: const EdgeInsets.only(left: 3),
      padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(compact ? 4 : 5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            increased
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: iconSize,
            color: color,
          ),
          SizedBox(width: compact ? 0 : 1),
          Flexible(
            child: Text(
              text,
              // 紧凑徽标随外层 WidgetSpan 整体缩放，避免文字二次缩放撑高数据行
              textScaler: compact ? TextScaler.noScaling : null,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: fontSize,
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
