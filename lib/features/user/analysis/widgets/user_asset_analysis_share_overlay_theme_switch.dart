part of 'user_asset_analysis_share_overlay.dart';

/// 分享预览主题切换
class _SharePreviewThemeSwitch extends StatelessWidget {
  /// 创建分享预览主题切换
  ///
  /// [brightness] 当前主题亮度
  /// [enabled] 是否允许切换
  /// [onChanged] 主题切换回调
  const _SharePreviewThemeSwitch({
    required this.brightness,
    required this.enabled,
    required this.onChanged,
  });

  final Brightness brightness;
  final bool enabled;
  final ValueChanged<Brightness> onChanged;

  /// 构建分享预览主题切换
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: SizedBox(
        width: 88,
        height: 40,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.26),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                _SharePreviewThemeOption(
                  icon: LucideIcons.sun,
                  value: Brightness.light,
                  currentValue: brightness,
                  enabled: enabled,
                  onChanged: onChanged,
                ),
                _SharePreviewThemeOption(
                  icon: LucideIcons.moon,
                  value: Brightness.dark,
                  currentValue: brightness,
                  enabled: enabled,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 分享预览主题选项
class _SharePreviewThemeOption extends StatelessWidget {
  /// 创建分享预览主题选项
  ///
  /// [icon] 主题图标
  /// [value] 选项主题亮度
  /// [currentValue] 当前主题亮度
  /// [enabled] 是否允许切换
  /// [onChanged] 主题切换回调
  const _SharePreviewThemeOption({
    required this.icon,
    required this.value,
    required this.currentValue,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final Brightness value;
  final Brightness currentValue;
  final bool enabled;
  final ValueChanged<Brightness> onChanged;

  /// 构建分享预览主题选项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final selected = value == currentValue;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: !enabled || selected ? null : () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(alpha: 0.20)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(17),
              border: selected
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    )
                  : null,
            ),
            child: Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
