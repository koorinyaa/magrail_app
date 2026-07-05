part of '../temple_asset_magic_action_sheet.dart';

/// 虚空道标确认与提交流程
extension _TempleAssetMagicGuidepostFlow on _TempleAssetMagicActionSheetState {
  /// 显示虚空道标目标确认弹窗
  ///
  /// [item] 已选择的目标角色
  Future<void> _showGuidepostConfirmDialog(
    CharacterDetailSearchItem item,
  ) async {
    TinygrailCharacterRewardItem? result;
    final confirmed = await showAppConfirmDialog(
      context,
      title: '',
      message: '',
      content: _TempleAssetGuidepostConfirmContent(
        data: _data,
        target: item,
      ),
      confirmText: 'POST',
      showCancelButton: false,
      onConfirm: () async {
        result = await _submitGuidepostFromDialog();
        return result != null;
      },
    );
    if (!mounted) {
      return;
    }

    if (confirmed) {
      final submittedResult = result;
      if (submittedResult != null) {
        await _TempleAssetMagicDialogFlow(this)._showMagicDrawResultDialog(
          submittedResult,
          onRetry: _submitGuidepostFromDialog,
        );
      }
      if (!mounted) {
        return;
      }

      if (_selectedCharacter?.characterId == item.characterId) {
        _setSheetState(() {
          _selectedCharacter = null;
        });
      }
      return;
    }

    if (_selectedCharacter?.characterId == item.characterId) {
      _setSheetState(() {
        _selectedCharacter = null;
      });
    }
  }

  /// 在虚空道标确认弹窗中提交
  Future<TinygrailCharacterRewardItem?> _submitGuidepostFromDialog() async {
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
          await _TempleAssetMagicSubmitLogic(this)._submitGuidepost();
      if (!mounted) {
        return null;
      }

      await _TempleAssetMagicDialogFlow(this)._recordRecentMagicCharacterId(
        _selectedCharacter?.characterId ?? result.id,
      );
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
}
