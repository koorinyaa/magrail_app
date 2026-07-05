import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_trade_section_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_data.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'character_detail_trade_section_depth.dart';
part 'character_detail_trade_section_form.dart';
part 'character_detail_trade_section_form_controls.dart';
part 'character_detail_trade_section_form_fields.dart';
part 'character_detail_trade_section_orders.dart';
part 'character_detail_trade_section_orders_header.dart';
part 'character_detail_trade_section_orders_list.dart';
part 'character_detail_trade_section_trade_records.dart';
part 'character_detail_trade_section_skeleton.dart';

const Color _tradeBuyColor = Color(0xFFFF5A91);
const Color _tradeSellColor = Color(0xFF38A8E8);

/// 角色详情交易区
class CharacterDetailTradeSection extends StatefulWidget {
  /// 创建角色详情交易区
  ///
  /// [key] Flutter 组件标识
  /// [repository] 角色详情仓库
  /// [header] 已上市角色头部资料
  /// [onChanged] 交易变化后的刷新回调
  const CharacterDetailTradeSection({
    super.key,
    required this.repository,
    required this.header,
    required this.onChanged,
  });

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 交易变化后的刷新回调
  final Future<void> Function() onChanged;

  /// 创建角色详情交易区状态
  @override
  State<CharacterDetailTradeSection> createState() =>
      _CharacterDetailTradeSectionState();
}

/// 角色详情交易区状态
class _CharacterDetailTradeSectionState
    extends State<CharacterDetailTradeSection> {
  late CharacterDetailTradeSectionController _controller;
  bool _isFormExpanded = false;

  /// 初始化角色详情交易区状态
  @override
  void initState() {
    super.initState();
    _createController();
  }

  /// 在角色或用户切换后重建交易区控制器
  ///
  /// [oldWidget] 更新前的交易区组件
  @override
  void didUpdateWidget(covariant CharacterDetailTradeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.header.characterId != widget.header.characterId ||
        oldWidget.header.currentUserId != widget.header.currentUserId) {
      _controller.dispose();
      _isFormExpanded = false;
      _createController();
    }
  }

  /// 释放角色详情交易区状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建角色详情交易区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final loadError = _controller.loadError;
        if (_controller.isLoading) {
          return const CharacterDetailTradeSectionSkeleton();
        }

        if (loadError != null) {
          return AppLoadFailedState(
            message: loadError,
            onActionPressed: () => unawaited(_controller.reload()),
          );
        }

        return _TradeSectionPanel(
          controller: _controller,
          isFormExpanded: _isFormExpanded,
          onSubmit: _handleSubmit,
          onOrderButtonPressed: _handleOrderButtonPressed,
          onTradeRecordsButtonPressed: _handleTradeRecordsButtonPressed,
          onFormTogglePressed: () {
            setState(() {
              _isFormExpanded = !_isFormExpanded;
            });
          },
          onFormExpandRequested: () {
            if (_isFormExpanded) {
              return;
            }

            setState(() {
              _isFormExpanded = true;
            });
          },
        );
      },
    );
  }

  /// 创建交易区控制器
  void _createController() {
    _controller = CharacterDetailTradeSectionController(
      repository: widget.repository,
      characterId: widget.header.characterId,
      currentPrice: widget.header.current,
    );
    unawaited(_controller.initialize());
  }

  /// 处理交易提交
  Future<void> _handleSubmit() async {
    try {
      final message = await _controller.submit();
      if (!mounted || message == null) {
        return;
      }

      AppToast.info(context, text: message);
      await widget.onChanged();
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.error(
        context,
        text: CharacterDetailTradeSectionController.resolveErrorMessage(
          error,
          fallback: '提交委托失败',
        ),
      );
    }
  }

  /// 处理当前委托入口
  void _handleOrderButtonPressed() {
    if (!_controller.hasActiveOrders) {
      AppToast.info(context, text: '暂无当前委托');
      return;
    }

    unawaited(
      showCharacterDetailTradeOrdersSheet(
        context,
        controller: _controller,
        onOrderCancelled: _handleOrderCancelled,
      ),
    );
  }

  /// 处理成交记录入口
  void _handleTradeRecordsButtonPressed() {
    unawaited(
      showCharacterDetailTradeRecordsSheet(
        context,
        controller: _controller,
      ),
    );
  }

  /// 处理委托取消后的页面刷新
  Future<void> _handleOrderCancelled() async {
    if (!mounted) {
      return;
    }

    await widget.onChanged();
  }
}

/// 角色详情交易区面板
class _TradeSectionPanel extends StatelessWidget {
  /// 创建角色详情交易区面板
  ///
  /// [controller] 交易区控制器
  /// [isFormExpanded] 是否展开交易表单
  /// [onSubmit] 提交委托回调
  /// [onOrderButtonPressed] 当前委托入口回调
  /// [onTradeRecordsButtonPressed] 成交记录入口回调
  /// [onFormTogglePressed] 交易表单展开状态切换回调
  /// [onFormExpandRequested] 交易表单展开请求回调
  const _TradeSectionPanel({
    required this.controller,
    required this.isFormExpanded,
    required this.onSubmit,
    required this.onOrderButtonPressed,
    required this.onTradeRecordsButtonPressed,
    required this.onFormTogglePressed,
    required this.onFormExpandRequested,
  });

  /// 交易区控制器
  final CharacterDetailTradeSectionController controller;

  /// 是否展开交易表单
  final bool isFormExpanded;

  /// 提交委托回调
  final Future<void> Function() onSubmit;

  /// 当前委托入口回调
  final VoidCallback onOrderButtonPressed;

  /// 成交记录入口回调
  final VoidCallback onTradeRecordsButtonPressed;

  /// 交易表单展开状态切换回调
  final VoidCallback onFormTogglePressed;

  /// 交易表单展开请求回调
  final VoidCallback onFormExpandRequested;

  /// 构建角色详情交易区面板
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _TradeSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TradeSectionHeader(
            onTradeRecordsButtonPressed: onTradeRecordsButtonPressed,
          ),
          const SizedBox(height: 12),
          _TradeDepthPanel(
            controller: controller,
            onOrdersPressed: onOrderButtonPressed,
            onFormExpandRequested: onFormExpandRequested,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: isFormExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _TradeForm(
                      controller: controller,
                      onSubmit: onSubmit,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          _TradeFormToggleButton(
            isFormExpanded: isFormExpanded,
            onPressed: onFormTogglePressed,
          ),
        ],
      ),
    );
  }
}

/// 角色详情交易区表面
class _TradeSurface extends StatelessWidget {
  /// 创建角色详情交易区表面
  ///
  /// [child] 表面内容
  const _TradeSurface({
    required this.child,
  });

  /// 表面内容
  final Widget child;

  /// 构建角色详情交易区表面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerLow : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}

/// 角色详情交易区标题行
class _TradeSectionHeader extends StatelessWidget {
  /// 创建角色详情交易区标题行
  ///
  /// [onTradeRecordsButtonPressed] 成交记录入口回调
  const _TradeSectionHeader({
    required this.onTradeRecordsButtonPressed,
  });

  /// 成交记录入口回调
  final VoidCallback onTradeRecordsButtonPressed;

  /// 构建角色详情交易区标题行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            '交易',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onTradeRecordsButtonPressed,
          icon: const Icon(LucideIcons.clipboardClock, size: 16),
          label: const Text('成交记录'),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// 角色详情交易表单展开按钮
class _TradeFormToggleButton extends StatelessWidget {
  /// 创建角色详情交易表单展开按钮
  ///
  /// [isFormExpanded] 是否展开交易表单
  /// [onPressed] 点击回调
  const _TradeFormToggleButton({
    required this.isFormExpanded,
    required this.onPressed,
  });

  /// 是否展开交易表单
  final bool isFormExpanded;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建角色详情交易表单展开按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor =
        colorScheme.onSurfaceVariant.withValues(alpha: 0.72);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        minimumSize: const Size.fromHeight(26),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isFormExpanded ? '点击收起' : '展开交易'),
          const SizedBox(width: 2),
          Icon(
            isFormExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 15,
          ),
        ],
      ),
    );
  }
}
