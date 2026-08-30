import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';

/// 角色等级分组列表条目构建器
///
/// [context] 当前组件树上下文
/// [item] 当前角色条目
/// [index] 当前角色在完整展示列表中的下标
typedef CharacterLevelItemBuilder<ItemType> =
    Widget Function(BuildContext context, ItemType item, int index);

/// 角色等级分组列表
class CharacterLevelGroupedSliverList<ItemType> extends StatelessWidget {
  /// 创建角色等级分组列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 已按等级排序的角色
  /// [levelOf] 角色等级读取函数
  /// [itemBuilder] 角色条目构建器
  const CharacterLevelGroupedSliverList({
    super.key,
    required this.items,
    required this.levelOf,
    required this.itemBuilder,
  });

  /// 已按等级排序的角色
  final List<ItemType> items;

  /// 角色等级读取函数
  final int Function(ItemType item) levelOf;

  /// 角色条目构建器
  final CharacterLevelItemBuilder<ItemType> itemBuilder;

  /// 构建角色等级分组列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final groups = <({int start, int end, int level})>[];
    var groupStart = 0;
    for (var index = 1; index <= items.length; index += 1) {
      if (index < items.length &&
          levelOf(items[index]) == levelOf(items[groupStart])) {
        continue;
      }
      groups.add((
        start: groupStart,
        end: index,
        level: levelOf(items[groupStart]),
      ));
      groupStart = index;
    }

    return SliverMainAxisGroup(
      slivers: [
        for (final group in groups) ...[
          SliverToBoxAdapter(
            child: CharacterFullListLevelHeader(level: group.level),
          ),
          SliverFixedExtentList(
            itemExtent: CharacterLevelListMetrics.itemExtent,
            delegate: SliverChildBuilderDelegate((context, index) {
              final itemIndex = group.start + index;
              return itemBuilder(context, items[itemIndex], itemIndex);
            }, childCount: group.end - group.start),
          ),
        ],
      ],
    );
  }
}

/// 角色全量列表等级标题
class CharacterFullListLevelHeader extends StatelessWidget {
  /// 创建角色全量列表等级标题
  ///
  /// [key] Flutter 组件标识
  /// [level] 角色等级
  const CharacterFullListLevelHeader({super.key, required this.level});

  /// 角色等级
  final int level;

  /// 构建角色全量列表等级标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: CharacterLevelListMetrics.levelHeaderExtent,
      child: Padding(
        padding: AppSafeAreaInsets.fromLTRB(
          context,
          left: 20,
          top: 8,
          right: 32,
          bottom: 4,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Lv.$level',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

/// 角色等级分组列表尺寸与偏移计算
final class CharacterLevelListMetrics {
  /// 禁止创建角色等级分组列表尺寸实例
  const CharacterLevelListMetrics._();

  /// 角色列表条目固定高度
  static const double itemExtent = 68;

  /// 等级分组标题固定高度
  static const double levelHeaderExtent = 40;

  /// 根据列表内容偏移查找当前可视角色
  ///
  /// [items] 当前展示角色
  /// [listOffset] 列表内容顶部相对视口的偏移量
  /// [showLevelHeaders] 是否包含等级标题
  /// [levelOf] 角色等级读取函数
  static int? itemIndexAtOffset<ItemType>(
    List<ItemType> items,
    double listOffset, {
    required bool showLevelHeaders,
    required int Function(ItemType item) levelOf,
  }) {
    if (items.isEmpty) {
      return null;
    }
    final resolvedOffset = listOffset.clamp(0.0, double.infinity).toDouble();
    if (!showLevelHeaders) {
      return (resolvedOffset ~/ itemExtent).clamp(0, items.length - 1).toInt();
    }

    var currentOffset = 0.0;
    for (var index = 0; index < items.length; index += 1) {
      if (index == 0 || levelOf(items[index]) != levelOf(items[index - 1])) {
        currentOffset += levelHeaderExtent;
      }
      if (resolvedOffset < currentOffset + itemExtent) {
        return index;
      }
      currentOffset += itemExtent;
    }
    return items.length - 1;
  }

  /// 计算角色条目在列表内容中的顶部位置
  ///
  /// [items] 当前展示角色
  /// [itemIndex] 角色条目下标
  /// [showLevelHeaders] 是否包含等级标题
  /// [levelOf] 角色等级读取函数
  static double itemOffsetForIndex<ItemType>(
    List<ItemType> items,
    int itemIndex, {
    required bool showLevelHeaders,
    required int Function(ItemType item) levelOf,
  }) {
    if (items.isEmpty) {
      return 0;
    }
    final targetIndex = itemIndex.clamp(0, items.length - 1).toInt();
    if (!showLevelHeaders) {
      return targetIndex * itemExtent;
    }

    var offset = 0.0;
    for (var index = 0; index <= targetIndex; index += 1) {
      if (index == 0 || levelOf(items[index]) != levelOf(items[index - 1])) {
        offset += levelHeaderExtent;
      }
      if (index == targetIndex) {
        return offset;
      }
      offset += itemExtent;
    }
    return offset;
  }

  /// 计算指定等级标题在列表内容中的顶部位置
  ///
  /// [items] 当前展示角色
  /// [itemIndex] 当前等级首个角色下标
  /// [levelOf] 角色等级读取函数
  static double levelHeaderOffsetForIndex<ItemType>(
    List<ItemType> items,
    int itemIndex, {
    required int Function(ItemType item) levelOf,
  }) {
    return itemOffsetForIndex(
          items,
          itemIndex,
          showLevelHeaders: true,
          levelOf: levelOf,
        ) -
        levelHeaderExtent;
  }
}
