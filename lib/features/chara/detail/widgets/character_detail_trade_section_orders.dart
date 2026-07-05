part of 'character_detail_trade_section.dart';

/// 显示角色详情当前委托底部抽屉
///
/// [context] 当前组件树上下文
/// [controller] 交易区控制器
/// [onOrderCancelled] 委托取消后的刷新回调
Future<void> showCharacterDetailTradeOrdersSheet(
  BuildContext context, {
  required CharacterDetailTradeSectionController controller,
  required Future<void> Function() onOrderCancelled,
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
        child: _TradeOrdersSheet(
          controller: controller,
          onOrderCancelled: onOrderCancelled,
        ),
      );
    },
  );
}

/// 角色详情当前委托底部抽屉
class _TradeOrdersSheet extends StatelessWidget {
  /// 创建角色详情当前委托底部抽屉
  ///
  /// [controller] 交易区控制器
  /// [onOrderCancelled] 委托取消后的刷新回调
  const _TradeOrdersSheet({
    required this.controller,
    required this.onOrderCancelled,
  });

  /// 交易区控制器
  final CharacterDetailTradeSectionController controller;

  /// 委托取消后的刷新回调
  final Future<void> Function() onOrderCancelled;

  /// 构建角色详情当前委托底部抽屉
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
                        final trading = controller.trading;
                        final bids = trading.activeBids.toList(
                          growable: false,
                        );
                        final asks = trading.activeAsks.toList(
                          growable: false,
                        );

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _TradeOrdersHeader(
                              bidCount: bids.length,
                              askCount: asks.length,
                            ),
                            const SizedBox(height: 12),
                            Flexible(
                              child: _TradeOrdersList(
                                controller: controller,
                                bids: bids,
                                asks: asks,
                                onOrderCancelled: onOrderCancelled,
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
