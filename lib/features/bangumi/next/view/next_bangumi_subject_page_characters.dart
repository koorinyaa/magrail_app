part of 'next_bangumi_subject_page.dart';

/// Next Bangumi 条目详情角色区
class _NextBangumiSubjectCharacterSection extends StatelessWidget {
  /// 创建 Next Bangumi 条目详情角色区
  ///
  /// [items] 条目角色列表
  /// [statuses] 小圣杯角色状态
  /// [isInitialLoading] 是否正在首次加载
  /// [initialError] 首次加载错误文案
  /// [isLoadingMore] 是否正在加载下一页
  /// [hasLoadMoreError] 是否存在下一页加载错误
  /// [canLoadMore] 是否还有下一页
  /// [onRetryInitial] 首次加载重试回调
  /// [onRetryMore] 下一页重试回调
  /// [onItemBuilt] 条目构建回调
  /// [onItemTap] 条目点击回调
  const _NextBangumiSubjectCharacterSection({
    required this.items,
    required this.statuses,
    required this.isInitialLoading,
    required this.initialError,
    required this.isLoadingMore,
    required this.hasLoadMoreError,
    required this.canLoadMore,
    required this.onRetryInitial,
    required this.onRetryMore,
    required this.onItemBuilt,
    required this.onItemTap,
  });

  /// 条目角色列表
  final List<NextBangumiSubjectCharacterItem> items;

  /// 小圣杯角色状态
  final Map<int, CharacterDetailBasicInfo> statuses;

  /// 是否正在首次加载
  final bool isInitialLoading;

  /// 首次加载错误文案
  final String initialError;

  /// 是否正在加载下一页
  final bool isLoadingMore;

  /// 是否存在下一页加载错误
  final bool hasLoadMoreError;

  /// 是否还有下一页
  final bool canLoadMore;

  /// 首次加载重试回调
  final VoidCallback onRetryInitial;

  /// 下一页重试回调
  final VoidCallback onRetryMore;

  /// 条目构建回调
  final ValueChanged<int> onItemBuilt;

  /// 条目点击回调
  final ValueChanged<NextBangumiSubjectCharacterItem> onItemTap;

  /// 构建 Next Bangumi 条目详情角色区
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        const PageSectionSliver(
          title: '角色',
          topSpacing: 24,
          child: SizedBox.shrink(),
        ),
        if (isInitialLoading)
          const _NextBangumiSubjectCharacterSkeletonGrid()
        else if (initialError.isNotEmpty)
          _NextBangumiSubjectCharacterErrorSliver(
            message: initialError,
            onRetry: onRetryInitial,
          )
        else if (items.isEmpty)
          const _NextBangumiSubjectCharacterEmptySliver()
        else ...[
          _NextBangumiSubjectCharacterGrid(
            items: items,
            statuses: statuses,
            onItemBuilt: onItemBuilt,
            onItemTap: onItemTap,
          ),
          PaginationFooterSliver(
            isLoadingMore: isLoadingMore,
            hasLoadMoreError: hasLoadMoreError,
            canLoadMore: canLoadMore,
            completedLabel: '没有更多角色了',
            onRetry: onRetryMore,
          ),
        ],
        const _NextBangumiSubjectCharacterBottomSpacer(),
      ],
    );
  }
}

/// Next Bangumi 条目角色网格
class _NextBangumiSubjectCharacterGrid extends StatelessWidget {
  /// 创建 Next Bangumi 条目角色网格
  ///
  /// [items] 条目角色列表
  /// [statuses] 小圣杯角色状态
  /// [onItemBuilt] 条目构建回调
  /// [onItemTap] 条目点击回调
  const _NextBangumiSubjectCharacterGrid({
    required this.items,
    required this.statuses,
    required this.onItemBuilt,
    required this.onItemTap,
  });

  /// 条目角色列表
  final List<NextBangumiSubjectCharacterItem> items;

  /// 小圣杯角色状态
  final Map<int, CharacterDetailBasicInfo> statuses;

  /// 条目构建回调
  final ValueChanged<int> onItemBuilt;

  /// 条目点击回调
  final ValueChanged<NextBangumiSubjectCharacterItem> onItemTap;

  /// 构建 Next Bangumi 条目角色网格
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 16,
        top: 2,
        right: 16,
        bottom: 0,
      ),
      sliver: SliverGrid(
        gridDelegate: _NextBangumiSubjectCharacterGridMetrics.delegate,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            onItemBuilt(index);
            return NextBangumiCharacterGridItem(
              item: item,
              status: statuses[item.characterId],
              onTap: () => onItemTap(item),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

/// Next Bangumi 条目角色骨架网格
class _NextBangumiSubjectCharacterSkeletonGrid extends StatelessWidget {
  /// 创建 Next Bangumi 条目角色骨架网格
  const _NextBangumiSubjectCharacterSkeletonGrid();

  /// 构建 Next Bangumi 条目角色骨架网格
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 16,
        top: 2,
        right: 16,
        bottom: 0,
      ),
      sliver: SliverGrid(
        gridDelegate: _NextBangumiSubjectCharacterGridMetrics.delegate,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return const _NextBangumiSubjectCharacterSkeletonTile();
          },
          childCount: _NextBangumiSubjectPageState._subjectCharacterPageSize,
        ),
      ),
    );
  }
}

/// Next Bangumi 条目角色骨架卡片
class _NextBangumiSubjectCharacterSkeletonTile extends StatelessWidget {
  /// 创建 Next Bangumi 条目角色骨架卡片
  const _NextBangumiSubjectCharacterSkeletonTile();

  /// 构建 Next Bangumi 条目角色骨架卡片
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Skeletonizer.zone(
        child: SizedBox(
          width: 104,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Bone(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              SizedBox(height: 8),
              Bone(
                width: 52,
                height: 12,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              SizedBox(height: 5),
              Bone(
                width: 28,
                height: 15,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              SizedBox(height: 5),
              Bone(
                width: 38,
                height: 10,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Next Bangumi 条目角色失败状态
class _NextBangumiSubjectCharacterErrorSliver extends StatelessWidget {
  /// 创建 Next Bangumi 条目角色失败状态
  ///
  /// [message] 失败文案
  /// [onRetry] 重试回调
  const _NextBangumiSubjectCharacterErrorSliver({
    required this.message,
    required this.onRetry,
  });

  /// 失败文案
  final String message;

  /// 重试回调
  final VoidCallback onRetry;

  /// 构建 Next Bangumi 条目角色失败状态
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: AppSafeAreaInsets.symmetricHorizontal(
          context,
          horizontal: 16,
        ),
        child: AppLoadFailedState(
          message: message,
          onActionPressed: onRetry,
        ),
      ),
    );
  }
}

/// Next Bangumi 条目角色空状态
class _NextBangumiSubjectCharacterEmptySliver extends StatelessWidget {
  /// 创建 Next Bangumi 条目角色空状态
  const _NextBangumiSubjectCharacterEmptySliver();

  /// 构建 Next Bangumi 条目角色空状态
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: AppSafeAreaInsets.fromLTRB(
          context,
          left: 24,
          top: 8,
          right: 24,
          bottom: 16,
        ),
        child: Text(
          '暂无角色',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Next Bangumi 条目角色底部留白
class _NextBangumiSubjectCharacterBottomSpacer extends StatelessWidget {
  /// 创建 Next Bangumi 条目角色底部留白
  const _NextBangumiSubjectCharacterBottomSpacer();

  /// 构建 Next Bangumi 条目角色底部留白
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
    );
  }
}

/// Next Bangumi 条目角色网格尺寸
final class _NextBangumiSubjectCharacterGridMetrics {
  /// 禁止创建 Next Bangumi 条目角色网格尺寸实例
  const _NextBangumiSubjectCharacterGridMetrics._();

  /// 条目角色网格代理
  static const SliverGridDelegateWithMaxCrossAxisExtent delegate =
      SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 118,
    mainAxisExtent: 136,
    mainAxisSpacing: 14,
    crossAxisSpacing: 10,
  );
}
