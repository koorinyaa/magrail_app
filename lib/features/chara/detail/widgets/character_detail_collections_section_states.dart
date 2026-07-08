part of 'character_detail_collections_section.dart';

/// 预览区失败状态
class _PreviewFailedState extends StatelessWidget {
  /// 创建预览区失败状态
  ///
  /// [message] 失败状态说明
  /// [onRetry] 重试回调
  const _PreviewFailedState({
    required this.message,
    required this.onRetry,
  });

  /// 失败状态说明
  final String message;

  /// 重试回调
  final VoidCallback onRetry;

  /// 构建预览区失败状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSafeAreaInsets.symmetricHorizontal(
        context,
        horizontal: 12,
      ),
      child: AppLoadFailedState(
        message: message,
        onActionPressed: onRetry,
      ),
    );
  }
}

/// LINK 预览骨架
class _LinkPreviewSkeleton extends StatelessWidget {
  /// 创建 LINK 预览骨架
  const _LinkPreviewSkeleton();

  /// 构建 LINK 预览骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SnappingHorizontalListView(
      height: CharacterDetailLinkCard.heightForWidth(
        CharacterDetailLinkCard.defaultWidth,
      ),
      itemCount: 2,
      itemExtent: CharacterDetailLinkCard.defaultWidth,
      separatorExtent: 12,
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 24,
        top: 0,
        right: 24,
        bottom: 0,
      ),
      itemBuilder: (context, index) {
        return const _LinkSkeletonCard(
          width: CharacterDetailLinkCard.defaultWidth,
        );
      },
    );
  }
}

/// 固定资产预览骨架
class _TemplePreviewSkeleton extends StatelessWidget {
  /// 创建固定资产预览骨架
  const _TemplePreviewSkeleton();

  /// 构建固定资产预览骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    const itemWidth = 156.0;

    return SnappingHorizontalListView(
      height: CharacterDetailTempleCard.heightForWidth(itemWidth),
      itemCount: 4,
      itemExtent: itemWidth,
      separatorExtent: 12,
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 24,
        top: 0,
        right: 24,
        bottom: 0,
      ),
      itemBuilder: (context, index) {
        return const _TempleSkeletonCard(width: itemWidth);
      },
    );
  }
}

/// LINK 预览骨架卡片
class _LinkSkeletonCard extends StatelessWidget {
  /// 创建 LINK 预览骨架卡片
  ///
  /// [width] 卡片宽度
  const _LinkSkeletonCard({
    required this.width,
  });

  /// 卡片宽度
  final double width;

  /// 构建 LINK 预览骨架卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone(
            width: width,
            height: CharacterDetailLinkCard.imageHeight *
                width /
                CharacterDetailLinkCard.defaultWidth,
            borderRadius: BorderRadius.circular(24),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Bone(
                width: 92,
                height: 20,
                borderRadius: BorderRadius.circular(999),
              ),
              const Spacer(),
              Bone(
                width: 66,
                height: 22,
                borderRadius: BorderRadius.circular(999),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 固定资产预览骨架卡片
class _TempleSkeletonCard extends StatelessWidget {
  /// 创建固定资产预览骨架卡片
  ///
  /// [width] 卡片宽度
  const _TempleSkeletonCard({
    required this.width,
  });

  /// 卡片宽度
  final double width;

  /// 构建固定资产预览骨架卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final coverHeight = width / 3 * 4;

    return Skeletonizer.zone(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone(
            width: width,
            height: coverHeight,
            borderRadius: BorderRadius.circular(24),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone(
                  width: width * 0.56,
                  height: 11,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 6),
                Bone(
                  width: width - 8,
                  height: 4,
                  borderRadius: BorderRadius.circular(999),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
