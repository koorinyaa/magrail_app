part of 'character_detail_trade_header_card.dart';

/// 已上市头部流通 Chip
class _TradeHeaderCirculationChip extends StatelessWidget {
  /// 创建已上市头部流通 Chip
  ///
  /// [header] 已上市角色头部资料
  const _TradeHeaderCirculationChip({
    required this.header,
  });

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 构建已上市头部流通 Chip
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colors = _TradeHeaderChipColors.resolve(context, null);

    return _TradeHeaderChipShell(
      colors: colors,
      onPressed: () {
        _showCirculationDialog(context);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: _TradeHeaderChipText(
              text: '流通 ${Formatters.tinygrailCompactValue(header.total)}',
              color: colors.foregroundColor,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            LucideIcons.chevronRight,
            size: 11,
            color: colors.foregroundColor,
          ),
        ],
      ),
    );
  }

  /// 显示流通等级说明弹窗
  ///
  /// [context] 当前组件树上下文
  Future<void> _showCirculationDialog(BuildContext context) async {
    final progress = _TradeHeaderCirculationProgressData.fromTotal(
      header.total,
    );

    await showAppConfirmDialog(
      context,
      title: '升级所需流通',
      message: '流通数据每周六晚上 0 点结算后更新',
      content: _TradeHeaderCirculationProgress(data: progress),
      confirmText: '知道了',
      showCancelButton: false,
      icon: LucideIcons.trendingUp,
    );
  }
}

/// 已上市头部流通等级进度数据
final class _TradeHeaderCirculationProgressData {
  /// 创建已上市头部流通等级进度数据
  ///
  /// [total] 当前流通
  /// [remaining] 距离下一级所需流通
  /// [progress] 当前等级区间进度
  const _TradeHeaderCirculationProgressData({
    required this.total,
    required this.remaining,
    required this.progress,
  });

  /// 当前流通
  final int total;

  /// 距离下一级所需流通
  final int remaining;

  /// 当前等级区间进度
  final double progress;

  /// 根据流通创建已上市头部流通等级进度数据
  ///
  /// [total] 当前流通
  factory _TradeHeaderCirculationProgressData.fromTotal(int total) {
    final safeTotal = total < 0 ? 0 : total;
    final currentLevel = TinygrailCalculations.characterLevelFromCirculation(
      safeTotal,
    );
    final nextLevel = currentLevel + 1;
    final currentMinimum =
        TinygrailCalculations.minimumCirculationForCharacterLevel(
      currentLevel,
    );
    final nextMinimum =
        TinygrailCalculations.minimumCirculationForCharacterLevel(nextLevel);
    final remaining = (nextMinimum - safeTotal).clamp(0, nextMinimum);
    final levelSpan = nextMinimum - currentMinimum;
    final progress = levelSpan <= 0
        ? 1.0
        : ((safeTotal - currentMinimum) / levelSpan).clamp(0.0, 1.0);

    return _TradeHeaderCirculationProgressData(
      total: safeTotal,
      remaining: remaining,
      progress: progress,
    );
  }
}

/// 已上市头部流通等级进度
class _TradeHeaderCirculationProgress extends StatelessWidget {
  /// 创建已上市头部流通等级进度
  ///
  /// [data] 流通等级进度数据
  const _TradeHeaderCirculationProgress({
    required this.data,
  });

  /// 流通等级进度数据
  final _TradeHeaderCirculationProgressData data;

  /// 构建已上市头部流通等级进度
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = TextStyle(
      color: colorScheme.onSurfaceVariant,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '流通 ${Formatters.groupedNumber(data.total)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '还需 ${Formatters.groupedNumber(data.remaining)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: textStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: data.progress,
          minHeight: 5,
          borderRadius: BorderRadius.circular(999),
          backgroundColor: colorScheme.surfaceContainerHighest,
          color: colorScheme.primary,
        ),
      ],
    );
  }
}

/// 已上市头部股息 Chip
class _TradeHeaderDividendChip extends StatelessWidget {
  /// 创建已上市头部股息 Chip
  ///
  /// [header] 已上市角色头部资料
  const _TradeHeaderDividendChip({
    required this.header,
  });

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 构建已上市头部股息 Chip
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colors = _TradeHeaderChipColors.resolve(context, null);

    return _TradeHeaderChipShell(
      colors: colors,
      onPressed: () {
        _showDividendFormulaDialog(context);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: _TradeHeaderChipText(
              text: '股息 ${Formatters.tinygrailCurrency(header.dividend)}',
              color: colors.foregroundColor,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            LucideIcons.chevronRight,
            size: 11,
            color: colors.foregroundColor,
          ),
        ],
      ),
    );
  }

  /// 显示股息计算说明弹窗
  ///
  /// [context] 当前组件树上下文
  Future<void> _showDividendFormulaDialog(BuildContext context) async {
    final dividendText = Formatters.tinygrailCurrency(header.dividend);
    final perStarDividendText = Formatters.tinygrailCurrency(2);
    final rankFormulaText = '${Formatters.tinygrailCurrency(header.rate)} × '
        '0.005 × (601 - ${header.rank})';
    final starFormulaText = '${header.stars} × $perStarDividendText';
    final appliedFormulaText = header.rank <= 500
        ? '$rankFormulaText = $dividendText'
        : '$starFormulaText = $dividendText';
    final message = '在通天塔前 500 名时：\n'
        '基础股息 × 0.005 × (601 - 排名)\n'
        '\n'
        '不在通天塔前 500 名时：\n'
        '星级 × $perStarDividendText\n'
        '\n'
        '当前使用：$appliedFormulaText';

    await showAppConfirmDialog(
      context,
      title: '股息计算方式',
      message: message,
      confirmText: '知道了',
      showCancelButton: false,
      icon: LucideIcons.calculator,
    );
  }
}
