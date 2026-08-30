import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 角色资产行骨架
class CharacterAssetRowSkeleton extends StatelessWidget {
  /// 创建角色资产行骨架
  ///
  /// [key] Flutter 组件标识
  /// [showLevel] 是否显示等级骨架
  /// [metricCount] 数据项骨架数量
  /// [showTrailing] 是否显示右侧胶囊骨架
  /// [trailingWidth] 右侧骨架宽度
  /// [trailingHeight] 右侧骨架高度
  /// [contentPadding] 内容内边距
  /// [titleMetricSpacing] 名称与首行数据间距
  /// [metricSpacing] 数据行间距
  /// [primaryMetricAsPill] 首行数据是否使用胶囊骨架
  const CharacterAssetRowSkeleton({
    super.key,
    this.showLevel = true,
    this.metricCount = 2,
    this.showTrailing = false,
    this.trailingWidth = 54,
    this.trailingHeight = 18,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 6),
    this.titleMetricSpacing = 5,
    this.metricSpacing = 3,
    this.primaryMetricAsPill = false,
  });

  /// 是否显示等级骨架
  final bool showLevel;

  /// 数据项骨架数量
  final int metricCount;

  /// 是否显示右侧胶囊骨架
  final bool showTrailing;

  /// 右侧骨架宽度
  final double trailingWidth;

  /// 右侧骨架高度
  final double trailingHeight;

  /// 内容内边距
  final EdgeInsetsGeometry contentPadding;

  /// 名称与首行数据间距
  final double titleMetricSpacing;

  /// 数据行间距
  final double metricSpacing;

  /// 首行数据是否使用胶囊骨架
  final bool primaryMetricAsPill;

  /// 构建角色资产行骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: contentPadding,
          child: Row(
            children: [
              Bone(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(16),
              ),
              const SizedBox(width: 8),
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
                            height: 16,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        if (showLevel) ...[
                          const SizedBox(width: 6),
                          Bone(
                            width: 34,
                            height: 15,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: titleMetricSpacing),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var index = 0; index < metricCount; index++) ...[
                          Bone(
                            width: 92.0 + index * 16,
                            height: index == 0 && primaryMetricAsPill
                                ? 16
                                : index == 0
                                ? 11
                                : 10,
                            borderRadius: BorderRadius.circular(
                              index == 0 && primaryMetricAsPill ? 999 : 5,
                            ),
                          ),
                          if (index != metricCount - 1)
                            SizedBox(height: metricSpacing),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (showTrailing) ...[
                const SizedBox(width: 8),
                Bone(
                  width: trailingWidth,
                  height: trailingHeight,
                  borderRadius: BorderRadius.circular(999),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
