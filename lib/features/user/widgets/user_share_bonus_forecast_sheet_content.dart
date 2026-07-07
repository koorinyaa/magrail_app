part of 'user_share_bonus_forecast_sheet.dart';

/// 股息预测标题区
class _ShareBonusForecastHeader extends StatelessWidget {
  /// 创建股息预测标题区
  ///
  /// [displayName] 目标用户展示名称
  const _ShareBonusForecastHeader({
    required this.displayName,
  });

  /// 目标用户展示名称
  final String displayName;

  /// 构建股息预测标题区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '股息预测',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          displayName,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

/// 股息预测内容
class _ShareBonusForecastContent extends StatefulWidget {
  /// 创建股息预测内容
  ///
  /// [forecast] 股息预测数据
  const _ShareBonusForecastContent({
    required this.forecast,
  });

  /// 股息预测数据
  final UserShareBonusForecast forecast;

  /// 创建股息预测内容状态
  @override
  State<_ShareBonusForecastContent> createState() =>
      _ShareBonusForecastContentState();
}

/// 股息预测内容状态
class _ShareBonusForecastContentState
    extends State<_ShareBonusForecastContent> {
  bool _showFullNumbers = false;

  /// 构建股息预测内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ShareBonusForecastSummary(
          forecast: widget.forecast,
          showFullNumbers: _showFullNumbers,
          onToggleNumbers: _toggleNumberDisplayMode,
        ),
        const SizedBox(height: 12),
        _ShareBonusForecastChart(
          forecast: widget.forecast,
          showFullNumbers: _showFullNumbers,
        ),
        const SizedBox(height: 12),
        _ShareBonusForecastStats(
          forecast: widget.forecast,
          showFullNumbers: _showFullNumbers,
        ),
      ],
    );
  }

  /// 切换股息预测数字显示模式
  void _toggleNumberDisplayMode() {
    setState(() {
      _showFullNumbers = !_showFullNumbers;
    });
  }
}

/// 股息预测摘要
class _ShareBonusForecastSummary extends StatelessWidget {
  /// 创建股息预测摘要
  ///
  /// [forecast] 股息预测数据
  /// [showFullNumbers] 是否显示完整数字
  /// [onToggleNumbers] 数字显示模式切换回调
  const _ShareBonusForecastSummary({
    required this.forecast,
    required this.showFullNumbers,
    required this.onToggleNumbers,
  });

  /// 股息预测数据
  final UserShareBonusForecast forecast;

  /// 是否显示完整数字
  final bool showFullNumbers;

  /// 数字显示模式切换回调
  final VoidCallback onToggleNumbers;

  /// 构建股息预测摘要
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(
          alpha: colorScheme.brightness == Brightness.dark ? 0.24 : 0.42,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '税后收入',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatShareBonusCurrency(
                      forecast.afterTax,
                      showFullNumbers: showFullNumbers,
                    ),
                    maxLines: 1,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '预期股息 ${_formatShareBonusCurrency(
                    forecast.share,
                    showFullNumbers: showFullNumbers,
                  )}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onToggleNumbers,
                customBorder: const CircleBorder(),
                child: SizedBox.square(
                  dimension: 32,
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    size: 17,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 股息预测明细
class _ShareBonusForecastStats extends StatelessWidget {
  /// 创建股息预测明细
  ///
  /// [forecast] 股息预测数据
  /// [showFullNumbers] 是否显示完整数字
  const _ShareBonusForecastStats({
    required this.forecast,
    required this.showFullNumbers,
  });

  /// 股息预测数据
  final UserShareBonusForecast forecast;

  /// 是否显示完整数字
  final bool showFullNumbers;

  /// 构建股息预测明细
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final entries = [
      _ShareBonusStatEntry(
        label: '计息股份',
        value:
            '${_formatShareBonusNumber(forecast.total, showFullNumbers: showFullNumbers)} 股',
      ),
      _ShareBonusStatEntry(
        label: '圣殿数量',
        value:
            '${_formatShareBonusNumber(forecast.temples, showFullNumbers: showFullNumbers)} 座',
      ),
      _ShareBonusStatEntry(
        label: '预期股息',
        value: _formatShareBonusCurrency(
          forecast.share,
          showFullNumbers: showFullNumbers,
        ),
      ),
      _ShareBonusStatEntry(
        label: '个人所得税',
        value: _formatShareBonusCurrency(
          forecast.tax,
          showFullNumbers: showFullNumbers,
        ),
      ),
      _ShareBonusStatEntry(
        label: '税率',
        value: '${Formatters.groupedNumber(forecast.taxRate * 100)}%',
      ),
      _ShareBonusStatEntry(
        label: '登录奖励',
        value: _formatShareBonusCurrency(
          forecast.daily,
          showFullNumbers: showFullNumbers,
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in entries)
              SizedBox(
                width: itemWidth,
                child: _ShareBonusStatTile(entry: entry),
              ),
          ],
        );
      },
    );
  }
}

/// 格式化股息预测金额
///
/// [value] 金额数值
/// [showFullNumbers] 是否显示完整数字
String _formatShareBonusCurrency(
  num value, {
  required bool showFullNumbers,
}) {
  if (showFullNumbers) {
    return Formatters.tinygrailCurrency(value);
  }

  return Formatters.tinygrailCompactValue(value, prefix: '₵');
}

/// 格式化股息预测数量
///
/// [value] 数量数值
/// [showFullNumbers] 是否显示完整数字
String _formatShareBonusNumber(
  num value, {
  required bool showFullNumbers,
}) {
  if (showFullNumbers) {
    return Formatters.groupedNumber(value);
  }

  return Formatters.tinygrailCompactValue(value);
}

/// 股息预测明细条目数据
class _ShareBonusStatEntry {
  /// 创建股息预测明细条目数据
  ///
  /// [label] 条目标题
  /// [value] 条目数值
  const _ShareBonusStatEntry({
    required this.label,
    required this.value,
  });

  /// 条目标题
  final String label;

  /// 条目数值
  final String value;
}

/// 股息预测明细卡片
class _ShareBonusStatTile extends StatelessWidget {
  /// 创建股息预测明细卡片
  ///
  /// [entry] 明细条目数据
  const _ShareBonusStatTile({
    required this.entry,
  });

  /// 明细条目数据
  final _ShareBonusStatEntry entry;

  /// 构建股息预测明细卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(
          alpha: colorScheme.brightness == Brightness.dark ? 0.42 : 0.68,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                entry.value,
                maxLines: 1,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
