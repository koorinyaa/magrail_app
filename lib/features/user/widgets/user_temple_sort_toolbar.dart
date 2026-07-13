import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/user/assets/model/user_temple_snapshot_query.dart';
import 'package:magrail_app/features/user/controller/current_user_temple_page_controller.dart';

/// 当前用户圣殿排序工具栏
class UserTempleSortToolbar extends StatelessWidget
    implements PreferredSizeWidget {
  /// 排序工具栏高度
  static const double toolbarHeight = 44;

  /// 创建当前用户圣殿排序工具栏
  ///
  /// [key] Flutter 组件标识
  /// [controller] 当前用户圣殿控制器
  /// [onSortSelected] 排序选择回调
  const UserTempleSortToolbar({
    super.key,
    required this.controller,
    required this.onSortSelected,
  });

  /// 当前用户圣殿控制器
  final CurrentUserTemplePageController controller;

  /// 排序选择回调
  final ValueChanged<UserTempleSnapshotSort> onSortSelected;

  /// 固定区域尺寸
  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  /// 构建当前用户圣殿排序工具栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: preferredSize.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.32),
            ),
          ),
        ),
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            final sort = controller.sort;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: AppSafeAreaInsets.fromLTRB(
                context,
                left: 12,
                top: 6,
                right: 12,
                bottom: 8,
              ),
              child: Row(
                children: [
                  for (final option in UserTempleSnapshotSort.values) ...[
                    if (option != UserTempleSnapshotSort.values.first)
                      const SizedBox(width: 6),
                    _UserTempleSortChip(
                      label: option.label,
                      isSelected: sort == option,
                      direction: controller.direction,
                      showDirection: sort == option,
                      onPressed: () => onSortSelected(option),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 当前用户圣殿排序选择项
class _UserTempleSortChip extends StatelessWidget {
  /// 创建当前用户圣殿排序选择项
  ///
  /// [label] 选择项文案
  /// [isSelected] 是否选中
  /// [direction] 排序方向
  /// [showDirection] 是否显示排序方向
  /// [onPressed] 点击回调
  const _UserTempleSortChip({
    required this.label,
    required this.isSelected,
    required this.direction,
    required this.showDirection,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final UserTempleSnapshotSortDirection direction;
  final bool showDirection;
  final VoidCallback onPressed;

  /// 构建当前用户圣殿排序选择项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isSelected
        ? colorScheme.primary.withValues(alpha: 0.1)
        : Colors.transparent;
    final foregroundColor =
        isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (showDirection) ...[
                const SizedBox(width: 4),
                Icon(
                  direction == UserTempleSnapshotSortDirection.ascending
                      ? LucideIcons.chevronUp
                      : LucideIcons.chevronDown,
                  size: 13,
                  color: foregroundColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
