import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/chara/tower/controller/tower_ranking_page_controller.dart';

/// 通天塔榜单分段标题
class TowerRankingRangeHeader extends StatelessWidget
    implements PreferredSizeWidget {
  /// 创建通天塔榜单分段标题
  ///
  /// [selectedIndex] 当前选中的分段索引
  /// [segmentCount] 分段数量
  /// [onSelected] 分段选择回调
  const TowerRankingRangeHeader({
    super.key,
    required this.selectedIndex,
    required this.segmentCount,
    required this.onSelected,
  });

  /// 当前选中的分段索引
  final int selectedIndex;

  /// 分段数量
  final int segmentCount;

  /// 分段选择回调
  final ValueChanged<int> onSelected;

  /// 固定区域尺寸
  @override
  Size get preferredSize => const Size.fromHeight(40);

  /// 构建通天塔榜单分段标题
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
        child: _TowerRankingRangeSelector(
          selectedIndex: selectedIndex,
          segmentCount: segmentCount,
          onSelected: onSelected,
        ),
      ),
    );
  }
}

/// 通天塔榜单分段选择器
class _TowerRankingRangeSelector extends StatelessWidget {
  /// 创建通天塔榜单分段选择器
  ///
  /// [selectedIndex] 当前选中的分段索引
  /// [segmentCount] 分段数量
  /// [onSelected] 分段选择回调
  const _TowerRankingRangeSelector({
    required this.selectedIndex,
    required this.segmentCount,
    required this.onSelected,
  });

  final int selectedIndex;
  final int segmentCount;
  final ValueChanged<int> onSelected;

  /// 构建通天塔榜单分段选择器
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
      itemCount: segmentCount,
      separatorBuilder: (context, index) => const SizedBox(width: 6),
      itemBuilder: (context, index) {
        final start = index * TowerRankingPageController.segmentSize + 1;
        final rawEnd = (index + 1) * TowerRankingPageController.segmentSize;
        final end = rawEnd > TowerRankingPageController.displayLimit
            ? TowerRankingPageController.displayLimit
            : rawEnd;
        final isSelected = selectedIndex == index;

        return _TowerRankingRangeChip(
          label: Text('$start-$end'),
          isSelected: isSelected,
          onPressed: () => onSelected(index),
        );
      },
    );
  }
}

/// 通天塔榜单分段选择项
class _TowerRankingRangeChip extends StatelessWidget {
  /// 创建通天塔榜单分段选择项
  ///
  /// [label] 分段文案
  /// [isSelected] 是否选中
  /// [onPressed] 点击回调
  const _TowerRankingRangeChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final Widget label;
  final bool isSelected;
  final VoidCallback onPressed;

  /// 构建通天塔榜单分段选择项
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
