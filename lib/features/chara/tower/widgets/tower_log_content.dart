part of 'tower_log_panel.dart';

/// 通天塔日志内容
class _TowerLogContent {
  /// 创建通天塔日志内容
  ///
  /// [controller] 通天塔日志控制器
  /// [onHistoryItemBuilt] 历史日志条目构建回调
  const _TowerLogContent({
    required this.controller,
    required this.onHistoryItemBuilt,
  });

  /// 通天塔日志控制器
  final TowerLogController controller;

  /// 历史日志条目构建回调
  final ValueChanged<int> onHistoryItemBuilt;

  /// 构建通天塔日志 Sliver 内容
  ///
  /// [context] 当前组件树上下文
  List<Widget> buildSlivers(BuildContext context) {
    final realtimeItems = controller.realtimeItems;
    final historyItems = controller.historyItems;
    final hasLargeRealtimeUpdate = controller.hasLargeRealtimeUpdate;
    final hasRealtimeDivider =
        realtimeItems.isNotEmpty && historyItems.isNotEmpty;

    if (controller.isInitialLoading) {
      return [
        const _TowerLogSkeletonSliverList(),
      ];
    }

    if (controller.initialError != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _TowerLogErrorState(
            onRetry: () => controller.loadPage(1, force: true),
          ),
        ),
      ];
    }

    if (realtimeItems.isEmpty &&
        historyItems.isEmpty &&
        !hasLargeRealtimeUpdate) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: _TowerLogEmptyState(),
        ),
      ];
    }

    return [
      SliverList.builder(
        itemCount: realtimeItems.length +
            (hasRealtimeDivider ? 1 : 0) +
            historyItems.length +
            1,
        itemBuilder: (context, index) {
          var cursor = index;

          if (cursor < realtimeItems.length) {
            return _TowerLogSeparatedItem(
              item: realtimeItems[cursor],
              showDivider: cursor < realtimeItems.length - 1,
            );
          }

          cursor -= realtimeItems.length;

          if (hasRealtimeDivider) {
            if (cursor == 0) {
              return _TowerLogRealtimeDivider(count: realtimeItems.length);
            }

            cursor -= 1;
          }

          if (cursor < historyItems.length) {
            onHistoryItemBuilt(cursor);
            return _TowerLogSeparatedItem(
              item: historyItems[cursor],
              showDivider: cursor < historyItems.length - 1,
            );
          }

          if (cursor == historyItems.length) {
            return _TowerLogFooter(controller: controller);
          }

          return const SizedBox.shrink();
        },
      ),
    ];
  }
}

/// 通天塔日志骨架 Sliver 列表
class _TowerLogSkeletonSliverList extends StatelessWidget {
  /// 创建通天塔日志骨架 Sliver 列表
  const _TowerLogSkeletonSliverList();

  /// 构建通天塔日志骨架 Sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: 10,
      separatorBuilder: (context, index) => const _TowerLogDivider(),
      itemBuilder: (context, index) {
        return const _TowerLogSkeletonRow();
      },
    );
  }
}

/// 通天塔日志带分割线条目
class _TowerLogSeparatedItem extends StatelessWidget {
  /// 创建通天塔日志带分割线条目
  ///
  /// [item] 通天塔日志接口条目
  /// [showDivider] 是否显示底部分割线
  const _TowerLogSeparatedItem({
    required this.item,
    required this.showDivider,
  });

  /// 通天塔日志接口条目
  final TowerLogApiItem item;

  /// 是否显示底部分割线
  final bool showDivider;

  /// 构建通天塔日志带分割线条目
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TowerLogItem(item: item),
        if (showDivider) const _TowerLogDivider(),
      ],
    );
  }
}

/// 通天塔日志列表分割线
class _TowerLogDivider extends StatelessWidget {
  /// 创建通天塔日志列表分割线
  const _TowerLogDivider();

  /// 构建通天塔日志列表分割线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: _towerLogDividerIndent,
        top: 0,
        right: _towerLogHorizontalPadding,
        bottom: 0,
      ),
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: colorScheme.outlineVariant.withValues(
          alpha: isDark ? 0.32 : 0.58,
        ),
      ),
    );
  }
}
