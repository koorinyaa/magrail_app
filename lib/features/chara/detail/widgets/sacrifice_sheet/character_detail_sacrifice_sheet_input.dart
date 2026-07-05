part of '../character_detail_sacrifice_sheet.dart';

class _SacrificeAmountField extends StatelessWidget {
  /// 创建资产重组数量输入框
  ///
  /// [controller] 资产重组抽屉控制器
  const _SacrificeAmountField({
    required this.controller,
  });

  /// 资产重组抽屉控制器
  final CharacterDetailSacrificeSheetController controller;

  /// 构建资产重组数量输入框
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final fillColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.48)
        : colorScheme.surfaceContainerLowest;
    final borderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.26 : 0.58,
    );

    return TextField(
      controller: controller.amountController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
      decoration: InputDecoration(
        labelText: '数量',
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        floatingLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
        suffixText: '股',
        suffixStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}

/// 资产重组快捷数量按钮组
class _SacrificeQuickButtons extends StatelessWidget {
  /// 创建资产重组快捷数量按钮组
  ///
  /// [controller] 资产重组抽屉控制器
  const _SacrificeQuickButtons({
    required this.controller,
  });

  /// 资产重组抽屉控制器
  final CharacterDetailSacrificeSheetController controller;

  /// 构建资产重组快捷数量按钮组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (controller.mode == CharacterDetailSacrificeMode.financing) {
      children.add(
        _SacrificeQuickButton(
          text: 'max',
          onPressed: controller.fillMaxAmount,
        ),
      );
    } else {
      children.addAll([
        _SacrificeQuickButton(
          text: '500',
          onPressed: () => controller.fillAmount(500),
        ),
        _SacrificeQuickButton(
          text: '2500',
          onPressed: () => controller.fillAmount(2500),
        ),
        _SacrificeQuickButton(
          text: '12500',
          onPressed: () => controller.fillAmount(12500),
        ),
        _SacrificeQuickButton(
          text: 'max',
          onPressed: controller.fillMaxAmount,
        ),
        _SacrificeQuickButton(
          text: '补塔',
          onPressed: controller.fillTempleAmount,
        ),
      ]);
    }

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

/// 资产重组快捷数量按钮
class _SacrificeQuickButton extends StatelessWidget {
  /// 创建资产重组快捷数量按钮
  ///
  /// [text] 按钮文案
  /// [onPressed] 点击回调
  const _SacrificeQuickButton({
    required this.text,
    required this.onPressed,
  });

  /// 按钮文案
  final String text;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建资产重组快捷数量按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(
        alpha: isDark ? 0.22 : 0.46,
      ),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(
                alpha: isDark ? 0.22 : 0.42,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              text,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 资产重组提交按钮
class _SacrificeSubmitButton extends StatelessWidget {
  /// 创建资产重组提交按钮
  ///
  /// [controller] 资产重组抽屉控制器
  /// [onSubmit] 提交回调
  const _SacrificeSubmitButton({
    required this.controller,
    required this.onSubmit,
  });

  /// 资产重组抽屉控制器
  final CharacterDetailSacrificeSheetController controller;

  /// 提交回调
  final VoidCallback onSubmit;

  /// 构建资产重组提交按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final text = controller.mode == CharacterDetailSacrificeMode.financing
        ? '股权融资'
        : '资产重组';
    final buttonColor =
        controller.mode == CharacterDetailSacrificeMode.financing
            ? const Color(0xFFF25C62)
            : const Color(0xFF17C964);

    return SizedBox(
      height: 42,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor:
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.68),
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        onPressed: controller.canSubmit ? onSubmit : null,
        child: Text(controller.isSubmitting ? '处理中' : text),
      ),
    );
  }
}

/// 资产重组加载骨架
class _SacrificeSheetSkeleton extends StatelessWidget {
  /// 创建资产重组加载骨架
  const _SacrificeSheetSkeleton();

  /// 构建资产重组加载骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Bone(
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone(
                      width: 160,
                      height: 18,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    const SizedBox(height: 8),
                    Bone(
                      width: 92,
                      height: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Bone(
                  height: 96,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Bone(
                  height: 96,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Bone(
            height: 34,
            borderRadius: BorderRadius.circular(14),
          ),
          const SizedBox(height: 14),
          Bone(
            height: 54,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              Bone(
                width: 44,
                height: 24,
                borderRadius: BorderRadius.circular(999),
              ),
              Bone(
                width: 54,
                height: 24,
                borderRadius: BorderRadius.circular(999),
              ),
              Bone(
                width: 66,
                height: 24,
                borderRadius: BorderRadius.circular(999),
              ),
              Bone(
                width: 44,
                height: 24,
                borderRadius: BorderRadius.circular(999),
              ),
              Bone(
                width: 48,
                height: 24,
                borderRadius: BorderRadius.circular(999),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Bone(
            height: 42,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}
