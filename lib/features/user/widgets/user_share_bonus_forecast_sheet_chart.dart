part of 'user_share_bonus_forecast_sheet.dart';

/// 股息预测图表
class _ShareBonusForecastChart extends StatelessWidget {
  /// 创建股息预测图表
  ///
  /// [forecast] 股息预测数据
  /// [showFullNumbers] 是否显示完整数字
  const _ShareBonusForecastChart({
    required this.forecast,
    required this.showFullNumbers,
  });

  /// 股息预测数据
  final UserShareBonusForecast forecast;

  /// 是否显示完整数字
  final bool showFullNumbers;

  /// 构建股息预测图表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const taxColor = Color(0xFF3BB4F2);
    final afterTaxColor = colorScheme.primary;
    final afterTax = math.max(0, forecast.afterTax);
    final tax = math.max(0, forecast.tax);
    final total = afterTax + tax;
    final afterTaxRate = total <= 0 ? 0.0 : afterTax / total;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(
          alpha: colorScheme.brightness == Brightness.dark ? 0.48 : 0.72,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.42),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 124,
              height: 124,
              child: CustomPaint(
                painter: _ShareBonusDonutPainter(
                  afterTaxRate: afterTaxRate,
                  afterTaxColor: afterTaxColor,
                  taxColor: taxColor,
                  emptyColor: colorScheme.outlineVariant.withValues(
                    alpha: 0.42,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        total <= 0 ? '暂无' : '${(afterTaxRate * 100).round()}%',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '税后',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ShareBonusChartLegendItem(
                    color: afterTaxColor,
                    label: '税后收入',
                    value: _formatShareBonusCurrency(
                      forecast.afterTax,
                      showFullNumbers: showFullNumbers,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ShareBonusChartLegendItem(
                    color: taxColor,
                    label: '个人所得税',
                    value: _formatShareBonusCurrency(
                      forecast.tax,
                      showFullNumbers: showFullNumbers,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 股息预测图例条目
class _ShareBonusChartLegendItem extends StatelessWidget {
  /// 创建股息预测图例条目
  ///
  /// [color] 图例颜色
  /// [label] 图例标题
  /// [value] 图例数值
  const _ShareBonusChartLegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  /// 图例颜色
  final Color color;

  /// 图例标题
  final String label;

  /// 图例数值
  final String value;

  /// 构建股息预测图例条目
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 股息预测环形图绘制器
class _ShareBonusDonutPainter extends CustomPainter {
  /// 创建股息预测环形图绘制器
  ///
  /// [afterTaxRate] 税后收入占比
  /// [afterTaxColor] 税后收入颜色
  /// [taxColor] 个人所得税颜色
  /// [emptyColor] 空数据颜色
  const _ShareBonusDonutPainter({
    required this.afterTaxRate,
    required this.afterTaxColor,
    required this.taxColor,
    required this.emptyColor,
  });

  /// 税后收入占比
  final double afterTaxRate;

  /// 税后收入颜色
  final Color afterTaxColor;

  /// 个人所得税颜色
  final Color taxColor;

  /// 空数据颜色
  final Color emptyColor;

  /// 绘制股息预测环形图
  ///
  /// [canvas] 绘制画布
  /// [size] 绘制尺寸
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = math.min(size.width, size.height) * 0.16;
    final rect = Offset.zero & size;
    final radiusRect = rect.deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final startAngle = -math.pi / 2;
    final clampedRate = afterTaxRate.clamp(0.0, 1.0);
    if (clampedRate <= 0) {
      canvas.drawArc(
        radiusRect,
        0,
        math.pi * 2,
        false,
        paint..color = emptyColor,
      );
      return;
    }

    final afterTaxSweep = math.pi * 2 * clampedRate;
    canvas.drawArc(
      radiusRect,
      startAngle,
      afterTaxSweep,
      false,
      paint..color = afterTaxColor,
    );

    if (clampedRate < 1) {
      canvas.drawArc(
        radiusRect,
        startAngle + afterTaxSweep,
        math.pi * 2 - afterTaxSweep,
        false,
        paint..color = taxColor,
      );
    }
  }

  /// 判断环形图是否需要重绘
  ///
  /// [oldDelegate] 上一次绘制器
  @override
  bool shouldRepaint(covariant _ShareBonusDonutPainter oldDelegate) {
    return oldDelegate.afterTaxRate != afterTaxRate ||
        oldDelegate.afterTaxColor != afterTaxColor ||
        oldDelegate.taxColor != taxColor ||
        oldDelegate.emptyColor != emptyColor;
  }
}
