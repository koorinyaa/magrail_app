import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/features/temple/controller/temple_asset_magic_action_controller.dart';
import 'package:magrail_app/features/temple/model/temple_asset_card_data.dart';

import 'temple_asset_refine_sheet_sections.dart';

/// 显示圣殿资产精炼抽屉
///
/// [context] 当前组件树上下文
/// [data] 圣殿资产卡片展示数据
Future<void> showTempleAssetRefineSheet(
  BuildContext context, {
  required TempleAssetCardData data,
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
        child: TempleAssetRefineSheet(data: data),
      );
    },
  );
}

/// 圣殿资产精炼抽屉
class TempleAssetRefineSheet extends StatefulWidget {
  /// 创建圣殿资产精炼抽屉
  ///
  /// [key] Flutter 组件标识
  /// [data] 圣殿资产卡片展示数据
  const TempleAssetRefineSheet({
    super.key,
    required this.data,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 创建圣殿资产精炼抽屉状态
  @override
  State<TempleAssetRefineSheet> createState() => _TempleAssetRefineSheetState();
}

/// 圣殿资产精炼抽屉状态
class _TempleAssetRefineSheetState extends State<TempleAssetRefineSheet> {
  final _actionController = const TempleAssetMagicActionController();
  late TempleAssetCardData _data;
  bool _isSubmitting = false;
  bool _skipConfirm = false;

  /// 初始化圣殿资产精炼抽屉状态
  @override
  void initState() {
    super.initState();
    _data = widget.data;
  }

  /// 构建圣殿资产精炼抽屉
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final data = _data;
    final canSubmit =
        !_isSubmitting && data.actionContext != null && _canRefine(data);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerLow
                : colorScheme.surfaceContainerLowest,
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
            child: SingleChildScrollView(
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
                    TempleAssetRefineHeader(data: data),
                    const SizedBox(height: 16),
                    TempleAssetRefineTransferPreview(
                      data: data,
                      costText: _refineCostText,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      onPressed: canSubmit ? _submit : null,
                      child: Text(_isSubmitting ? '精炼中' : '精炼'),
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

  /// 提交圣殿精炼
  Future<void> _submit() async {
    final actionContext = _data.actionContext;
    if (_isSubmitting || actionContext == null) {
      return;
    }

    if (!_canRefine(_data)) {
      AppToast.error(context, text: '当前固定资产不足，暂时无法精炼');
      return;
    }

    final confirmed = await _confirmRefine();
    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final message = await actionContext.magicRepository.refineTemple(
        characterId: _data.characterId,
      );
      if (!mounted) {
        return;
      }

      if (message.contains('失败')) {
        AppToast.error(context, text: message);
      } else {
        AppToast.info(context, text: message.isEmpty ? '精炼成功' : message);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.error(
        context,
        text: _messageForError(error),
      );
    } finally {
      try {
        await actionContext.onActionCompleted?.call();
      } catch (_) {
        // 外层刷新失败时保留精炼结果提示
      }

      try {
        final refreshed = await _actionController.refreshActionSheetData(_data);
        if (refreshed != null) {
          _data = refreshed;
        }
      } catch (_) {
        // 抽屉内部刷新失败时保留精炼结果提示
      }

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 确认本次精炼
  Future<bool> _confirmRefine() async {
    if (_skipConfirm) {
      return true;
    }

    var skipConfirm = false;
    final confirmed = await showAppConfirmDialog(
      context,
      title: '确认精炼',
      message: _refineDescription,
      cancelText: '取消',
      confirmText: '精炼',
      middleButtonText: '精炼，本次不再确认',
      onMiddleButtonPressed: () async {
        skipConfirm = true;
        return true;
      },
    );
    if (confirmed && skipConfirm && mounted) {
      setState(() {
        _skipConfirm = true;
      });
    }

    return confirmed;
  }

  /// 解析精炼失败文案
  ///
  /// [error] 捕获到的异常
  String _messageForError(Object error) {
    return resolveUserErrorMessage(error, fallback: '精炼失败');
  }

  /// 本次精炼 cc 消耗文案
  String get _refineCostText {
    final cost = math.pow(1.3, _data.refine) * 10000;
    return Formatters.groupedNumber(cost.round());
  }

  /// 本次精炼确认说明
  String get _refineDescription {
    return '确定要消耗1股固定资产和${_refineCostText}cc进行精炼？';
  }

  /// 当前圣殿是否满足精炼门槛
  ///
  /// [data] 圣殿资产卡片展示数据
  bool _canRefine(TempleAssetCardData data) {
    return data.sacrifices >= _refineMinimumTempleAssets &&
        data.assets >= _refineMinimumTempleAssets;
  }
}

/// 精炼所需圣殿固定资产门槛
const int _refineMinimumTempleAssets = 2500;
