part of '../temple_asset_magic_action_sheet.dart';

extension _TempleAssetMagicDialogFlow on _TempleAssetMagicActionSheetState {
  /// 显示鲤鱼之眼目标确认弹窗
  ///
  /// [item] 已选择的目标角色
  /// [gensokyoAmount] 目标角色幻想乡持股
  Future<void> _showFisheyeConfirmDialog(
    CharacterDetailSearchItem item,
    int gensokyoAmount,
  ) async {
    final navigator = Navigator.of(context);
    final dialogContext = Navigator.of(context, rootNavigator: true).context;
    final data = _data;
    final actionContext = data.actionContext!;
    final username = actionContext.currentUserName.trim();

    await navigator.maybePop();
    await Future<void>.delayed(Duration.zero);
    if (!dialogContext.mounted) {
      return;
    }

    String? message;
    final confirmed = await showAppConfirmDialog(
      dialogContext,
      title: '',
      message: '',
      content: _TempleAssetFisheyeConfirmContent(
        data: data,
        target: item,
        gensokyoAmount: gensokyoAmount,
      ),
      confirmText: 'TRANSFER',
      showCancelButton: false,
      onConfirm: () async {
        if (username.isEmpty) {
          AppToast.error(dialogContext, text: '请先授权');
          return false;
        }

        if (data.level <= 0) {
          AppToast.error(dialogContext, text: '圣殿等级不足');
          return false;
        }

        try {
          message =
              await _TempleAssetMagicSubmitLogic(this)._submitFisheyeForTarget(
            consumeCharacterId: data.characterId,
            targetCharacterId: item.characterId,
          );
        } catch (error) {
          if (dialogContext.mounted) {
            AppToast.error(
              dialogContext,
              text: _TempleAssetMagicSubmitLogic(this)
                  ._messageForError(error, '鲤鱼之眼失败'),
            );
          }
          return false;
        }

        try {
          await saveTempleAssetMagicRecentCharacterId(
            storageKeyPrefix: _TempleAssetMagicActionSheetState
                ._fisheyeRecentCharacterIdsKeyPrefix,
            username: username,
            characterId: item.characterId,
          );
        } catch (_) {
          // 最近使用记录失败不影响道具使用结果
        }

        try {
          await actionContext.onActionCompleted?.call();
        } catch (_) {
          if (dialogContext.mounted) {
            AppToast.error(dialogContext, text: '操作成功，刷新失败');
          }
        }
        return true;
      },
    );
    if (!dialogContext.mounted) {
      return;
    }

    if (confirmed) {
      final submittedMessage = message;
      if (submittedMessage != null) {
        AppToast.info(dialogContext, text: submittedMessage);
      }
    }
  }

  /// 关闭搜索抽屉并显示闪光结晶目标确认弹窗
  ///
  /// [item] 已选择的攻击目标
  Future<void> _showDetachedStarbreakConfirmDialog(
    CharacterDetailSearchItem item,
  ) async {
    final navigator = Navigator.of(context);
    final dialogContext = Navigator.of(context, rootNavigator: true).context;
    final data = _data;
    final selectedCharacter = _selectedCharacter;

    await navigator.maybePop();
    await Future<void>.delayed(Duration.zero);
    if (!dialogContext.mounted || selectedCharacter == null) {
      return;
    }

    await _showDetachedStarbreakDialog(
      dialogContext: dialogContext,
      initialData: data,
      initialTarget: selectedCharacter,
    );
  }

  /// 显示脱离搜索抽屉的闪光结晶确认弹窗
  ///
  /// [dialogContext] 弹窗上下文
  /// [initialData] 初始圣殿资产卡片展示数据
  /// [initialTarget] 初始攻击目标
  Future<void> _showDetachedStarbreakDialog({
    required BuildContext dialogContext,
    required TempleAssetCardData initialData,
    required CharacterDetailSearchItem initialTarget,
  }) async {
    final dataNotifier = ValueNotifier<TempleAssetCardData>(initialData);
    final targetNotifier = ValueNotifier<CharacterDetailSearchItem>(
      initialTarget,
    );
    try {
      await showAppConfirmDialog(
        dialogContext,
        title: '',
        message: '',
        content: ValueListenableBuilder<TempleAssetCardData>(
          valueListenable: dataNotifier,
          builder: (context, currentData, child) {
            return ValueListenableBuilder<CharacterDetailSearchItem>(
              valueListenable: targetNotifier,
              builder: (context, currentTarget, child) {
                return _TempleAssetStarbreakConfirmContent(
                  data: currentData,
                  target: currentTarget,
                  rateText:
                      _TempleAssetMagicStateQueries(this)._starbreakRateForData(
                    currentData,
                    currentTarget,
                  ),
                );
              },
            );
          },
        ),
        confirmText: 'ATTACK',
        showCancelButton: false,
        onConfirm: () async {
          final message = await _TempleAssetMagicStarbreakFlow(this)
              ._submitDetachedStarbreakFromDialog(
            dialogContext: dialogContext,
            dataNotifier: dataNotifier,
            targetNotifier: targetNotifier,
          );
          if (message != null && dialogContext.mounted) {
            AppToast.info(dialogContext, text: message);
          }
          return false;
        },
      );
    } finally {
      dataNotifier.dispose();
      targetNotifier.dispose();
    }
  }

  /// 校验独立闪光结晶确认弹窗提交
  ///
  /// [data] 当前圣殿资产卡片展示数据
  /// [target] 当前攻击目标
  String? _validateDetachedStarbreakSubmit({
    required TempleAssetCardData data,
    required CharacterDetailSearchItem target,
  }) {
    final actionContext = data.actionContext;
    if (actionContext == null || actionContext.currentUserName.trim().isEmpty) {
      return '请先授权';
    }

    if (data.level <= 0) {
      return '圣殿等级不足';
    }

    if (target.characterId <= 0) {
      return '请选择目标角色';
    }

    if (data.assets < 100) {
      return '固定资产余量不足';
    }

    return null;
  }

  /// 显示魔法道具抽取结果弹窗
  ///
  /// [result] 魔法道具抽取结果
  /// [dialogContext] 显示弹窗的上下文
  /// [onRetry] 再次使用道具的回调
  Future<void> _showMagicDrawResultDialog(
    TinygrailCharacterRewardItem result, {
    BuildContext? dialogContext,
    required Future<TinygrailCharacterRewardItem?> Function() onRetry,
  }) async {
    final targetContext = dialogContext ?? context;
    final resultNotifier = ValueNotifier<TinygrailCharacterRewardItem>(
      result,
    );
    var isResultDialogOpen = true;

    try {
      await showAppConfirmDialog(
        targetContext,
        title: '',
        message: '',
        content: ValueListenableBuilder<TinygrailCharacterRewardItem>(
          valueListenable: resultNotifier,
          builder: (context, currentResult, child) {
            return _TempleAssetMagicDrawResultDialogContent(
              result: currentResult,
            );
          },
        ),
        confirmText: '再来一次',
        showCancelButton: false,
        onConfirm: () async {
          final nextResult = await onRetry();
          if (nextResult != null && isResultDialogOpen) {
            resultNotifier.value = nextResult;
          }
          return false;
        },
      );
    } finally {
      isResultDialogOpen = false;
      resultNotifier.dispose();
    }
  }

  /// 从混沌魔方确认区显示结果弹窗
  Future<void> _showChaosResultDialogFromConfirm() async {
    final result =
        await _TempleAssetMagicChaosFlow(this)._submitChaosCubeFromDialog();
    if (result == null || !mounted) {
      return;
    }

    final navigator = Navigator.of(context);
    final dialogContext = navigator.context;
    navigator.pop();
    await Future<void>.delayed(Duration.zero);
    if (!dialogContext.mounted) {
      return;
    }

    await _showMagicDrawResultDialog(
      result,
      dialogContext: dialogContext,
      onRetry: () => _TempleAssetMagicChaosFlow(this)
          ._submitChaosCubeFromResultDialog(dialogContext),
    );
  }

  /// 刷新魔法道具使用后的入口数据
  ///
  /// [toastContext] 刷新失败提示上下文
  Future<void> _refreshAfterMagicAction(BuildContext? toastContext) async {
    var hasRefreshError = false;
    try {
      await _data.actionContext?.onActionCompleted?.call();
    } catch (_) {
      hasRefreshError = true;
    }

    try {
      await _refreshActionSheetData();
    } catch (_) {
      hasRefreshError = true;
    }

    if (!hasRefreshError || toastContext == null || !toastContext.mounted) {
      return;
    }

    AppToast.error(toastContext, text: '操作成功，刷新失败');
  }

  /// 记录魔法角色搜索最近使用角色
  ///
  /// [characterId] 最近使用的角色 ID
  Future<void> _recordRecentMagicCharacterId(int characterId) async {
    final username = _data.actionContext?.currentUserName.trim() ?? '';
    if (characterId <= 0 || username.isEmpty) {
      return;
    }

    try {
      final panelState = _searchPanelKey.currentState;
      if (panelState != null) {
        await panelState.saveRecentCharacterId(characterId);
        return;
      }

      await saveTempleAssetMagicRecentCharacterId(
        storageKeyPrefix: _recentMagicCharacterIdsKeyPrefix,
        username: username,
        characterId: characterId,
      );
    } catch (_) {
      return;
    }
  }
}
