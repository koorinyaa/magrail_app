part of 'character_detail_trade_section.dart';

/// 角色详情交易抽屉标题
class _TradeSheetHeader extends StatelessWidget {
  /// 创建角色详情交易抽屉标题
  ///
  /// [icon] 标题图标
  /// [title] 主标题
  /// [subtitle] 副标题
  const _TradeSheetHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  /// 标题图标
  final IconData icon;

  /// 主标题
  final String title;

  /// 副标题
  final String subtitle;

  /// 构建角色详情交易抽屉标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            icon,
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
                title,
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
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 角色详情当前委托抽屉标题
class _TradeOrdersHeader extends StatelessWidget {
  /// 创建角色详情当前委托抽屉标题
  ///
  /// [bidCount] 当前买入委托数量
  /// [askCount] 当前卖出委托数量
  const _TradeOrdersHeader({
    required this.bidCount,
    required this.askCount,
  });

  /// 当前买入委托数量
  final int bidCount;

  /// 当前卖出委托数量
  final int askCount;

  /// 构建角色详情当前委托抽屉标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _TradeSheetHeader(
      icon: LucideIcons.clipboardList,
      title: '我的委托',
      subtitle: _subtitle,
    );
  }

  /// 当前委托副标题
  String get _subtitle {
    if (bidCount <= 0 && askCount <= 0) {
      return '暂无委托';
    }

    return '买入委托$bidCount条 / 卖出委托$askCount条';
  }
}
