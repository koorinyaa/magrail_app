import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';

/// 应用轻提示类型
enum AppToastVariant {
  /// 普通信息提示
  info,

  /// 错误提示
  error,
}

/// 应用轻提示入口
class AppToast {
  /// 禁止创建应用轻提示入口
  const AppToast._();

  static OverlayEntry? _activeEntry;
  static GlobalKey<_AppToastOverlayState>? _activeOverlayKey;

  /// 展示应用轻提示
  ///
  /// [context] 当前组件树上下文
  /// [text] 提示正文
  /// [variant] 提示类型
  /// [duration] 停留时间
  static void show(
    BuildContext context, {
    required String text,
    AppToastVariant variant = AppToastVariant.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final effectiveText = text.trim();
    final overlayState = _resolveOverlayState(context);
    if (overlayState == null) {
      return;
    }

    _dismissActiveToast(immediate: true);

    final overlayKey = GlobalKey<_AppToastOverlayState>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _AppToastOverlay(
          key: overlayKey,
          text: effectiveText,
          variant: variant,
          duration: duration,
          onDismissed: () {
            // 新提示可能已提前移除当前 Entry，避免退出动画完成后重复 remove
            if (_activeEntry != entry) {
              return;
            }

            _activeEntry = null;
            _activeOverlayKey = null;
            entry.remove();
          },
        );
      },
    );
    _activeEntry = entry;
    _activeOverlayKey = overlayKey;
    overlayState.insert(entry);
  }

  /// 解析轻提示挂载的浮层
  ///
  /// [context] 当前组件树上下文
  static OverlayState? _resolveOverlayState(BuildContext context) {
    return Overlay.maybeOf(context, rootOverlay: true) ??
        Navigator.maybeOf(context, rootNavigator: true)?.overlay;
  }

  /// 关闭当前活动轻提示
  ///
  /// [immediate] 是否跳过退出动画
  static void _dismissActiveToast({required bool immediate}) {
    final activeEntry = _activeEntry;
    if (activeEntry == null) {
      return;
    }

    if (immediate) {
      activeEntry.remove();
      _activeEntry = null;
      _activeOverlayKey = null;
      return;
    }

    final activeState = _activeOverlayKey?.currentState;
    if (activeState == null) {
      activeEntry.remove();
      _activeEntry = null;
      _activeOverlayKey = null;
      return;
    }

    activeState.dismiss();
  }

  /// 展示普通信息提示
  ///
  /// [context] 当前组件树上下文
  /// [text] 提示正文
  static void info(
    BuildContext context, {
    required String text,
  }) {
    show(context, text: text);
  }

  /// 展示错误提示
  ///
  /// [context] 当前组件树上下文
  /// [text] 提示正文
  static void error(
    BuildContext context, {
    required String text,
  }) {
    show(
      context,
      text: text,
      variant: AppToastVariant.error,
    );
  }
}

/// 底部胶囊轻提示浮层
class _AppToastOverlay extends StatefulWidget {
  /// 创建底部胶囊轻提示浮层
  ///
  /// [key] Flutter 组件标识
  /// [text] 提示正文
  /// [variant] 提示类型
  /// [duration] 停留时间
  /// [onDismissed] 浮层移除回调
  const _AppToastOverlay({
    super.key,
    required this.text,
    required this.variant,
    required this.duration,
    required this.onDismissed,
  });

  final String text;
  final AppToastVariant variant;
  final Duration duration;
  final VoidCallback onDismissed;

  /// 创建底部胶囊轻提示浮层状态
  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

/// 底部胶囊轻提示浮层状态
class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  // 与 MainMobileNavigationDock 的高度和底部间距计算保持一致
  static const double _dockBottomPadding = 10;
  static const double _dockGap = 24;
  static const double _keyboardGap = 84;
  static const double _compactDockHeight = 60;
  static const double _regularDockHeight = 64;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _autoCloseTimer;
  bool _isClosing = false;

  /// 初始化底部胶囊轻提示浮层状态
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutCubic,
      ),
    );
    _controller.forward();
    _autoCloseTimer = Timer(widget.duration, dismiss);
  }

  /// 释放底部胶囊轻提示浮层状态
  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// 关闭底部胶囊轻提示浮层
  Future<void> dismiss() async {
    if (_isClosing) {
      return;
    }

    _isClosing = true;
    _autoCloseTimer?.cancel();
    await _controller.reverse();
    if (!mounted) {
      return;
    }

    widget.onDismissed();
  }

  /// 构建底部胶囊轻提示浮层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final bottomPadding = _resolveBottomPadding(context);

    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.bottomCenter,
              child: _AppToastPill(
                text: widget.text,
                variant: widget.variant,
                onTap: dismiss,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 计算轻提示底部避让距离
  ///
  /// [context] 当前组件树上下文
  double _resolveBottomPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final dockHeight =
        screenWidth < 360 ? _compactDockHeight : _regularDockHeight;

    // 底部 dock 使用 SafeArea 和 10dp 底部间距，这里叠加系统安全区后再留出提示间距
    final dockPadding =
        mediaQuery.padding.bottom + dockHeight + _dockBottomPadding + _dockGap;
    final keyboardPadding = mediaQuery.viewInsets.bottom > 0
        ? mediaQuery.viewInsets.bottom + _keyboardGap
        : 0.0;

    return keyboardPadding > dockPadding ? keyboardPadding : dockPadding;
  }
}

/// 底部胶囊轻提示
class _AppToastPill extends StatelessWidget {
  /// 创建底部胶囊轻提示
  ///
  /// [text] 提示正文
  /// [variant] 提示类型
  /// [onTap] 点击轻提示时执行的回调
  const _AppToastPill({
    required this.text,
    required this.variant,
    required this.onTap,
  });

  final String text;
  final AppToastVariant variant;
  final VoidCallback onTap;

  static const double _height = 40;
  static const double _horizontalPadding = 14;
  static const double _minWidth = 88;

  /// 构建底部胶囊轻提示
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final toastMaxWidth = (screenWidth - 64).clamp(200.0, 360.0).toDouble();
    final textColor = _resolveTextColor(context, variant);
    final textStyle = theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.22,
        ) ??
        TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.22,
        );
    final toastWidth = _resolveToastWidth(
      context,
      textStyle: textStyle,
      maxWidth: toastMaxWidth,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: toastWidth,
        height: _height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: AppBlurStyle.filter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _resolveSurfaceColor(context),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 计算轻提示宽度
  ///
  /// [context] 当前组件树上下文
  /// [textStyle] 提示正文样式
  /// [maxWidth] 轻提示最大宽度
  double _resolveToastWidth(
    BuildContext context, {
    required TextStyle textStyle,
    required double maxWidth,
  }) {
    final textMaxWidth = maxWidth - _horizontalPadding * 2;
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: textMaxWidth);

    return (textPainter.width + _horizontalPadding * 2)
        .clamp(_minWidth, maxWidth)
        .toDouble();
  }

  /// 解析轻提示背景色
  ///
  /// [context] 当前组件树上下文
  Color _resolveSurfaceColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return (isDark ? const Color(0xFF2A2A2D) : const Color(0xFFECECEF))
        .withValues(
      alpha: isDark ? 0.92 : 0.96,
    );
  }

  /// 解析轻提示正文颜色
  ///
  /// [context] 当前组件树上下文
  /// [variant] 提示类型
  Color _resolveTextColor(BuildContext context, AppToastVariant variant) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return switch (variant) {
      AppToastVariant.info =>
        isDark ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
      AppToastVariant.error =>
        isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
    };
  }
}
