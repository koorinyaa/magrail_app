import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 用户资产分析头图星轨圆环
class UserAssetAnalysisOrbitRing extends StatelessWidget {
  /// 创建用户资产分析头图星轨圆环
  ///
  /// [key] Flutter 组件标识
  /// [ringColor] 静态轨道颜色
  /// [trailColor] 星轨光尾颜色
  /// [duration] 完成一周旋转的时间
  /// [reverse] 是否反向旋转
  const UserAssetAnalysisOrbitRing({
    super.key,
    required this.ringColor,
    required this.trailColor,
    required this.duration,
    this.reverse = false,
  });

  /// 静态轨道颜色
  final Color ringColor;

  /// 星轨光尾颜色
  final Color trailColor;

  /// 完成一周旋转的时间
  final Duration duration;

  /// 是否反向旋转
  final bool reverse;

  /// 构建带渐变光尾的圆形轨道
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    Widget movingOrbit = ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return SweepGradient(
          colors: [
            Colors.transparent,
            trailColor.withValues(alpha: 0.02),
            trailColor.withValues(alpha: 0.10),
            trailColor.withValues(alpha: 0.42),
            trailColor.withValues(alpha: 0.16),
            trailColor.withValues(alpha: 0.04),
            Colors.transparent,
          ],
          stops: const [0, 0.08, 0.16, 0.24, 0.32, 0.44, 1],
        ).createShader(bounds);
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.25),
        ),
      ),
    );

    if (!MediaQuery.disableAnimationsOf(context)) {
      movingOrbit = movingOrbit
          .animate(onPlay: (controller) => controller.repeat())
          .rotate(
            begin: 0,
            end: reverse ? -1 : 1,
            duration: duration,
            curve: Curves.linear,
          );
    }

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor),
          ),
        ),
        movingOrbit,
      ],
    );
  }
}
