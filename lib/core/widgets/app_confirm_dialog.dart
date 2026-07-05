import 'package:flutter/material.dart';

/// 显示应用通用确认面板
///
/// [context] 当前组件树上下文
/// [title] 面板标题
/// [message] 面板说明，传入空文本时不显示
/// [content] 面板自定义内容
/// [contentPadding] 面板自定义内容内边距
/// [middleButtonText] 确认按钮和取消按钮之间的按钮文案
/// [cancelText] 取消按钮文案
/// [confirmText] 确认按钮文案
/// [showCancelButton] 是否显示取消按钮
/// [icon] 标题图标
/// [iconWidget] 标题自定义图标
/// [confirmColor] 确认按钮背景色
/// [onConfirm] 确认前执行的异步回调
/// [onMiddleButtonPressed] 中间按钮点击前执行的异步回调
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  Widget? content,
  EdgeInsetsGeometry? contentPadding,
  String? middleButtonText,
  String cancelText = '取消',
  String confirmText = '确认',
  bool showCancelButton = true,
  IconData? icon,
  Widget? iconWidget,
  Color? confirmColor,
  Future<bool> Function()? onConfirm,
  Future<bool> Function()? onMiddleButtonPressed,
}) async {
  final colorScheme = Theme.of(context).colorScheme;
  final isDark = colorScheme.brightness == Brightness.dark;
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: isDark ? 0.62 : 0.48),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      final viewInsets = MediaQuery.viewInsetsOf(context);
      return Material(
        type: MaterialType.transparency,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AppConfirmDialog(
                title: title,
                message: message,
                content: content,
                contentPadding: contentPadding,
                middleButtonText: middleButtonText,
                cancelText: cancelText,
                confirmText: confirmText,
                showCancelButton: showCancelButton,
                icon: icon,
                iconWidget: iconWidget,
                confirmColor: confirmColor,
                onConfirm: onConfirm,
                onMiddleButtonPressed: onMiddleButtonPressed,
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = animation.drive(
        CurveTween(curve: Curves.easeOutCubic),
      );
      final slideAnimation = animation.drive(
        Tween<Offset>(
          begin: const Offset(0, 0.16),
          end: Offset.zero,
        ).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
      );
      final scaleAnimation = animation.drive(
        Tween<double>(begin: 0.98, end: 1).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
      );

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        ),
      );
    },
  );

  return result ?? false;
}

/// 应用通用确认面板
class AppConfirmDialog extends StatelessWidget {
  /// 创建应用通用确认面板
  ///
  /// [key] Flutter 组件标识
  /// [title] 面板标题
  /// [message] 面板说明，传入空文本时不显示
  /// [content] 面板自定义内容
  /// [contentPadding] 面板自定义内容内边距
  /// [middleButtonText] 确认按钮和取消按钮之间的按钮文案
  /// [cancelText] 取消按钮文案
  /// [confirmText] 确认按钮文案
  /// [showCancelButton] 是否显示取消按钮
  /// [icon] 标题图标
  /// [iconWidget] 标题自定义图标
  /// [confirmColor] 确认按钮背景色
  /// [onConfirm] 确认前执行的异步回调
  /// [onMiddleButtonPressed] 中间按钮点击前执行的异步回调
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.content,
    this.contentPadding,
    this.middleButtonText,
    this.cancelText = '取消',
    this.confirmText = '确认',
    this.showCancelButton = true,
    this.icon,
    this.iconWidget,
    this.confirmColor,
    this.onConfirm,
    this.onMiddleButtonPressed,
  });

  /// 面板标题
  final String title;

  /// 面板说明，空文本不显示
  final String message;

  /// 面板自定义内容
  final Widget? content;

  /// 面板自定义内容内边距
  final EdgeInsetsGeometry? contentPadding;

  /// 确认按钮和取消按钮之间的按钮文案
  final String? middleButtonText;

  /// 取消按钮文案
  final String cancelText;

  /// 确认按钮文案
  final String confirmText;

  /// 是否显示取消按钮
  final bool showCancelButton;

  /// 标题图标
  final IconData? icon;

  /// 标题自定义图标
  final Widget? iconWidget;

  /// 确认按钮背景色
  final Color? confirmColor;

  /// 确认前执行的异步回调
  final Future<bool> Function()? onConfirm;

  /// 中间按钮点击前执行的异步回调
  final Future<bool> Function()? onMiddleButtonPressed;

  /// 构建应用通用确认面板
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final hasMessage = message.trim().isNotEmpty;
    final hasHeader =
        title.trim().isNotEmpty || icon != null || iconWidget != null;
    final panelRadius = BorderRadius.circular(24);
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerLowest;
    final borderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.32 : 0.54,
    );
    const defaultContentPadding = EdgeInsets.fromLTRB(24, 24, 24, 24);
    final actionButtons = _AppConfirmDialogActionButtons(
      cancelText: cancelText,
      confirmText: confirmText,
      showCancelButton: showCancelButton,
      confirmColor: confirmColor,
      middleButtonText: middleButtonText,
      onConfirm: onConfirm,
      onMiddleButtonPressed: onMiddleButtonPressed,
    );
    final customContentPadding = contentPadding;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: panelRadius,
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.42 : 0.18),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: panelRadius,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: customContentPadding == null
                  ? Padding(
                      padding: defaultContentPadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (hasHeader)
                            _AppConfirmDialogHeader(
                              title: title,
                              icon: icon,
                              iconWidget: iconWidget,
                            ),
                          if (hasMessage) ...[
                            if (hasHeader) const SizedBox(height: 14),
                            Text(
                              message,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.45,
                              ),
                            ),
                          ],
                          if (content != null) ...[
                            if (hasHeader || hasMessage)
                              const SizedBox(height: 16),
                            content!,
                          ],
                          const SizedBox(height: 20),
                          actionButtons,
                        ],
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (hasHeader || hasMessage)
                          Padding(
                            padding: defaultContentPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (hasHeader)
                                  _AppConfirmDialogHeader(
                                    title: title,
                                    icon: icon,
                                    iconWidget: iconWidget,
                                  ),
                                if (hasMessage) ...[
                                  if (hasHeader) const SizedBox(height: 14),
                                  Text(
                                    message,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        if (content != null)
                          Padding(
                            padding: customContentPadding,
                            child: content!,
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                          child: actionButtons,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 应用确认面板标题区
class _AppConfirmDialogHeader extends StatelessWidget {
  /// 创建应用确认面板标题区
  ///
  /// [title] 面板标题
  /// [icon] 标题图标
  /// [iconWidget] 标题自定义图标
  const _AppConfirmDialogHeader({
    required this.title,
    required this.icon,
    required this.iconWidget,
  });

  /// 面板标题
  final String title;

  /// 标题图标
  final IconData? icon;

  /// 标题自定义图标
  final Widget? iconWidget;

  /// 构建应用确认面板标题区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = this.icon;
    final iconWidget = this.iconWidget;
    final hasTitle = title.trim().isNotEmpty;
    final hasIcon = iconWidget != null || icon != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (iconWidget != null)
          iconWidget
        else if (icon != null)
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                size: 20,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        if (hasIcon && hasTitle) const SizedBox(height: 18),
        if (hasTitle)
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.18,
            ),
          ),
      ],
    );
  }
}

/// 应用确认面板操作按钮区
class _AppConfirmDialogActionButtons extends StatefulWidget {
  /// 创建应用确认面板操作按钮区
  ///
  /// [cancelText] 取消按钮文案
  /// [confirmText] 确认按钮文案
  /// [showCancelButton] 是否显示取消按钮
  /// [confirmColor] 确认按钮背景色
  /// [middleButtonText] 确认按钮和取消按钮之间的按钮文案
  /// [onConfirm] 确认前执行的异步回调
  /// [onMiddleButtonPressed] 中间按钮点击前执行的异步回调
  const _AppConfirmDialogActionButtons({
    required this.cancelText,
    required this.confirmText,
    required this.showCancelButton,
    required this.confirmColor,
    required this.middleButtonText,
    required this.onConfirm,
    required this.onMiddleButtonPressed,
  });

  /// 取消按钮文案
  final String cancelText;

  /// 确认按钮文案
  final String confirmText;

  /// 是否显示取消按钮
  final bool showCancelButton;

  /// 确认按钮背景色
  final Color? confirmColor;

  /// 确认按钮和取消按钮之间的按钮文案
  final String? middleButtonText;

  /// 确认前执行的异步回调
  final Future<bool> Function()? onConfirm;

  /// 中间按钮点击前执行的异步回调
  final Future<bool> Function()? onMiddleButtonPressed;

  /// 创建应用确认面板操作按钮区状态
  @override
  State<_AppConfirmDialogActionButtons> createState() =>
      _AppConfirmDialogActionButtonsState();
}

/// 应用确认面板操作按钮区状态
class _AppConfirmDialogActionButtonsState
    extends State<_AppConfirmDialogActionButtons> {
  var _isConfirming = false;

  /// 构建应用确认面板操作按钮区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final resolvedConfirmColor = widget.confirmColor ?? colorScheme.primary;
    final confirmForegroundColor = widget.confirmColor == null
        ? colorScheme.onPrimary
        : _resolveForegroundColor(resolvedConfirmColor);
    final cancelBackgroundColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.12 : 0.07,
    );
    final cancelButtonStyle = TextButton.styleFrom(
      foregroundColor: colorScheme.onSurface,
      backgroundColor: cancelBackgroundColor,
      minimumSize: const Size.fromHeight(40),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
    final middleButtonText = widget.middleButtonText?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          style: FilledButton.styleFrom(
            foregroundColor: confirmForegroundColor,
            backgroundColor: resolvedConfirmColor,
            minimumSize: const Size.fromHeight(40),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          onPressed: _isConfirming ? null : () => _handleConfirm(context),
          child: Text(widget.confirmText),
        ),
        if (middleButtonText != null && middleButtonText.isNotEmpty) ...[
          const SizedBox(height: 6),
          TextButton(
            style: cancelButtonStyle,
            onPressed: _isConfirming
                ? null
                : () => _handleMiddleButtonPressed(context),
            child: Text(middleButtonText),
          ),
        ],
        if (widget.showCancelButton) ...[
          const SizedBox(height: 6),
          TextButton(
            style: cancelButtonStyle,
            onPressed:
                _isConfirming ? null : () => Navigator.of(context).pop(false),
            child: Text(widget.cancelText),
          ),
        ],
      ],
    );
  }

  /// 处理确认按钮点击
  ///
  /// [context] 当前组件树上下文
  Future<void> _handleConfirm(BuildContext context) async {
    final onConfirm = widget.onConfirm;
    if (onConfirm == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isConfirming = true;
    });
    final shouldClose = await onConfirm();
    if (!mounted) {
      return;
    }

    setState(() {
      _isConfirming = false;
    });
    if (shouldClose && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  /// 处理中间按钮点击
  ///
  /// [context] 当前组件树上下文
  Future<void> _handleMiddleButtonPressed(BuildContext context) async {
    final onMiddleButtonPressed = widget.onMiddleButtonPressed;
    if (onMiddleButtonPressed == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isConfirming = true;
    });
    final shouldClose = await onMiddleButtonPressed();
    if (!mounted) {
      return;
    }

    setState(() {
      _isConfirming = false;
    });
    if (shouldClose && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  /// 解析按钮前景色
  ///
  /// [backgroundColor] 按钮背景色
  Color _resolveForegroundColor(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}
