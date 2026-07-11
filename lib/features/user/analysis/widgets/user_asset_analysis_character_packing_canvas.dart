part of 'user_asset_analysis_character_packing_section.dart';

/// 用户资产分析资产占比来源图例
class _AssetProportionSourceLegend extends StatelessWidget {
  /// 创建用户资产分析资产占比来源图例
  ///
  /// [key] Flutter 组件标识
  /// [mode] 资产占比统计模式
  const _AssetProportionSourceLegend({
    super.key,
    required this.mode,
  });

  /// 资产占比统计模式
  final UserAssetAnalysisAssetProportionMode mode;

  /// 构建用户资产分析资产占比来源图例
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AssetProportionSourceLegendItem(
          label: '持股',
          color: _characterDividendColor,
          textColor: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        _AssetProportionSourceLegendItem(
          label: '圣殿',
          color: _templeDividendColor,
          textColor: colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

/// 用户资产分析资产占比模式切换
class _AssetProportionModeSwitch extends StatelessWidget {
  /// 创建用户资产分析资产占比模式切换
  ///
  /// [mode] 当前统计模式
  /// [onChanged] 统计模式切换回调
  const _AssetProportionModeSwitch({
    required this.mode,
    required this.onChanged,
  });

  /// 当前统计模式
  final UserAssetAnalysisAssetProportionMode mode;

  /// 统计模式切换回调
  final ValueChanged<UserAssetAnalysisAssetProportionMode> onChanged;

  /// 构建用户资产分析资产占比模式切换
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return SizedBox(
      width: 126,
      height: 32,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.055)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              _AssetProportionModeOption(
                label: '股息',
                mode: UserAssetAnalysisAssetProportionMode.dividend,
                currentMode: mode,
                onChanged: onChanged,
              ),
              _AssetProportionModeOption(
                label: '资产',
                mode: UserAssetAnalysisAssetProportionMode.assets,
                currentMode: mode,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 用户资产分析资产占比模式选项
class _AssetProportionModeOption extends StatelessWidget {
  /// 创建用户资产分析资产占比模式选项
  ///
  /// [label] 选项文案
  /// [mode] 选项统计模式
  /// [currentMode] 当前统计模式
  /// [onChanged] 统计模式切换回调
  const _AssetProportionModeOption({
    required this.label,
    required this.mode,
    required this.currentMode,
    required this.onChanged,
  });

  /// 选项文案
  final String label;

  /// 选项统计模式
  final UserAssetAnalysisAssetProportionMode mode;

  /// 当前统计模式
  final UserAssetAnalysisAssetProportionMode currentMode;

  /// 统计模式切换回调
  final ValueChanged<UserAssetAnalysisAssetProportionMode> onChanged;

  /// 构建用户资产分析资产占比模式选项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = mode == currentMode;
    final color = mode == UserAssetAnalysisAssetProportionMode.dividend
        ? _coreGold
        : _coreCyan;
    final isDark = colorScheme.brightness == Brightness.dark;
    final selectedTextColor = Color.lerp(
      color,
      colorScheme.onSurface,
      isDark ? 0.06 : 0.28,
    )!;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: selected ? null : () => onChanged(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? isDark
                      ? colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.88,
                        )
                      : colorScheme.surface.withValues(alpha: 0.96)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: selected
                  ? Border.all(
                      color: colorScheme.onSurface.withValues(
                        alpha: isDark ? 0.12 : 0.07,
                      ),
                    )
                  : null,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.16 : 0.08,
                        ),
                        blurRadius: isDark ? 5 : 7,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : const [],
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? selectedTextColor
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 用户资产分析资产占比来源图例项
class _AssetProportionSourceLegendItem extends StatelessWidget {
  /// 创建用户资产分析资产占比来源图例项
  ///
  /// [label] 来源标签
  /// [color] 来源颜色
  /// [textColor] 图例文字颜色
  const _AssetProportionSourceLegendItem({
    required this.label,
    required this.color,
    required this.textColor,
  });

  /// 来源标签
  final String label;

  /// 来源颜色
  final Color color;

  /// 图例文字颜色
  final Color textColor;

  /// 构建用户资产分析资产占比来源图例项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.38),
                blurRadius: 7,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

/// 用户资产分析角色圆图画布
class _CharacterPackingCanvas extends StatelessWidget {
  /// 创建用户资产分析角色圆图画布
  ///
  /// [layout] 圆图布局
  /// [mode] 资产占比统计模式
  /// [onCharacterTap] 角色点击回调，为空时禁用点击
  const _CharacterPackingCanvas({
    required this.layout,
    required this.mode,
    required this.onCharacterTap,
  });

  /// 圆图布局
  final List<_PackedBubbleLayoutItem> layout;

  /// 资产占比统计模式
  final UserAssetAnalysisAssetProportionMode mode;

  /// 角色点击回调
  final ValueChanged<UserAssetAnalysisCharacterBubble>? onCharacterTap;

  /// 构建用户资产分析角色圆图画布
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final orbitColor = isDark
        ? Colors.white.withValues(alpha: 0.085)
        : const Color(0xFF335B66).withValues(alpha: 0.12);

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          _PackingDust(isDark: isDark),
          _PackingGuideLine(
            angle: -0.28,
            color: orbitColor,
          ),
          _PackingGuideLine(
            angle: 0.72,
            color: orbitColor.withValues(alpha: 0.68),
          ),
          _OrbitRing(
            widthFactor: 0.90,
            heightFactor: 0.90,
            angle: 0,
            color: orbitColor.withValues(alpha: 0.72),
          ),
          _OrbitRing(
            widthFactor: 0.91,
            heightFactor: 0.60,
            angle: -0.20,
            color: orbitColor,
          ),
          _OrbitRing(
            widthFactor: 0.76,
            heightFactor: 0.47,
            angle: 0.30,
            color: orbitColor,
          ),
          _OrbitRing(
            widthFactor: 0.55,
            heightFactor: 0.34,
            angle: -0.48,
            color: orbitColor,
          ),
          for (final item in layout)
            _PackedCharacterBubble(
              item: item,
              mode: mode,
              disableAnimations: disableAnimations,
              onTap: onCharacterTap == null
                  ? null
                  : () => onCharacterTap!(item.bubble),
            ),
        ],
      ),
    );
  }
}

/// 用户资产分析角色圆图微光点阵
class _PackingDust extends StatelessWidget {
  /// 创建用户资产分析角色圆图微光点阵
  ///
  /// [isDark] 是否为深色模式
  const _PackingDust({required this.isDark});

  /// 是否为深色模式
  final bool isDark;

  /// 构建用户资产分析角色圆图微光点阵
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (var index = 0; index < 26; index += 1)
                Positioned(
                  left: constraints.maxWidth * (((index * 47) % 97) / 100),
                  top: constraints.maxHeight *
                      ((((index * 71) + 13) % 97) / 100),
                  child: Container(
                    width: index % 6 == 0 ? 2.0 : 1.0,
                    height: index % 6 == 0 ? 2.0 : 1.0,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : const Color(0xFF335B66))
                          .withValues(alpha: index % 6 == 0 ? 0.34 : 0.20),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// 用户资产分析角色圆图引导线
class _PackingGuideLine extends StatelessWidget {
  /// 创建用户资产分析角色圆图引导线
  ///
  /// [angle] 引导线旋转弧度
  /// [color] 引导线颜色
  const _PackingGuideLine({
    required this.angle,
    required this.color,
  });

  /// 引导线旋转弧度
  final double angle;

  /// 引导线颜色
  final Color color;

  /// 构建用户资产分析角色圆图引导线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: angle,
        child: FractionallySizedBox(
          widthFactor: 0.86,
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  color,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 用户资产分析角色圆图轨道
class _OrbitRing extends StatelessWidget {
  /// 创建用户资产分析角色圆图轨道
  ///
  /// [widthFactor] 轨道宽度比例
  /// [heightFactor] 轨道高度比例
  /// [angle] 轨道旋转弧度
  /// [color] 轨道颜色
  const _OrbitRing({
    required this.widthFactor,
    required this.heightFactor,
    required this.angle,
    required this.color,
  });

  final double widthFactor;
  final double heightFactor;
  final double angle;
  final Color color;

  /// 构建用户资产分析角色圆图轨道
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: angle,
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          heightFactor: heightFactor,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color),
            ),
          ),
        ),
      ),
    );
  }
}

/// 用户资产分析空资产占比
class _EmptyCharacterPacking extends StatelessWidget {
  /// 创建用户资产分析空资产占比
  ///
  /// [mode] 资产占比统计模式
  const _EmptyCharacterPacking({required this.mode});

  /// 资产占比统计模式
  final UserAssetAnalysisAssetProportionMode mode;

  /// 构建用户资产分析空资产占比
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Text(
        mode == UserAssetAnalysisAssetProportionMode.dividend
            ? '暂无可展示的角色总息'
            : '暂无可展示的角色资产',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
