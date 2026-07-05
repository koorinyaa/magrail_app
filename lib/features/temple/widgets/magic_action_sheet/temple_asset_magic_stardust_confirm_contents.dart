part of '../temple_asset_magic_action_sheet.dart';

/// 星光碎片确认内容
class _TempleAssetStardustConfirmContent extends StatefulWidget {
  /// 创建星光碎片确认内容
  ///
  /// [data] 当前圣殿资产卡片展示数据
  /// [source] 已选择的消耗角色
  /// [amountController] 消耗数量输入控制器
  /// [downSacrificesNotifier] 降塔模式状态
  /// [rateValue] 补充固定资产效率数值
  const _TempleAssetStardustConfirmContent({
    required this.data,
    required this.source,
    required this.amountController,
    required this.downSacrificesNotifier,
    required this.rateValue,
  });

  /// 当前圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 已选择的消耗角色
  final CharacterDetailSearchItem source;

  /// 消耗数量输入控制器
  final TextEditingController amountController;

  /// 降塔模式状态
  final ValueNotifier<bool> downSacrificesNotifier;

  /// 补充固定资产效率数值
  final int rateValue;

  /// 创建星光碎片确认内容状态
  @override
  State<_TempleAssetStardustConfirmContent> createState() =>
      _TempleAssetStardustConfirmContentState();
}

/// 星光碎片确认内容状态
class _TempleAssetStardustConfirmContentState
    extends State<_TempleAssetStardustConfirmContent> {
  /// 初始化星光碎片确认内容状态
  @override
  void initState() {
    super.initState();
    widget.amountController.addListener(_handleChanged);
    widget.downSacrificesNotifier.addListener(_handleChanged);
  }

  /// 更新星光碎片确认内容配置
  ///
  /// [oldWidget] 更新前的组件配置
  @override
  void didUpdateWidget(_TempleAssetStardustConfirmContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amountController != widget.amountController) {
      oldWidget.amountController.removeListener(_handleChanged);
      widget.amountController.addListener(_handleChanged);
    }
    if (oldWidget.downSacrificesNotifier != widget.downSacrificesNotifier) {
      oldWidget.downSacrificesNotifier.removeListener(_handleChanged);
      widget.downSacrificesNotifier.addListener(_handleChanged);
    }
  }

  /// 释放星光碎片确认内容状态
  @override
  void dispose() {
    widget.amountController.removeListener(_handleChanged);
    widget.downSacrificesNotifier.removeListener(_handleChanged);
    super.dispose();
  }

  /// 处理星光碎片确认内容变化
  void _handleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// 构建星光碎片确认内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentName = TinygrailFormatters.decodeHtmlEntities(
      widget.data.characterName,
    );
    final sourceName = TinygrailFormatters.decodeHtmlEntities(
      widget.source.name,
    );
    final amount = int.tryParse(widget.amountController.text.trim()) ?? 0;
    final convertedAmount = amount ~/ widget.rateValue;
    final availableAmount = widget.source.userAmount;
    final isDownSacrifices = widget.downSacrificesNotifier.value;
    final actionText = isDownSacrifices
        ? '降低「$currentName」${Formatters.groupedNumber(convertedAmount)}点固定资产上限'
        : '补充「$currentName」${Formatters.groupedNumber(convertedAmount)}点固定资产';
    final description =
        '消耗「$sourceName」${Formatters.groupedNumber(amount)}活股，$actionText，效率${widget.rateValue}:1';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TempleAssetStardustModeSelector(
          isDownSacrifices: isDownSacrifices,
          onChanged: (value) {
            widget.downSacrificesNotifier.value = value;
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TempleAssetMagicConfirmTransferLayout(
                left: _TempleAssetMagicTargetPreview(
                  target: widget.source,
                  stockText:
                      '可用 ${Formatters.groupedNumber(availableAmount)} 股',
                ),
                right: _TempleAssetMagicTemplePreview(data: widget.data),
                arrowColor: colorScheme.onSurfaceVariant,
                description: description,
              ),
              const SizedBox(height: 14),
              _TempleAssetMagicNumberField(
                controller: widget.amountController,
                label: '消耗数量',
                suffixText: '股',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 闪光结晶确认内容
class _TempleAssetStarbreakConfirmContent extends StatelessWidget {
  /// 创建闪光结晶确认内容
  ///
  /// [data] 当前圣殿资产卡片展示数据
  /// [target] 已选择的攻击目标
  /// [rateText] 攻击倍率文案
  const _TempleAssetStarbreakConfirmContent({
    required this.data,
    required this.target,
    required this.rateText,
  });

  /// 当前圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 已选择的攻击目标
  final CharacterDetailSearchItem target;

  /// 攻击倍率文案
  final String rateText;

  /// 构建闪光结晶确认内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentName = TinygrailFormatters.decodeHtmlEntities(
      data.characterName,
    );
    final targetName = TinygrailFormatters.decodeHtmlEntities(
      target.name,
    );
    final rate = double.tryParse(rateText) ?? 0;
    final minDamage = (20 * rate).floor();
    final maxDamage = (200 * rate).floor();
    final damageText =
        '${Formatters.groupedNumber(minDamage)}-${Formatters.groupedNumber(maxDamage)}';
    final description =
        '消耗「$currentName」100点固定资产，对「$targetName」星之力造成$damageText的伤害，倍率$rateText';

    return _TempleAssetMagicConfirmTransferLayout(
      left: _TempleAssetMagicTemplePreview(data: data),
      right: _TempleAssetMagicTargetPreview(
        target: target,
        stockText:
            '星之力 ${Formatters.groupedNumber(math.max(0, target.starForces))}',
      ),
      arrowColor: colorScheme.onSurfaceVariant,
      description: description,
    );
  }
}

/// 星光碎片模式选择器
class _TempleAssetStardustModeSelector extends StatelessWidget {
  /// 创建星光碎片模式选择器
  ///
  /// [isDownSacrifices] 是否选择降塔
  /// [onChanged] 模式变更回调
  const _TempleAssetStardustModeSelector({
    required this.isDownSacrifices,
    required this.onChanged,
  });

  /// 是否选择降塔
  final bool isDownSacrifices;

  /// 模式变更回调
  final ValueChanged<bool> onChanged;

  /// 构建星光碎片模式选择器
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: isDark ? 0.58 : 0.92,
    );
    final selectedColor = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerLowest;

    return SizedBox(
      height: 44,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final curveWidth = math.min(height * 1.5, width * 0.16);
          final indicatorWidth = width / 2 + curveWidth * 1.5;
          final indicatorLeft =
              isDownSacrifices ? width / 2 - curveWidth / 2 : -curveWidth;

          return Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: backgroundColor),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: indicatorLeft,
                top: 0,
                bottom: 0,
                width: indicatorWidth,
                child: ClipPath(
                  clipper: _TempleAssetStardustModeClipper(
                    curveWidth: curveWidth,
                  ),
                  child: ColoredBox(color: selectedColor),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _TempleAssetStardustModeSegment(
                      label: '补塔',
                      selected: !isDownSacrifices,
                      onPressed: () => onChanged(false),
                    ),
                  ),
                  Expanded(
                    child: _TempleAssetStardustModeSegment(
                      label: '降塔',
                      selected: isDownSacrifices,
                      onPressed: () => onChanged(true),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 星光碎片模式选中背景裁剪器
class _TempleAssetStardustModeClipper extends CustomClipper<Path> {
  /// 创建星光碎片模式选中背景裁剪器
  ///
  /// [curveWidth] 曲线区域宽度
  const _TempleAssetStardustModeClipper({
    required this.curveWidth,
  });

  /// 曲线区域宽度
  final double curveWidth;

  /// 构建星光碎片模式选中背景路径
  ///
  /// [size] 可绘制区域尺寸
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final path = Path();

    path
      ..moveTo(curveWidth, 0)
      ..lineTo(width - curveWidth, 0)
      ..cubicTo(
        width - curveWidth / 2,
        0,
        width - curveWidth / 2,
        height,
        width,
        height,
      )
      ..lineTo(0, height)
      ..cubicTo(
        curveWidth / 2,
        height,
        curveWidth / 2,
        0,
        curveWidth,
        0,
      )
      ..close();
    return path;
  }

  /// 判断星光碎片模式选中背景是否需要重绘
  ///
  /// [oldClipper] 上一次裁剪器
  @override
  bool shouldReclip(_TempleAssetStardustModeClipper oldClipper) {
    return oldClipper.curveWidth != curveWidth;
  }
}

/// 星光碎片模式分段按钮
class _TempleAssetStardustModeSegment extends StatelessWidget {
  /// 创建星光碎片模式分段按钮
  ///
  /// [label] 按钮文案
  /// [selected] 是否选中
  /// [onPressed] 点击回调
  const _TempleAssetStardustModeSegment({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  /// 按钮文案
  final String label;

  /// 是否选中
  final bool selected;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建星光碎片模式分段按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        child: SizedBox.expand(
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? colorScheme.primary : colorScheme.onSurface,
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
