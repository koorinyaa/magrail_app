import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bootstrap.dart';
import 'router/app_router.dart';
import 'theme/app_material_theme.dart';

/// Magrail 根组件
class MagrailApp extends StatelessWidget {
  /// 创建根组件
  ///
  /// [key] Flutter 组件标识
  /// [dependencies] 应用依赖集合
  /// [themeMode] 应用主题模式
  const MagrailApp({
    super.key,
    required this.dependencies,
    ThemeMode? themeMode,
  }) : _themeMode = themeMode;

  final AppDependencies dependencies;
  final ThemeMode? _themeMode;

  /// 当前应用主题模式
  ThemeMode get themeMode => _themeMode ?? ThemeMode.system;

  /// 构建根组件
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MaGrail',
      debugShowCheckedModeBanner: false,
      theme: AppMaterialTheme.light(),
      darkTheme: AppMaterialTheme.dark(),
      themeMode: themeMode,
      builder: (context, child) {
        final brightness = _resolveBrightness(context);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: _buildSystemOverlayStyle(brightness),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: createAppRouter(dependencies: dependencies),
    );
  }

  /// 解析当前系统栏亮暗模式
  ///
  /// [context] 当前组件树上下文
  Brightness _resolveBrightness(BuildContext context) {
    return switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
  }

  /// 构建系统栏样式
  ///
  /// [brightness] 当前亮暗模式
  SystemUiOverlayStyle _buildSystemOverlayStyle(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    );
  }
}
