import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/chara/model/character_full_list_sort.dart';

/// 角色全量列表排序工具栏
class CharacterFullListSortToolbar extends StatelessWidget
    implements PreferredSizeWidget {
  /// 排序工具栏高度
  static const double toolbarHeight = 44;

  /// 创建角色全量列表排序工具栏
  ///
  /// [key] Flutter 组件标识
  /// [options] 当前页面可用排序字段
  /// [selectedSort] 当前排序字段，未选择时为空
  /// [direction] 当前排序方向
  /// [onSortSelected] 排序选择回调
  const CharacterFullListSortToolbar({
    super.key,
    required this.options,
    required this.selectedSort,
    required this.direction,
    required this.onSortSelected,
  });

  /// 当前页面可用排序字段
  final List<CharacterFullListSort> options;

  /// 当前排序字段，未选择时为空
  final CharacterFullListSort? selectedSort;

  /// 当前排序方向
  final CharacterFullListSortDirection direction;

  /// 排序选择回调
  final ValueChanged<CharacterFullListSort> onSortSelected;

  /// 固定区域尺寸
  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  /// 构建角色全量列表排序工具栏
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
        child: Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
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
                for (var index = 0; index < options.length; index += 1) ...[
                  if (index > 0) const SizedBox(width: 6),
                  _CharacterFullListSortChip(
                    label: options[index].label,
                    isSelected: selectedSort == options[index],
                    direction: direction,
                    onPressed: () => onSortSelected(options[index]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 角色全量列表排序选择项
class _CharacterFullListSortChip extends StatelessWidget {
  /// 创建角色全量列表排序选择项
  ///
  /// [label] 选择项文案
  /// [isSelected] 是否选中
  /// [direction] 当前排序方向
  /// [onPressed] 点击回调
  const _CharacterFullListSortChip({
    required this.label,
    required this.isSelected,
    required this.direction,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final CharacterFullListSortDirection direction;
  final VoidCallback onPressed;

  /// 构建角色全量列表排序选择项
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
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(
                  direction == CharacterFullListSortDirection.ascending
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
