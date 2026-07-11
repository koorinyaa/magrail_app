import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

/// 用户资产分析核心动态背景
class UserAssetAnalysisCoreBackground extends StatelessWidget {
  /// 创建用户资产分析核心动态背景
  ///
  /// [key] Flutter 组件标识
  /// [isDark] 是否为深色模式
  /// [intensity] 圣殿覆盖率映射的背景强度
  const UserAssetAnalysisCoreBackground({
    super.key,
    required this.isDark,
    required this.intensity,
  });

  /// 是否为深色模式
  final bool isDark;

  /// 圣殿覆盖率映射的背景强度
  final double intensity;

  /// 构建用户资产分析核心动态背景
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final normalizedIntensity = intensity.clamp(0, 1).toDouble();
    final colors = isDark ? _darkHeroColors : _lightHeroColors;

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: disableAnimations
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                      stops: const [0, 0.34, 0.68, 1],
                    ),
                  ),
                )
              : AnimatedMeshGradient(
                  colors: colors,
                  options: AnimatedMeshGradientOptions(
                    frequency: 2.0 + normalizedIntensity * 0.5,
                    amplitude: 13 + normalizedIntensity * 3,
                    speed: 0.42,
                    grain: isDark ? 0.024 : 0.014,
                  ),
                ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF02070A).withValues(alpha: 0.14),
                      const Color(0xFF07111A).withValues(alpha: 0.20),
                      Colors.black.withValues(alpha: 0.34),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.58),
                      Colors.white.withValues(alpha: 0.10),
                      const Color(0xFFFFF8E8).withValues(alpha: 0.28),
                    ],
              stops: const [0, 0.48, 1],
            ),
          ),
        ),
      ],
    );
  }
}

const _lightHeroColors = [
  Color(0xFFF7FFFC),
  Color(0xFFBDECE0),
  Color(0xFFFFE1A3),
  Color(0xFFA9DDF0),
];

const _darkHeroColors = [
  Color(0xFF07111A),
  Color(0xFF123C4A),
  Color(0xFF2F5D50),
  Color(0xFFC99A3A),
];
