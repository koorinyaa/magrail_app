part of 'bot_config_page.dart';

/// bot 设置表面
class _BotSurface extends StatelessWidget {
  /// 创建 bot 设置表面
  ///
  /// [child] 表面内容
  const _BotSurface({required this.child});

  /// 表面内容
  final Widget child;

  /// 构建 bot 设置表面
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

/// bot 表面分割线
class _BotDivider extends StatelessWidget {
  /// 创建 bot 表面分割线
  const _BotDivider();

  /// 构建 bot 表面分割线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(
            alpha: 0.72,
          ),
    );
  }
}

/// bot 开关行
class _BotSwitchRow extends StatelessWidget {
  /// 创建 bot 开关行
  ///
  /// [label] 左侧文案
  /// [value] 当前开关值
  /// [detail] 左侧说明文案
  /// [onChanged] 开关变更回调
  const _BotSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.detail,
  });

  /// 左侧文案
  final String label;

  /// 当前开关值
  final bool value;

  /// 左侧说明文案
  final String? detail;

  /// 开关变更回调
  final ValueChanged<bool> onChanged;

  /// 构建 bot 开关行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final detail = this.detail;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (detail != null && detail.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
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

/// bot 选择行
class _BotSelectRow extends StatelessWidget {
  /// 创建 bot 选择行
  ///
  /// [label] 左侧文案
  /// [value] 当前值文案
  /// [valueWidget] 当前值展示组件
  /// [onPressed] 点击回调
  const _BotSelectRow({
    required this.label,
    required this.value,
    required this.onPressed,
    this.valueWidget,
  });

  /// 左侧文案
  final String label;

  /// 当前值文案
  final String value;

  /// 当前值展示组件
  final Widget? valueWidget;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建 bot 选择行
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
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    child: valueWidget ??
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
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
