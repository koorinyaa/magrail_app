import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/features/user/analysis/model/user_asset_analysis.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_section_title.dart';

/// 用户资产分析股息构成区块
class UserAssetAnalysisDividendCompositionSection extends StatelessWidget {
  /// 创建用户资产分析股息构成区块
  ///
  /// [key] Flutter 组件标识
  /// [segments] 股息构成分段
  const UserAssetAnalysisDividendCompositionSection({
    super.key,
    required this.segments,
  });

  /// 股息构成分段
  final List<UserAssetAnalysisDividendSegment> segments;

  /// 构建用户资产分析股息构成区块
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final character = _segmentByLabel(segments, '持股');
    final temple = _segmentByLabel(segments, '圣殿');
    final starlight = _segmentByLabel(segments, '星光股息');
    final hasDividend =
        character.value > 0 || temple.value > 0 || starlight.value > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const UserAssetAnalysisSectionTitle(
          title: '股息构成',
          leadingIcon: LucideIcons.chartSpline,
          accentColor: _characterColor,
        ),
        const SizedBox(height: 22),
        if (!hasDividend)
          const _EmptyDividendComposition()
        else ...[
          _DividendShareLabels(
            character: character,
            temple: temple,
          ),
          const SizedBox(height: 9),
          _DividendShareTrack(
            character: character,
            temple: temple,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _DividendSourceCard(
                    segment: character,
                    icon: LucideIcons.trendingUp,
                    color: _characterColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DividendSourceCard(
                    segment: temple,
                    icon: LucideIcons.images,
                    color: _templeColor,
                  ),
                ),
              ],
            ),
          ),
          if (starlight.value > 0) ...[
            const SizedBox(height: 12),
            _StarlightDividendRow(segment: starlight),
          ],
        ],
      ],
    );
  }
}

/// 用户资产分析股息占比标签
class _DividendShareLabels extends StatelessWidget {
  /// 创建用户资产分析股息占比标签
  ///
  /// [character] 持股股息分段
  /// [temple] 圣殿股息分段
  const _DividendShareLabels({
    required this.character,
    required this.temple,
  });

  /// 持股股息分段
  final UserAssetAnalysisDividendSegment character;

  /// 圣殿股息分段
  final UserAssetAnalysisDividendSegment temple;

  /// 构建用户资产分析股息占比标签
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            '持股  ${_formatShare(character.share)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '圣殿  ${_formatShare(temple.share)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

/// 用户资产分析股息占比轨道
class _DividendShareTrack extends StatelessWidget {
  /// 创建用户资产分析股息占比轨道
  ///
  /// [character] 持股股息分段
  /// [temple] 圣殿股息分段
  const _DividendShareTrack({
    required this.character,
    required this.temple,
  });

  /// 持股股息分段
  final UserAssetAnalysisDividendSegment character;

  /// 圣殿股息分段
  final UserAssetAnalysisDividendSegment temple;

  /// 构建用户资产分析股息占比轨道
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final total = character.value + temple.value;
    final characterShare =
        total <= 0 ? 0.5 : (character.value / total).clamp(0, 1).toDouble();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: characterShare),
      duration:
          disableAnimations ? Duration.zero : const Duration(milliseconds: 680),
      curve: Curves.easeOutCubic,
      builder: (context, animatedShare, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 7,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth * animatedShare,
                      child: const ColoredBox(color: _characterColor),
                    ),
                    const Expanded(
                      child: ColoredBox(
                        color: _templeColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// 用户资产分析股息来源卡片
class _DividendSourceCard extends StatelessWidget {
  /// 创建用户资产分析股息来源卡片
  ///
  /// [segment] 股息分段
  /// [icon] 来源图标
  /// [color] 来源颜色
  const _DividendSourceCard({
    required this.segment,
    required this.icon,
    required this.color,
  });

  /// 股息分段
  final UserAssetAnalysisDividendSegment segment;

  /// 来源图标
  final IconData icon;

  /// 来源颜色
  final Color color;

  /// 构建用户资产分析股息来源卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _AcrylicDividendCard(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    segment.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Formatters.tinygrailCompactValue(
                  segment.value,
                  prefix: '₵',
                ),
                maxLines: 1,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  letterSpacing: 0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 用户资产分析星光股息行
class _StarlightDividendRow extends StatelessWidget {
  /// 创建用户资产分析星光股息行
  ///
  /// [segment] 星光股息分段
  const _StarlightDividendRow({required this.segment});

  /// 星光股息分段
  final UserAssetAnalysisDividendSegment segment;

  /// 构建用户资产分析星光股息行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _AcrylicDividendCard(
      color: _starlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(
              LucideIcons.sparkles,
              size: 17,
              color: _starlightColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                segment.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              Formatters.tinygrailCompactValue(segment.value, prefix: '₵'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 用户资产分析股息磨砂亚克力卡片
class _AcrylicDividendCard extends StatelessWidget {
  /// 创建用户资产分析股息磨砂亚克力卡片
  ///
  /// [color] 卡片语义色
  /// [child] 卡片内容
  const _AcrylicDividendCard({
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  /// 构建用户资产分析股息磨砂亚克力卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(8);
    final surfaceColor = AppBlurStyle.surfaceColor(context);
    final topColor = Color.alphaBlend(
      Colors.white.withValues(alpha: isDark ? 0.08 : 0.24),
      surfaceColor,
    );
    final bottomColor = Color.alphaBlend(
      color.withValues(alpha: isDark ? 0.13 : 0.08),
      surfaceColor,
    );
    final borderColor = Color.alphaBlend(
      color.withValues(alpha: isDark ? 0.32 : 0.18),
      Colors.white.withValues(alpha: isDark ? 0.14 : 0.56),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.12 : 0.09),
            blurRadius: 18,
            spreadRadius: -5,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 14,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: AppBlurStyle.filter,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [topColor, bottomColor],
                    ),
                    borderRadius: radius,
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// 用户资产分析空股息构成
class _EmptyDividendComposition extends StatelessWidget {
  /// 创建用户资产分析空股息构成
  const _EmptyDividendComposition();

  /// 构建用户资产分析空股息构成
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Text(
        '暂无可分析的股息构成',
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

/// 按标签读取股息分段
///
/// [segments] 股息分段列表
/// [label] 目标标签
UserAssetAnalysisDividendSegment _segmentByLabel(
  List<UserAssetAnalysisDividendSegment> segments,
  String label,
) {
  for (final segment in segments) {
    if (segment.label == label) {
      return segment;
    }
  }
  return UserAssetAnalysisDividendSegment(
    label: label,
    value: 0,
    share: 0,
  );
}

/// 格式化股息占比
///
/// [share] 原始占比
String _formatShare(double share) {
  return '${Formatters.groupedNumber(share * 100)}%';
}

const _characterColor = Color(0xFF20B8D8);
const _templeColor = Color(0xFFD9A441);
const _starlightColor = Color(0xFFB08BEA);
