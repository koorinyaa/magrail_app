import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';

/// 角色资产行右侧胶囊
class CharacterAssetTrailingChip extends StatelessWidget {
  /// 创建角色资产行右侧胶囊
  ///
  /// [key] Flutter 组件标识
  /// [text] 胶囊文本
  /// [accentColor] 强调色
  const CharacterAssetTrailingChip({
    super.key,
    required this.text,
    this.accentColor,
  });

  /// 胶囊文本
  final String text;

  /// 强调色
  final Color? accentColor;

  /// 构建角色资产行右侧胶囊
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final neutralForegroundColor = colorScheme.onSurfaceVariant.withValues(
      alpha: isDark ? 0.86 : 0.72,
    );
    final resolvedColor = accentColor;
    final foregroundColor = resolvedColor ?? neutralForegroundColor;
    final backgroundBaseColor = resolvedColor ?? colorScheme.onSurfaceVariant;
    final backgroundColor = backgroundBaseColor.withValues(
      alpha: resolvedColor == null
          ? (isDark ? 0.12 : 0.08)
          : (isDark ? 0.16 : 0.10),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 84),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// 角色当前价胶囊
class CharacterAssetCurrentPriceChip extends StatelessWidget {
  /// 创建角色当前价胶囊
  ///
  /// [key] Flutter 组件标识
  /// [current] 当前价
  /// [fluctuation] 当前价涨跌幅
  const CharacterAssetCurrentPriceChip({
    super.key,
    required this.current,
    required this.fluctuation,
  });

  /// 当前价
  final double current;

  /// 当前价涨跌幅
  final double fluctuation;

  /// 构建角色当前价胶囊
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return CharacterAssetTrailingChip(
      text: _formatCurrentPrice(current),
      accentColor: resolveCurrentPriceColor(fluctuation),
    );
  }

  /// 格式化角色当前价
  ///
  /// [value] 当前价
  String _formatCurrentPrice(double value) {
    if (value <= 0) {
      return '--';
    }

    if (value.abs() >= 10000) {
      return Formatters.tinygrailCompactValue(
        value.truncate(),
        prefix: '₵',
      );
    }

    return Formatters.tinygrailCurrency(value);
  }

  /// 解析角色当前价胶囊颜色
  ///
  /// [value] 当前价涨跌幅
  static Color? resolveCurrentPriceColor(double value) {
    if (value > 0) {
      return const Color(0xFFFF5A91);
    }

    if (value < 0) {
      return const Color(0xFF38A8E8);
    }

    return null;
  }
}
