import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:magrail_app/app/theme/app_material_theme.dart';
import 'package:magrail_app/features/user/analysis/model/user_asset_analysis.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_character_packing_section.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_core_header.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_dividend_composition_section.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_level_distribution_section.dart';

/// 资产分析分享长图逻辑宽度
const double userAssetAnalysisSharePosterWidth = 360;

/// 用户资产分析分享长图
class UserAssetAnalysisSharePoster extends StatelessWidget {
  /// 创建用户资产分析分享长图
  ///
  /// [key] Flutter 组件标识
  /// [analysis] 用户资产分析缓存
  /// [nickname] 用户昵称
  /// [analysisAgeLabel] 分析更新时间文案
  /// [assetMode] 资产占比统计模式
  /// [levelMode] 等级分布统计模式
  /// [brightness] 长图主题亮度
  /// [generatedAt] 长图生成时间
  const UserAssetAnalysisSharePoster({
    super.key,
    required this.analysis,
    required this.nickname,
    required this.analysisAgeLabel,
    required this.assetMode,
    required this.levelMode,
    required this.brightness,
    required this.generatedAt,
  });

  /// 用户资产分析缓存
  final UserAssetAnalysis analysis;

  /// 用户昵称
  final String nickname;

  /// 分析更新时间文案
  final String analysisAgeLabel;

  /// 资产占比统计模式
  final UserAssetAnalysisAssetProportionMode assetMode;

  /// 等级分布统计模式
  final UserAssetAnalysisLevelDistributionMode levelMode;

  /// 长图主题亮度
  final Brightness brightness;

  /// 长图生成时间
  final DateTime generatedAt;

  /// 构建用户资产分析分享长图
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final isDark = brightness == Brightness.dark;
    final theme = isDark ? AppMaterialTheme.dark() : AppMaterialTheme.light();

    return Theme(
      data: theme,
      child: MediaQuery(
        data: MediaQueryData(
          size: const Size(userAssetAnalysisSharePosterWidth, 800),
          platformBrightness: brightness,
          textScaler: TextScaler.noScaling,
          disableAnimations: true,
        ),
        child: Material(
          color: isDark ? _darkPageBottom : _lightPageBottom,
          child: SizedBox(
            width: userAssetAnalysisSharePosterWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [
                          _darkPageTop,
                          _darkPageMiddle,
                          _darkPageBottom,
                        ]
                      : const [
                          _lightPageTop,
                          _lightPageMiddle,
                          _lightPageBottom,
                        ],
                  stops: const [0, 0.46, 1],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 304,
                    child: UserAssetAnalysisCoreHeader(
                      analysis: analysis,
                      nickname: nickname,
                      analysisAgeLabel: analysisAgeLabel,
                      isRefreshing: false,
                      progressLabel: '',
                      hasRefreshError: false,
                      contentTopPadding: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 30, 18, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        UserAssetAnalysisDividendCompositionSection(
                          segments: analysis.dividendSegments,
                        ),
                        const SizedBox(height: 42),
                        UserAssetAnalysisCharacterPackingSection(
                          analysis: analysis,
                          mode: assetMode,
                        ),
                        const SizedBox(height: 42),
                        UserAssetAnalysisLevelDistributionSection(
                          buckets: analysis.levelBuckets,
                          mode: levelMode,
                        ),
                        const SizedBox(height: 24),
                        _SharePosterFooter(generatedAt: generatedAt),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 用户资产分析分享长图页脚
class _SharePosterFooter extends StatelessWidget {
  /// 创建用户资产分析分享长图页脚
  ///
  /// [generatedAt] 长图生成时间
  const _SharePosterFooter({required this.generatedAt});

  /// 长图生成时间
  final DateTime generatedAt;

  /// 构建用户资产分析分享长图页脚
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.09),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  _appIconAsset,
                  width: 13,
                  height: 13,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                Text(
                  'MaGrail',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(generatedAt),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _appIconAsset = 'assets/icons/app_icon_cropped.png';
const _lightPageTop = Color(0xFFEAF7F4);
const _lightPageMiddle = Color(0xFFF7FAF9);
const _lightPageBottom = Color(0xFFFFFBF4);
const _darkPageTop = Color(0xFF07111A);
const _darkPageMiddle = Color(0xFF071014);
const _darkPageBottom = Color(0xFF050A0D);
