import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/chara/rank/repository/character_rank_repository.dart';

/// 角色排序切换标题
class CharacterRankSortHeader extends StatelessWidget
    implements PreferredSizeWidget {
  /// 创建角色排序切换标题
  ///
  /// [key] Flutter 组件标识
  /// [selectedType] 当前排序类型
  /// [onSelected] 排序选择回调
  const CharacterRankSortHeader({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  /// 当前排序类型
  final CharacterRankSortType selectedType;

  /// 排序选择回调
  final ValueChanged<CharacterRankSortType> onSelected;

  /// 固定区域尺寸
  @override
  Size get preferredSize => const Size.fromHeight(40);

  /// 构建角色排序切换标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final dividerColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.24 : 0.30,
    );

    return SizedBox(
      height: preferredSize.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: dividerColor),
          ),
        ),
        child: _CharacterRankSortSelector(
          selectedType: selectedType,
          onSelected: onSelected,
        ),
      ),
    );
  }
}

class _CharacterRankSortSelector extends StatelessWidget {
  /// 创建角色排序选择器
  ///
  /// [selectedType] 当前排序类型
  /// [onSelected] 排序选择回调
  const _CharacterRankSortSelector({
    required this.selectedType,
    required this.onSelected,
  });

  final CharacterRankSortType selectedType;
  final ValueChanged<CharacterRankSortType> onSelected;

  /// 构建角色排序选择器
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 16,
        top: 4,
        right: 16,
        bottom: 8,
      ),
      itemCount: CharacterRankSortType.values.length,
      separatorBuilder: (context, index) => const SizedBox(width: 6),
      itemBuilder: (context, index) {
        final type = CharacterRankSortType.values[index];

        return _CharacterRankSortChip(
          label: Text(type.label),
          isSelected: selectedType == type,
          onPressed: () => onSelected(type),
        );
      },
    );
  }
}

class _CharacterRankSortChip extends StatelessWidget {
  /// 创建角色排序选择项
  ///
  /// [label] 选择项文案
  /// [isSelected] 是否选中
  /// [onPressed] 点击回调
  const _CharacterRankSortChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final Widget label;
  final bool isSelected;
  final VoidCallback onPressed;

  /// 构建角色排序选择项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = isSelected
        ? Color.alphaBlend(
            colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.14),
            isDark ? colorScheme.surfaceContainerLow : colorScheme.surface,
          )
        : isDark
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainerHighest;
    final textColor = isSelected
        ? colorScheme.primary
        : isDark
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: textColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
              child: label,
            ),
          ),
        ),
      ),
    );
  }
}
