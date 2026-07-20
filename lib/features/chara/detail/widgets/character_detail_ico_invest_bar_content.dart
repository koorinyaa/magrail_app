part of 'character_detail_ico_invest_bar.dart';

/// ICO 注资栏浮层外壳
class _IcoInvestSurface extends StatelessWidget {
  /// 创建 ICO 注资栏浮层外壳
  ///
  /// [child] 注资栏内容
  const _IcoInvestSurface({
    required this.child,
  });

  /// 注资栏内容
  final Widget child;

  /// 构建 ICO 注资栏浮层外壳
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    const borderRadius = BorderRadius.vertical(
      top: Radius.circular(22),
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: AppBlurStyle.filter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppBlurStyle.surfaceColor(context),
            borderRadius: borderRadius,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.24 : 0.42,
                ),
                width: 0.7,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.14),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SafeArea(
            left: false,
            right: false,
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// ICO 注资栏表单
class _IcoInvestForm extends StatelessWidget {
  /// 创建 ICO 注资栏表单
  ///
  /// [amountController] 注资金额输入控制器
  /// [icoInfo] ICO 头部资料
  /// [userInfo] 当前用户 ICO 注资资料
  /// [balance] 当前登录用户余额
  /// [isSubmitting] 是否正在提交
  /// [onFillNextLevel] 填入下一等级金额回调
  /// [onSubmit] 提交注资回调
  const _IcoInvestForm({
    required this.amountController,
    required this.icoInfo,
    required this.userInfo,
    required this.balance,
    required this.isSubmitting,
    required this.onFillNextLevel,
    required this.onSubmit,
  });

  /// 注资金额输入控制器
  final TextEditingController amountController;

  /// ICO 头部资料
  final CharacterDetailIcoInfo icoInfo;

  /// 当前用户 ICO 注资资料
  final CharacterDetailIcoUserInfo userInfo;

  /// 当前登录用户余额
  final double? balance;

  /// 是否正在提交
  final bool isSubmitting;

  /// 填入下一等级金额回调
  final VoidCallback onFillNextLevel;

  /// 提交注资回调
  final VoidCallback onSubmit;

  /// 构建 ICO 注资栏表单
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final prediction = CharacterDetailIcoPrediction.fromInfo(icoInfo);
    final expectedShares = prediction.expectedShares(userInfo.amount);
    final promptText = userInfo.hasInvested
        ? '已注资 ${Formatters.tinygrailCurrency(userInfo.amount)}，预计可得 '
            '${Formatters.groupedNumber(expectedShares)} 股'
        : '追加注资请在下方输入金额';
    final balanceText = balance == null
        ? '账户余额：未知'
        : '账户余额：${Formatters.tinygrailCurrency(balance!)}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          promptText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _IcoInvestAmountField(controller: amountController),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: FilledButton.styleFrom(
                minimumSize: const Size(74, 42),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              child: const Text('注资'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _IcoInvestQuickButton(
              text: '下一等级',
              onPressed: isSubmitting ? null : onFillNextLevel,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                balanceText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.78),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ICO 注资金额输入框
class _IcoInvestAmountField extends StatelessWidget {
  /// 创建 ICO 注资金额输入框
  ///
  /// [controller] 注资金额输入控制器
  const _IcoInvestAmountField({
    required this.controller,
  });

  /// 注资金额输入控制器
  final TextEditingController controller;

  /// 构建 ICO 注资金额输入框
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
      decoration: InputDecoration(
        labelText: '金额',
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// ICO 注资快捷金额按钮
class _IcoInvestQuickButton extends StatelessWidget {
  /// 创建 ICO 注资快捷金额按钮
  ///
  /// [text] 按钮文案
  /// [onPressed] 点击回调，为空时禁用
  const _IcoInvestQuickButton({
    required this.text,
    required this.onPressed,
  });

  /// 按钮文案
  final String text;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 构建 ICO 注资快捷金额按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return TextFieldTapRegion(
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.22 : 0.46,
        ),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          canRequestFocus: false,
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
      ),
    );
  }
}

/// ICO 注资加载失败内容
class _IcoInvestLoadFailedContent extends StatelessWidget {
  /// 创建 ICO 注资加载失败内容
  ///
  /// [message] 加载失败文案
  /// [onRetry] 重试回调
  const _IcoInvestLoadFailedContent({
    required this.message,
    required this.onRetry,
  });

  /// 加载失败文案
  final String message;

  /// 重试回调
  final VoidCallback onRetry;

  /// 构建 ICO 注资加载失败内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(
            minimumSize: const Size(68, 34),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: const Text('重试'),
        ),
      ],
    );
  }
}

/// ICO 注资状态文本
class _IcoInvestStatusText extends StatelessWidget {
  /// 创建 ICO 注资状态文本
  ///
  /// [text] 状态文案
  const _IcoInvestStatusText({
    required this.text,
  });

  /// 状态文案
  final String text;

  /// 构建 ICO 注资状态文本
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
