import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';

/// 显示应用通用加载弹窗
///
/// [context] 当前组件树上下文
/// [message] 加载提示文案
/// [messageListenable] 动态加载提示文案
Future<void> showAppLoadingDialog(
  BuildContext context, {
  required String message,
  ValueListenable<String>? messageListenable,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AppLoadingDialog(
        message: message,
        messageListenable: messageListenable,
      );
    },
  );
}

/// 应用通用加载弹窗
class AppLoadingDialog extends StatelessWidget {
  /// 创建应用通用加载弹窗
  ///
  /// [key] Flutter 组件标识
  /// [message] 加载提示文案
  /// [messageListenable] 动态加载提示文案
  const AppLoadingDialog({
    super.key,
    required this.message,
    this.messageListenable,
  });

  /// 加载提示文案
  final String message;

  /// 动态加载提示文案
  final ValueListenable<String>? messageListenable;

  /// 构建应用通用加载弹窗
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final messageStyle = TextStyle(
      color: colorScheme.onSurface,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );

    return PopScope(
      canPop: false,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: AppBlurStyle.filter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppBlurStyle.surfaceColor(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(
                      alpha: isDark ? 0.18 : 0.28,
                    ),
                    width: 0.6,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: messageListenable != null
                            ? ValueListenableBuilder<String>(
                                valueListenable: messageListenable!,
                                builder: (context, value, _) {
                                  final resolvedValue = value.trim();
                                  return Text(
                                    resolvedValue.isEmpty
                                        ? message
                                        : resolvedValue,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: messageStyle,
                                  );
                                },
                              )
                            : Text(
                                message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: messageStyle,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
