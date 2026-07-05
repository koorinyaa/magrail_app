import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// 通天塔星级图标行
class TowerStarsRow extends StatelessWidget {
  /// 创建通天塔星级图标行
  ///
  /// [key] Flutter 组件标识
  /// [stars] 星级数量
  /// [iconSize] 星级图标尺寸
  /// [spacing] 星级图标横向间距
  /// [runSpacing] 星级图标换行间距
  const TowerStarsRow({
    super.key,
    required this.stars,
    this.iconSize = 12,
    this.spacing = 2,
    this.runSpacing = 1,
  });

  /// 星级数量
  final int stars;

  /// 星级图标尺寸
  final double iconSize;

  /// 星级图标横向间距
  final double spacing;

  /// 星级图标换行间距
  final double runSpacing;

  /// 构建通天塔星级图标行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final crownCount = stars <= 0 ? 0 : stars ~/ 125;
    final sunCount = stars <= 0 ? 0 : (stars % 125) ~/ 25;
    final moonCount = stars <= 0 ? 0 : (stars % 25) ~/ 5;
    final starCount = stars <= 0 ? 0 : stars % 5;
    final icons = <IconData>[
      for (var index = 0; index < crownCount; index++) Symbols.crown,
      for (var index = 0; index < sunCount; index++) Symbols.light_mode,
      for (var index = 0; index < moonCount; index++) Symbols.dark_mode,
      for (var index = 0; index < starCount; index++) Symbols.star,
    ];
    final hasLevelIcons = icons.isNotEmpty;

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!hasLevelIcons)
          Icon(
            Symbols.star,
            size: iconSize,
            fill: 0,
            color: const Color(0xFFF2B72F),
          ),
        if (hasLevelIcons)
          for (final icon in icons)
            Icon(
              icon,
              size: iconSize,
              fill: 1,
              color: const Color(0xFFF2B72F),
            ),
      ],
    );
  }
}

/// 通天塔星之力徽标
class TowerStarForcesBadge extends StatelessWidget {
  /// 创建通天塔星之力徽标
  ///
  /// [value] 星之力数值
  const TowerStarForcesBadge({
    super.key,
    required this.value,
  });

  /// 星之力显示文本
  final String value;

  /// 构建通天塔星之力徽标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF3F2F13).withValues(alpha: 0.86)
        : const Color(0xFFFFF4D6);
    final borderColor = isDark
        ? const Color(0xFFEAB308).withValues(alpha: 0.18)
        : const Color(0x40F5A524);
    final iconColor =
        isDark ? const Color(0xFFFACC15) : const Color(0xFFB76E00);
    final textColor =
        isDark ? const Color(0xFFFDE68A) : const Color(0xFF9A5B00);

    return Container(
      width: 72,
      height: 24,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: iconColor,
            size: 11,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
