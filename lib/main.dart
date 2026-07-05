import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:magrail_app/core/error/app_error_report.dart';
import 'package:magrail_app/core/error/app_fatal_error_view.dart';

import 'app/bootstrap.dart';
import 'app/magrail_app.dart';

/// 平板布局的最短边阈值
const _tabletShortestSideBreakpoint = 600.0;

// 防止错误页自身异常重复替换根组件
var _showingFatalErrorView = false;

/// 应用入口
Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    _startApp,
    _handleZoneError,
  );
}

/// 启动应用
Future<void> _startApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configureErrorHandling();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await _configurePreferredOrientations();
  // 预热液态玻璃着色器，避免底部导航首次渲染白屏
  await LiquidGlassWidgets.initialize();
  final dependencies = await bootstrap();

  runApp(
    LiquidGlassWidgets.wrap(
      adaptiveQuality: true,
      child: MagrailApp(dependencies: dependencies),
    ),
  );
}

/// 配置全局错误处理
void _configureErrorHandling() {
  FlutterError.onError = FlutterError.presentError;
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    FlutterError.presentError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'magrail app',
        context: ErrorDescription('unhandled platform error'),
      ),
    );
    _showFatalErrorView(
      error: error,
      stackTrace: stackTrace,
      source: 'unhandled platform error',
    );
    return kReleaseMode;
  };

  ErrorWidget.builder = (details) {
    if (!kReleaseMode) {
      return ErrorWidget.withDetails(
        message: details.exceptionAsString(),
      );
    }

    return AppFatalErrorView(
      report: AppErrorReport.fromFlutterDetails(details),
    );
  };
}

/// 显示不可恢复错误页面
///
/// [error] 未捕获错误
/// [stackTrace] 未捕获堆栈
/// [source] 错误来源
void _showFatalErrorView({
  required Object error,
  required StackTrace? stackTrace,
  required String source,
}) {
  if (!kReleaseMode || _showingFatalErrorView) {
    return;
  }

  _showingFatalErrorView = true;
  runApp(
    AppFatalErrorView(
      report: AppErrorReport.fromUnhandledError(
        error: error,
        stackTrace: stackTrace,
        source: source,
      ),
    ),
  );
}

/// 处理 Zone 未捕获错误
///
/// [error] 未捕获错误
/// [stackTrace] 未捕获堆栈
void _handleZoneError(Object error, StackTrace stackTrace) {
  FlutterError.presentError(
    FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'magrail app',
      context: ErrorDescription('unhandled zone error'),
    ),
  );
  _showFatalErrorView(
    error: error,
    stackTrace: stackTrace,
    source: 'unhandled zone error',
  );
}

/// 配置手机和平板的屏幕方向
Future<void> _configurePreferredOrientations() {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final logicalSize = view.physicalSize / view.devicePixelRatio;
  final isTablet = logicalSize.shortestSide >= _tabletShortestSideBreakpoint;

  if (isTablet) {
    return SystemChrome.setPreferredOrientations(const []);
  }

  return SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
