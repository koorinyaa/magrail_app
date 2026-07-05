part of '../temple_asset_magic_action_sheet.dart';

/// 闪光结晶独立确认弹窗提交流程
extension _TempleAssetMagicStarbreakFlow on _TempleAssetMagicActionSheetState {
  /// 在独立闪光结晶确认弹窗中提交
  ///
  /// [dialogContext] 弹窗上下文
  /// [dataNotifier] 闪光结晶确认弹窗中的圣殿数据
  /// [targetNotifier] 闪光结晶确认弹窗中的目标角色数据
  Future<String?> _submitDetachedStarbreakFromDialog({
    required BuildContext dialogContext,
    required ValueNotifier<TempleAssetCardData> dataNotifier,
    required ValueNotifier<CharacterDetailSearchItem> targetNotifier,
  }) async {
    final data = dataNotifier.value;
    final target = targetNotifier.value;
    final validation =
        _TempleAssetMagicDialogFlow(this)._validateDetachedStarbreakSubmit(
      data: data,
      target: target,
    );
    if (validation != null) {
      if (dialogContext.mounted) {
        AppToast.error(dialogContext, text: validation);
      }
      return null;
    }

    try {
      final message = await _actionController.submitStarbreak(
        data: data,
        targetCharacterId: target.characterId,
      );

      await saveTempleAssetMagicRecentCharacterId(
        storageKeyPrefix: _TempleAssetMagicActionSheetState
            ._starbreakRecentCharacterIdsKeyPrefix,
        username: data.actionContext!.currentUserName,
        characterId: target.characterId,
      );
      await _refreshDetachedStarbreakDialogData(
        dataNotifier: dataNotifier,
        targetNotifier: targetNotifier,
      );

      return message;
    } catch (error) {
      if (dialogContext.mounted) {
        AppToast.error(
          dialogContext,
          text: _TempleAssetMagicSubmitLogic(this)._messageForError(
            error,
            '闪光结晶失败',
          ),
        );
      }
      return null;
    }
  }

  /// 刷新独立闪光结晶确认弹窗数据
  ///
  /// [dataNotifier] 闪光结晶确认弹窗中的圣殿数据
  /// [targetNotifier] 闪光结晶确认弹窗中的目标角色数据
  Future<void> _refreshDetachedStarbreakDialogData({
    required ValueNotifier<TempleAssetCardData> dataNotifier,
    required ValueNotifier<CharacterDetailSearchItem> targetNotifier,
  }) async {
    final result = await _actionController.refreshDetachedStarbreakDialogData(
      data: dataNotifier.value,
      targetCharacterId: targetNotifier.value.characterId,
    );
    final refreshedData = result.data;
    if (refreshedData != null) {
      dataNotifier.value = refreshedData;
    }
    final refreshedTarget = result.target;
    if (refreshedTarget != null) {
      targetNotifier.value =
          TempleAssetMagicCharacterSearchItem.fromUserCharacter(refreshedTarget)
              .toSearchItem();
    }
  }
}
