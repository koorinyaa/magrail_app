import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/pagination_footer.dart';

/// 分页底部状态 sliver
class PaginationFooterSliver extends StatelessWidget {
  /// 创建分页底部状态 sliver
  ///
  /// [key] Flutter 组件标识
  /// [isLoadingMore] 是否正在加载下一页
  /// [hasLoadMoreError] 是否存在加载下一页错误
  /// [canLoadMore] 是否还有下一页
  /// [completedLabel] 全部加载完成文案
  /// [onRetry] 加载下一页重试回调
  const PaginationFooterSliver({
    super.key,
    required this.isLoadingMore,
    required this.hasLoadMoreError,
    required this.canLoadMore,
    required this.completedLabel,
    required this.onRetry,
  });

  /// 是否正在加载下一页
  final bool isLoadingMore;

  /// 是否存在加载下一页错误
  final bool hasLoadMoreError;

  /// 是否还有下一页
  final bool canLoadMore;

  /// 全部加载完成文案
  final String completedLabel;

  /// 加载下一页重试回调
  final VoidCallback onRetry;

  /// 构建分页底部状态 sliver
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: PaginationFooter(
        isLoadingMore: isLoadingMore,
        hasLoadMoreError: hasLoadMoreError,
        canLoadMore: canLoadMore,
        completedLabel: completedLabel,
        onRetry: onRetry,
      ),
    );
  }
}
