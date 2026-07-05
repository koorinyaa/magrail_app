import 'package:flutter/material.dart';
import 'package:magrail_app/features/temple/widgets/latest_link_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 最新连接加载骨架卡片
class LatestLinkSkeletonCard extends StatelessWidget {
  /// 创建最新连接加载骨架卡片
  ///
  /// [width] 卡片宽度
  const LatestLinkSkeletonCard({
    super.key,
    required this.width,
  });

  /// 卡片宽度
  final double width;

  /// 构建最新连接加载骨架卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: SizedBox(
        width: width,
        height: LatestLinkCard.heightForWidth(width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Bone(
              width: width,
              height: LatestLinkCard.imageHeightForWidth(width),
              borderRadius: BorderRadius.circular(LatestLinkCard.imageRadius),
            ),
            const SizedBox(height: 11),
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Bone(
                width: 78,
                height: 12,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
