import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magrail_app/features/chara/model/character_full_list_sort.dart';

/// 角色全量列表等级快速跳转轨道
class CharacterFullListLevelRail extends StatefulWidget {
  /// 单个等级索引的固定高度
  static const double itemExtent = 18;

  /// 创建角色全量列表等级快速跳转轨道
  ///
  /// [key] Flutter 组件标识
  /// [positions] 等级跳转位置
  /// [onLevelSelected] 等级选择回调
  const CharacterFullListLevelRail({
    super.key,
    required this.positions,
    required this.onLevelSelected,
  });

  /// 等级跳转位置
  final List<CharacterFullListLevelPosition> positions;

  /// 等级选择回调
  final ValueChanged<int> onLevelSelected;

  /// 创建角色全量列表等级快速跳转轨道状态
  @override
  State<CharacterFullListLevelRail> createState() =>
      _CharacterFullListLevelRailState();
}

/// 角色全量列表等级快速跳转轨道状态
class _CharacterFullListLevelRailState
    extends State<CharacterFullListLevelRail> {
  int? _lastDraggedLevel;

  /// 构建角色全量列表等级快速跳转轨道
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (widget.positions.isEmpty) {
          return const SizedBox.shrink();
        }
        final height =
            (widget.positions.length * CharacterFullListLevelRail.itemExtent)
                .clamp(0.0, constraints.maxHeight);
        final resolvedItemExtent = height / widget.positions.length;
        final fontSize = resolvedItemExtent.clamp(9.0, 11.0);
        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: height,
            width: constraints.maxWidth,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                _selectAt(details.localPosition.dy, height);
              },
              onVerticalDragStart: (details) {
                _lastDraggedLevel = null;
                _selectAt(
                  details.localPosition.dy,
                  height,
                  deduplicateDrag: true,
                );
              },
              onVerticalDragUpdate: (details) {
                _selectAt(
                  details.localPosition.dy,
                  height,
                  deduplicateDrag: true,
                );
              },
              onVerticalDragEnd: (_) {
                _lastDraggedLevel = null;
              },
              onVerticalDragCancel: () {
                _lastDraggedLevel = null;
              },
              child: Column(
                children: [
                  for (final position in widget.positions)
                    Expanded(
                      child: Center(
                        child: Text(
                          '${position.level}',
                          style: TextStyle(
                            color: colorScheme.primary.withValues(alpha: 0.82),
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            letterSpacing: 0,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 根据轨道位置选择等级
  ///
  /// [dy] 轨道内纵向位置
  /// [height] 轨道高度
  /// [deduplicateDrag] 是否过滤拖动过程中重复的等级
  void _selectAt(double dy, double height, {bool deduplicateDrag = false}) {
    if (widget.positions.isEmpty || height <= 0) {
      return;
    }
    final resolvedDy = dy.clamp(0.0, height);
    final index = ((resolvedDy / height) * widget.positions.length)
        .floor()
        .clamp(0, widget.positions.length - 1);
    final level = widget.positions[index].level;
    if (deduplicateDrag && _lastDraggedLevel == level) {
      return;
    }
    _lastDraggedLevel = deduplicateDrag ? level : null;
    unawaited(HapticFeedback.lightImpact());
    widget.onLevelSelected(level);
  }
}
