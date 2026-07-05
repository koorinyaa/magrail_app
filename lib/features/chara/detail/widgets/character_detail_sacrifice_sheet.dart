import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_sacrifice_sheet_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_sacrifice_result.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_sacrifice_result_panel.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'sacrifice_sheet/character_detail_sacrifice_sheet_layout.dart';
part 'sacrifice_sheet/character_detail_sacrifice_sheet_modes.dart';
part 'sacrifice_sheet/character_detail_sacrifice_sheet_input.dart';

/// 显示角色资产重组底部抽屉
///
/// [context] 当前组件树上下文
/// [repository] 角色详情仓库
/// [userRepository] 用户仓库
/// [characterId] 角色 ID
/// [currentUserName] 当前登录用户名
Future<CharacterDetailSacrificeMode?> showCharacterDetailSacrificeSheet(
  BuildContext context, {
  required CharacterDetailRepository repository,
  required UserRepository userRepository,
  required int characterId,
  required String currentUserName,
}) async {
  CharacterDetailSacrificeMode? submittedMode;
  final closedMode = await showModalBottomSheet<CharacterDetailSacrificeMode>(
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
        child: CharacterDetailSacrificeSheet(
          repository: repository,
          userRepository: userRepository,
          characterId: characterId,
          currentUserName: currentUserName,
          onSubmitSucceeded: (mode) {
            submittedMode = mode;
          },
        ),
      );
    },
  );
  return closedMode ?? submittedMode;
}

/// 角色资产重组底部抽屉
class CharacterDetailSacrificeSheet extends StatefulWidget {
  /// 创建角色资产重组底部抽屉
  ///
  /// [key] Flutter 组件标识
  /// [repository] 角色详情仓库
  /// [userRepository] 用户仓库
  /// [characterId] 角色 ID
  /// [currentUserName] 当前登录用户名
  /// [onSubmitSucceeded] 提交成功回调
  const CharacterDetailSacrificeSheet({
    super.key,
    required this.repository,
    required this.userRepository,
    required this.characterId,
    required this.currentUserName,
    required this.onSubmitSucceeded,
  });

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 角色 ID
  final int characterId;

  /// 当前登录用户名
  final String currentUserName;

  /// 提交成功后通知外层刷新所需类型
  final ValueChanged<CharacterDetailSacrificeMode> onSubmitSucceeded;

  /// 创建角色资产重组底部抽屉状态
  @override
  State<CharacterDetailSacrificeSheet> createState() =>
      _CharacterDetailSacrificeSheetState();
}

/// 角色资产重组底部抽屉状态
class _CharacterDetailSacrificeSheetState
    extends State<CharacterDetailSacrificeSheet> {
  late final CharacterDetailSacrificeSheetController _controller;
  CharacterDetailSacrificeResult? _result;
  CharacterDetailSacrificeMode? _resultMode;

  /// 初始化角色资产重组底部抽屉状态
  @override
  void initState() {
    super.initState();
    _controller = CharacterDetailSacrificeSheetController(
      repository: widget.repository,
      userRepository: widget.userRepository,
      characterId: widget.characterId,
      currentUserName: widget.currentUserName,
    )..addListener(_handleControllerChanged);
    unawaited(_controller.initialize());
  }

  /// 释放角色资产重组底部抽屉状态
  @override
  void dispose() {
    _controller
      ..removeListener(_handleControllerChanged)
      ..dispose();
    super.dispose();
  }

  /// 根据控制器变化刷新抽屉
  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// 构建角色资产重组底部抽屉
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

    // 提交中阻止系统关闭，避免接口成功但外层拿不到刷新类型
    return PopScope(
      canPop: !_controller.isSubmitting,
      child: Padding(
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
                    Flexible(
                      child: SingleChildScrollView(
                        child: _buildContent(context),
                      ),
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

  /// 构建抽屉内容
  ///
  /// [context] 当前组件树上下文
  Widget _buildContent(BuildContext context) {
    if (_controller.isLoading) {
      return const _SacrificeSheetSkeleton();
    }

    if (_controller.hasLoadError) {
      return AppLoadFailedState(
        message: _controller.loadErrorMessage,
        onActionPressed: _controller.reload,
      );
    }

    final result = _result;
    if (result != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SacrificeSheetHeader(
            controller: _controller,
            mode: _resultMode ?? _controller.mode,
          ),
          const SizedBox(height: 16),
          CharacterDetailSacrificeResultPanel(
            mode: _resultMode ?? _controller.mode,
            result: result,
            onComplete: _completeResult,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SacrificeSheetHeader(controller: _controller),
        const SizedBox(height: 16),
        _SacrificeMainPanel(
          controller: _controller,
          onSubmit: _handleSubmit,
        ),
      ],
    );
  }

  /// 提交资产重组或股权融资
  Future<void> _handleSubmit() async {
    final validation = _controller.validationMessage;
    if (validation != null) {
      AppToast.error(context, text: validation);
      return;
    }

    final mode = _controller.mode;
    if (mode == CharacterDetailSacrificeMode.financing &&
        _controller.amount >= 2500) {
      final shouldContinue = await showAppConfirmDialog(
        context,
        title: '股权融资确认',
        message: '当前股权融资数量较大，是否继续？',
        confirmText: '继续',
        icon: LucideIcons.repeat2,
      );
      if (!shouldContinue || !mounted) {
        return;
      }
    }

    try {
      final result = await _controller.submit();
      if (!mounted) {
        return;
      }

      setState(() {
        _resultMode = mode;
        _result = result;
      });
      widget.onSubmitSucceeded(mode);
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.error(
        context,
        text: _errorText(error, mode),
      );
    }
  }

  /// 转换提交异常为展示文案
  ///
  /// [error] 捕获到的异常
  /// [mode] 本次提交类型
  String _errorText(Object error, CharacterDetailSacrificeMode mode) {
    final fallback =
        mode == CharacterDetailSacrificeMode.financing ? '股权融资失败' : '资产重组失败';
    return resolveUserErrorMessage(error, fallback: fallback);
  }

  /// 完成结果展示并关闭抽屉
  void _completeResult() {
    Navigator.of(context).pop(_resultMode);
  }
}
