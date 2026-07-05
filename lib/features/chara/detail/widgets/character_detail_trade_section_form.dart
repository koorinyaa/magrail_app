part of 'character_detail_trade_section.dart';

/// 角色详情交易表单
class _TradeForm extends StatelessWidget {
  /// 创建角色详情交易表单
  ///
  /// [controller] 交易区控制器
  /// [onSubmit] 提交委托回调
  const _TradeForm({
    required this.controller,
    required this.onSubmit,
  });

  /// 交易区控制器
  final CharacterDetailTradeSectionController controller;

  /// 提交委托回调
  final Future<void> Function() onSubmit;

  /// 构建角色详情交易表单
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final side = controller.side;
    final accentColor = _accentColorForSide(side);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TradeSideSwitch(
          value: side,
          onChanged: controller.selectSide,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TradeTextField(
                controller: controller.priceController,
                label: '价格',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TradeTextField(
                controller: controller.amountController,
                label: '数量',
                keyboardType: TextInputType.number,
                inputFormatter: FilteringTextInputFormatter.digitsOnly,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _TradeTotalPreview(
          total: controller.currentTotal,
          isWarning: controller.isBuyTotalOverBalance,
        ),
        const SizedBox(height: 10),
        _TradeAccountSummary(
          balance: Formatters.tinygrailCurrency(controller.balance),
          availableAmount: Formatters.groupedNumber(
            controller.availableAmount,
          ),
          balanceWarning: controller.isBuyTotalOverBalance,
          availableWarning: controller.isSellAmountOverAvailable,
        ),
        const SizedBox(height: 10),
        _TradeIcebergOption(
          value: controller.orderType == CharacterDetailTradeOrderType.iceberg,
          onChanged: (value) {
            controller.selectOrderType(
              value
                  ? CharacterDetailTradeOrderType.iceberg
                  : CharacterDetailTradeOrderType.regular,
            );
          },
        ),
        const SizedBox(height: 8),
        _TradeSubmitButton(
          side: side,
          orderType: controller.orderType,
          accentColor: accentColor,
          isSubmitting: controller.isSubmitting,
          canSubmit: controller.canSubmit,
          onSubmit: onSubmit,
        ),
      ],
    );
  }
}
