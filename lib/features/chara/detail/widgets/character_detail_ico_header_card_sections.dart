part of 'character_detail_ico_header_card.dart';

/// ICO 头部卡片外壳
class _IcoHeaderShell extends StatelessWidget {
  /// 创建 ICO 头部卡片外壳
  ///
  /// [child] 卡片主体内容
  const _IcoHeaderShell({
    required this.child,
  });

  /// 卡片主体内容
  final Widget child;

  /// 构建 ICO 头部卡片外壳
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final cardColor =
        isDark ? colorScheme.surfaceContainerLow : colorScheme.surface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// ICO 头部标题区
class _IcoHeaderTitle extends StatelessWidget {
  /// 创建 ICO 头部标题区
  ///
  /// [info] ICO 头部资料
  /// [prediction] ICO 预测数据
  const _IcoHeaderTitle({
    required this.info,
    required this.prediction,
  });

  /// ICO 头部资料
  final CharacterDetailIcoInfo info;

  /// ICO 预测数据
  final CharacterDetailIcoPrediction prediction;

  /// 构建 ICO 头部标题区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasListingLevel = prediction.listingLevel > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                _displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
              ),
            ),
            const SizedBox(width: 7),
            LevelBadge(level: prediction.level),
            if (hasListingLevel) ...[
              const SizedBox(width: 7),
              Icon(
                Icons.chevron_right_rounded,
                size: 15,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 7),
              LevelBadge(level: prediction.listingLevel),
            ],
          ],
        ),
        const SizedBox(height: 6),
        _IcoHeaderCharacterIdRow(characterId: info.characterId),
      ],
    );
  }

  /// 角色展示名称
  String get _displayName {
    final name = TinygrailFormatters.decodeHtmlEntities(info.name).trim();
    if (name.isEmpty) {
      return '#${info.characterId}';
    }

    return name;
  }
}

/// ICO 头部角色 ID 行
class _IcoHeaderCharacterIdRow extends StatelessWidget {
  /// 创建 ICO 头部角色 ID 行
  ///
  /// [characterId] 角色 ID
  const _IcoHeaderCharacterIdRow({
    required this.characterId,
  });

  /// 角色 ID
  final int characterId;

  /// 构建 ICO 头部角色 ID 行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            await _copyCharacterId(context);
          },
          borderRadius: BorderRadius.circular(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '#$characterId',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.copy_rounded,
                size: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 复制角色 ID
  ///
  /// [context] 当前组件树上下文
  Future<void> _copyCharacterId(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: '#$characterId'),
    );
    if (!context.mounted) {
      return;
    }

    AppToast.info(
      context,
      text: '已复制角色ID',
    );
  }
}

/// ICO 头部数据胶囊组
class _IcoHeaderChips extends StatelessWidget {
  /// 创建 ICO 头部数据胶囊组
  ///
  /// [info] ICO 头部资料
  /// [prediction] ICO 预测数据
  const _IcoHeaderChips({
    required this.info,
    required this.prediction,
  });

  /// ICO 头部资料
  final CharacterDetailIcoInfo info;

  /// ICO 预测数据
  final CharacterDetailIcoPrediction prediction;

  /// 构建 ICO 头部数据胶囊组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _IcoHeaderInfoChip(
          text: '已筹集 ${Formatters.tinygrailCurrency(info.total)}',
        ),
        _IcoHeaderInfoChip(
          text: '发行量 ${Formatters.groupedNumber(prediction.amount)}股',
        ),
        _IcoHeaderInfoChip(
          text: '发行价 ${Formatters.tinygrailCurrency(prediction.displayPrice)}',
        ),
      ],
    );
  }
}

/// ICO 头部进度区
class _IcoHeaderProgress extends StatelessWidget {
  /// 创建 ICO 头部进度区
  ///
  /// [info] ICO 头部资料
  /// [prediction] ICO 预测数据
  const _IcoHeaderProgress({
    required this.info,
    required this.prediction,
  });

  /// ICO 头部资料
  final CharacterDetailIcoInfo info;

  /// ICO 预测数据
  final CharacterDetailIcoPrediction prediction;

  /// 构建 ICO 头部进度区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = prediction.percent;
    final progressColor = _levelColor(prediction.level).withValues(alpha: 0.92);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _IcoHeaderProgressMessage(prediction: prediction),
            ),
            const SizedBox(width: 12),
            Text(
              '$percent%',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: prediction.progress,
            minHeight: 4,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor,
            ),
          ),
        ),
      ],
    );
  }

  /// 获取 ICO 等级对应的进度条颜色
  ///
  /// [level] ICO 等级
  static Color _levelColor(int level) {
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

/// ICO 头部进度目标文案
class _IcoHeaderProgressMessage extends StatelessWidget {
  /// 创建 ICO 头部进度目标文案
  ///
  /// [prediction] ICO 预测数据
  const _IcoHeaderProgressMessage({
    required this.prediction,
  });

  /// ICO 预测数据
  final CharacterDetailIcoPrediction prediction;

  /// 构建 ICO 头部进度目标文案
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = TextStyle(
      color: colorScheme.onSurfaceVariant,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      height: 1.15,
    );
    final accentStyle = baseStyle.copyWith(color: colorScheme.primary);
    final moneyNeeded = prediction.next - prediction.total;

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: _buildSpans(accentStyle, moneyNeeded),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建进度目标文案片段
  ///
  /// [accentStyle] 数字强调样式
  /// [moneyNeeded] 还需金额
  List<InlineSpan> _buildSpans(
    TextStyle accentStyle,
    double moneyNeeded,
  ) {
    final needsUsers = prediction.users > 0;
    final needsMoney = moneyNeeded > 0;
    if (!needsUsers && !needsMoney) {
      return <InlineSpan>[
        TextSpan(
          text: prediction.level > 0 ? '已达到下一等级条件' : '已满足上市条件',
        ),
      ];
    }

    return <InlineSpan>[
      TextSpan(text: prediction.level > 0 ? '升级还需' : '上市还需'),
      if (needsUsers) ...[
        TextSpan(text: '${prediction.users}', style: accentStyle),
        const TextSpan(text: '名参与者'),
      ],
      if (needsMoney) ..._buildMoneySpans(accentStyle, moneyNeeded),
    ];
  }

  /// 构建还需金额文案片段
  ///
  /// [accentStyle] 数字强调样式
  /// [moneyNeeded] 还需金额
  List<InlineSpan> _buildMoneySpans(
    TextStyle accentStyle,
    double moneyNeeded,
  ) {
    final moneyText = Formatters.tinygrailCurrency(moneyNeeded);
    if (!moneyText.startsWith('₵')) {
      return <InlineSpan>[
        const TextSpan(text: '投入'),
        TextSpan(text: moneyText, style: accentStyle),
      ];
    }

    return <InlineSpan>[
      const TextSpan(text: '投入'),
      TextSpan(text: moneyText, style: accentStyle),
    ];
  }
}

/// ICO 头部倒计时区
class _IcoHeaderCountdown extends StatelessWidget {
  /// 创建 ICO 头部倒计时区
  ///
  /// [countdown] ICO 倒计时数据
  const _IcoHeaderCountdown({
    required this.countdown,
  });

  /// ICO 倒计时数据
  final _CharacterDetailIcoCountdown countdown;

  /// 构建 ICO 头部倒计时区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    const warningColor = Color(0xFFF5A524);
    final countdownColor = countdown.isEndingSoon
        ? isDark
            ? const Color(0xFFFFD58A)
            : warningColor
        : colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Expanded(
          child: Text(
            countdown.remainingText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: countdownColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              height: 1.1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            countdown.endTimeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.62),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

/// ICO 头部通用信息胶囊
class _IcoHeaderInfoChip extends StatelessWidget {
  /// 创建 ICO 头部通用信息胶囊
  ///
  /// [text] 胶囊文本
  const _IcoHeaderInfoChip({
    required this.text,
  });

  /// 胶囊文本
  final String text;

  /// 构建 ICO 头部通用信息胶囊
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colors = _IcoHeaderChipColors.resolve(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final isHighlighted = text.startsWith('已筹集 ');
    const highlightColor = Color(0xFFF5A524);
    final backgroundColor = isHighlighted
        ? highlightColor.withValues(alpha: isDark ? 0.22 : 0.14)
        : colors.backgroundColor;
    final foregroundColor =
        isHighlighted ? highlightColor : colors.foregroundColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 22, maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// ICO 头部胶囊颜色配置
class _IcoHeaderChipColors {
  /// 创建 ICO 头部胶囊颜色配置
  ///
  /// [backgroundColor] 胶囊背景色
  /// [foregroundColor] 胶囊前景色
  const _IcoHeaderChipColors({
    required this.backgroundColor,
    required this.foregroundColor,
  });

  /// 胶囊背景色
  final Color backgroundColor;

  /// 胶囊前景色
  final Color foregroundColor;

  /// 解析 ICO 头部胶囊颜色配置
  ///
  /// [context] 当前组件树上下文
  static _IcoHeaderChipColors resolve(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return _IcoHeaderChipColors(
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: isDark ? 0.44 : 0.68,
      ),
      foregroundColor: colorScheme.onSurfaceVariant,
    );
  }
}
