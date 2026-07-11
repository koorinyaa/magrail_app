import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/error/app_error_report.dart';

/// 不可恢复错误页面
class AppFatalErrorView extends StatefulWidget {
  /// 创建不可恢复错误页面
  ///
  /// [key] Flutter 组件标识
  /// [report] 可复制的错误报告
  const AppFatalErrorView({
    super.key,
    required this.report,
  });

  /// 可复制的错误报告
  final AppErrorReport report;

  /// 创建页面状态
  @override
  State<AppFatalErrorView> createState() => _AppFatalErrorViewState();
}

/// 不可恢复错误页面状态
class _AppFatalErrorViewState extends State<AppFatalErrorView> {
  var _copied = false;
  var _copyFailed = false;

  /// 构建不可恢复错误页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: colorScheme.surface,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    LucideIcons.triangleAlert,
                    size: 42,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'App 运行异常，请重启后再试',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '请尝试关闭 App 后重新打开，并将错误信息反馈给开发者',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _copyReport,
                    icon: Icon(_copyFailed ? LucideIcons.x : LucideIcons.copy),
                    label: Text(_copyButtonText),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.report.summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 当前复制按钮文本
  String get _copyButtonText {
    if (_copyFailed) {
      return '复制失败';
    }
    if (_copied) {
      return '已复制错误信息';
    }
    return '复制错误信息';
  }

  /// 复制错误报告
  Future<void> _copyReport() async {
    try {
      final reportText = await widget.report.toClipboardText();
      await Clipboard.setData(
        ClipboardData(text: reportText),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _copied = true;
        _copyFailed = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _copyFailed = true;
        _copied = false;
      });
    }
  }
}
