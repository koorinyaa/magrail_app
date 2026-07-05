part of 'character_detail_trade_section.dart';

/// 角色详情交易合计预览
class _TradeTotalPreview extends StatelessWidget {
  /// 创建角色详情交易合计预览
  ///
  /// [total] 当前合计金额
  /// [isWarning] 是否使用警告色
  const _TradeTotalPreview({
    required this.total,
    required this.isWarning,
  });

  /// 当前合计金额
  final double total;

  /// 是否使用警告色
  final bool isWarning;

  /// 构建角色详情交易合计预览
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final foregroundColor =
        isWarning ? colorScheme.error : colorScheme.onSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.24 : 0.38,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            Text(
              '金额',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                Formatters.tinygrailCurrency(total),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 角色详情交易账户摘要
class _TradeAccountSummary extends StatelessWidget {
  /// 创建角色详情交易账户摘要
  ///
  /// [balance] 当前用户余额
  /// [availableAmount] 当前角色可用持股
  /// [balanceWarning] 余额是否使用警告色
  /// [availableWarning] 可用持股是否使用警告色
  const _TradeAccountSummary({
    required this.balance,
    required this.availableAmount,
    required this.balanceWarning,
    required this.availableWarning,
  });

  /// 当前用户余额
  final String balance;

  /// 当前角色可用持股
  final String availableAmount;

  /// 余额是否使用警告色
  final bool balanceWarning;

  /// 可用持股是否使用警告色
  final bool availableWarning;

  /// 构建角色详情交易账户摘要
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: _TradeAccountSummaryItem(
              label: '可用持股',
              value: availableAmount,
              isWarning: availableWarning,
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _TradeAccountSummaryItem(
              label: '余额',
              value: balance,
              isWarning: balanceWarning,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// 角色详情交易账户摘要项
class _TradeAccountSummaryItem extends StatelessWidget {
  /// 创建角色详情交易账户摘要项
  ///
  /// [label] 标签文本
  /// [value] 数值文本
  /// [isWarning] 是否使用警告色
  /// [textAlign] 文本对齐方式
  const _TradeAccountSummaryItem({
    required this.label,
    required this.value,
    required this.isWarning,
    required this.textAlign,
  });

  /// 标签文本
  final String label;

  /// 数值文本
  final String value;

  /// 是否使用警告色
  final bool isWarning;

  /// 文本对齐方式
  final TextAlign textAlign;

  /// 构建角色详情交易账户摘要项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final valueColor = isWarning ? colorScheme.error : colorScheme.onSurface;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: value,
            style: TextStyle(
              color: valueColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}

/// 角色详情交易输入框
class _TradeTextField extends StatelessWidget {
  /// 创建角色详情交易输入框
  ///
  /// [controller] 输入控制器
  /// [label] 输入标签
  /// [keyboardType] 键盘类型
  /// [inputFormatter] 输入格式限制
  const _TradeTextField({
    required this.controller,
    required this.label,
    required this.keyboardType,
    this.inputFormatter,
  });

  /// 输入控制器
  final TextEditingController controller;

  /// 输入标签
  final String label;

  /// 键盘类型
  final TextInputType keyboardType;

  /// 输入格式限制
  final TextInputFormatter? inputFormatter;

  /// 构建角色详情交易输入框
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final fillColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.38)
        : colorScheme.surfaceContainerLowest;
    final borderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.24 : 0.52,
    );

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters:
          inputFormatter == null ? null : <TextInputFormatter>[inputFormatter!],
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        floatingLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}
