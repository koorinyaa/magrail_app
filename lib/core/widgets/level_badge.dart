import 'package:flutter/material.dart';

/// 等级标签
class LevelBadge extends StatelessWidget {
  /// 创建等级标签
  ///
  /// [level] 等级数值
  /// [zeroCount] 等级为 0 时显示的 st 数量
  /// [isCompact] 是否使用更小尺寸
  const LevelBadge({
    super.key,
    required this.level,
    this.zeroCount = 0,
    this.isCompact = false,
  });

  /// 等级数值
  final int level;

  /// 等级为 0 时显示的 st 数量
  final int zeroCount;

  /// 是否使用更小尺寸
  final bool isCompact;

  /// 构建等级标签
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCompact ? 15 : 17,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 6 : 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _backgroundColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: Colors.white,
          fontSize: isCompact ? 8 : 9,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }

  /// 标签文案
  String get _label {
    if (level == 0 && zeroCount != 0) {
      return 'st$zeroCount';
    }

    return 'Lv.$level';
  }

  /// 背景色
  Color get _backgroundColor {
    if (level == 0) {
      return const Color(0xFFD2D2D2);
    }

    return switch (level) {
      1 => const Color(0xFF45D216),
      2 => const Color(0xFF70BBFF),
      3 => const Color(0xFFFFDC51),
      4 => const Color(0xFFFF9800),
      5 => const Color(0xFFD965FF),
      6 => const Color(0xFFFF5555),
      7 => const Color(0xFFE9EA54),
      8 => const Color(0xFF4293E4),
      >= 9 => const Color(0xFFFFC107),
      _ => const Color(0xFFD2D2D2),
    };
  }
}
