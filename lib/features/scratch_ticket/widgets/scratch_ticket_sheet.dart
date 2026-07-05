import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/model/tinygrail_character_reward_item.dart';
import 'package:magrail_app/features/scratch_ticket/repository/scratch_ticket_repository.dart';
import 'package:magrail_app/features/scratch_ticket/widgets/scratch_ticket_result_sheet.dart';

part 'scratch_ticket_sheet_content.dart';

/// 显示刮刮乐购买弹层
///
/// [context] 当前组件树上下文
/// [repository] 刮刮乐仓库
/// [characterRepository] 角色详情仓库
/// [onCompleted] 购买完成回调
Future<void> showScratchTicketSheet(
  BuildContext context, {
  required ScratchTicketRepository repository,
  required CharacterDetailRepository characterRepository,
  ValueChanged<List<TinygrailCharacterRewardItem>>? onCompleted,
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
        child: ScratchTicketSheet(
          repository: repository,
          characterRepository: characterRepository,
          onCompleted: onCompleted,
        ),
      );
    },
  );
}

/// 刮刮乐购买弹层
class ScratchTicketSheet extends StatefulWidget {
  /// 创建刮刮乐购买弹层
  ///
  /// [key] Flutter 组件标识
  /// [repository] 刮刮乐仓库
  /// [characterRepository] 角色详情仓库
  /// [onCompleted] 购买完成回调
  const ScratchTicketSheet({
    super.key,
    required this.repository,
    required this.characterRepository,
    this.onCompleted,
  });

  /// 刮刮乐仓库
  final ScratchTicketRepository repository;

  /// 角色详情仓库
  final CharacterDetailRepository characterRepository;

  /// 购买完成回调
  final ValueChanged<List<TinygrailCharacterRewardItem>>? onCompleted;

  /// 创建刮刮乐购买弹层状态
  @override
  State<ScratchTicketSheet> createState() => _ScratchTicketSheetState();
}

/// 刮刮乐购买弹层状态
class _ScratchTicketSheetState extends State<ScratchTicketSheet> {
  int _lotusCount = 0;
  bool _isLotus = false;
  bool _isLoadingCount = true;
  bool _isLotusCountUnknown = false;
  bool _isSubmitting = false;

  /// 当前选中票种强调色
  Color get _selectedAccentColor =>
      _isLotus ? _scratchTicketLotusColor : _scratchTicketNormalColor;

  /// 初始化刮刮乐购买弹层状态
  @override
  void initState() {
    super.initState();
    _loadLotusCount();
  }

  /// 构建刮刮乐购买弹层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerLowest;

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppBottomSheetDragHandle(),
                    const SizedBox(height: 14),
                    const _ScratchHeader(),
                    const SizedBox(height: 18),
                    _TicketChoiceGroup(
                      isLotus: _isLotus,
                      lotusPriceText: _lotusPriceText,
                      isLoadingCount: _isLoadingCount,
                      isLotusCountUnknown: _isLotusCountUnknown,
                      isDisabled: _isSubmitting,
                      onChanged: _updateTicketType,
                    ),
                    const SizedBox(height: 14),
                    _PurchaseSummary(
                      title: _selectedTitle,
                      description: _selectedDescription,
                      priceText: _selectedPriceText,
                    ),
                    const SizedBox(height: 16),
                    _ConfirmButton(
                      label: '购买$_selectedTitle',
                      accentColor: _selectedAccentColor,
                      isLoading: _isSubmitting,
                      isDisabled: _isSubmitDisabled,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 当前选中票种标题
  String get _selectedTitle => _isLotus ? '幻想乡刮刮乐' : '环保刮刮乐';

  /// 当前选中票种说明
  String get _selectedDescription {
    if (_isLotus) {
      if (_isLoadingCount) {
        return '正在读取今日次数';
      }

      return _isLotusCountUnknown ? '今日购买次数未知' : '今日已购买 $_lotusCount 次';
    }

    return '固定价格';
  }

  /// 当前选中票种价格文案
  String get _selectedPriceText {
    if (_isLotus) {
      return _lotusPriceText;
    }

    return Formatters.tinygrailCurrency(1000);
  }

  /// 幻想乡刮刮乐价格文案
  String get _lotusPriceText {
    if (_isLoadingCount) {
      return '读取中';
    }

    if (_isLotusCountUnknown) {
      return '价格未知';
    }

    return Formatters.tinygrailCurrency(_lotusPrice);
  }

  /// 幻想乡刮刮乐价格
  double get _lotusPrice {
    return math.pow(2, _lotusCount).toDouble() * 2000;
  }

  /// 购买按钮是否禁用
  bool get _isSubmitDisabled => _isLotus && _isLoadingCount;

  /// 加载幻想乡刮刮乐使用次数
  Future<void> _loadLotusCount() async {
    try {
      final count = await widget.repository.fetchLotusScratchCount();
      if (!mounted) {
        return;
      }

      setState(() {
        _lotusCount = count;
        _isLoadingCount = false;
        _isLotusCountUnknown = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingCount = false;
        _isLotusCountUnknown = true;
      });
    }
  }

  /// 更新刮刮乐类型
  ///
  /// [value] 是否选择幻想乡刮刮乐
  void _updateTicketType(bool value) {
    setState(() {
      _isLotus = value;
    });
  }

  /// 提交刮刮乐购买请求
  Future<void> _submit() async {
    if (_isSubmitting || _isSubmitDisabled) {
      return;
    }

    final isLotusPurchase = _isLotus;
    setState(() {
      _isSubmitting = true;
    });

    try {
      final items = await widget.repository.scratchTicket(
        isLotus: isLotusPurchase,
      );
      if (!mounted) {
        return;
      }

      if (isLotusPurchase) {
        _refreshLotusCountAfterPurchase();
      }
      widget.onCompleted?.call(items);
      await showScratchTicketResultSheet(
        context,
        characterRepository: widget.characterRepository,
        title: '彩票抽奖',
        items: items,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.error(
        context,
        text: _resolveErrorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 购买幻想乡刮刮乐后刷新今日次数
  void _refreshLotusCountAfterPurchase() {
    if (!_isLotusCountUnknown && !_isLoadingCount) {
      setState(() {
        _lotusCount += 1;
      });
      return;
    }

    setState(() {
      _isLoadingCount = true;
      _isLotusCountUnknown = false;
    });
    unawaited(_loadLotusCount());
  }

  /// 解析购买失败文案
  ///
  /// [error] 原始错误
  String _resolveErrorMessage(Object error) {
    return resolveUserErrorMessage(error, fallback: '刮刮乐施法失败');
  }
}
