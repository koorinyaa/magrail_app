import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/user/analysis/model/user_asset_analysis.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_section_title.dart';

part 'user_asset_analysis_character_packing_bubble.dart';
part 'user_asset_analysis_character_packing_canvas.dart';
part 'user_asset_analysis_character_packing_layout.dart';

// 24 个气泡在当前前链布局下更接近完整圆形，并保留足够的角色差异
const int _maxVisibleBubbles = 24;

// 圆图气泡之间保留少量间隙，避免头像边框相互贴住
const double _packingGap = 1.5;

// 浮点碰撞检测保留微小误差，避免相切圆被误判为相交
const double _collisionEpsilon = 1e-6;

// 前三名角色使用更强的视觉层级
const int _featuredBubbleCount = 3;

const Color _characterDividendColor = Color(0xFF20B8D8);
const Color _templeDividendColor = Color(0xFFD9A441);
const Color _coreCyan = Color(0xFF32D6E8);
const Color _coreMint = Color(0xFF5AD6A0);
const Color _coreCoral = Color(0xFFF27C6B);
const Color _coreGold = Color(0xFFE7B554);

/// 用户资产分析资产占比区块
class UserAssetAnalysisCharacterPackingSection extends StatelessWidget {
  /// 创建用户资产分析资产占比区块
  ///
  /// [key] Flutter 组件标识
  /// [analysis] 用户资产分析结果
  /// [mode] 当前统计模式
  /// [onModeChanged] 统计模式切换回调，为空时显示静态模式标签
  /// [onCharacterTap] 角色点击回调，为空时禁用角色点击
  const UserAssetAnalysisCharacterPackingSection({
    super.key,
    required this.analysis,
    required this.mode,
    this.onModeChanged,
    this.onCharacterTap,
  });

  /// 用户资产分析结果
  final UserAssetAnalysis analysis;

  /// 当前统计模式
  final UserAssetAnalysisAssetProportionMode mode;

  /// 统计模式切换回调
  final ValueChanged<UserAssetAnalysisAssetProportionMode>? onModeChanged;

  /// 角色点击回调
  final ValueChanged<UserAssetAnalysisCharacterBubble>? onCharacterTap;

  /// 构建用户资产分析资产占比区块
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final displayBubbles = selectUserAssetAnalysisCharacterBubbles(
      analysis: analysis,
      mode: mode,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UserAssetAnalysisSectionTitle(
          title: '资产占比',
          leadingIcon: LucideIcons.orbit,
          accentColor: _coreGold,
          trailing: onModeChanged == null
              ? _AssetProportionModeBadge(mode: mode)
              : _AssetProportionModeSwitch(
                  mode: mode,
                  onChanged: onModeChanged!,
                ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _AssetProportionSourceLegend(
              key: ValueKey(mode),
              mode: mode,
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (displayBubbles.isEmpty)
          _EmptyCharacterPacking(mode: mode)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final side = constraints.maxWidth.clamp(292.0, 620.0);
              final layout = _PackedBubbleLayout.build(
                bubbles: displayBubbles,
                side: side,
                mode: mode,
              );

              return Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: side,
                  height: side,
                  child: KeyedSubtree(
                    key: ValueKey(mode),
                    child: _CharacterPackingCanvas(
                      layout: layout,
                      mode: mode,
                      onCharacterTap: onCharacterTap,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// 选取资产占比展示角色
///
/// [analysis] 用户资产分析缓存
/// [mode] 当前统计模式
List<UserAssetAnalysisCharacterBubble> selectUserAssetAnalysisCharacterBubbles({
  required UserAssetAnalysis analysis,
  required UserAssetAnalysisAssetProportionMode mode,
}) {
  final visibleBubbles = analysis.characterBubbles
      .where((bubble) => _characterBubbleValue(bubble, mode) > 0)
      .toList()
    ..sort((a, b) {
      final valueCompare = _characterBubbleValue(
        b,
        mode,
      ).compareTo(_characterBubbleValue(a, mode));
      if (valueCompare != 0) {
        return valueCompare;
      }
      return a.characterId.compareTo(b.characterId);
    });

  return visibleBubbles.take(_maxVisibleBubbles).toList(growable: false);
}

/// 读取资产占比角色数值
///
/// [bubble] 角色聚合数据
/// [mode] 资产占比统计模式
double _characterBubbleValue(
  UserAssetAnalysisCharacterBubble bubble,
  UserAssetAnalysisAssetProportionMode mode,
) {
  return switch (mode) {
    UserAssetAnalysisAssetProportionMode.dividend => bubble.totalDividend,
    UserAssetAnalysisAssetProportionMode.assets =>
      bubble.totalAssets.toDouble(),
  };
}

/// 用户资产分析资产占比统计模式
enum UserAssetAnalysisAssetProportionMode {
  /// 按股息展示
  dividend,

  /// 按持股与圣殿资产展示
  assets,
}

/// 用户资产分析资产占比模式标签
class _AssetProportionModeBadge extends StatelessWidget {
  /// 创建用户资产分析资产占比模式标签
  ///
  /// [mode] 当前统计模式
  const _AssetProportionModeBadge({required this.mode});

  /// 当前统计模式
  final UserAssetAnalysisAssetProportionMode mode;

  /// 构建用户资产分析资产占比模式标签
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = mode == UserAssetAnalysisAssetProportionMode.dividend
        ? _coreGold
        : _coreCyan;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          mode == UserAssetAnalysisAssetProportionMode.dividend ? '股息' : '资产',
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
