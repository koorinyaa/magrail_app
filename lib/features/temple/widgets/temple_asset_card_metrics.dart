part of 'temple_asset_card.dart';

/// 圣殿资产指标区
class _TempleAssetMetrics extends StatelessWidget {
  /// 创建圣殿资产指标区
  ///
  /// [data] 圣殿资产卡片展示数据
  /// [reservedTrailingWidth] 顶部主文案右侧预留宽度
  const _TempleAssetMetrics({
    required this.data,
    required this.reservedTrailingWidth,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 顶部主文案右侧预留宽度
  final double reservedTrailingWidth;

  /// 构建圣殿资产指标区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 3),
        _TempleAssetPrimarySummary(
          data: data,
          reservedTrailingWidth: reservedTrailingWidth,
        ),
        if (data.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Expanded(
            child: _TempleAssetSoftTagsScrollView(
              child: _TempleAssetSoftTags(items: data.tags),
            ),
          ),
          const SizedBox(height: 4),
        ] else
          const Spacer(),
        _TempleAssetProgress(data: data),
      ],
    );
  }
}

/// 圣殿资产胶囊滚动区
class _TempleAssetSoftTagsScrollView extends StatelessWidget {
  /// 创建圣殿资产胶囊滚动区
  ///
  /// [child] 胶囊内容
  const _TempleAssetSoftTagsScrollView({
    required this.child,
  });

  /// 胶囊内容
  final Widget child;

  /// 构建圣殿资产胶囊滚动区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SingleChildScrollView(
        primary: false,
        physics: const ClampingScrollPhysics(),
        child: child,
      ),
    );
  }
}

/// 圣殿资产主信息
class _TempleAssetPrimarySummary extends StatelessWidget {
  /// 创建圣殿资产主信息
  ///
  /// [data] 圣殿资产卡片展示数据
  /// [reservedTrailingWidth] 右侧预留宽度
  const _TempleAssetPrimarySummary({
    required this.data,
    required this.reservedTrailingWidth,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 右侧预留宽度
  final double reservedTrailingWidth;

  /// 构建圣殿资产主信息
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(right: reservedTrailingWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _TempleAssetPrimaryLine(
            text: data.primaryValue,
            level: data.characterLevel,
            zeroCount: data.zeroCount,
            showLevelBadge: data.showPrimaryLevelBadge,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              height: 1.1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.primaryLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.58),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

/// 圣殿资产主文案行
class _TempleAssetPrimaryLine extends StatelessWidget {
  /// 创建圣殿资产主文案行
  ///
  /// [text] 显示文本
  /// [level] 角色等级
  /// [zeroCount] ST 等级
  /// [showLevelBadge] 是否显示等级标签
  /// [style] 文本样式
  const _TempleAssetPrimaryLine({
    required this.text,
    required this.level,
    required this.zeroCount,
    required this.showLevelBadge,
    required this.style,
  });

  /// 显示文本
  final String text;

  /// 角色等级
  final int level;

  /// ST 等级
  final int zeroCount;

  /// 是否显示等级标签
  final bool showLevelBadge;

  /// 文本样式
  final TextStyle style;

  /// 构建圣殿资产主文案行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (!showLevelBadge) {
      return _TempleAssetScalingText(
        text: text,
        style: style,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              maxLines: 1,
              softWrap: false,
              style: style,
            ),
          ),
        ),
        const SizedBox(width: 6),
        LevelBadge(
          level: level,
          zeroCount: zeroCount,
          isCompact: true,
        ),
      ],
    );
  }
}

/// 圣殿资产自适应单行文本
class _TempleAssetScalingText extends StatelessWidget {
  /// 创建圣殿资产自适应单行文本
  ///
  /// [text] 显示文本
  /// [style] 文本样式
  const _TempleAssetScalingText({
    required this.text,
    required this.style,
  });

  /// 显示文本
  final String text;

  /// 文本样式
  final TextStyle style;

  /// 构建圣殿资产自适应单行文本
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style: style,
        ),
      ),
    );
  }
}

/// 圣殿资产浅色标签组
class _TempleAssetSoftTags extends StatelessWidget {
  /// 创建圣殿资产浅色标签组
  ///
  /// [items] 指标条目
  const _TempleAssetSoftTags({
    required this.items,
  });

  /// 指标条目
  final List<TempleAssetCardTagData> items;

  /// 构建圣殿资产浅色标签组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 5,
      runSpacing: 3,
      children: [
        for (final item in items) _TempleAssetSoftTag(data: item),
      ],
    );
  }
}

/// 圣殿资产浅色标签
class _TempleAssetSoftTag extends StatelessWidget {
  /// 创建圣殿资产浅色标签
  ///
  /// [data] 指标数据
  const _TempleAssetSoftTag({
    required this.data,
  });

  /// 指标数据
  final TempleAssetCardTagData data;

  /// 构建圣殿资产浅色标签
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final foregroundColor = colorScheme.onSurfaceVariant.withValues(
      alpha: data.muted ? 0.62 : 1,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.44 : 0.68,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 18, maxWidth: 240),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '${data.label} ${data.value}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            if (data.showStarIcon) ...[
              const SizedBox(width: 4),
              Icon(
                data.starHighlighted
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: const Color(0xFFFFD25A),
                size: 11,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 圣殿资产进度条
class _TempleAssetProgress extends StatelessWidget {
  /// 创建圣殿资产进度条
  ///
  /// [data] 圣殿资产卡片展示数据
  const _TempleAssetProgress({
    required this.data,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 构建圣殿资产进度条
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final trackColor = colorScheme.onSurfaceVariant.withValues(
      alpha: isDark ? 0.24 : 0.14,
    );
    final progressColor = _themeColor.withValues(alpha: isDark ? 0.92 : 0.86);
    final progress = !data.hasTemple || data.sacrifices <= 0
        ? 0.0
        : (data.assets / data.sacrifices).clamp(0.0, 1.0).toDouble();

    return SizedBox(
      height: 24,
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _assetLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: trackColor,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 资产进度文案
  String get _assetLabel {
    if (!data.hasTemple) {
      return '-- / --';
    }

    return '${Formatters.groupedNumber(data.assets)} / '
        '${Formatters.groupedNumber(data.sacrifices)}';
  }

  /// 圣殿主题色
  Color get _themeColor {
    return _templeLevelColor(data.level);
  }
}
