part of '../temple_asset_magic_action_sheet.dart';

/// 圣殿资产魔法道具图片图标
class _TempleAssetMagicImageIcon extends StatelessWidget {
  /// 创建圣殿资产魔法道具图片图标
  ///
  /// [imageAsset] 本地图标资源
  /// [fallbackIcon] 资源加载失败时的图标
  const _TempleAssetMagicImageIcon({
    required this.imageAsset,
    required this.fallbackIcon,
  });

  /// 本地图标资源
  final String imageAsset;

  /// 资源加载失败时的图标
  final IconData fallbackIcon;

  /// 构建圣殿资产魔法道具图片图标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox.square(
        dimension: 40,
        child: Transform.scale(
          scale: 1.24,
          child: Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  fallbackIcon,
                  size: 20,
                  color: colorScheme.primary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 圣殿资产魔法道具操作标题
class _TempleAssetMagicSheetHeader extends StatelessWidget {
  /// 创建圣殿资产魔法道具操作标题
  ///
  /// [action] 操作类型
  /// [characterName] 当前角色名称
  /// [characterId] 当前角色 ID
  const _TempleAssetMagicSheetHeader({
    required this.action,
    required this.characterName,
    required this.characterId,
  });

  /// 操作类型
  final TempleAssetMagicAction action;

  /// 当前角色名称
  final String characterName;

  /// 当前角色 ID
  final int characterId;

  /// 构建圣殿资产魔法道具操作标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedCharacterName =
        characterName.trim().isEmpty ? '角色名称' : characterName.trim();
    final subtitle = '#$characterId 「$resolvedCharacterName」';
    final iconWidget = switch (action) {
      TempleAssetMagicAction.guidepost => const _TempleAssetMagicImageIcon(
          imageAsset: TempleAssetMagicAssets.guidepostIcon,
          fallbackIcon: LucideIcons.mapPinned,
        ),
      TempleAssetMagicAction.chaosCube => const _TempleAssetMagicImageIcon(
          imageAsset: TempleAssetMagicAssets.chaosCubeIcon,
          fallbackIcon: LucideIcons.dices,
        ),
      TempleAssetMagicAction.fisheye => const _TempleAssetMagicImageIcon(
          imageAsset: TempleAssetMagicAssets.fisheyeIcon,
          fallbackIcon: LucideIcons.eye,
        ),
      TempleAssetMagicAction.stardust => const _TempleAssetMagicImageIcon(
          imageAsset: TempleAssetMagicAssets.stardustIcon,
          fallbackIcon: LucideIcons.sparkles,
        ),
      TempleAssetMagicAction.starbreak => const _TempleAssetMagicImageIcon(
          imageAsset: TempleAssetMagicAssets.starbreakIcon,
          fallbackIcon: LucideIcons.flame,
        ),
      TempleAssetMagicAction.starForces => _TempleAssetMagicSymbolIcon(
          icon: Symbols.auto_awesome,
          color: colorScheme.primary,
        ),
    };

    final titleContent = Row(
      children: [
        iconWidget,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return titleContent;
  }

  /// 标题文案
  String get _label {
    return switch (action) {
      TempleAssetMagicAction.guidepost => '虚空道标',
      TempleAssetMagicAction.chaosCube => '混沌魔方',
      TempleAssetMagicAction.fisheye => '鲤鱼之眼',
      TempleAssetMagicAction.stardust => '星光碎片',
      TempleAssetMagicAction.starbreak => '闪光结晶',
      TempleAssetMagicAction.starForces => '星之力',
    };
  }
}

/// 圣殿资产魔法道具符号图标
class _TempleAssetMagicSymbolIcon extends StatelessWidget {
  /// 创建圣殿资产魔法道具符号图标
  ///
  /// [icon] 符号图标
  /// [color] 图标颜色
  const _TempleAssetMagicSymbolIcon({
    required this.icon,
    required this.color,
  });

  /// 符号图标
  final IconData icon;

  /// 图标颜色
  final Color color;

  /// 构建圣殿资产魔法道具符号图标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 20,
          color: color,
        ),
      ),
    );
  }
}

/// 圣殿资产魔法道具数量输入框
class _TempleAssetMagicNumberField extends StatelessWidget {
  /// 创建圣殿资产魔法道具数量输入框
  ///
  /// [controller] 输入控制器
  /// [label] 标签文案
  /// [suffixText] 单位文案，为空时不显示
  const _TempleAssetMagicNumberField({
    required this.controller,
    required this.label,
    required this.suffixText,
  });

  /// 输入控制器
  final TextEditingController controller;

  /// 标签文案
  final String label;

  /// 单位文案，为空时不显示
  final String suffixText;

  /// 构建圣殿资产魔法道具数量输入框
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
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
      decoration: InputDecoration(
        labelText: label,
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
        suffixText: suffixText.trim().isEmpty ? null : suffixText,
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

/// 圣殿资产魔法道具快捷数量按钮组
class _TempleAssetMagicQuickButtons extends StatelessWidget {
  /// 创建圣殿资产魔法道具快捷数量按钮组
  ///
  /// [buttons] 快捷数量按钮配置
  const _TempleAssetMagicQuickButtons({
    required this.buttons,
  });

  /// 快捷数量按钮配置
  final List<_TempleAssetMagicQuickButtonData> buttons;

  /// 构建圣殿资产魔法道具快捷数量按钮组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final button in buttons)
          _TempleAssetMagicQuickButton(
            text: button.text,
            onPressed: button.onPressed,
          ),
      ],
    );
  }
}

/// 圣殿资产魔法道具快捷数量按钮配置
class _TempleAssetMagicQuickButtonData {
  /// 创建圣殿资产魔法道具快捷数量按钮配置
  ///
  /// [text] 按钮文案
  /// [onPressed] 点击回调，为空时禁用
  const _TempleAssetMagicQuickButtonData({
    required this.text,
    required this.onPressed,
  });

  /// 按钮文案
  final String text;

  /// 点击回调
  final VoidCallback? onPressed;
}

/// 圣殿资产魔法道具快捷数量按钮
class _TempleAssetMagicQuickButton extends StatelessWidget {
  /// 创建圣殿资产魔法道具快捷数量按钮
  ///
  /// [text] 按钮文案
  /// [onPressed] 点击回调，为空时禁用
  const _TempleAssetMagicQuickButton({
    required this.text,
    required this.onPressed,
  });

  /// 按钮文案
  final String text;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 构建圣殿资产魔法道具快捷数量按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final enabled = onPressed != null;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(
        alpha: enabled ? (isDark ? 0.22 : 0.46) : (isDark ? 0.14 : 0.28),
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
                alpha: enabled ? (isDark ? 0.22 : 0.42) : 0.18,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              text,
              style: TextStyle(
                color: enabled
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.48),
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

/// 圣殿资产魔法道具开关行
class _TempleAssetMagicSwitchRow extends StatelessWidget {
  /// 创建圣殿资产魔法道具开关行
  ///
  /// [label] 标签文案
  /// [value] 当前值
  /// [onChanged] 切换回调
  /// [detail] 说明文案
  const _TempleAssetMagicSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.detail,
  });

  /// 标签文案
  final String label;

  /// 当前值
  final bool value;

  /// 切换回调
  final ValueChanged<bool>? onChanged;

  /// 说明文案
  final String detail;

  /// 构建圣殿资产魔法道具开关行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final enabled = onChanged != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: _insetDecoration(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(
                      alpha: value ? 0.14 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      LucideIcons.starPlus,
                      size: 18,
                      color: value
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return null;
                    }

                    return colorScheme.onSurfaceVariant.withValues(
                      alpha: isDark ? 0.92 : 0.78,
                    );
                  }),
                  trackColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return null;
                    }

                    return colorScheme.onSurfaceVariant.withValues(
                      alpha: isDark ? 0.24 : 0.16,
                    );
                  }),
                  trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return null;
                    }

                    return colorScheme.outlineVariant.withValues(
                      alpha: isDark ? 0.72 : 0.44,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
