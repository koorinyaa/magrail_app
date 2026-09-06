import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';

/// 排行榜页内文字标签栏
class RankingTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// 标签栏高度，同时保留完整触控区域
  static const double height = 44;

  static const double _labelSpacing = 24;
  static const double _indicatorWidth = 24;
  static const double _indicatorHeight = 2;
  static const double _labelIndicatorGap = 6;

  /// 创建排行榜文字标签栏
  ///
  /// [key] Flutter 组件标识
  /// [labels] 榜单标签文案
  /// [selectedIndex] 当前榜单索引
  /// [pageController] 提供页面连续滑动进度的控制器，由分页页面负责释放
  /// [onSelected] 榜单切换回调
  const RankingTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.pageController,
    required this.onSelected,
  }) : assert(labels.length > 0);

  /// 榜单标签文案
  final List<String> labels;

  /// 当前榜单索引
  final int selectedIndex;

  /// 页面滑动进度来源，不创建或持有额外的切页状态
  final PageController pageController;

  /// 榜单切换回调
  final ValueChanged<int> onSelected;

  /// 标签栏在分页页面中占用的固定尺寸
  @override
  Size get preferredSize => const Size.fromHeight(height);

  /// 构建排行榜文字标签栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final direction = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final labelStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: 0,
    );

    return SizedBox(
      height: height,
      child: Padding(
        padding: AppSafeAreaInsets.fromLTRB(
          context,
          left: 24,
          top: 0,
          right: 24,
          bottom: 0,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxLabelWidth = math.max(
              0.0,
              (constraints.maxWidth - _labelSpacing * (labels.length - 1)) /
                  labels.length,
            );
            // 按选中字重预留固定文字宽度，避免切换字重时标签和下划线端点跳动
            final labelSizes = [
              for (final label in labels)
                _measureLabel(
                  label,
                  labelStyle,
                  textScaler,
                  direction,
                  maxLabelWidth,
                ),
            ];
            final labelHeight = labelSizes
                .map((size) => size.height)
                .reduce(math.max);
            final groupWidth =
                labelSizes.fold<double>(0, (sum, size) => sum + size.width) +
                _labelSpacing * (labels.length - 1);
            final centers = <double>[];
            var offset = 0.0;
            for (final size in labelSizes) {
              final center = offset + size.width / 2;
              centers.add(
                direction == TextDirection.rtl ? groupWidth - center : center,
              );
              offset += size.width + _labelSpacing;
            }

            return Center(
              child: SizedBox(
                width: groupWidth,
                height: height,
                child: AnimatedBuilder(
                  animation: pageController,
                  builder: (context, child) {
                    final progress = _pageProgress();
                    final lower = progress.floor();
                    final upper = progress.ceil();
                    final center =
                        centers[lower] +
                        (centers[upper] - centers[lower]) * (progress - lower);

                    return Stack(
                      children: [
                        child!,
                        Positioned(
                          left: center - _indicatorWidth / 2,
                          top:
                              (height +
                                  labelHeight +
                                  _labelIndicatorGap -
                                  _indicatorHeight) /
                              2,
                          width: _indicatorWidth,
                          height: _indicatorHeight,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  child: Row(
                    children: [
                      for (
                        var index = 0;
                        index < labels.length;
                        index += 1
                      ) ...[
                        if (index > 0) const SizedBox(width: _labelSpacing),
                        SizedBox(
                          width: labelSizes[index].width,
                          height: height,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => onSelected(index),
                              splashFactory: NoSplash.splashFactory,
                              highlightColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: labelSizes[index].width,
                                    height: labelHeight,
                                    child: Text(
                                      labels[index],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: labelStyle.copyWith(
                                        color: index == selectedIndex
                                            ? colorScheme.onSurface
                                            : colorScheme.onSurfaceVariant,
                                        fontWeight: index == selectedIndex
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height:
                                        _labelIndicatorGap + _indicatorHeight,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 测量受可用宽度约束的标签尺寸
  ///
  /// [label] 榜单标签文案
  /// [style] 用于固定宽度的选中文字样式
  /// [textScaler] 系统文字缩放设置
  /// [direction] 当前文字方向
  /// [maxWidth] 单个标签的可用宽度
  Size _measureLabel(
    String label,
    TextStyle style,
    TextScaler textScaler,
    TextDirection direction,
    double maxWidth,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textScaler: textScaler,
      textDirection: direction,
      maxLines: 1,
      ellipsis: '\u2026',
    )..layout(maxWidth: maxWidth);
    final size = Size(
      math.min(maxWidth, math.max(_indicatorWidth, painter.width)),
      painter.height,
    );
    painter.dispose();
    return size;
  }

  /// 读取连续页进度，页面尚未布局时使用当前选中索引
  double _pageProgress() {
    final page =
        pageController.hasClients &&
            pageController.position.hasContentDimensions
        ? pageController.page
        : null;
    return (page ?? selectedIndex.toDouble())
        .clamp(0, labels.length - 1)
        .toDouble();
  }
}
