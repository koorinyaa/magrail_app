import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/update/app_update_dialog.dart';

import 'bootstrap.dart';
import 'router/app_router.dart';
import 'theme/app_material_theme.dart';

// 采用 Cupertino 支持集确保 Android 与 iOS 文本操作菜单都有对应翻译
final List<Locale> _flutterSupportedLocales = <Locale>[
  const Locale('en'),
  for (final languageCode in kCupertinoSupportedLanguages)
    if (languageCode != 'en') Locale(languageCode),
];

/// Magrail 根组件
class MagrailApp extends StatefulWidget {
  /// 创建根组件
  ///
  /// [key] Flutter 组件标识
  /// [dependencies] 应用依赖集合
  /// [themeMode] 启动时覆盖本地偏好的主题模式
  const MagrailApp({
    super.key,
    required this.dependencies,
    ThemeMode? themeMode,
  }) : _themeMode = themeMode;

  /// 应用依赖集合
  final AppDependencies dependencies;
  final ThemeMode? _themeMode;

  /// 创建根组件状态
  @override
  State<MagrailApp> createState() => _MagrailAppState();
}

/// Magrail 根组件状态
class _MagrailAppState extends State<MagrailApp> {
  late final GlobalKey<NavigatorState> _rootNavigatorKey;
  late final GoRouter _router;
  late ThemeMode _themeMode;

  /// 初始化根组件状态
  @override
  void initState() {
    super.initState();
    _themeMode = widget._themeMode ?? widget.dependencies.preferences.themeMode;
    _rootNavigatorKey = GlobalKey<NavigatorState>();
    _router = createAppRouter(
      dependencies: widget.dependencies,
      rootNavigatorKey: _rootNavigatorKey,
      onThemeModeChanged: _handleThemeModeChanged,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForStartupUpdate();
    });
  }

  /// 释放根组件状态
  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

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
      themeMode: _themeMode,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: _flutterSupportedLocales,
      builder: (context, child) {
        final brightness = _resolveBrightness(context);

        return Actions(
          actions: <Type, Action<Intent>>{
            EditableTextTapOutsideIntent:
                CallbackAction<EditableTextTapOutsideIntent>(
              onInvoke: _unfocusEditableText,
            ),
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: _buildSystemOverlayStyle(brightness),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      routerConfig: _router,
    );
  }

  /// 检查启动时是否需要提示新版本
  Future<void> _checkForStartupUpdate() async {
    try {
      final controller = widget.dependencies.updateController;
      final result = await controller.checkForUpdate();
      if (!mounted || !result.hasUpdate) {
        return;
      }

      final shouldPrompt = await controller.shouldShowAutomaticPrompt();
      if (!mounted || !shouldPrompt) {
        return;
      }

      final context = _rootNavigatorKey.currentContext;
      if (context == null || !context.mounted) {
        return;
      }

      await showAppUpdateDialog(
        context,
        controller: controller,
        markPrompted: true,
      );
    } catch (_) {
      // 启动检查失败不影响应用正常使用
    }
  }

  /// 解析当前系统栏亮暗模式
  ///
  /// [context] 当前组件树上下文
  Brightness _resolveBrightness(BuildContext context) {
    return switch (_themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
  }

  /// 处理应用主题模式变化
  ///
  /// [themeMode] 新的应用主题模式
  void _handleThemeModeChanged(ThemeMode themeMode) {
    if (!mounted || _themeMode == themeMode) {
      return;
    }

    setState(() {
      _themeMode = themeMode;
    });
  }

  /// 处理输入框外部点击意图
  ///
  /// [intent] 输入框外部点击意图
  Object? _unfocusEditableText(EditableTextTapOutsideIntent intent) {
    intent.focusNode.unfocus();
    return null;
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
