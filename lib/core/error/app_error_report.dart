import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';

/// 应用错误报告
class AppErrorReport {
  /// 创建应用错误报告
  ///
  /// [error] 捕获到的错误对象
  /// [stackTrace] 捕获到的堆栈
  /// [source] 错误来源
  /// [time] 捕获时间
  const AppErrorReport({
    required this.error,
    required this.stackTrace,
    required this.source,
    required this.time,
  });

  /// 根据 Flutter 错误详情创建报告
  ///
  /// [details] Flutter 错误详情
  factory AppErrorReport.fromFlutterDetails(FlutterErrorDetails details) {
    return AppErrorReport(
      error: details.exception,
      stackTrace: details.stack,
      source: details.context?.toDescription() ?? 'Flutter',
      time: DateTime.now(),
    );
  }

  /// 根据未捕获错误创建报告
  ///
  /// [error] 捕获到的错误对象
  /// [stackTrace] 捕获到的堆栈
  /// [source] 错误来源
  factory AppErrorReport.fromUnhandledError({
    required Object error,
    required StackTrace? stackTrace,
    required String source,
  }) {
    return AppErrorReport(
      error: error,
      stackTrace: stackTrace,
      source: source,
      time: DateTime.now(),
    );
  }

  /// 捕获到的错误对象
  final Object error;

  /// 捕获到的堆栈
  final StackTrace? stackTrace;

  /// 错误来源
  final String source;

  /// 捕获时间
  final DateTime time;

  /// 用户可见的错误摘要
  String get summary => resolveUserErrorMessage(error, fallback: '应用运行异常');

  /// 构建可复制的反馈文本
  String toClipboardText() {
    return [
      'MaGrail 错误反馈',
      '时间: ${time.toIso8601String()}',
      '模式: ${kReleaseMode ? 'release' : 'debug'}',
      '平台: ${defaultTargetPlatform.name}',
      '来源: $source',
      '错误: $error',
      if (stackTrace != null) '堆栈:\n$stackTrace',
    ].join('\n');
  }
}
