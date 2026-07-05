part of 'temple_asset_card.dart';

/// 圣殿资产骨架指标区
class _TempleAssetSkeletonMetrics extends StatelessWidget {
  /// 创建圣殿资产骨架指标区
  const _TempleAssetSkeletonMetrics();

  /// 构建圣殿资产骨架指标区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TempleAssetSkeletonSummary(),
        _TempleAssetSkeletonProgress(),
      ],
    );
  }
}

/// 圣殿资产骨架主信息区
class _TempleAssetSkeletonSummary extends StatelessWidget {
  /// 创建圣殿资产骨架主信息区
  const _TempleAssetSkeletonSummary();

  /// 构建圣殿资产骨架主信息区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 3),
        Align(
          alignment: Alignment.centerLeft,
          child: Bone(
            width: 132,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        SizedBox(height: 7),
        Align(
          alignment: Alignment.centerLeft,
          child: Bone(
            width: 72,
            height: 10,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.start,
          runSpacing: 3,
          spacing: 6,
          children: [
            Bone(
              width: 84,
              height: 20,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            Bone(
              width: 78,
              height: 20,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            Bone(
              width: 88,
              height: 20,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            Bone(
              width: 74,
              height: 20,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ],
        ),
      ],
    );
  }
}

/// 圣殿资产骨架进度区
class _TempleAssetSkeletonProgress extends StatelessWidget {
  /// 创建圣殿资产骨架进度区
  const _TempleAssetSkeletonProgress();

  /// 构建圣殿资产骨架进度区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Bone(
              width: 116,
              height: 11,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),
          SizedBox(height: 6),
          Bone(
            width: double.infinity,
            height: 4,
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
        ],
      ),
    );
  }
}
