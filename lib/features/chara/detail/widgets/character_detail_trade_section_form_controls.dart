part of 'character_detail_trade_section.dart';

/// 角色详情交易方向切换
class _TradeSideSwitch extends StatelessWidget {
  /// 创建角色详情交易方向切换
  ///
  /// [value] 当前交易方向
  /// [onChanged] 交易方向变化回调
  const _TradeSideSwitch({
    required this.value,
    required this.onChanged,
  });

  /// 当前交易方向
  final CharacterDetailTradeSide value;

  /// 交易方向变化回调
  final ValueChanged<CharacterDetailTradeSide> onChanged;

  /// 构建角色详情交易方向切换
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _segmentedDecoration(context),
      child: Row(
        children: [
          Expanded(
            child: _TradeSegmentButton(
              label: '卖出',
              selected: value == CharacterDetailTradeSide.sell,
              accentColor: _tradeSellColor,
              onPressed: () => onChanged(CharacterDetailTradeSide.sell),
            ),
          ),
          Expanded(
            child: _TradeSegmentButton(
              label: '买入',
              selected: value == CharacterDetailTradeSide.buy,
              accentColor: _tradeBuyColor,
              onPressed: () => onChanged(CharacterDetailTradeSide.buy),
            ),
          ),
        ],
      ),
    );
  }
}

/// 角色详情交易分段按钮
class _TradeSegmentButton extends StatelessWidget {
  /// 创建角色详情交易分段按钮
  ///
  /// [label] 按钮文案
  /// [selected] 是否选中
  /// [accentColor] 强调色
  /// [onPressed] 点击回调
  const _TradeSegmentButton({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onPressed,
  });

  /// 按钮文案
  final String label;

  /// 是否选中
  final bool selected;

  /// 强调色
  final Color accentColor;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建角色详情交易分段按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// 角色详情冰山委托选项
class _TradeIcebergOption extends StatelessWidget {
  /// 创建角色详情冰山委托选项
  ///
  /// [value] 是否启用冰山委托
  /// [onChanged] 状态变化回调
  const _TradeIcebergOption({
    required this.value,
    required this.onChanged,
  });

  /// 是否启用冰山委托
  final bool value;

  /// 状态变化回调
  final ValueChanged<bool> onChanged;

  /// 构建角色详情冰山委托选项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final borderColor = value
        ? colorScheme.primary.withValues(alpha: 0.24)
        : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.20 : 0.36);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(13),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(
              alpha: value ? (isDark ? 0.24 : 0.32) : (isDark ? 0.16 : 0.24),
            ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '冰山委托',
                        style: TextStyle(
                          color: value
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '隐藏价格，显示为 ₵--',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value ? colorScheme.primary : Colors.transparent,
                    border: value
                        ? null
                        : Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: isDark ? 0.72 : 0.86,
                            ),
                            width: 1.2,
                          ),
                  ),
                  child: value
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 角色详情交易提交按钮
class _TradeSubmitButton extends StatelessWidget {
  /// 创建角色详情交易提交按钮
  ///
  /// [side] 当前交易方向
  /// [orderType] 当前委托类型
  /// [accentColor] 强调色
  /// [isSubmitting] 是否提交中
  /// [canSubmit] 是否可以提交
  /// [onSubmit] 提交回调
  const _TradeSubmitButton({
    required this.side,
    required this.orderType,
    required this.accentColor,
    required this.isSubmitting,
    required this.canSubmit,
    required this.onSubmit,
  });

  /// 当前交易方向
  final CharacterDetailTradeSide side;

  /// 当前委托类型
  final CharacterDetailTradeOrderType orderType;

  /// 强调色
  final Color accentColor;

  /// 是否提交中
  final bool isSubmitting;

  /// 是否可以提交
  final bool canSubmit;

  /// 提交回调
  final Future<void> Function() onSubmit;

  /// 构建角色详情交易提交按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sideLabel = side == CharacterDetailTradeSide.buy ? '买入' : '卖出';
    final label = switch (orderType) {
      CharacterDetailTradeOrderType.regular => sideLabel,
      CharacterDetailTradeOrderType.iceberg => '冰山$sideLabel',
    };

    return SizedBox(
      height: 38,
      child: FilledButton(
        onPressed: canSubmit ? () => unawaited(onSubmit()) : null,
        style: FilledButton.styleFrom(
          backgroundColor: accentColor,
          disabledBackgroundColor:
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.56),
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        child: Text(isSubmitting ? '提交中...' : label),
      ),
    );
  }
}

/// 获取交易方向强调色
///
/// [side] 交易方向
Color _accentColorForSide(CharacterDetailTradeSide side) {
  return switch (side) {
    CharacterDetailTradeSide.buy => _tradeBuyColor,
    CharacterDetailTradeSide.sell => _tradeSellColor,
  };
}

/// 获取分段控件背景样式
///
/// [context] 当前组件树上下文
BoxDecoration _segmentedDecoration(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final isDark = colorScheme.brightness == Brightness.dark;

  return BoxDecoration(
    color: colorScheme.surfaceContainerHighest.withValues(
      alpha: isDark ? 0.42 : 0.64,
    ),
    borderRadius: BorderRadius.circular(13),
    border: Border.all(
      color: colorScheme.outlineVariant.withValues(
        alpha: isDark ? 0.30 : 0.56,
      ),
    ),
  );
}
