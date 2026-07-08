part of 'tower_log_panel.dart';

/// 通天塔日志底部状态
class _TowerLogFooter extends StatelessWidget {
  /// 创建通天塔日志底部状态
  ///
  /// [controller] 通天塔日志控制器
  const _TowerLogFooter({
    required this.controller,
  });

  final TowerLogController controller;

  /// 构建通天塔日志底部状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (controller.hasLargeRealtimeUpdate) {
      return _TowerLogExpiredFooter(
        onRefresh: controller.refreshLatest,
      );
    }

    return PaginationFooter(
      isLoadingMore: controller.isLoadingMore,
      hasLoadMoreError: controller.loadMoreError != null,
      canLoadMore: controller.canLoadMore,
      completedLabel: '没有更多日志了',
      onRetry: controller.loadNextPage,
    );
  }
}

/// 通天塔日志分页过期底部提示
class _TowerLogExpiredFooter extends StatelessWidget {
  /// 创建通天塔日志分页过期底部提示
  ///
  /// [onRefresh] 刷新最新日志回调
  const _TowerLogExpiredFooter({
    required this.onRefresh,
  });

  final VoidCallback onRefresh;

  /// 构建通天塔日志分页过期底部提示
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: _towerLogHorizontalPadding,
        top: 10,
        right: _towerLogHorizontalPadding,
        bottom: 10,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.36)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '新日志较多，当前分页已过期',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 32,
                child: TextButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('刷新'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 通天塔日志大量更新提示
class _TowerLogLargeUpdateBanner extends StatelessWidget {
  /// 创建通天塔日志大量更新提示
  ///
  /// [count] 待刷新的实时日志数量
  /// [onRefresh] 刷新回调
  const _TowerLogLargeUpdateBanner({
    required this.count,
    required this.onRefresh,
  });

  final int count;
  final VoidCallback onRefresh;

  /// 构建通天塔日志大量更新提示
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.54)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$count 条新日志，刷新查看最新列表',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 32,
            child: TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('刷新'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 通天塔日志实时分隔线
class _TowerLogRealtimeDivider extends StatelessWidget {
  /// 创建通天塔日志实时分隔线
  ///
  /// [count] 已显示的实时日志数量
  const _TowerLogRealtimeDivider({
    required this.count,
  });

  final int count;

  /// 构建通天塔日志实时分隔线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lineColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.22);

    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: lineColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '已更新 $count 条新日志',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: lineColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// 通天塔日志条目骨架
class _TowerLogSkeletonRow extends StatelessWidget {
  /// 创建通天塔日志条目骨架
  const _TowerLogSkeletonRow();

  /// 构建通天塔日志条目骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: AppSafeAreaInsets.symmetricHorizontal(
            context,
            horizontal: _towerLogHorizontalPadding,
            vertical: 8,
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Bone(
                width: _towerLogAvatarSize,
                height: _towerLogAvatarSize,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              SizedBox(width: _towerLogAvatarTextGap),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Bone(
                            width: 98,
                            height: 14,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                        SizedBox(width: 6),
                        Bone(
                          width: 34,
                          height: 16,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        SizedBox(width: 3),
                        Bone(
                          width: 28,
                          height: 16,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ],
                    ),
                    SizedBox(height: 7),
                    Row(
                      children: [
                        Bone(
                          width: 46,
                          height: 13,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Bone(
                            width: 58,
                            height: 13,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                        SizedBox(width: 4),
                        Bone(
                          width: 42,
                          height: 13,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Bone(
                width: 38,
                height: 12,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              SizedBox(width: 6),
              SizedBox(
                width: 20,
                child: Center(
                  child: Bone(
                    width: 16,
                    height: 16,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 通天塔日志加载错误状态
class _TowerLogErrorState extends StatelessWidget {
  /// 创建通天塔日志加载错误状态
  ///
  /// [onRetry] 重试回调
  const _TowerLogErrorState({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  /// 构建通天塔日志加载错误状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppLoadFailedState(
        title: '通天塔日志加载失败',
        message: '请检查网络后重试',
        onActionPressed: onRetry,
      ),
    );
  }
}

/// 通天塔日志空状态
class _TowerLogEmptyState extends StatelessWidget {
  /// 创建通天塔日志空状态
  const _TowerLogEmptyState();

  /// 构建通天塔日志空状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        '暂无日志',
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
