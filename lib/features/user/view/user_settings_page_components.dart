part of 'user_settings_page.dart';

/// 设置分组标题
class _SettingsSectionLabel extends StatelessWidget {
  /// 创建设置分组标题
  ///
  /// [label] 分组标题
  const _SettingsSectionLabel({required this.label});

  /// 分组标题
  final String label;

  /// 构建设置分组标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      label,
      style: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

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
  /// [icon] 左侧图标
  /// [label] 选项文字
  /// [showNewBadge] 是否显示新版本标签
  /// [onPressed] 点击回调
  const _SettingsActionTile({
    required this.icon,
    required this.label,
    this.showNewBadge = false,
    required this.onPressed,
  });

  /// 左侧图标
  final IconData icon;

  /// 选项文字
  final String label;

  /// 是否显示新版本标签
  final bool showNewBadge;

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
              if (showNewBadge) ...[
                const _SettingsNewBadge(),
                const SizedBox(width: 10),
              ],
              Icon(
                Icons.chevron_right_rounded,
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
