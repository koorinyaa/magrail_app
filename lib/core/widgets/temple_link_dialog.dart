import 'package:flutter/material.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';

/// 圣殿 LINK 弹窗卡片构建器
///
/// [width] 弹窗内可用的卡片宽度
typedef TempleLinkDialogCardBuilder = Widget Function(double width);

/// 显示圣殿 LINK 弹窗
///
/// [context] 当前组件树上下文
/// [cardBuilder] 根据可用宽度构建 LINK 卡片
/// [maxWidth] LINK 卡片最大宽度
Future<void> showTempleLinkDialog(
  BuildContext context, {
  required TempleLinkDialogCardBuilder cardBuilder,
  double maxWidth = 288,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final isDark = colorScheme.brightness == Brightness.dark;
  final screenWidth = MediaQuery.sizeOf(context).width;
  final cardWidth = (screenWidth - 32).clamp(0.0, maxWidth).toDouble();

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: isDark ? 0.38 : 0.22),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondaryAnimation) {
      return BackdropFilter(
        filter: AppBlurStyle.filter,
        child: Material(
          type: MaterialType.transparency,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () {},
                    child: cardBuilder(cardWidth),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = animation.drive(
        CurveTween(curve: Curves.easeOutCubic),
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          scale: animation.drive(
            Tween<double>(begin: 0.98, end: 1).chain(
              CurveTween(curve: Curves.easeOutCubic),
            ),
          ),
          child: child,
        ),
      );
    },
  );
}
