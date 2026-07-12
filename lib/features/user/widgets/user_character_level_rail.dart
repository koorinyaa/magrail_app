import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magrail_app/features/user/assets/model/user_character_snapshot_query.dart';

/// 用户角色等级快速跳转轨道
class UserCharacterLevelRail extends StatefulWidget {
  /// 单个等级索引的固定高度
  static const double itemExtent = 18;

  /// 创建用户角色等级快速跳转轨道
  ///
  /// [key] Flutter 组件标识
  /// [positions] 等级跳转位置
  /// [onLevelSelected] 等级选择回调
  const UserCharacterLevelRail({
    super.key,
    required this.positions,
    required this.onLevelSelected,
  });

  /// 等级跳转位置
  final List<UserCharacterLevelPosition> positions;

  /// 等级选择回调
  final ValueChanged<int> onLevelSelected;

  /// 创建等级快速跳转轨道状态
  @override
  State<UserCharacterLevelRail> createState() => _UserCharacterLevelRailState();
}

/// 用户角色等级快速跳转轨道状态
class _UserCharacterLevelRailState extends State<UserCharacterLevelRail> {
  int? _lastLongPressedLevel;

  /// 构建等级快速跳转轨道
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
            (widget.positions.length * UserCharacterLevelRail.itemExtent)
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
              onLongPressStart: (details) {
                _lastLongPressedLevel = null;
                _selectAt(
                  details.localPosition.dy,
                  height,
                  deduplicateLongPress: true,
                );
              },
              onLongPressMoveUpdate: (details) {
                _selectAt(
                  details.localPosition.dy,
                  height,
                  deduplicateLongPress: true,
                );
              },
              onLongPressEnd: (_) {
                _lastLongPressedLevel = null;
              },
              onLongPressCancel: () {
                _lastLongPressedLevel = null;
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
  /// [deduplicateLongPress] 是否过滤长按过程中重复的等级
  void _selectAt(
    double dy,
    double height, {
    bool deduplicateLongPress = false,
  }) {
    if (widget.positions.isEmpty || height <= 0) {
      return;
    }
    final resolvedDy = dy.clamp(0.0, height);
    final index = ((resolvedDy / height) * widget.positions.length)
        .floor()
        .clamp(0, widget.positions.length - 1);
    final level = widget.positions[index].level;
    if (deduplicateLongPress && _lastLongPressedLevel == level) {
      return;
    }
    _lastLongPressedLevel = deduplicateLongPress ? level : null;
    unawaited(HapticFeedback.selectionClick());
    widget.onLevelSelected(level);
  }
}
