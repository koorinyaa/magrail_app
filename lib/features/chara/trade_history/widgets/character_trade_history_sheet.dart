import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/features/chara/trade_history/controller/character_trade_history_sheet_controller.dart';
import 'package:magrail_app/features/chara/trade_history/model/character_trade_history_item.dart';
import 'package:magrail_app/features/chara/trade_history/repository/character_trade_history_repository.dart';

part 'character_trade_history_sheet_content.dart';
part 'character_trade_history_sheet_states.dart';

/// 显示角色交易记录底部抽屉
///
/// [context] 当前组件树上下文
/// [repository] 角色交易记录仓库
/// [characterId] 角色 ID
/// [characterName] 角色名称
Future<void> showCharacterTradeHistorySheet(
  BuildContext context, {
  required CharacterTradeHistoryRepository repository,
  required int characterId,
  required String characterName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: BoxConstraints.tightFor(
      width: MediaQuery.sizeOf(context).width,
    ),
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      const topGap = 32.0;
      final availableHeight =
          mediaQuery.size.height - mediaQuery.padding.top - topGap;
      final heightCap = mediaQuery.size.height *
          (mediaQuery.orientation == Orientation.landscape ? 0.9 : 0.86);
      final maxHeight = availableHeight.clamp(0.0, heightCap).toDouble();

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: CharacterTradeHistorySheet(
          repository: repository,
          characterId: characterId,
          characterName: characterName,
        ),
      );
    },
  );
}

/// 角色交易记录底部抽屉
class CharacterTradeHistorySheet extends StatefulWidget {
  /// 创建角色交易记录底部抽屉
  ///
  /// [key] Flutter 组件标识
  /// [repository] 角色交易记录仓库
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  const CharacterTradeHistorySheet({
    super.key,
    required this.repository,
    required this.characterId,
    required this.characterName,
  });

  /// 角色交易记录仓库
  final CharacterTradeHistoryRepository repository;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 创建角色交易记录底部抽屉状态
  @override
  State<CharacterTradeHistorySheet> createState() =>
      _CharacterTradeHistorySheetState();
}

/// 角色交易记录底部抽屉状态
class _CharacterTradeHistorySheetState
    extends State<CharacterTradeHistorySheet> {
  late final CharacterTradeHistorySheetController _controller;

  /// 初始化角色交易记录底部抽屉状态
  @override
  void initState() {
    super.initState();
    _controller = CharacterTradeHistorySheetController(
      repository: widget.repository,
      characterId: widget.characterId,
    )..addListener(_handleControllerChanged);
    unawaited(_controller.initialize());
  }

  /// 释放角色交易记录底部抽屉状态
  @override
  void dispose() {
    _controller
      ..removeListener(_handleControllerChanged)
      ..dispose();
    super.dispose();
  }

  /// 按控制器状态刷新抽屉
  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// 构建角色交易记录底部抽屉
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerLowest;

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.32 : 0.58,
                ),
              ),
            ),
          ),
          child: SafeArea(
            left: false,
            right: false,
            top: false,
            child: Padding(
              padding: AppSafeAreaInsets.fromLTRB(
                context,
                left: 20,
                top: 10,
                right: 20,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppBottomSheetDragHandle(),
                  const SizedBox(height: 14),
                  _CharacterTradeHistoryHeader(
                    characterId: widget.characterId,
                    characterName: widget.characterName,
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: _CharacterTradeHistoryBody(
                      controller: _controller,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
