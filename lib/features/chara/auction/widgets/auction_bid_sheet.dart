import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/features/chara/auction/controller/auction_bid_sheet_controller.dart';
import 'package:magrail_app/features/chara/auction/model/auction_api_item.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/shared/widgets/app_bottom_sheet_header.dart';

part 'auction_bid_sheet_controls.dart';
part 'auction_bid_sheet_sections.dart';

/// 显示角色拍卖底部抽屉
///
/// [context] 当前组件树上下文
/// [repository] 拍卖仓库
/// [characterId] 角色 ID
/// [characterName] 角色名称
/// [basePrice] 拍卖底价
/// [maxAmount] 英灵殿数量
/// [initialAuction] 初始拍卖详情
/// [onChanged] 拍卖变更回调
Future<void> showAuctionBidSheet(
  BuildContext context, {
  required AuctionRepository repository,
  required int characterId,
  required String characterName,
  required double basePrice,
  required int maxAmount,
  AuctionApiItem? initialAuction,
  Future<void> Function()? onChanged,
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
      final maxHeight =
          availableHeight.clamp(0.0, mediaQuery.size.height).toDouble();

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: AuctionBidSheet(
          repository: repository,
          characterId: characterId,
          characterName: characterName,
          basePrice: basePrice,
          maxAmount: maxAmount,
          initialAuction: initialAuction,
          onChanged: onChanged,
        ),
      );
    },
  );
}

/// 角色拍卖底部抽屉
class AuctionBidSheet extends StatefulWidget {
  /// 创建角色拍卖底部抽屉
  ///
  /// [key] Flutter 组件标识
  /// [repository] 拍卖仓库
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  /// [basePrice] 拍卖底价
  /// [maxAmount] 英灵殿数量
  /// [initialAuction] 初始拍卖详情
  /// [onChanged] 拍卖变更回调
  const AuctionBidSheet({
    super.key,
    required this.repository,
    required this.characterId,
    required this.characterName,
    required this.basePrice,
    required this.maxAmount,
    this.initialAuction,
    this.onChanged,
  });

  /// 拍卖仓库
  final AuctionRepository repository;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 拍卖底价
  final double basePrice;

  /// 英灵殿数量
  final int maxAmount;

  /// 初始拍卖详情
  final AuctionApiItem? initialAuction;

  /// 拍卖变更回调
  final Future<void> Function()? onChanged;

  /// 创建角色拍卖底部面板状态
  @override
  State<AuctionBidSheet> createState() => _AuctionBidSheetState();
}

/// 角色拍卖底部抽屉状态
class _AuctionBidSheetState extends State<AuctionBidSheet> {
  late final AuctionBidSheetController _controller;

  /// 初始化角色拍卖底部抽屉状态
  @override
  void initState() {
    super.initState();
    _controller = AuctionBidSheetController(
      repository: widget.repository,
      characterId: widget.characterId,
      characterName: widget.characterName,
      basePrice: widget.basePrice,
      maxAmount: widget.maxAmount,
      initialAuction: widget.initialAuction,
    )..addListener(_handleControllerChanged);
    unawaited(_controller.initialize());
  }

  /// 释放角色拍卖底部抽屉状态
  @override
  void dispose() {
    _controller
      ..removeListener(_handleControllerChanged)
      ..dispose();
    super.dispose();
  }

  /// 按控制器状态刷新弹窗
  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// 构建角色拍卖底部抽屉
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  const SizedBox(height: 10),
                  _AuctionBidSheetHeader(
                    characterId: widget.characterId,
                    characterName: controller.displayName,
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AuctionInfoSection(
                            auction: controller.auction,
                            maxAmount: controller.maxAmount,
                            isLoading: controller.isLoading,
                            loadError: controller.loadError,
                          ),
                          if (controller.hasCurrentBid) ...[
                            const SizedBox(height: 12),
                            _MyAuctionBidSection(auction: controller.auction),
                          ],
                          const SizedBox(height: 12),
                          if (controller.hasCurrentBid)
                            _LockTotalSwitch(
                              value: controller.lockTotal,
                              onChanged: controller.updateLockTotal,
                            ),
                          if (controller.hasCurrentBid)
                            const SizedBox(height: 10),
                          _AuctionBidTextField(
                            controller: controller.priceController,
                            label: '价格',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _AuctionBidTextField(
                            controller: controller.amountController,
                            label: '数量',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 8),
                          _AuctionQuickInputButtons(
                            onFillBasePrice: controller.fillBasePrice,
                            onFillRemaining: controller.fillRemainingAmount,
                            onFillMaxAmount: controller.fillMaxAmount,
                          ),
                          const SizedBox(height: 12),
                          _AuctionTotalText(total: controller.currentTotal),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _AuctionBidActions(
                    canCancel: controller.canCancelAuction,
                    isSubmitting: controller.isSubmitting,
                    isCancelling: controller.isCancelling,
                    onCancel: _handleCancelAuction,
                    onSubmit: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 提交竞拍
  Future<void> _handleSubmit() async {
    try {
      final message = await _controller.submit();
      if (!mounted || message == null) {
        return;
      }

      AppToast.info(context, text: message);
      await widget.onChanged?.call();
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.error(
        context,
        text: AuctionBidSheetController.resolveErrorMessage(
          error,
          fallback: '竞拍失败',
        ),
      );
    }
  }

  /// 取消竞拍
  Future<void> _handleCancelAuction() async {
    if (!_controller.canCancelAuction) {
      AppToast.error(context, text: '没有可取消的竞拍');
      return;
    }

    final shouldCancel = await showAppConfirmDialog(
      context,
      title: '撤销竞拍',
      message: '确定要撤销竞拍吗？',
      confirmText: '撤销竞拍',
      showCancelButton: false,
      icon: LucideIcons.gavel,
    );
    if (!shouldCancel || !mounted) {
      return;
    }

    try {
      final message = await _controller.cancelAuction();
      if (!mounted || message == null) {
        return;
      }

      AppToast.info(context, text: message);
      await widget.onChanged?.call();
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.error(
        context,
        text: AuctionBidSheetController.resolveErrorMessage(
          error,
          fallback: '撤销竞拍失败',
        ),
      );
    }
  }
}
