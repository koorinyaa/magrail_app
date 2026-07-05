part of 'top_week_section.dart';

/// 每周萌王骨架轮播
class _TopWeekSkeletonCarousel extends StatelessWidget {
  /// 创建每周萌王骨架轮播
  const _TopWeekSkeletonCarousel();

  /// 构建每周萌王骨架轮播
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SnappingHorizontalListView(
      height: 364,
      itemCount: 3,
      itemExtent: _TopWeekCard.cardWidth,
      separatorExtent: 12,
      padding: AppSafeAreaInsets.symmetricHorizontal(
        context,
        horizontal: 24,
        vertical: 6,
      ),
      clipBehavior: Clip.none,
      itemBuilder: (context, index) => const _TopWeekSkeletonCard(),
    );
  }
}

/// 每周萌王骨架卡片
class _TopWeekSkeletonCard extends StatelessWidget {
  /// 创建每周萌王骨架卡片
  const _TopWeekSkeletonCard();

  /// 构建每周萌王骨架卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _TopWeekCard.cardWidth,
      child: AspectRatio(
        aspectRatio: _TopWeekCard.cardAspectRatio,
        child: Skeletonizer.zone(
          child: Bone(
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.circular(_TopWeekCard.cardRadius),
          ),
        ),
      ),
    );
  }
}
