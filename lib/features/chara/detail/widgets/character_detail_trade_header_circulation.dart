part of 'character_detail_trade_header_card.dart';

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
        TinygrailCalculations.minimumCirculationForCharacterLevel(currentLevel);
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
  /// [level] 当前角色等级，用于匹配等级标签颜色
  /// [updatedAt] 当前数据的设备本地更新时间
  /// [statusText] 采集进度或失败说明
  /// [hasError] 是否以错误色显示状态
  /// [change] 有效实际流通相对结算流通的变化，无有效快照时为空
  const _TradeHeaderCirculationProgress({
    required this.data,
    required this.level,
    required this.updatedAt,
    required this.statusText,
    required this.hasError,
    required this.change,
  });

  /// 有效实际流通相对结算流通的变化
  final int? change;

  /// 当前数据的设备本地更新时间
  final String updatedAt;

  /// 采集进度或失败说明
  final String statusText;

  /// 是否显示错误状态
  final bool hasError;

  /// 当前角色等级
  final int level;

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
      fontSize: 11,
      fontWeight: FontWeight.w700,
      height: 1.15,
    );
    final accentStyle = textStyle.copyWith(color: colorScheme.primary);
    final delta = change;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: '流通 '),
                    TextSpan(
                      text: Formatters.groupedNumber(data.total),
                      style: accentStyle,
                    ),
                    if (delta != null && delta != 0)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: NumericChangeBadge(
                          text: Formatters.groupedNumber(delta.abs()),
                          increased: delta > 0,
                        ),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: '还需 '),
                    TextSpan(
                      text: Formatters.groupedNumber(data.remaining),
                      style: accentStyle,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: textStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        LinearProgressIndicator(
          value: data.progress,
          minHeight: 4,
          borderRadius: BorderRadius.circular(999),
          backgroundColor: colorScheme.surfaceContainerHighest,
          color: LevelBadge.colorForLevel(level).withValues(alpha: 0.92),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Expanded(
                  child: Text(
                    '更新时间：$updatedAt',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                if (statusText.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.4,
                    ),
                    child: Text(
                      statusText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: textStyle.copyWith(
                        color: hasError
                            ? colorScheme.error
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                ],
                // 为卡片叠加的刷新按钮保留位置，点击区域不参与信息行高度计算
                const SizedBox(width: 24, height: 13),
              ],
            );
          },
        ),
      ],
    );
  }
}
