import 'package:flutter/material.dart';

/// 用户资产记录胶囊标签
class UserAssetRecordPill extends StatelessWidget {
  /// 创建用户资产记录胶囊标签
  ///
  /// [key] Flutter 组件标识
  /// [text] 标签文本
  /// [accentColor] 强调色
  /// [isCompact] 是否使用紧凑尺寸
  const UserAssetRecordPill({
    super.key,
    required this.text,
    this.accentColor,
    this.isCompact = false,
  });

  /// 标签文本
  final String text;

  /// 强调色
  final Color? accentColor;

  /// 是否使用紧凑尺寸
  final bool isCompact;

  /// 构建用户资产记录胶囊标签
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final resolvedAccent = accentColor;
    final backgroundColor = resolvedAccent ??
        colorScheme.onSurfaceVariant.withValues(alpha: isDark ? 0.16 : 0.10);
    final foregroundColor =
        resolvedAccent == null ? colorScheme.onSurfaceVariant : Colors.white;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 6 : 8,
          vertical: isCompact ? 3 : 4,
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foregroundColor,
            fontSize: isCompact ? 9 : 10,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}
