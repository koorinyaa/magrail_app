import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/features/chara/auction/controller/auction_history_sheet_controller.dart';
import 'package:magrail_app/features/chara/auction/model/auction_history_api_item.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';

part 'auction_history_sheet_content.dart';
part 'auction_history_sheet_states.dart';

/// 显示角色往期拍卖底部抽屉
///
/// [context] 当前组件树上下文
/// [repository] 拍卖仓库
/// [characterId] 角色 ID
/// [characterName] 角色名称
/// [currentUserId] 当前登录用户 ID
Future<void> showAuctionHistorySheet(
  BuildContext context, {
  required AuctionRepository repository,
  required int characterId,
  required String characterName,
  int? currentUserId,
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
      // 列表型抽屉保留更明显的顶部拖拽空间，避免内容加载后贴到屏幕顶部
      final heightCap = mediaQuery.size.height *
          (mediaQuery.orientation == Orientation.landscape ? 0.9 : 0.86);
      final maxHeight = availableHeight.clamp(0.0, heightCap).toDouble();

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: AuctionHistorySheet(
          repository: repository,
          characterId: characterId,
          characterName: characterName,
          currentUserId: currentUserId,
        ),
      );
    },
  );
}

/// 角色往期拍卖底部抽屉
class AuctionHistorySheet extends StatefulWidget {
  /// 创建角色往期拍卖底部抽屉
  ///
  /// [key] Flutter 组件标识
  /// [repository] 拍卖仓库
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  /// [currentUserId] 当前登录用户 ID
  const AuctionHistorySheet({
    super.key,
    required this.repository,
    required this.characterId,
    required this.characterName,
    this.currentUserId,
  });

  /// 拍卖仓库
  final AuctionRepository repository;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 当前登录用户 ID
  final int? currentUserId;

  /// 创建角色往期拍卖底部抽屉状态
  @override
  State<AuctionHistorySheet> createState() => _AuctionHistorySheetState();
}

/// 角色往期拍卖底部抽屉状态
class _AuctionHistorySheetState extends State<AuctionHistorySheet> {
  late final AuctionHistorySheetController _controller;

  /// 初始化角色往期拍卖底部抽屉状态
  @override
  void initState() {
    super.initState();
    _controller = AuctionHistorySheetController(
      repository: widget.repository,
      characterId: widget.characterId,
    )..addListener(_handleControllerChanged);
    unawaited(_controller.initialize());
  }

  /// 释放角色往期拍卖底部抽屉状态
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

  /// 构建角色往期拍卖底部抽屉
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
                  _AuctionHistoryHeader(
                    characterId: widget.characterId,
                    characterName: widget.characterName,
                  ),
                  const SizedBox(height: 12),
                  _AuctionHistorySummary(controller: _controller),
                  const SizedBox(height: 10),
                  Flexible(
                    child: _AuctionHistoryBody(
                      controller: _controller,
                      currentUserId: widget.currentUserId,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AuctionHistoryPager(controller: _controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
