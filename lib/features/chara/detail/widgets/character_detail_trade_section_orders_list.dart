part of 'character_detail_trade_section.dart';

/// 角色详情当前委托列表
class _TradeOrdersList extends StatelessWidget {
  /// 创建角色详情当前委托列表
  ///
  /// [controller] 交易区控制器
  /// [bids] 买入委托列表
  /// [asks] 卖出委托列表
  /// [onOrderCancelled] 委托取消后的刷新回调
  const _TradeOrdersList({
    required this.controller,
    required this.bids,
    required this.asks,
    required this.onOrderCancelled,
  });

  /// 交易区控制器
  final CharacterDetailTradeSectionController controller;

  /// 买入委托列表
  final List<CharacterDetailTradeOrder> bids;

  /// 卖出委托列表
  final List<CharacterDetailTradeOrder> asks;

  /// 委托取消后的刷新回调
  final Future<void> Function() onOrderCancelled;

  /// 构建角色详情当前委托列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final rows = <_TradeOrderRowData>[
      for (final bid in bids)
        _TradeOrderRowData(
          order: bid,
          isBid: true,
        ),
      for (final ask in asks)
        _TradeOrderRowData(
          order: ask,
          isBid: false,
        ),
    ];

    if (rows.isEmpty) {
      return const _TradeOrdersEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: rows.length,
      separatorBuilder: (context, index) => const _TradeOrdersDivider(),
      itemBuilder: (context, index) {
        final row = rows[index];
        return _TradeOrderRow(
          controller: controller,
          order: row.order,
          isBid: row.isBid,
          onOrderCancelled: onOrderCancelled,
        );
      },
    );
  }
}

/// 角色详情当前委托行数据
final class _TradeOrderRowData {
  /// 创建角色详情当前委托行数据
  ///
  /// [order] 当前委托
  /// [isBid] 是否买入委托
  const _TradeOrderRowData({
    required this.order,
    required this.isBid,
  });

  /// 当前委托
  final CharacterDetailTradeOrder order;

  /// 是否买入委托
  final bool isBid;
}

/// 角色详情当前委托行
class _TradeOrderRow extends StatelessWidget {
  /// 创建角色详情当前委托行
  ///
  /// [controller] 交易区控制器
  /// [order] 当前委托
  /// [isBid] 是否买入委托
  /// [onOrderCancelled] 委托取消后的刷新回调
  const _TradeOrderRow({
    required this.controller,
    required this.order,
    required this.isBid,
    required this.onOrderCancelled,
  });

  /// 交易区控制器
  final CharacterDetailTradeSectionController controller;

  /// 当前委托
  final CharacterDetailTradeOrder order;

  /// 是否买入委托
  final bool isBid;

  /// 委托取消后的刷新回调
  final Future<void> Function() onOrderCancelled;

  /// 构建角色详情当前委托行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sideColor = isBid ? _tradeBuyColor : _tradeSellColor;
    final sideText = isBid ? '买入' : '卖出';
    final isCancelling = controller.isCancellingOrder(order);
    final totalText = isBid
        ? '-${Formatters.tinygrailCurrency(order.total)}'
        : '+${Formatters.tinygrailCurrency(order.total)}';
    final orderValuesText =
        '${Formatters.tinygrailCurrency(order.price)} / ${Formatters.groupedNumber(order.amount)}股';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 132),
                child: Text(
                  totalText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: sideColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _TradeOrderSideChip(
                text: sideText,
                color: sideColor,
              ),
              if (order.isIceberg) ...[
                const SizedBox(width: 6),
                _TradeOrderSideChip(
                  text: '冰山',
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      LucideIcons.clock3,
                      size: 12,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.58,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        TinygrailFormatters.relativeTime(order.begin),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  orderValuesText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _TradeOrderCancelButton(
                isLoading: isCancelling,
                onPressed: isCancelling
                    ? null
                    : () {
                        unawaited(_handleCancelPressed(context));
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 处理取消委托点击
  ///
  /// [context] 当前组件树上下文
  Future<void> _handleCancelPressed(BuildContext context) async {
    try {
      final message = await controller.cancelOrder(
        order: order,
        isBid: isBid,
      );
      if (!context.mounted || message == null) {
        return;
      }

      AppToast.info(context, text: message);
      await onOrderCancelled();
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      AppToast.error(
        context,
        text: CharacterDetailTradeSectionController.resolveErrorMessage(
          error,
          fallback: '取消委托失败',
        ),
      );
    }
  }
}

/// 角色详情当前委托方向标签
class _TradeOrderSideChip extends StatelessWidget {
  /// 创建角色详情当前委托方向标签
  ///
  /// [text] 标签文本
  /// [color] 标签颜色
  const _TradeOrderSideChip({
    required this.text,
    required this.color,
  });

  /// 标签文本
  final String text;

  /// 标签颜色
  final Color color;

  /// 构建角色详情当前委托方向标签
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// 角色详情当前委托取消按钮
class _TradeOrderCancelButton extends StatelessWidget {
  /// 创建角色详情当前委托取消按钮
  ///
  /// [isLoading] 是否正在取消委托
  /// [onPressed] 取消按钮点击回调
  const _TradeOrderCancelButton({
    required this.isLoading,
    required this.onPressed,
  });

  /// 是否正在取消委托
  final bool isLoading;

  /// 取消按钮点击回调
  final VoidCallback? onPressed;

  /// 构建角色详情当前委托取消按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final foregroundColor = onPressed == null
        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.50)
        : colorScheme.onSurfaceVariant;
    final backgroundColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: isDark ? 0.34 : 0.62,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.6,
                      color: foregroundColor,
                    ),
                  )
                else
                  Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: foregroundColor,
                  ),
                const SizedBox(width: 4),
                Text(
                  '取消',
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 角色详情当前委托分割线
class _TradeOrdersDivider extends StatelessWidget {
  /// 创建角色详情当前委托分割线
  const _TradeOrdersDivider();

  /// 构建角色详情当前委托分割线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Divider(
      height: 1,
      thickness: 1,
      color: colorScheme.outlineVariant.withValues(alpha: 0.42),
    );
  }
}

/// 角色详情当前委托空态
class _TradeOrdersEmptyState extends StatelessWidget {
  /// 创建角色详情当前委托空态
  const _TradeOrdersEmptyState();

  /// 构建角色详情当前委托空态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        '暂无委托',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}
