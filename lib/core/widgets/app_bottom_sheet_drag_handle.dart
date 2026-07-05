import 'package:flutter/material.dart';

/// 底部抽屉拖拽提示条
class AppBottomSheetDragHandle extends StatelessWidget {
  /// 创建底部抽屉拖拽提示条
  ///
  /// [key] Flutter 组件标识
  const AppBottomSheetDragHandle({super.key});

  /// 构建底部抽屉拖拽提示条
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        width: 64,
        height: 5,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.28)
              : Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
