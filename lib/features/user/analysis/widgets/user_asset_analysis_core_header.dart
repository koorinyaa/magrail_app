import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/features/user/analysis/model/user_asset_analysis.dart';

import 'user_asset_analysis_core_background.dart';
import 'user_asset_analysis_orbit_ring.dart';

/// 用户资产分析沉浸式核心头图
class UserAssetAnalysisCoreHeader extends StatelessWidget {
  /// 创建用户资产分析沉浸式核心头图
  ///
  /// [key] Flutter 组件标识
  /// [analysis] 用户资产分析结果
  /// [nickname] 用户昵称
  /// [analysisAgeLabel] 分析更新时间文案
  /// [isRefreshing] 是否正在刷新
  /// [progressLabel] 刷新状态文案
  /// [hasRefreshError] 是否显示刷新失败状态
  /// [contentTopPadding] 顶部内容与安全区的间距
  /// [onCharactersTap] 角色指标点击回调
  /// [onTemplesTap] 圣殿指标点击回调
  /// [onStarlightTemplesTap] 星光圣殿指标点击回调
  const UserAssetAnalysisCoreHeader({
    super.key,
    required this.analysis,
    required this.nickname,
    required this.analysisAgeLabel,
    required this.isRefreshing,
    required this.progressLabel,
    required this.hasRefreshError,
    this.contentTopPadding = 76,
    this.onCharactersTap,
    this.onTemplesTap,
    this.onStarlightTemplesTap,
  });

  /// 用户资产分析结果
  final UserAssetAnalysis analysis;

  /// 用户昵称
  final String nickname;

  /// 分析更新时间文案
  final String analysisAgeLabel;

  /// 是否正在刷新
  final bool isRefreshing;

  /// 刷新状态文案
  final String progressLabel;

  /// 是否显示刷新失败状态
  final bool hasRefreshError;

  /// 顶部内容与安全区的间距
  final double contentTopPadding;

  /// 角色指标点击回调
  final VoidCallback? onCharactersTap;

  /// 圣殿指标点击回调
  final VoidCallback? onTemplesTap;

  /// 星光圣殿指标点击回调
  final VoidCallback? onStarlightTemplesTap;

  /// 构建用户资产分析沉浸式核心头图
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF07161B);
    final mutedTextColor =
        isDark ? const Color(0xFFDCEAE6) : const Color(0xFF17343A);
    final cachedDisplayName = analysis.nickname.trim().isEmpty
        ? analysis.username
        : analysis.nickname;
    final displayName = nickname.trim().isEmpty ? cachedDisplayName : nickname;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final horizontalPadding = isTablet ? 32.0 : 20.0;
        final safeTop = MediaQuery.paddingOf(context).top;

        return Stack(
          fit: StackFit.expand,
          children: [
            UserAssetAnalysisCoreBackground(
              isDark: isDark,
              intensity: analysis.templeCoverage,
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      (isDark ? const Color(0xFF041014) : Colors.white)
                          .withValues(alpha: isDark ? 0.32 : 0.30),
                    ],
                    stops: const [0, 0.56, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              right: isTablet ? 34 : 18,
              top: safeTop + contentTopPadding + 2,
              child: IgnorePointer(
                child: Opacity(
                  opacity: isDark ? 0.10 : 0.12,
                  child: Image.asset(
                    _appIconAsset,
                    width: isTablet ? 142 : 112,
                    height: isTablet ? 142 : 112,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -82,
              bottom: -126,
              width: isTablet ? 360 : 310,
              height: isTablet ? 360 : 310,
              child: IgnorePointer(
                child: UserAssetAnalysisOrbitRing(
                  ringColor: primaryTextColor.withValues(alpha: 0.09),
                  trailColor: isDark
                      ? const Color(0xFFE6BC65)
                      : const Color(0xFFC38A24),
                  duration: const Duration(seconds: 18),
                ),
              ),
            ),
            Positioned(
              right: -18,
              bottom: -72,
              width: isTablet ? 238 : 206,
              height: isTablet ? 238 : 206,
              child: IgnorePointer(
                child: UserAssetAnalysisOrbitRing(
                  ringColor: primaryTextColor.withValues(alpha: 0.07),
                  trailColor: isDark
                      ? const Color(0xFF45CBDD)
                      : const Color(0xFF159BB4),
                  duration: const Duration(seconds: 13),
                  reverse: true,
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      safeTop + contentTopPadding,
                      horizontalPadding,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: mutedTextColor.withValues(alpha: 0.78),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _AnalysisStatusIndicator(
                              analysisAgeLabel: analysisAgeLabel,
                              isRefreshing: isRefreshing,
                              progressLabel: progressLabel,
                              hasRefreshError: hasRefreshError,
                              textColor: mutedTextColor,
                            ),
                          ],
                        ),
                        const Spacer(),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.72,
                          ),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: analysis.totalShares.toDouble(),
                            ),
                            duration: disableAnimations
                                ? Duration.zero
                                : const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  Formatters.groupedNumber(value.round()),
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: primaryTextColor,
                                    fontSize: isTablet ? 60 : 48,
                                    fontWeight: FontWeight.w600,
                                    height: 0.96,
                                    letterSpacing: 0,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '总持股',
                          style: TextStyle(
                            color: mutedTextColor.withValues(alpha: 0.58),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          height: 1,
                          color: primaryTextColor.withValues(alpha: 0.12),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _HeroMetric(
                                icon: LucideIcons.usersRound,
                                value: Formatters.groupedNumber(
                                  analysis.characterTotalItems,
                                ),
                                label: '角色',
                                textColor: primaryTextColor,
                                mutedTextColor: mutedTextColor,
                                onTap: onCharactersTap,
                              ),
                            ),
                            _HeroMetricDivider(color: primaryTextColor),
                            Expanded(
                              child: _HeroMetric(
                                icon: LucideIcons.images,
                                value: Formatters.groupedNumber(
                                  analysis.templeTotalItems,
                                ),
                                label: '圣殿',
                                textColor: primaryTextColor,
                                mutedTextColor: mutedTextColor,
                                onTap: onTemplesTap,
                              ),
                            ),
                            _HeroMetricDivider(color: primaryTextColor),
                            Expanded(
                              child: _HeroMetric(
                                icon: LucideIcons.star,
                                value: Formatters.groupedNumber(
                                  analysis.starlightTempleCount,
                                ),
                                label: '星光圣殿',
                                textColor: primaryTextColor,
                                mutedTextColor: mutedTextColor,
                                onTap: onStarlightTemplesTap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 用户资产分析头图指标
class _HeroMetric extends StatelessWidget {
  /// 创建用户资产分析头图指标
  ///
  /// [icon] 指标图标
  /// [value] 指标数值
  /// [label] 指标标签
  /// [textColor] 主要文字颜色
  /// [mutedTextColor] 次要文字颜色
  /// [onTap] 指标点击回调
  const _HeroMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.textColor,
    required this.mutedTextColor,
    this.onTap,
  });

  /// 指标图标
  final IconData icon;

  /// 指标数值
  final String value;

  /// 指标标签
  final String label;

  /// 主要文字颜色
  final Color textColor;

  /// 次要文字颜色
  final Color mutedTextColor;

  /// 指标点击回调
  final VoidCallback? onTap;

  /// 构建用户资产分析头图指标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final iconColor = mutedTextColor.withValues(alpha: 0.60);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.90),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          letterSpacing: 0,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: mutedTextColor.withValues(alpha: 0.52),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 用户资产分析头图指标分隔线
class _HeroMetricDivider extends StatelessWidget {
  /// 创建用户资产分析头图指标分隔线
  ///
  /// [color] 分隔线颜色
  const _HeroMetricDivider({required this.color});

  /// 分隔线颜色
  final Color color;

  /// 构建用户资产分析头图指标分隔线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: color.withValues(alpha: 0.11),
    );
  }
}

/// 用户资产分析更新时间状态
class _AnalysisStatusIndicator extends StatelessWidget {
  /// 创建用户资产分析更新时间状态
  ///
  /// [analysisAgeLabel] 分析更新时间文案
  /// [isRefreshing] 是否正在刷新
  /// [progressLabel] 刷新状态文案
  /// [hasRefreshError] 是否显示刷新失败状态
  /// [textColor] 次要文字颜色
  const _AnalysisStatusIndicator({
    required this.analysisAgeLabel,
    required this.isRefreshing,
    required this.progressLabel,
    required this.hasRefreshError,
    required this.textColor,
  });

  /// 分析更新时间文案
  final String analysisAgeLabel;

  /// 是否正在刷新
  final bool isRefreshing;

  /// 刷新状态文案
  final String progressLabel;

  /// 是否显示刷新失败状态
  final bool hasRefreshError;

  /// 次要文字颜色
  final Color textColor;

  /// 构建用户资产分析更新时间状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final label = _resolveLabel();
    final color = hasRefreshError
        ? const Color(0xFFE46D68)
        : textColor.withValues(alpha: 0.62);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 170),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Row(
          key: ValueKey('$isRefreshing-$hasRefreshError-$label'),
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isRefreshing)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.6,
                  color: color,
                ),
              )
            else
              Icon(
                hasRefreshError ? LucideIcons.circleAlert : LucideIcons.clock3,
                size: 13,
                color: color,
              ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 解析分析更新时间状态文案
  String _resolveLabel() {
    if (isRefreshing) {
      return progressLabel.trim().isEmpty ? '正在刷新资产分析' : progressLabel;
    }
    if (hasRefreshError) {
      return '刷新失败';
    }
    return analysisAgeLabel.trim().isEmpty ? '暂无分析' : analysisAgeLabel;
  }
}

const _appIconAsset = 'assets/icons/app_icon_cropped.png';
