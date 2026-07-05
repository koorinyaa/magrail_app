part of 'user_share_bonus_forecast_sheet.dart';

/// 股息预测加载骨架
class _ShareBonusForecastSkeleton extends StatelessWidget {
  /// 创建股息预测加载骨架
  const _ShareBonusForecastSkeleton();

  // 与真实摘要区文本行高和内边距对齐，避免加载完成后抽屉高度跳动
  static const double _summaryHeight = 106.3;

  /// 构建股息预测加载骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SkeletonBlock(height: _summaryHeight),
        SizedBox(height: 12),
        _SkeletonBlock(height: 152),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SkeletonStatTile(),
            _SkeletonStatTile(),
            _SkeletonStatTile(),
            _SkeletonStatTile(),
            _SkeletonStatTile(),
            _SkeletonStatTile(),
          ],
        ),
      ],
    );
  }
}

/// 骨架块
class _SkeletonBlock extends StatelessWidget {
  /// 创建骨架块
  ///
  /// [height] 骨架高度
  const _SkeletonBlock({
    required this.height,
  });

  /// 骨架高度
  final double height;

  /// 构建骨架块
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.26 : 0.36,
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(height: height),
    );
  }
}

/// 明细骨架卡片
class _SkeletonStatTile extends StatelessWidget {
  /// 创建明细骨架卡片
  const _SkeletonStatTile();

  // 与真实明细卡片文本行高和内边距对齐，避免网格区域高度变化
  static const double _tileHeight = 56;

  /// 构建明细骨架卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width -
            AppSafeAreaInsets.horizontalSum(context) -
            48) /
        2;

    return SizedBox(
      width: width,
      child: const _SkeletonBlock(height: _tileHeight),
    );
  }
}

/// 股息预测失败状态
class _ShareBonusForecastError extends StatelessWidget {
  /// 创建股息预测失败状态
  ///
  /// [message] 失败文案
  /// [onRetry] 重试回调
  const _ShareBonusForecastError({
    required this.message,
    required this.onRetry,
  });

  /// 失败文案
  final String message;

  /// 重试回调
  final VoidCallback onRetry;

  /// 构建股息预测失败状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return AppLoadFailedState(
      message: message,
      icon: Icons.error_outline_rounded,
      actionLabel: '重新加载',
      onActionPressed: onRetry,
    );
  }
}
