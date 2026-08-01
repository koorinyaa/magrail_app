import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/ico/model/ico_character_sort.dart';

/// ICO 角色本地排序栏
class IcoCharacterSortToolbar extends StatelessWidget
    implements PreferredSizeWidget {
  /// ICO 排序栏高度
  static const double toolbarHeight = 44;

  /// 创建 ICO 角色本地排序栏
  ///
  /// [key] Flutter 组件标识
  /// [selectedSort] 当前排序字段
  /// [onSortSelected] 排序选择回调
  const IcoCharacterSortToolbar({
    super.key,
    required this.selectedSort,
    required this.onSortSelected,
  });

  /// 当前排序字段
  final IcoCharacterSort selectedSort;

  /// 排序选择回调
  final ValueChanged<IcoCharacterSort> onSortSelected;

  /// 固定区域尺寸
  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  /// 构建 ICO 角色本地排序栏
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
                for (var index = 0;
                    index < IcoCharacterSort.values.length;
                    index += 1) ...[
                  if (index > 0) const SizedBox(width: 6),
                  _IcoCharacterSortChip(
                    sort: IcoCharacterSort.values[index],
                    isSelected:
                        selectedSort == IcoCharacterSort.values[index],
                    onSelected: onSortSelected,
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

/// ICO 角色排序项
class _IcoCharacterSortChip extends StatelessWidget {
  /// 创建 ICO 角色排序项
  ///
  /// [sort] 当前排序项
  /// [isSelected] 是否已经选中
  /// [onSelected] 排序选择回调
  const _IcoCharacterSortChip({
    required this.sort,
    required this.isSelected,
    required this.onSelected,
  });

  final IcoCharacterSort sort;
  final bool isSelected;
  final ValueChanged<IcoCharacterSort> onSelected;

  /// 构建 ICO 角色排序项
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
        onTap: isSelected ? null : () => onSelected(sort),
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              sort.label,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
