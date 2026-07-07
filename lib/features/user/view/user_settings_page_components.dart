part of 'user_settings_page.dart';

/// 设置页表面分组
class _SettingsSurface extends StatelessWidget {
  /// 创建设置页表面分组
  ///
  /// [child] 分组内容
  const _SettingsSurface({required this.child});

  /// 分组内容
  final Widget child;

  /// 构建设置页表面分组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerLow : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 设置页普通跳转项
class _SettingsActionTile extends StatelessWidget {
  /// 创建设置页普通跳转项
  ///
  /// [icon] 左侧默认图标
  /// [leadingIcon] 自定义左侧图标
  /// [label] 选项文字
  /// [showNewBadge] 是否显示新版本标签
  /// [trailingIcon] 右侧状态图标
  /// [onPressed] 点击回调
  const _SettingsActionTile({
    this.icon,
    this.leadingIcon,
    required this.label,
    this.showNewBadge = false,
    this.trailingIcon = Icons.chevron_right_rounded,
    required this.onPressed,
  }) : assert(icon != null || leadingIcon != null);

  /// 左侧默认图标
  final IconData? icon;

  /// 自定义左侧图标
  final Widget? leadingIcon;

  /// 选项文字
  final String label;

  /// 是否显示新版本标签
  final bool showNewBadge;

  /// 右侧状态图标
  final IconData trailingIcon;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建设置页普通跳转项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              leadingIcon ?? Icon(icon, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (showNewBadge) ...[
                const _SettingsNewBadge(),
                const SizedBox(width: 10),
              ],
              Icon(
                trailingIcon,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 设置页带当前值的跳转项
class _SettingsValueActionTile extends StatelessWidget {
  /// 创建设置页带当前值的跳转项
  ///
  /// [icon] 左侧图标
  /// [label] 选项文字
  /// [value] 当前值文字
  /// [onPressed] 点击回调
  const _SettingsValueActionTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onPressed,
  });

  /// 左侧图标
  final IconData icon;

  /// 选项文字
  final String label;

  /// 当前值文字
  final String value;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建设置页带当前值的跳转项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                Icon(icon, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 设置页新版本标签
class _SettingsNewBadge extends StatelessWidget {
  /// 创建设置页新版本标签
  const _SettingsNewBadge();

  /// 构建设置页新版本标签
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          'New',
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Bangumi 镜像开关
class _BangumiMirrorSwitchTile extends StatelessWidget {
  /// 创建 Bangumi 镜像开关
  ///
  /// [value] 是否使用 Bangumi 镜像
  /// [mirrorHost] Bangumi 镜像域名
  /// [onChanged] 开关变化回调
  const _BangumiMirrorSwitchTile({
    required this.value,
    required this.mirrorHost,
    required this.onChanged,
  });

  /// 是否使用 Bangumi 镜像
  final bool value;

  /// Bangumi 镜像域名
  final String mirrorHost;

  /// 开关变化回调
  final ValueChanged<bool> onChanged;

  /// 构建 Bangumi 镜像开关
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
      child: Row(
        children: [
          const Icon(Icons.travel_explore_rounded, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '使用 $mirrorHost 镜像',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
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
    );
  }
}

/// 设置页普通开关
class _SettingsSwitchTile extends StatelessWidget {
  /// 创建设置页普通开关
  ///
  /// [icon] 左侧图标
  /// [label] 选项文字
  /// [value] 当前开关状态
  /// [onChanged] 开关变化回调
  const _SettingsSwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  /// 左侧图标
  final IconData icon;

  /// 选项文字
  final String label;

  /// 当前开关状态
  final bool value;

  /// 开关变化回调
  final ValueChanged<bool> onChanged;

  /// 构建设置页普通开关
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
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
    );
  }
}

/// 退出登录按钮
class _SignOutButton extends StatelessWidget {
  /// 创建退出登录按钮
  ///
  /// [isDisabled] 是否禁用点击
  /// [onPressed] 退出按钮点击回调
  const _SignOutButton({
    required this.isDisabled,
    required this.onPressed,
  });

  /// 是否禁用点击
  final bool isDisabled;

  /// 退出按钮点击回调
  final VoidCallback onPressed;

  /// 构建退出登录按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: 22,
                color: colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '退出登录',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
