import 'package:flutter/widgets.dart';

/// 应用安全区间距工具
class AppSafeAreaInsets {
  /// 禁止创建应用安全区间距工具
  const AppSafeAreaInsets._();

  /// 创建叠加横向安全区的对称内边距
  ///
  /// [context] 当前组件树上下文
  /// [horizontal] 基础水平内边距
  /// [vertical] 基础垂直内边距
  static EdgeInsets symmetricHorizontal(
    BuildContext context, {
    required double horizontal,
    double vertical = 0,
  }) {
    final padding = MediaQuery.paddingOf(context);
    return EdgeInsets.fromLTRB(
      horizontal + padding.left,
      vertical,
      horizontal + padding.right,
      vertical,
    );
  }

  /// 创建叠加横向安全区的四边内边距
  ///
  /// [context] 当前组件树上下文
  /// [left] 基础左内边距
  /// [top] 基础上内边距
  /// [right] 基础右内边距
  /// [bottom] 基础下内边距
  static EdgeInsets fromLTRB(
    BuildContext context, {
    required double left,
    required double top,
    required double right,
    required double bottom,
  }) {
    final padding = MediaQuery.paddingOf(context);
    return EdgeInsets.fromLTRB(
      left + padding.left,
      top,
      right + padding.right,
      bottom,
    );
  }

  /// 读取横向安全区总宽度
  ///
  /// [context] 当前组件树上下文
  static double horizontalSum(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return padding.left + padding.right;
  }
}
