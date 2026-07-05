part of 'character_trade_history_sheet.dart';

/// 角色交易记录标题区
class _CharacterTradeHistoryHeader extends StatelessWidget {
  /// 创建角色交易记录标题区
  ///
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  const _CharacterTradeHistoryHeader({
    required this.characterId,
    required this.characterName,
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 构建角色交易记录标题区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = _displayName;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            LucideIcons.clipboardClock,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '交易记录',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '#$characterId 「$displayName」',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 角色展示名称
  String get _displayName {
    final name = TinygrailFormatters.decodeHtmlEntities(characterName).trim();
    return name.isEmpty ? '角色' : name;
  }
}

/// 角色交易记录主体内容
class _CharacterTradeHistoryBody extends StatelessWidget {
  /// 创建角色交易记录主体内容
  ///
  /// [controller] 角色交易记录控制器
  const _CharacterTradeHistoryBody({
    required this.controller,
  });

  /// 角色交易记录控制器
  final CharacterTradeHistorySheetController controller;

  /// 构建角色交易记录主体内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.items.isEmpty) {
      return const _CharacterTradeHistoryLoadingState();
    }

    final loadError = controller.loadError;
    if (loadError != null && controller.items.isEmpty) {
      return _CharacterTradeHistoryErrorState(
        message: loadError,
        onRetry: () => unawaited(controller.reload()),
      );
    }

    final items = controller.items;
    if (items.isEmpty) {
      return const _CharacterTradeHistoryEmptyState();
    }

    return ListView.separated(
      primary: false,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          const _CharacterTradeHistoryListDivider(),
      itemBuilder: (context, index) {
        return _CharacterTradeHistoryRow(item: items[index]);
      },
    );
  }
}

/// 角色交易记录条目
class _CharacterTradeHistoryRow extends StatelessWidget {
  /// 创建角色交易记录条目
  ///
  /// [item] 角色交易记录图表接口条目
  const _CharacterTradeHistoryRow({
    required this.item,
  });

  /// 角色交易记录图表接口条目
  final CharacterTradeHistoryItem item;

  /// 构建角色交易记录条目
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unitPriceText = Formatters.tinygrailCurrency(item.unitPrice);
    final amountText = Formatters.groupedNumber(item.amount);
    final totalText = Formatters.tinygrailCurrency(item.price);
    final valueText = '$unitPriceText / $amountText股';
    final timeText = TinygrailFormatters.relativeTime(item.time);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  totalText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
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
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.58),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        timeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.62,
                          ),
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
                  valueText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.62),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 角色交易记录列表分割线
class _CharacterTradeHistoryListDivider extends StatelessWidget {
  /// 创建角色交易记录列表分割线
  const _CharacterTradeHistoryListDivider();

  /// 构建角色交易记录列表分割线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Divider(
      height: 1,
      thickness: 0.6,
      color: colorScheme.outlineVariant.withValues(
        alpha: isDark ? 0.32 : 0.56,
      ),
    );
  }
}
