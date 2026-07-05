import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 应用柔色背景
class AppSoftBackground extends StatelessWidget {
  /// 创建应用柔色背景
  ///
  /// [key] Flutter 组件标识
  /// [isDark] 是否使用深色模式
  const AppSoftBackground({
    super.key,
    required this.isDark,
  });

  /// 是否使用深色模式
  final bool isDark;

  /// 构建应用柔色背景
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (isDark) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: CustomPaint(
        painter: _SoftColorBlobPainter(isDark: isDark),
      ),
    );
  }
}

/// 应用柔色色块绘制器
class _SoftColorBlobPainter extends CustomPainter {
  /// 创建应用柔色色块绘制器
  ///
  /// [isDark] 是否使用深色模式
  const _SoftColorBlobPainter({
    required this.isDark,
  });

  final bool isDark;

  /// 绘制应用柔色色块
  ///
  /// [canvas] 绘制画布
  /// [size] 绘制区域尺寸
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 390;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 52);

    _paintBlob(
      canvas,
      paint,
      color: const Color(0x33F09199),
      offset: const Offset(-92, 70),
      width: 350,
      height: 260,
    );
    _paintBlob(
      canvas,
      paint,
      color: const Color(0x308EC5FF),
      offset: const Offset(174, 296),
      width: 300,
      height: 245,
    );
    _paintBlob(
      canvas,
      paint,
      color: const Color(0x2CA8D98B),
      offset: const Offset(-108, 668),
      width: 300,
      height: 235,
    );
    _paintBlob(
      canvas,
      paint,
      color: const Color(0x2AF6C76B),
      offset: const Offset(182, 910),
      width: 315,
      height: 235,
    );
    canvas.restore();
  }

  /// 绘制单个柔色色块
  ///
  /// [canvas] 绘制画布
  /// [paint] 画笔
  /// [color] 色块颜色
  /// [offset] 色块左上偏移
  /// [width] 色块宽度
  /// [height] 色块高度
  void _paintBlob(
    Canvas canvas,
    Paint paint, {
    required Color color,
    required Offset offset,
    required double width,
    required double height,
  }) {
    paint.color = color;
    final path = Path()
      ..moveTo(offset.dx + width * 0.12, offset.dy + height * 0.18)
      ..cubicTo(
        offset.dx + width * 0.34,
        offset.dy - height * 0.10,
        offset.dx + width * 0.78,
        offset.dy + height * 0.02,
        offset.dx + width * 0.94,
        offset.dy + height * 0.32,
      )
      ..cubicTo(
        offset.dx + width * 1.12,
        offset.dy + height * 0.68,
        offset.dx + width * 0.72,
        offset.dy + height * 1.05,
        offset.dx + width * 0.38,
        offset.dy + height * 0.94,
      )
      ..cubicTo(
        offset.dx + width * 0.02,
        offset.dy + height * 0.84,
        offset.dx - width * 0.08,
        offset.dy + height * 0.42,
        offset.dx + width * 0.12,
        offset.dy + height * 0.18,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  /// 判断柔色背景是否需要重绘
  ///
  /// [oldDelegate] 上一次绘制器
  @override
  bool shouldRepaint(covariant _SoftColorBlobPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
