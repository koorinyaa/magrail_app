part of 'character_quick_entry_bar.dart';

/// 角色入口背景绘制器
class _PortalBackdropPainter extends CustomPainter {
  /// 创建角色入口背景绘制器
  ///
  /// [lineColor] 网格线颜色
  const _PortalBackdropPainter({
    required this.lineColor,
  });

  final Color lineColor;

  /// 绘制入口背景网格
  ///
  /// [canvas] 当前画布
  /// [size] 当前绘制尺寸
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.24)
      ..strokeWidth = 0.7;
    for (var x = 4.0; x < size.width; x += 24) {
      for (var y = 4.0; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 0.7, gridPaint);
      }
    }
  }

  /// 判断入口背景是否需要重绘
  ///
  /// [oldDelegate] 上一次入口背景绘制器
  @override
  bool shouldRepaint(covariant _PortalBackdropPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}

/// 角色入口卡片背景绘制器
class _PortalCardPainter extends CustomPainter {
  /// 创建角色入口卡片背景绘制器
  ///
  /// [accent] 入口强调色
  /// [prominent] 是否为主入口
  const _PortalCardPainter({
    required this.accent,
    required this.prominent,
  });

  final Color accent;
  final bool prominent;

  /// 绘制入口卡片光晕
  ///
  /// [canvas] 当前画布
  /// [size] 当前绘制尺寸
  @override
  void paint(Canvas canvas, Size size) {
    final glowCenter = Offset(size.width * 0.82, size.height * 0.22);
    final glowRadius = prominent ? size.longestSide * 0.72 : size.width * 0.78;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: prominent ? 0.22 : 0.18),
          accent.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(center: glowCenter, radius: glowRadius),
      );
    canvas.drawCircle(glowCenter, glowRadius, glowPaint);
  }

  /// 判断入口卡片背景是否需要重绘
  ///
  /// [oldDelegate] 上一次入口卡片背景绘制器
  @override
  bool shouldRepaint(covariant _PortalCardPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.prominent != prominent;
  }
}
