import 'dart:ui';

import 'package:flutter/material.dart';

/// 应用统一模糊浮层样式
class AppBlurStyle {
  /// 禁止创建应用统一模糊浮层样式
  const AppBlurStyle._();

  /// 项目统一背景模糊强度
  static const double sigma = 18;

  /// 浅色模式浮层表面透明度
  static const double lightSurfaceAlpha = 0.62;

  /// 深色模式浮层表面透明度
  static const double darkSurfaceAlpha = 0.72;

  /// 创建项目统一背景模糊滤镜
  static ImageFilter get filter {
    return ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
  }

  /// 解析项目统一模糊浮层表面色
  ///
  /// [context] 当前组件树上下文
  static Color surfaceColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return colorScheme.surface.withValues(
      alpha: isDark ? darkSurfaceAlpha : lightSurfaceAlpha,
    );
  }
}
