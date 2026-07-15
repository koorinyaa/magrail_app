part of 'auction_bid_sheet.dart';

/// 拍卖抽屉标题
class _AuctionBidSheetHeader extends StatelessWidget {
  /// 创建拍卖抽屉标题
  ///
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  const _AuctionBidSheetHeader({
    required this.characterId,
    required this.characterName,
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 构建拍卖抽屉标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return AppBottomSheetHeader(
      icon: LucideIcons.gavel,
      title: '拍卖',
      subtitle: '#$characterId「$characterName」',
    );
  }
}

/// 拍卖信息区
class _AuctionInfoSection extends StatelessWidget {
  /// 创建拍卖信息区
  ///
  /// [auction] 当前拍卖详情
  /// [maxAmount] 英灵殿数量
  /// [isLoading] 是否加载中
  /// [loadError] 加载失败文案
  const _AuctionInfoSection({
    required this.auction,
    required this.maxAmount,
    required this.isLoading,
    required this.loadError,
  });

  /// 当前拍卖详情
  final AuctionApiItem? auction;

  /// 英灵殿数量
  final int maxAmount;

  /// 是否加载中
  final bool isLoading;

  /// 加载失败文案
  final String? loadError;

  /// 构建拍卖信息区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final error = loadError;

    return _AuctionSectionBlock(
      title: isLoading ? '竞拍信息加载中' : '竞拍信息',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _AuctionMetricTile(
                  label: '竞拍人数',
                  value: Formatters.groupedNumber(auction?.state ?? 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AuctionMetricTile(
                  label: '竞拍数量',
                  value: Formatters.groupedNumber(auction?.type ?? 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AuctionMetricTile(
                  label: '英灵殿',
                  value: Formatters.groupedNumber(maxAmount),
                ),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            _AuctionInlineMessage(
              text: error,
              isError: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// 我的出价区
class _MyAuctionBidSection extends StatelessWidget {
  /// 创建我的出价区
  ///
  /// [auction] 当前拍卖详情
  const _MyAuctionBidSection({
    required this.auction,
  });

  /// 当前拍卖详情
  final AuctionApiItem? auction;

  /// 构建我的出价区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final auction = this.auction;
    final colorScheme = Theme.of(context).colorScheme;

    return _AuctionSectionBlock(
      title: '我的出价',
      child: Row(
        children: [
          Expanded(
            child: _AuctionMetricTile(
              label: '价格',
              value: Formatters.tinygrailCurrency(auction?.price ?? 0),
              accentColor: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _AuctionMetricTile(
              label: '数量',
              value: Formatters.groupedNumber(auction?.amount ?? 0),
              accentColor: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 拍卖信息区块
class _AuctionSectionBlock extends StatelessWidget {
  /// 创建拍卖信息区块
  ///
  /// [title] 区块标题
  /// [child] 区块内容
  const _AuctionSectionBlock({
    required this.title,
    required this.child,
  });

  /// 区块标题
  final String title;

  /// 区块内容
  final Widget child;

  /// 构建拍卖信息区块
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

/// 拍卖指标块
class _AuctionMetricTile extends StatelessWidget {
  /// 创建拍卖指标块
  ///
  /// [label] 指标标签
  /// [value] 指标数值
  /// [accentColor] 指标强调色
  const _AuctionMetricTile({
    required this.label,
    required this.value,
    this.accentColor,
  });

  /// 指标标签
  final String label;

  /// 指标数值
  final String value;

  /// 指标强调色
  final Color? accentColor;

  /// 构建拍卖指标块
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final valueColor = accentColor ?? colorScheme.onSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerLow.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.22 : 0.48,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 拍卖内联提示
class _AuctionInlineMessage extends StatelessWidget {
  /// 创建拍卖内联提示
  ///
  /// [text] 提示文本
  /// [isError] 是否为错误提示
  const _AuctionInlineMessage({
    required this.text,
    required this.isError,
  });

  /// 提示文本
  final String text;

  /// 是否为错误提示
  final bool isError;

  /// 构建拍卖内联提示
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor =
        isError ? colorScheme.error : colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: foregroundColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

/// 拍卖表面样式
abstract final class _AuctionSurfaceStyle {
  /// 创建拍卖表面装饰
  ///
  /// [context] 当前组件树上下文
  /// [radius] 表面圆角
  static BoxDecoration decoration(
    BuildContext context, {
    double radius = 18,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.42)
          : colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: colorScheme.outlineVariant.withValues(
          alpha: isDark ? 0.24 : 0.54,
        ),
      ),
    );
  }
}
