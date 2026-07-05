part of 'character_detail_trade_section.dart';

/// 显示角色详情成交记录底部抽屉
///
/// [context] 当前组件树上下文
/// [controller] 交易区控制器
Future<void> showCharacterDetailTradeRecordsSheet(
  BuildContext context, {
  required CharacterDetailTradeSectionController controller,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: BoxConstraints.tightFor(
      width: MediaQuery.sizeOf(context).width,
    ),
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      const topGap = 32.0;
      final availableHeight =
          mediaQuery.size.height - mediaQuery.padding.top - topGap;
      final heightCap = mediaQuery.size.height *
          (mediaQuery.orientation == Orientation.landscape ? 0.9 : 0.72);
      final maxHeight = availableHeight.clamp(0.0, heightCap).toDouble();

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: _TradeRecordsSheet(controller: controller),
      );
    },
  );
}

/// 角色详情成交记录底部抽屉
class _TradeRecordsSheet extends StatelessWidget {
  /// 创建角色详情成交记录底部抽屉
  ///
  /// [controller] 交易区控制器
  const _TradeRecordsSheet({
    required this.controller,
  });

  /// 交易区控制器
  final CharacterDetailTradeSectionController controller;

  /// 构建角色详情成交记录底部抽屉
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerLowest;

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.32 : 0.58,
                ),
              ),
            ),
          ),
          child: SafeArea(
            left: false,
            right: false,
            top: false,
            child: Padding(
              padding: AppSafeAreaInsets.fromLTRB(
                context,
                left: 20,
                top: 10,
                right: 20,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppBottomSheetDragHandle(),
                  const SizedBox(height: 14),
                  Flexible(
                    child: ListenableBuilder(
                      listenable: controller,
                      builder: (context, _) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _TradeRecordsHeader(),
                            const SizedBox(height: 12),
                            Flexible(
                              child: _TradeRecordsTabs(
                                bids: controller.bidTradeRecords,
                                asks: controller.askTradeRecords,
                              ),
                            ),
                          ],
                        );
                      },
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

/// 角色详情成交记录抽屉标题
class _TradeRecordsHeader extends StatelessWidget {
  /// 创建角色详情成交记录抽屉标题
  const _TradeRecordsHeader();

  /// 构建角色详情成交记录抽屉标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const _TradeSheetHeader(
      icon: LucideIcons.clipboardClock,
      title: '成交记录',
      subtitle: '最近20条成交记录',
    );
  }
}

/// 角色详情成交记录分页标签
class _TradeRecordsTabs extends StatelessWidget {
  /// 创建角色详情成交记录分页标签
  ///
  /// [bids] 买入成交列表
  /// [asks] 卖出成交列表
  const _TradeRecordsTabs({
    required this.bids,
    required this.asks,
  });

  /// 买入成交列表
  final List<CharacterDetailTradeHistoryOrder> bids;

  /// 卖出成交列表
  final List<CharacterDetailTradeHistoryOrder> asks;

  /// 构建角色详情成交记录分页标签
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TradeRecordsTabBar(),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              children: [
                _TradeRecordsList(
                  orders: asks,
                  isBid: false,
                  emptyText: '暂无卖出成交',
                ),
                _TradeRecordsList(
                  orders: bids,
                  isBid: true,
                  emptyText: '暂无买入成交',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 角色详情成交记录切换栏
class _TradeRecordsTabBar extends StatelessWidget {
  /// 创建角色详情成交记录切换栏
  const _TradeRecordsTabBar();

  /// 构建角色详情成交记录切换栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.36 : 0.58,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          labelColor: colorScheme.onSurface,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
          tabs: const [
            Tab(height: 30, text: '卖出'),
            Tab(height: 30, text: '买入'),
          ],
        ),
      ),
    );
  }
}

/// 角色详情单侧成交记录列表
class _TradeRecordsList extends StatelessWidget {
  /// 创建角色详情单侧成交记录列表
  ///
  /// [orders] 成交记录列表
  /// [isBid] 是否买入成交
  /// [emptyText] 空态文案
  const _TradeRecordsList({
    required this.orders,
    required this.isBid,
    required this.emptyText,
  });

  /// 成交记录列表
  final List<CharacterDetailTradeHistoryOrder> orders;

  /// 是否买入成交
  final bool isBid;

  /// 空态文案
  final String emptyText;

  /// 构建角色详情单侧成交记录列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final sortedOrders = orders.toList(growable: false)
      ..sort(_compareTradeRecordsByTime);

    if (sortedOrders.isEmpty) {
      return _TradeRecordsEmptyState(text: emptyText);
    }

    return ListView.separated(
      primary: false,
      padding: EdgeInsets.zero,
      itemCount: sortedOrders.length,
      separatorBuilder: (context, index) => const _TradeOrdersDivider(),
      itemBuilder: (context, index) {
        return _TradeRecordRow(
          order: sortedOrders[index],
          isBid: isBid,
        );
      },
    );
  }
}

/// 按成交时间倒序比较成交记录
///
/// [left] 左侧成交记录
/// [right] 右侧成交记录
int _compareTradeRecordsByTime(
  CharacterDetailTradeHistoryOrder left,
  CharacterDetailTradeHistoryOrder right,
) {
  final leftTime = TinygrailFormatters.parseServerTime(left.tradeTime);
  final rightTime = TinygrailFormatters.parseServerTime(right.tradeTime);
  if (leftTime != null && rightTime != null) {
    return rightTime.compareTo(leftTime);
  }

  return right.tradeTime.compareTo(left.tradeTime);
}

/// 角色详情成交记录行
class _TradeRecordRow extends StatelessWidget {
  /// 创建角色详情成交记录行
  ///
  /// [order] 历史成交委托
  /// [isBid] 是否买入成交
  const _TradeRecordRow({
    required this.order,
    required this.isBid,
  });

  /// 历史成交委托
  final CharacterDetailTradeHistoryOrder order;

  /// 是否买入成交
  final bool isBid;

  /// 构建角色详情成交记录行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sideColor = isBid ? _tradeBuyColor : _tradeSellColor;
    final totalText = Formatters.tinygrailCompactValue(
      order.total,
      prefix: isBid ? '-₵' : '+₵',
    );
    final orderValuesText =
        '${Formatters.tinygrailCurrency(order.price)} / ${Formatters.groupedNumber(order.amount)}股';
    final timeText = TinygrailFormatters.relativeTime(order.tradeTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: sideColor.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 10,
                height: 10,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: sideColor,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(width: 5, height: 5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        totalText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: sideColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
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
                              timeText,
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
                Text(
                  orderValuesText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 角色详情成交记录空态
class _TradeRecordsEmptyState extends StatelessWidget {
  /// 创建角色详情成交记录空态
  ///
  /// [text] 空态文案
  const _TradeRecordsEmptyState({
    required this.text,
  });

  /// 空态文案
  final String text;

  /// 构建角色详情成交记录空态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        text,
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
