part of '../temple_asset_magic_action_sheet.dart';

class _TempleAssetMagicAssetProgress extends StatelessWidget {
  /// 创建固定资产进度条
  ///
  /// [data] 固定资产卡片展示数据
  const _TempleAssetMagicAssetProgress({
    required this.data,
  });

  /// 固定资产卡片展示数据
  final TempleAssetCardData data;

  /// 构建固定资产进度条
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final progress = !data.hasTemple || data.sacrifices <= 0
        ? 0.0
        : (data.assets / data.sacrifices).clamp(0.0, 1.0).toDouble();
    final progressColor = switch (data.level) {
      2 => const Color(0xFFEAB308),
      3 => const Color(0xFFA855F7),
      _ => const Color(0xFF9CA3AF),
    };
    final trackColor = colorScheme.onSurfaceVariant.withValues(
      alpha: isDark ? 0.24 : 0.14,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _assetLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressColor.withValues(alpha: isDark ? 0.92 : 0.86),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 固定资产进度文案
  String get _assetLabel {
    if (!data.hasTemple) {
      return '-- / --';
    }

    return '${Formatters.groupedNumber(data.assets)} / '
        '${Formatters.groupedNumber(data.sacrifices)}';
  }
}

/// 用户资产数据行
class _TempleAssetUserAssetStatsRow extends StatelessWidget {
  /// 创建用户资产数据行
  ///
  /// [items] 数据项
  const _TempleAssetUserAssetStatsRow({
    required this.items,
  });

  /// 数据项
  final List<_TempleAssetUserAssetStatsItem> items;

  /// 构建用户资产数据行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(child: items[index]),
        ],
      ],
    );
  }
}

/// 用户资产数据项
class _TempleAssetUserAssetStatsItem extends StatelessWidget {
  /// 创建用户资产数据项
  ///
  /// [label] 标签文案
  /// [value] 数值文案
  /// [showStarIcon] 是否显示星之力图标
  /// [starHighlighted] 星之力图标是否高亮
  const _TempleAssetUserAssetStatsItem({
    required this.label,
    required this.value,
    this.showStarIcon = false,
    this.starHighlighted = false,
    this.accentColor,
  });

  /// 标签文案
  final String label;

  /// 数值文案
  final String value;

  /// 是否显示星之力图标
  final bool showStarIcon;

  /// 星之力图标是否高亮
  final bool starHighlighted;

  /// 数值强调色
  final Color? accentColor;

  /// 构建用户资产数据项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final valueColor = accentColor ?? colorScheme.onSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerLow.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.22 : 0.48,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: valueColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                    if (showStarIcon) ...[
                      const SizedBox(width: 4),
                      Icon(
                        starHighlighted
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: const Color(0xFFFFD25A),
                        size: 13,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 圣殿资产魔法道具内联警告
class _TempleAssetMagicInlineWarning extends StatelessWidget {
  /// 创建圣殿资产魔法道具内联警告
  ///
  /// [text] 警告文案
  const _TempleAssetMagicInlineWarning({
    required this.text,
  });

  /// 警告文案
  final String text;

  /// 构建圣殿资产魔法道具内联警告
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      text,
      style: TextStyle(
        color: colorScheme.error,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// 圣殿资产魔法道具进度遮罩
class _TempleAssetMagicProgressOverlay extends StatelessWidget {
  /// 创建圣殿资产魔法道具进度遮罩
  ///
  /// [text] 进度文案
  const _TempleAssetMagicProgressOverlay({
    required this.text,
  });

  /// 进度文案
  final String text;

  /// 构建圣殿资产魔法道具进度遮罩
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.82),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 获取圣殿资产魔法道具内嵌表面样式
///
/// [context] 当前组件树上下文
/// [radius] 表面圆角
BoxDecoration _insetDecoration(
  BuildContext context, {
  double radius = 18,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final isDark = colorScheme.brightness == Brightness.dark;

  return BoxDecoration(
    color: isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.42)
        : colorScheme.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: colorScheme.outlineVariant.withValues(
        alpha: isDark ? 0.24 : 0.54,
      ),
    ),
  );
}
