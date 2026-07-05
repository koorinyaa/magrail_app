part of '../temple_asset_magic_action_sheet.dart';

/// 星光碎片确认与提交流程
extension _TempleAssetMagicStardustFlow on _TempleAssetMagicActionSheetState {
  /// 显示星光碎片目标确认弹窗
  ///
  /// [item] 已选择的消耗角色
  Future<void> _showStardustConfirmDialog(
    CharacterDetailSearchItem item,
  ) async {
    String? message;
    final confirmed = await showAppConfirmDialog(
      context,
      title: '',
      message: '',
      content: _TempleAssetStardustConfirmContent(
        data: _data,
        source: item,
        amountController: _amountController,
        downSacrificesNotifier: _stardustDownSacrificesNotifier,
        rateValue: _TempleAssetMagicStateQueries(this)._stardustRateValue(item),
      ),
      contentPadding: EdgeInsets.zero,
      confirmText: 'CONVERT',
      showCancelButton: false,
      onConfirm: () async {
        message = await _submitStardustFromDialog();
        return message != null;
      },
    );
    if (!mounted) {
      return;
    }

    if (confirmed && message != null) {
      AppToast.info(context, text: message!);
    }

    if (_selectedCharacter?.characterId == item.characterId) {
      _setSheetState(() {
        _selectedCharacter = null;
        _amountController.text =
            _TempleAssetMagicStateQueries(this)._defaultAmountText;
      });
      _stardustDownSacrificesNotifier.value = false;
    }
  }

  /// 在星光碎片确认弹窗中提交
  Future<String?> _submitStardustFromDialog() async {
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
      final message =
          await _TempleAssetMagicSubmitLogic(this)._submitStardust();
      if (!mounted) {
        return null;
      }

      await _TempleAssetMagicDialogFlow(this)._recordRecentMagicCharacterId(
        _selectedCharacter?.characterId ?? 0,
      );
      if (!mounted) {
        return null;
      }

      await _TempleAssetMagicDialogFlow(this)._refreshAfterMagicAction(context);
      return message;
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
