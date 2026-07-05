part of 'auction_bid_sheet.dart';

/// 锁定总额开关
class _LockTotalSwitch extends StatelessWidget {
  /// 创建锁定总额开关
  ///
  /// [value] 是否锁定总额
  /// [onChanged] 状态变化回调
  const _LockTotalSwitch({
    required this.value,
    required this.onChanged,
  });

  /// 是否锁定总额
  final bool value;

  /// 状态变化回调
  final ValueChanged<bool> onChanged;

  /// 构建锁定总额开关
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: _AuctionSurfaceStyle.decoration(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(
                      alpha: value ? 0.14 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 18,
                      color: value
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '锁定总额',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '修改价格或数量时自动调整另一项',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return null;
                    }

                    return colorScheme.onSurfaceVariant.withValues(
                      alpha: isDark ? 0.92 : 0.78,
                    );
                  }),
                  trackColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return null;
                    }

                    return colorScheme.onSurfaceVariant.withValues(
                      alpha: isDark ? 0.24 : 0.16,
                    );
                  }),
                  trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return null;
                    }

                    return colorScheme.outlineVariant.withValues(
                      alpha: isDark ? 0.72 : 0.44,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 拍卖输入框
class _AuctionBidTextField extends StatelessWidget {
  /// 创建拍卖输入框
  ///
  /// [controller] 输入控制器
  /// [label] 输入标签
  /// [keyboardType] 键盘类型
  const _AuctionBidTextField({
    required this.controller,
    required this.label,
    required this.keyboardType,
  });

  /// 输入控制器
  final TextEditingController controller;

  /// 输入标签
  final String label;

  /// 键盘类型
  final TextInputType keyboardType;

  /// 构建拍卖输入框
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final fillColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.48)
        : colorScheme.surfaceContainerLowest;
    final borderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.26 : 0.58,
    );

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        floatingLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}

/// 拍卖快捷数量按钮组
class _AuctionQuickAmountButtons extends StatelessWidget {
  /// 创建拍卖快捷数量按钮组
  ///
  /// [onFillRemaining] 拍满回调
  /// [onFillMaxAmount] 英灵殿回调
  const _AuctionQuickAmountButtons({
    required this.onFillRemaining,
    required this.onFillMaxAmount,
  });

  /// 拍满回调
  final VoidCallback onFillRemaining;

  /// 英灵殿回调
  final VoidCallback onFillMaxAmount;

  /// 构建拍卖快捷数量按钮组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _AuctionQuickAmountButton(
          text: '拍满',
          onPressed: onFillRemaining,
        ),
        _AuctionQuickAmountButton(
          text: '英灵殿',
          onPressed: onFillMaxAmount,
        ),
      ],
    );
  }
}

/// 拍卖快捷数量按钮
class _AuctionQuickAmountButton extends StatelessWidget {
  /// 创建拍卖快捷数量按钮
  ///
  /// [text] 按钮文本
  /// [onPressed] 点击回调
  const _AuctionQuickAmountButton({
    required this.text,
    required this.onPressed,
  });

  /// 按钮文本
  final String text;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建拍卖快捷数量按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(
        alpha: isDark ? 0.22 : 0.46,
      ),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(
                alpha: isDark ? 0.22 : 0.42,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              text,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 拍卖合计文本
class _AuctionTotalText extends StatelessWidget {
  /// 创建拍卖合计文本
  ///
  /// [total] 合计金额
  const _AuctionTotalText({
    required this.total,
  });

  /// 合计金额
  final double total;

  /// 构建拍卖合计文本
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Text(
              '合计',
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
                  color: colorScheme.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
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

/// 拍卖操作按钮组
class _AuctionBidActions extends StatelessWidget {
  /// 创建拍卖操作按钮组
  ///
  /// [canCancel] 是否可取消竞拍
  /// [isSubmitting] 是否提交中
  /// [isCancelling] 是否取消中
  /// [onCancel] 取消竞拍回调
  /// [onSubmit] 提交竞拍回调
  const _AuctionBidActions({
    required this.canCancel,
    required this.isSubmitting,
    required this.isCancelling,
    required this.onCancel,
    required this.onSubmit,
  });

  /// 是否可取消竞拍
  final bool canCancel;

  /// 是否提交中
  final bool isSubmitting;

  /// 是否取消中
  final bool isCancelling;

  /// 取消竞拍回调
  final VoidCallback onCancel;

  /// 提交竞拍回调
  final VoidCallback onSubmit;

  /// 构建拍卖操作按钮组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final busy = isSubmitting || isCancelling;
    final cancelBackgroundColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.14 : 0.08,
    );

    return Row(
      children: [
        if (canCancel) ...[
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                backgroundColor: cancelBackgroundColor,
                disabledForegroundColor: colorScheme.onSurface.withValues(
                  alpha: 0.38,
                ),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              onPressed: busy ? null : onCancel,
              child: Text(isCancelling ? '撤销中' : '撤销竞拍'),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            onPressed: busy ? null : onSubmit,
            child: Text(isSubmitting ? '处理中' : '竞拍'),
          ),
        ),
      ],
    );
  }
}
