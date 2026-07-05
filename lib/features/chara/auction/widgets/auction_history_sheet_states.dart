part of 'auction_history_sheet.dart';

/// 往期拍卖分页指示器
class _AuctionHistoryPager extends StatelessWidget {
  /// 创建往期拍卖分页指示器
  ///
  /// [controller] 往期拍卖控制器
  const _AuctionHistoryPager({
    required this.controller,
  });

  static const int _dotCount = 5;

  /// 往期拍卖控制器
  final AuctionHistorySheetController controller;

  /// 构建往期拍卖分页指示器
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeIndex = _resolveActiveIndex();
    final activeColor = isDark
        ? Colors.white.withValues(alpha: 0.88)
        : Colors.black.withValues(alpha: 0.72);
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.16);

    return SizedBox(
      height: 22,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(_dotCount, (index) {
            final isActive = index == activeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                right: index == _dotCount - 1 ? 0 : 6,
              ),
              width: isActive ? 8 : 6,
              height: isActive ? 8 : 6,
              decoration: BoxDecoration(
                color: isActive ? activeColor : inactiveColor,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }

  /// 解析当前高亮圆点索引
  int _resolveActiveIndex() {
    if (controller.currentPage <= 1) {
      return 0;
    }

    if (controller.currentPage == 2) {
      return 1;
    }

    return 2;
  }
}

/// 往期拍卖加载状态
class _AuctionHistoryLoadingState extends StatelessWidget {
  /// 创建往期拍卖加载状态
  const _AuctionHistoryLoadingState();

  /// 构建往期拍卖加载状态
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      itemCount: 3,
      separatorBuilder: (context, index) => const _AuctionHistoryListDivider(),
      itemBuilder: (context, index) {
        return const _AuctionHistorySkeletonRow();
      },
    );
  }
}

/// 往期拍卖骨架条目
class _AuctionHistorySkeletonRow extends StatelessWidget {
  /// 创建往期拍卖骨架条目
  const _AuctionHistorySkeletonRow();

  /// 构建往期拍卖骨架条目
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final fillColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.12 : 0.07,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AuctionHistorySkeletonBlock(
                width: 156,
                height: 13,
                color: fillColor,
              ),
              const Spacer(),
              _AuctionHistorySkeletonBlock(
                width: 44,
                height: 21,
                radius: 999,
                color: fillColor,
              ),
            ],
          ),
          const SizedBox(height: 7),
          _AuctionHistorySkeletonBlock(
            width: 168,
            height: 12,
            color: fillColor,
          ),
        ],
      ),
    );
  }
}

/// 往期拍卖骨架占位块
class _AuctionHistorySkeletonBlock extends StatelessWidget {
  /// 创建往期拍卖骨架占位块
  ///
  /// [width] 占位宽度
  /// [height] 占位高度
  /// [radius] 占位圆角
  /// [color] 占位颜色
  const _AuctionHistorySkeletonBlock({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 8,
  });

  /// 占位宽度
  final double width;

  /// 占位高度
  final double height;

  /// 占位圆角
  final double radius;

  /// 占位颜色
  final Color color;

  /// 构建往期拍卖骨架占位块
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: SizedBox(
        width: width,
        height: height,
      ),
    );
  }
}

/// 往期拍卖失败状态
class _AuctionHistoryErrorState extends StatelessWidget {
  /// 创建往期拍卖失败状态
  ///
  /// [message] 失败文案
  /// [onRetry] 重试回调
  const _AuctionHistoryErrorState({
    required this.message,
    required this.onRetry,
  });

  /// 失败文案
  final String message;

  /// 重试回调
  final VoidCallback onRetry;

  /// 构建往期拍卖失败状态
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    return AppLoadFailedState(
      title: '读取失败',
      message: message,
      icon: LucideIcons.circleAlert,
      actionLabel: '重新加载',
      onActionPressed: onRetry,
    );
  }
}

/// 往期拍卖空状态
class _AuctionHistoryEmptyState extends StatelessWidget {
  /// 创建往期拍卖空状态
  const _AuctionHistoryEmptyState();

  /// 构建往期拍卖空状态
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    return const _AuctionHistoryStatePanel(
      icon: LucideIcons.inbox,
      title: '暂无拍卖记录',
      description: '向右滑动查看更早记录',
    );
  }
}

/// 往期拍卖状态面板
class _AuctionHistoryStatePanel extends StatelessWidget {
  /// 创建往期拍卖状态面板
  ///
  /// [icon] 状态图标
  /// [title] 状态标题
  /// [description] 状态说明
  const _AuctionHistoryStatePanel({
    required this.icon,
    required this.title,
    required this.description,
  });

  /// 状态图标
  final IconData icon;

  /// 状态标题
  final String title;

  /// 状态说明
  final String description;

  /// 构建往期拍卖状态面板
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: colorScheme.primary.withValues(alpha: 0.86),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
