import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/features/user/analysis/model/user_asset_analysis.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_section_title.dart';

/// 用户资产分析等级分布区块
class UserAssetAnalysisLevelDistributionSection extends StatelessWidget {
  /// 创建用户资产分析等级分布区块
  ///
  /// [key] Flutter 组件标识
  /// [buckets] 等级分布列表
  /// [mode] 当前统计模式
  /// [onModeChanged] 统计模式切换回调，为空时显示静态模式标签
  const UserAssetAnalysisLevelDistributionSection({
    super.key,
    required this.buckets,
    required this.mode,
    this.onModeChanged,
  });

  /// 等级分布列表
  final List<UserAssetAnalysisLevelBucket> buckets;

  /// 当前统计模式
  final UserAssetAnalysisLevelDistributionMode mode;

  /// 统计模式切换回调
  final ValueChanged<UserAssetAnalysisLevelDistributionMode>? onModeChanged;

  /// 构建用户资产分析等级分布区块
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final sortedBuckets = [...buckets]
      ..sort((a, b) => _valueForBucket(b).compareTo(_valueForBucket(a)));
    final visibleBuckets = sortedBuckets.take(10).toList(growable: false);
    final maxValue = sortedBuckets.fold<double>(0, (currentMax, bucket) {
      return math.max(currentMax, _valueForBucket(bucket));
    });
    final modeColor = _colorForMode(mode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UserAssetAnalysisSectionTitle(
          title: '等级分布',
          leadingIcon: LucideIcons.layers3,
          accentColor: modeColor,
          trailing: onModeChanged == null
              ? _LevelModeBadge(mode: mode)
              : _LevelModeSwitch(
                  mode: mode,
                  onChanged: onModeChanged!,
                ),
        ),
        const SizedBox(height: 22),
        if (visibleBuckets.isEmpty)
          const _EmptyLevelDistribution()
        else
          Column(
            children: [
              for (var index = 0;
                  index < visibleBuckets.length;
                  index += 1) ...[
                _LevelDistributionRow(
                  bucket: visibleBuckets[index],
                  value: _valueForBucket(visibleBuckets[index]),
                  maxValue: maxValue,
                  mode: mode,
                ),
                if (index != visibleBuckets.length - 1)
                  const SizedBox(height: 15),
              ],
            ],
          ),
      ],
    );
  }

  /// 读取当前模式下的等级数值
  ///
  /// [bucket] 等级分布
  double _valueForBucket(UserAssetAnalysisLevelBucket bucket) {
    return switch (mode) {
      UserAssetAnalysisLevelDistributionMode.shares =>
        bucket.totalShares.toDouble(),
      UserAssetAnalysisLevelDistributionMode.dividend => bucket.totalDividend,
    };
  }
}

/// 用户资产分析等级分布模式切换
class _LevelModeSwitch extends StatelessWidget {
  /// 创建用户资产分析等级分布模式切换
  ///
  /// [mode] 当前模式
  /// [onChanged] 模式切换回调
  const _LevelModeSwitch({
    required this.mode,
    required this.onChanged,
  });

  /// 当前模式
  final UserAssetAnalysisLevelDistributionMode mode;

  /// 模式切换回调
  final ValueChanged<UserAssetAnalysisLevelDistributionMode> onChanged;

  /// 构建用户资产分析等级分布模式切换
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return SizedBox(
      width: 126,
      height: 32,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.055)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              _LevelModeOption(
                label: '股息',
                mode: UserAssetAnalysisLevelDistributionMode.dividend,
                currentMode: mode,
                onChanged: onChanged,
              ),
              _LevelModeOption(
                label: '持股',
                mode: UserAssetAnalysisLevelDistributionMode.shares,
                currentMode: mode,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 用户资产分析等级分布模式选项
class _LevelModeOption extends StatelessWidget {
  /// 创建用户资产分析等级分布模式选项
  ///
  /// [label] 选项文案
  /// [mode] 选项模式
  /// [currentMode] 当前模式
  /// [onChanged] 模式切换回调
  const _LevelModeOption({
    required this.label,
    required this.mode,
    required this.currentMode,
    required this.onChanged,
  });

  /// 选项文案
  final String label;

  /// 选项模式
  final UserAssetAnalysisLevelDistributionMode mode;

  /// 当前模式
  final UserAssetAnalysisLevelDistributionMode currentMode;

  /// 模式切换回调
  final ValueChanged<UserAssetAnalysisLevelDistributionMode> onChanged;

  /// 构建用户资产分析等级分布模式选项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = mode == currentMode;
    final color = _colorForMode(mode);
    final isDark = colorScheme.brightness == Brightness.dark;
    final selectedTextColor = Color.lerp(
      color,
      colorScheme.onSurface,
      isDark ? 0.06 : 0.28,
    )!;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: selected ? null : () => onChanged(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? isDark
                      ? colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.88,
                        )
                      : colorScheme.surface.withValues(alpha: 0.96)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: selected
                  ? Border.all(
                      color: colorScheme.onSurface.withValues(
                        alpha: isDark ? 0.12 : 0.07,
                      ),
                    )
                  : null,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.16 : 0.08,
                        ),
                        blurRadius: isDark ? 5 : 7,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : const [],
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? selectedTextColor
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 用户资产分析等级分布行
class _LevelDistributionRow extends StatelessWidget {
  /// 创建用户资产分析等级分布行
  ///
  /// [bucket] 等级分布
  /// [value] 当前模式数值
  /// [maxValue] 最大模式数值
  /// [mode] 当前展示模式
  const _LevelDistributionRow({
    required this.bucket,
    required this.value,
    required this.maxValue,
    required this.mode,
  });

  /// 等级分布
  final UserAssetAnalysisLevelBucket bucket;

  /// 当前模式数值
  final double value;

  /// 最大模式数值
  final double maxValue;

  /// 当前展示模式
  final UserAssetAnalysisLevelDistributionMode mode;

  /// 构建用户资产分析等级分布行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final color = _colorForMode(mode);
    final ratio =
        maxValue <= 0 ? 0.0 : (value / maxValue).clamp(0.035, 1).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.13 : 0.09),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Text(
                  'Lv.${bucket.level}',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: 0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                _valueText(),
                key: ValueKey('${mode.name}-${bucket.level}'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  letterSpacing: 0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: ratio),
              duration: disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 560),
              curve: Curves.easeOutCubic,
              builder: (context, animatedRatio, child) {
                return Stack(
                  children: [
                    Container(
                      height: 7,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(
                          alpha: isDark ? 0.09 : 0.06,
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    Container(
                      width: constraints.maxWidth * animatedRatio,
                      height: 7,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(
                              alpha: isDark ? 0.28 : 0.18,
                            ),
                            blurRadius: 9,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// 读取当前模式数值文案
  String _valueText() {
    return switch (mode) {
      UserAssetAnalysisLevelDistributionMode.shares =>
        '${Formatters.groupedNumber(bucket.totalShares)} 股',
      UserAssetAnalysisLevelDistributionMode.dividend =>
        Formatters.tinygrailCompactValue(bucket.totalDividend, prefix: '₵'),
    };
  }
}

/// 用户资产分析空等级分布
class _EmptyLevelDistribution extends StatelessWidget {
  /// 创建用户资产分析空等级分布
  const _EmptyLevelDistribution();

  /// 构建用户资产分析空等级分布
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Text(
        '暂无等级分布',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

/// 解析等级分布模式颜色
///
/// [mode] 等级分布模式
Color _colorForMode(UserAssetAnalysisLevelDistributionMode mode) {
  return switch (mode) {
    UserAssetAnalysisLevelDistributionMode.shares => _sharesColor,
    UserAssetAnalysisLevelDistributionMode.dividend => _dividendColor,
  };
}

/// 用户资产分析等级分布模式
enum UserAssetAnalysisLevelDistributionMode {
  /// 按持股展示
  shares,

  /// 按股息展示
  dividend,
}

/// 用户资产分析等级分布模式标签
class _LevelModeBadge extends StatelessWidget {
  /// 创建用户资产分析等级分布模式标签
  ///
  /// [mode] 当前统计模式
  const _LevelModeBadge({required this.mode});

  /// 当前统计模式
  final UserAssetAnalysisLevelDistributionMode mode;

  /// 构建用户资产分析等级分布模式标签
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _colorForMode(mode);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          mode == UserAssetAnalysisLevelDistributionMode.dividend ? '股息' : '持股',
          style: TextStyle(
            color: Color.lerp(color, colorScheme.onSurface, 0.12),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

const _sharesColor = Color(0xFF20B8D8);
const _dividendColor = Color(0xFFD9A441);
