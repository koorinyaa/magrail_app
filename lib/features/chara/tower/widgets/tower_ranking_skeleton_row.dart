import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 通天塔排名行骨架
class TowerRankingSkeletonRow extends StatelessWidget {
  /// 创建通天塔排名行骨架
  ///
  /// [key] Flutter 组件标识
  const TowerRankingSkeletonRow({super.key});

  /// 构建通天塔排名行骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Skeletonizer.zone(
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              SizedBox(
                width: 34,
                child: Center(
                  child: Bone(
                    width: 24,
                    height: 22,
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                ),
              ),
              SizedBox(width: 5),
              Bone(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Bone(
                            width: 92,
                            height: 15,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                        SizedBox(width: 6),
                        Bone(
                          width: 34,
                          height: 16,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ],
                    ),
                    SizedBox(height: 7),
                    Row(
                      children: [
                        Bone(
                          width: 12,
                          height: 12,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        SizedBox(width: 4),
                        Bone(
                          width: 12,
                          height: 12,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        SizedBox(width: 4),
                        Bone(
                          width: 12,
                          height: 12,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Bone(
                width: 72,
                height: 24,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
