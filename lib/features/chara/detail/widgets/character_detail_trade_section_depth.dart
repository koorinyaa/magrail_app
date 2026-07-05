part of 'character_detail_trade_section.dart';

/// 角色详情当前买卖单面板
class _TradeDepthPanel extends StatelessWidget {
  /// 创建角色详情当前买卖单面板
  ///
  /// [controller] 交易区控制器
  /// [onOrdersPressed] 当前委托入口回调
  /// [onFormExpandRequested] 交易表单展开请求回调
  const _TradeDepthPanel({
    required this.controller,
    required this.onOrdersPressed,
    required this.onFormExpandRequested,
  });

  /// 交易区控制器
  final CharacterDetailTradeSectionController controller;

  /// 当前委托入口回调
  final VoidCallback onOrdersPressed;

  /// 交易表单展开请求回调
  final VoidCallback onFormExpandRequested;

  /// 构建角色详情当前买卖单面板
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final asks = controller.depth.asks
        .where((item) => item.amount > 0)
        .toList(growable: false)
        .reversed
        .toList(growable: false);
    final bids = controller.depth.bids
        .where((item) => item.amount > 0)
        .toList(growable: false);
    final hasDepth = asks.isNotEmpty || bids.isNotEmpty;

    if (!hasDepth && !controller.hasActiveOrders) {
      return const _TradeDepthEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasDepth)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _TradeDepthColumn(
                  emptyText: '暂无卖单',
                  items: asks,
                  accentColor: _tradeSellColor,
                  onItemPressed: (item) {
                    onFormExpandRequested();
                    controller.fillFromDepth(
                        CharacterDetailTradeSide.buy, item);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TradeDepthColumn(
                  emptyText: '暂无买单',
                  items: bids,
                  accentColor: _tradeBuyColor,
                  onItemPressed: (item) {
                    onFormExpandRequested();
                    controller.fillFromDepth(
                      CharacterDetailTradeSide.sell,
                      item,
                    );
                  },
                ),
              ),
            ],
          ),
        if (!hasDepth) const _TradeDepthEmptyState(),
        if (controller.hasActiveOrders) ...[
          SizedBox(height: hasDepth ? 6 : 0),
          _TradeCurrentOrdersEntry(
            bidCount: controller.activeBidOrders.length,
            askCount: controller.activeAskOrders.length,
            onPressed: onOrdersPressed,
          ),
        ],
      ],
    );
  }
}

/// 角色详情单侧当前买卖单
class _TradeDepthColumn extends StatelessWidget {
  /// 创建角色详情单侧当前买卖单
  ///
  /// [emptyText] 空态文案
  /// [items] 当前买卖单条目列表
  /// [accentColor] 强调色
  /// [onItemPressed] 当前买卖单条目点击回调
  const _TradeDepthColumn({
    required this.emptyText,
    required this.items,
    required this.accentColor,
    required this.onItemPressed,
  });

  /// 空态文案
  final String emptyText;

  /// 当前买卖单条目列表
  final List<CharacterDetailTradeDepthItem> items;

  /// 强调色
  final Color accentColor;

  /// 当前买卖单条目点击回调
  final ValueChanged<CharacterDetailTradeDepthItem> onItemPressed;

  /// 构建角色详情单侧当前买卖单
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.isEmpty)
          _TradeDepthColumnEmptyState(text: emptyText)
        else
          for (final item in items)
            _TradeDepthRow(
              item: item,
              accentColor: accentColor,
              onPressed: () {
                onItemPressed(item);
              },
            ),
      ],
    );
  }
}

/// 角色详情当前买卖单行
class _TradeDepthRow extends StatelessWidget {
  /// 创建角色详情当前买卖单行
  ///
  /// [item] 当前买卖单条目
  /// [accentColor] 强调色
  /// [onPressed] 点击回调
  const _TradeDepthRow({
    required this.item,
    required this.accentColor,
    required this.onPressed,
  });

  /// 当前买卖单条目
  final CharacterDetailTradeDepthItem item;

  /// 强调色
  final Color accentColor;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建角色详情当前买卖单行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = accentColor.withValues(alpha: isDark ? 0.16 : 0.12);
    final priceText =
        item.isIceberg ? '₵--' : Formatters.tinygrailCurrency(item.price);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(9),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      priceText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: Text(
                      Formatters.groupedNumber(item.amount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 角色详情当前委托入口
class _TradeCurrentOrdersEntry extends StatelessWidget {
  /// 创建角色详情当前委托入口
  ///
  /// [bidCount] 买入委托数量
  /// [askCount] 卖出委托数量
  /// [onPressed] 点击回调
  const _TradeCurrentOrdersEntry({
    required this.bidCount,
    required this.askCount,
    required this.onPressed,
  });

  /// 买入委托数量
  final int bidCount;

  /// 卖出委托数量
  final int askCount;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建角色详情当前委托入口
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(11),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(
              alpha: isDark ? 0.30 : 0.42,
            ),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(
                alpha: isDark ? 0.30 : 0.56,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              children: [
                Icon(
                  LucideIcons.clipboardList,
                  size: 15,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    '我的委托',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '买 $bidCount / 卖 $askCount',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_right_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 角色详情单侧当前买卖单空态
class _TradeDepthColumnEmptyState extends StatelessWidget {
  /// 创建角色详情单侧当前买卖单空态
  ///
  /// [text] 空态文案
  const _TradeDepthColumnEmptyState({
    required this.text,
  });

  /// 空态文案
  final String text;

  /// 构建角色详情单侧当前买卖单空态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}

/// 角色详情当前买卖单空态
class _TradeDepthEmptyState extends StatelessWidget {
  /// 创建角色详情当前买卖单空态
  const _TradeDepthEmptyState();

  /// 构建角色详情当前买卖单空态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        '暂无买卖单',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}
