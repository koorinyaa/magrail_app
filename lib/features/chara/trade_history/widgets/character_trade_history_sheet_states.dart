part of 'character_trade_history_sheet.dart';

/// 角色交易记录加载状态
class _CharacterTradeHistoryLoadingState extends StatelessWidget {
  /// 创建角色交易记录加载状态
  const _CharacterTradeHistoryLoadingState();

  /// 构建角色交易记录加载状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      itemCount: 5,
      separatorBuilder: (context, index) =>
          const _CharacterTradeHistoryListDivider(),
      itemBuilder: (context, index) {
        return const _CharacterTradeHistorySkeletonRow();
      },
    );
  }
}

/// 角色交易记录骨架条目
class _CharacterTradeHistorySkeletonRow extends StatelessWidget {
  /// 创建角色交易记录骨架条目
  const _CharacterTradeHistorySkeletonRow();

  /// 构建角色交易记录骨架条目
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final fillColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.12 : 0.07,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CharacterTradeHistorySkeletonBlock(
                width: 132,
                height: 14,
                color: fillColor,
              ),
              const Spacer(),
              _CharacterTradeHistorySkeletonBlock(
                width: 12,
                height: 12,
                radius: 999,
                color: fillColor,
              ),
              const SizedBox(width: 4),
              _CharacterTradeHistorySkeletonBlock(
                width: 64,
                height: 11,
                color: fillColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _CharacterTradeHistorySkeletonBlock(
            width: 128,
            height: 11,
            color: fillColor,
          ),
        ],
      ),
    );
  }
}

/// 角色交易记录骨架占位块
class _CharacterTradeHistorySkeletonBlock extends StatelessWidget {
  /// 创建角色交易记录骨架占位块
  ///
  /// [width] 占位宽度
  /// [height] 占位高度
  /// [color] 占位颜色
  /// [radius] 占位圆角
  const _CharacterTradeHistorySkeletonBlock({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 8,
  });

  /// 占位宽度
  final double width;

  /// 占位高度
  final double height;

  /// 占位颜色
  final Color color;

  /// 占位圆角
  final double radius;

  /// 构建角色交易记录骨架占位块
  ///
  /// [context] 当前组件树上下文
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

/// 角色交易记录失败状态
class _CharacterTradeHistoryErrorState extends StatelessWidget {
  /// 创建角色交易记录失败状态
  ///
  /// [message] 失败文案
  /// [onRetry] 重试回调
  const _CharacterTradeHistoryErrorState({
    required this.message,
    required this.onRetry,
  });

  /// 失败文案
  final String message;

  /// 重试回调
  final VoidCallback onRetry;

  /// 构建角色交易记录失败状态
  ///
  /// [context] 当前组件树上下文
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

/// 角色交易记录空状态
class _CharacterTradeHistoryEmptyState extends StatelessWidget {
  /// 创建角色交易记录空状态
  const _CharacterTradeHistoryEmptyState();

  /// 构建角色交易记录空状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const _CharacterTradeHistoryStatePanel(
      icon: LucideIcons.inbox,
      title: '暂无交易记录',
      description: '当前角色还没有可展示的交易记录',
    );
  }
}

/// 角色交易记录状态面板
class _CharacterTradeHistoryStatePanel extends StatelessWidget {
  /// 创建角色交易记录状态面板
  ///
  /// [icon] 状态图标
  /// [title] 状态标题
  /// [description] 状态说明
  const _CharacterTradeHistoryStatePanel({
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

  /// 构建角色交易记录状态面板
  ///
  /// [context] 当前组件树上下文
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
