part of '../temple_asset_magic_action_sheet.dart';

/// 混沌魔方确认与结果弹窗提交流程
extension _TempleAssetMagicChaosFlow on _TempleAssetMagicActionSheetState {
  /// 在混沌魔方确认区中提交
  Future<TinygrailCharacterRewardItem?> _submitChaosCubeFromDialog() async {
    if (_isSubmitting) {
      return null;
    }

    final validation = _TempleAssetMagicSubmitLogic(this)._validateSubmit();
    if (validation != null) {
      AppToast.error(context, text: validation);
      return null;
    }

    _setSheetState(() {
      _isSubmitting = true;
      _progressText = '';
    });

    try {
      final result =
          await _TempleAssetMagicSubmitLogic(this)._submitChaosCubeDraw();
      if (!mounted) {
        return null;
      }

      await _TempleAssetMagicDialogFlow(this)._refreshAfterMagicAction(context);
      return result;
    } catch (error) {
      if (!mounted) {
        return null;
      }

      AppToast.error(
        context,
        text: _TempleAssetMagicSubmitLogic(this)._messageForError(
          error,
          '${_TempleAssetMagicStateQueries(this)._actionLabel}失败',
        ),
      );
      return null;
    } finally {
      if (mounted) {
        _setSheetState(() {
          _isSubmitting = false;
          _progressText = '';
        });
      }
    }
  }

  /// 在混沌魔方结果弹窗中再次提交
  ///
  /// [dialogContext] 显示提示的弹窗上下文
  Future<TinygrailCharacterRewardItem?> _submitChaosCubeFromResultDialog(
    BuildContext dialogContext,
  ) async {
    final validation = _TempleAssetMagicSubmitLogic(this)._validateSubmit();
    if (validation != null) {
      AppToast.error(dialogContext, text: validation);
      return null;
    }

    try {
      final result =
          await _TempleAssetMagicSubmitLogic(this)._submitChaosCubeDraw();
      await _TempleAssetMagicDialogFlow(this)._refreshAfterMagicAction(
        dialogContext.mounted ? dialogContext : null,
      );
      return result;
    } catch (error) {
      if (!dialogContext.mounted) {
        return null;
      }

      AppToast.error(
        dialogContext,
        text: _TempleAssetMagicSubmitLogic(this)._messageForError(
          error,
          '${_TempleAssetMagicStateQueries(this)._actionLabel}失败',
        ),
      );
      return null;
    }
  }
}
