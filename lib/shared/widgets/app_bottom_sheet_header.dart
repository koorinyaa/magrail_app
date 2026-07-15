import 'package:flutter/material.dart';

/// 应用底部抽屉标题
class AppBottomSheetHeader extends StatelessWidget {
  /// 创建带标准图标的底部抽屉标题
  ///
  /// [key] Flutter 组件标识
  /// [icon] 标题图标
  /// [title] 主标题
  /// [subtitle] 副标题
  /// [iconColor] 图标强调色
  const AppBottomSheetHeader({
    super.key,
    required IconData icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
  })  : _icon = icon,
        _leading = null;

  /// 创建带自定义左侧图标的底部抽屉标题
  ///
  /// [key] Flutter 组件标识
  /// [leading] 自定义左侧图标
  /// [title] 主标题
  /// [subtitle] 副标题
  const AppBottomSheetHeader.customLeading({
    super.key,
    required Widget leading,
    required this.title,
    required this.subtitle,
  })  : _icon = null,
        _leading = leading,
        iconColor = null;

  final IconData? _icon;
  final Widget? _leading;

  /// 主标题
  final String title;

  /// 副标题
  final String subtitle;

  /// 图标强调色
  final Color? iconColor;

  /// 构建应用底部抽屉标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedIconColor = iconColor ?? colorScheme.primary;
    final leading = _leading;

    return Row(
      children: [
        SizedBox.square(
          dimension: 44,
          child: leading ??
              DecoratedBox(
                decoration: BoxDecoration(
                  color: resolvedIconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _icon,
                  size: 24,
                  color: resolvedIconColor,
                ),
              ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
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
  }
}
