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
class _ShareBonusForecastContent extends StatelessWidget {
  /// 创建股息预测内容
  ///
  /// [forecast] 股息预测数据
  const _ShareBonusForecastContent({
    required this.forecast,
  });

  /// 股息预测数据
  final UserShareBonusForecast forecast;

  /// 构建股息预测内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ShareBonusForecastSummary(forecast: forecast),
        const SizedBox(height: 12),
        _ShareBonusForecastChart(forecast: forecast),
        const SizedBox(height: 12),
        _ShareBonusForecastStats(forecast: forecast),
      ],
    );
  }
}

/// 股息预测摘要
class _ShareBonusForecastSummary extends StatelessWidget {
  /// 创建股息预测摘要
  ///
  /// [forecast] 股息预测数据
  const _ShareBonusForecastSummary({
    required this.forecast,
  });

  /// 股息预测数据
  final UserShareBonusForecast forecast;

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
      child: Padding(
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
                Formatters.tinygrailCurrency(forecast.afterTax),
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
              '预期股息 ${Formatters.tinygrailCurrency(forecast.share)}',
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
    );
  }
}

/// 股息预测明细
class _ShareBonusForecastStats extends StatelessWidget {
  /// 创建股息预测明细
  ///
  /// [forecast] 股息预测数据
  const _ShareBonusForecastStats({
    required this.forecast,
  });

  /// 股息预测数据
  final UserShareBonusForecast forecast;

  /// 构建股息预测明细
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final entries = [
      _ShareBonusStatEntry(
        label: '计息股份',
        value: '${Formatters.groupedNumber(forecast.total)} 股',
      ),
      _ShareBonusStatEntry(
        label: '圣殿数量',
        value: '${Formatters.groupedNumber(forecast.temples)} 座',
      ),
      _ShareBonusStatEntry(
        label: '预期股息',
        value: Formatters.tinygrailCurrency(forecast.share),
      ),
      _ShareBonusStatEntry(
        label: '个人所得税',
        value: Formatters.tinygrailCurrency(forecast.tax),
      ),
      _ShareBonusStatEntry(
        label: '税率',
        value: '${Formatters.groupedNumber(forecast.taxRate * 100)}%',
      ),
      _ShareBonusStatEntry(
        label: '登录奖励',
        value: Formatters.tinygrailCurrency(forecast.daily),
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
