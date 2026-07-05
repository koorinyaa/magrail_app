part of 'character_detail_trade_header_card.dart';

/// 已上市头部徽标组
class _TradeHeaderBadges extends StatelessWidget {
  /// 创建已上市头部徽标组
  ///
  /// [header] 已上市角色头部资料
  const _TradeHeaderBadges({
    required this.header,
  });

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 构建已上市头部徽标组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _TradeHeaderPriceChip(header: header),
        _TradeHeaderTowerChip(header: header),
        if (header.crown > 0)
          _TradeHeaderInfoChip(
            icon: LucideIcons.trophy,
            text: '${header.crown}',
            accentColor: const Color(0xFFF5A524),
          ),
        _TradeHeaderDividendChip(header: header),
        _TradeHeaderCirculationChip(header: header),
        _TradeHeaderStatChip(
          label: '英灵殿',
          value: _formatOptionalAmount(header.valhallaAmount),
        ),
        _TradeHeaderStatChip(
          label: '幻想乡',
          value: _formatOptionalAmount(header.gensokyoAmount),
        ),
        _TradeHeaderStatChip(
          label: '奖池',
          value: _formatOptionalAmount(header.poolAmount),
        ),
        _TradeHeaderInfoChip(
          text: _formatListedDate(header.listedDate),
        ),
      ],
    );
  }

  /// 格式化可空数量
  ///
  /// [value] 原始数量
  String _formatOptionalAmount(int? value) {
    if (value == null) {
      return '--';
    }

    return Formatters.groupedNumber(value);
  }

  /// 格式化上市时间
  ///
  /// [value] Tinygrail 服务端时间文本
  String _formatListedDate(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return '--';
    }

    final parsed = TinygrailFormatters.parseServerTime(text);
    if (parsed == null) {
      final dateText = text.split(RegExp(r'[T\s]')).first.trim();
      return dateText.isEmpty ? text : dateText;
    }

    return DateFormat('yyyy/MM/dd').format(parsed.toLocal());
  }
}

/// 已上市头部价格 Chip
class _TradeHeaderPriceChip extends StatelessWidget {
  /// 创建已上市头部价格 Chip
  ///
  /// [header] 已上市角色头部资料
  const _TradeHeaderPriceChip({
    required this.header,
  });

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 构建已上市头部价格 Chip
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final fluctuationText = switch (header.fluctuation) {
      > 0 => '+${Formatters.groupedNumber(header.fluctuation * 100)}%',
      < 0 => '${Formatters.groupedNumber(header.fluctuation * 100)}%',
      _ => '0%',
    };
    final Color? accentColor = switch (header.fluctuation) {
      > 0 => const Color(0xFFFF5A91),
      < 0 => const Color(0xFF38A8E8),
      _ => null,
    };

    return _TradeHeaderCompositeChip(
      accentColor: accentColor,
      leading: Formatters.tinygrailCurrency(header.current),
      trailing: _TradeHeaderChipText(text: fluctuationText),
    );
  }
}

/// 已上市头部通天塔 Chip
class _TradeHeaderTowerChip extends StatelessWidget {
  /// 创建已上市头部通天塔 Chip
  ///
  /// [header] 已上市角色头部资料
  const _TradeHeaderTowerChip({
    required this.header,
  });

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 构建已上市头部通天塔 Chip
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _TradeHeaderCompositeChip(
      leading: '#${header.rank}',
      trailing: _TradeHeaderStarForcesSegment(value: header.starForces),
      accentColor: _accentColor,
    );
  }

  /// 通天塔 Chip 强调色
  Color? get _accentColor {
    if (header.rank < 500) {
      return const Color(0xFF673AB7);
    }

    return null;
  }
}

/// 已上市头部次级数据 Chip
class _TradeHeaderStatChip extends StatelessWidget {
  /// 创建已上市头部次级数据 Chip
  ///
  /// [label] 数据名称
  /// [value] 数据值
  const _TradeHeaderStatChip({
    required this.label,
    required this.value,
  });

  /// 数据名称
  final String label;

  /// 数据值
  final String value;

  /// 构建已上市头部次级数据 Chip
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _TradeHeaderInfoChip(
      text: '$label $value',
    );
  }
}

/// 已上市头部复合数据 Chip
class _TradeHeaderCompositeChip extends StatelessWidget {
  /// 创建已上市头部复合数据 Chip
  ///
  /// [leading] 左侧文本
  /// [trailing] 右侧组件
  /// [accentColor] Chip 强调色
  const _TradeHeaderCompositeChip({
    required this.leading,
    required this.trailing,
    this.accentColor,
  });

  /// 左侧文本
  final String leading;

  /// 右侧组件
  final Widget trailing;

  /// Chip 强调色
  final Color? accentColor;

  /// 构建已上市头部复合数据 Chip
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colors = _TradeHeaderChipColors.resolve(context, accentColor);

    return _TradeHeaderChipShell(
      colors: colors,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: _TradeHeaderChipText(
              text: leading,
              color: colors.foregroundColor,
            ),
          ),
          _TradeHeaderChipDivider(color: colors.dividerColor),
          trailing,
        ],
      ),
    );
  }
}

/// 已上市头部星之力片段
class _TradeHeaderStarForcesSegment extends StatelessWidget {
  /// 创建已上市头部星之力片段
  ///
  /// [value] 星之力原始数值
  const _TradeHeaderStarForcesSegment({
    required this.value,
  });

  /// 星之力原始数值
  final int value;

  /// 构建已上市头部星之力片段
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final color = DefaultTextStyle.of(context).style.color;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Symbols.auto_awesome,
          size: 11,
          fill: 0,
          color: color,
        ),
        const SizedBox(width: 2),
        _TradeHeaderChipText(
          text: Formatters.tinygrailCompactValue(value),
          color: color,
        ),
      ],
    );
  }
}

/// 已上市头部 Chip 分隔线
class _TradeHeaderChipDivider extends StatelessWidget {
  /// 创建已上市头部 Chip 分隔线
  ///
  /// [color] 分隔线颜色
  const _TradeHeaderChipDivider({
    required this.color,
  });

  /// 分隔线颜色
  final Color color;

  /// 构建已上市头部 Chip 分隔线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

/// 已上市头部 Chip 文本
class _TradeHeaderChipText extends StatelessWidget {
  /// 创建已上市头部 Chip 文本
  ///
  /// [text] 显示文本
  /// [color] 文本颜色
  const _TradeHeaderChipText({
    required this.text,
    this.color,
  });

  /// 显示文本
  final String text;

  /// 文本颜色
  final Color? color;

  /// 构建已上市头部 Chip 文本
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
  }
}

/// 已上市头部 Chip 外壳
class _TradeHeaderChipShell extends StatelessWidget {
  /// 创建已上市头部 Chip 外壳
  ///
  /// [colors] Chip 颜色配置
  /// [child] Chip 内容
  /// [onPressed] Chip 点击回调
  const _TradeHeaderChipShell({
    required this.colors,
    required this.child,
    this.onPressed,
  });

  /// Chip 颜色配置
  final _TradeHeaderChipColors colors;

  /// Chip 内容
  final Widget child;

  /// Chip 点击回调
  final VoidCallback? onPressed;

  /// 构建已上市头部 Chip 外壳
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final onPressed = this.onPressed;
    final content = Container(
      constraints: const BoxConstraints(minHeight: 22, maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colors.foregroundColor),
        child: child,
      ),
    );

    if (onPressed == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: content,
      );
    }

    return Material(
      color: colors.backgroundColor,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: content,
      ),
    );
  }
}

/// 已上市头部 Chip 颜色配置
class _TradeHeaderChipColors {
  /// 创建已上市头部 Chip 颜色配置
  ///
  /// [backgroundColor] 背景色
  /// [foregroundColor] 前景色
  /// [dividerColor] 分隔线颜色
  const _TradeHeaderChipColors({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.dividerColor,
  });

  /// 背景色
  final Color backgroundColor;

  /// 前景色
  final Color foregroundColor;

  /// 分隔线颜色
  final Color dividerColor;

  /// 解析已上市头部 Chip 颜色配置
  ///
  /// [context] 当前组件树上下文
  /// [accentColor] Chip 强调色
  static _TradeHeaderChipColors resolve(
    BuildContext context,
    Color? accentColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final foregroundColor = accentColor ?? colorScheme.onSurfaceVariant;
    final backgroundColor = accentColor == null
        ? colorScheme.surfaceContainerHighest.withValues(
            alpha: isDark ? 0.44 : 0.68,
          )
        : foregroundColor.withValues(alpha: isDark ? 0.18 : 0.13);
    final dividerColor = accentColor == null
        ? colorScheme.outlineVariant.withValues(alpha: isDark ? 0.54 : 0.78)
        : foregroundColor.withValues(alpha: isDark ? 0.38 : 0.34);

    return _TradeHeaderChipColors(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      dividerColor: dividerColor,
    );
  }
}

/// 已上市头部通用信息 Chip
class _TradeHeaderInfoChip extends StatelessWidget {
  /// 创建已上市头部通用信息 Chip
  ///
  /// [text] Chip 文本
  /// [icon] Chip 图标
  /// [accentColor] Chip 强调色
  const _TradeHeaderInfoChip({
    required this.text,
    this.icon,
    this.accentColor,
  });

  /// Chip 文本
  final String text;

  /// Chip 图标
  final IconData? icon;

  /// Chip 强调色
  final Color? accentColor;

  /// 构建已上市头部通用信息 Chip
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colors = _TradeHeaderChipColors.resolve(context, accentColor);

    return _TradeHeaderChipShell(
      colors: colors,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 11,
              color: colors.foregroundColor,
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: _TradeHeaderChipText(
              text: text,
              color: colors.foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
