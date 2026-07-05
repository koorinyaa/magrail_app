part of '../temple_asset_magic_action_sheet.dart';

extension _TempleAssetMagicSubmitLogic on _TempleAssetMagicActionSheetState {
  /// 提交混沌魔方并返回抽取结果
  Future<TinygrailCharacterRewardItem> _submitChaosCubeDraw() {
    return _actionController.submitChaosCubeDraw(_data);
  }

  /// 提交虚空道标
  Future<TinygrailCharacterRewardItem> _submitGuidepost() {
    return _actionController.submitGuidepost(
      data: _data,
      targetCharacterId: _selectedCharacter!.characterId,
    );
  }

  /// 提交指定目标的鲤鱼之眼
  ///
  /// [consumeCharacterId] 消耗圣殿角色 ID

  /// [targetCharacterId] 目标角色 ID
  Future<String> _submitFisheyeForTarget({
    required int consumeCharacterId,
    required int targetCharacterId,
  }) {
    return _actionController.submitFisheyeForTarget(
      data: _data,
      consumeCharacterId: consumeCharacterId,
      targetCharacterId: targetCharacterId,
    );
  }

  /// 提交星光碎片
  Future<String> _submitStardust() {
    return _actionController.submitStardust(
      data: _data,
      sourceCharacterId: _selectedCharacter!.characterId,
      amount: _TempleAssetMagicStateQueries(this)._amount,
      isDownSacrifices: _stardustDownSacrificesNotifier.value,
    );
  }

  /// 提交星之力转换或冲星
  Future<String> _submitStarForces() {
    if (_isFillStar) {
      return _fillStarForces();
    }

    return _actionController.submitStarForces(
      data: _data,
      amount: _TempleAssetMagicStateQueries(this)._amount,
      isFillStar: false,
    );
  }

  /// 校验当前提交
  String? _validateSubmit() {
    final actionContext = _data.actionContext!;
    if (actionContext.currentUserName.trim().isEmpty) {
      return '请先授权';
    }

    if (!_TempleAssetMagicStateQueries(this)._isStarForcesAction &&
        _data.level <= 0) {
      return '圣殿等级不足';
    }

    if (_TempleAssetMagicStateQueries(this)._requiresSelected &&
        _selectedCharacter == null) {
      return '请选择目标角色';
    }

    if (_TempleAssetMagicStateQueries(this)._requiresAmount &&
        _TempleAssetMagicStateQueries(this)._amount <= 0) {
      return '请输入有效数量';
    }

    if (widget.action == TempleAssetMagicAction.stardust) {
      final selected = _selectedCharacter!;
      final available = selected.userAmount;
      if (_TempleAssetMagicStateQueries(this)._amount > available) {
        return '可用活股数量不足';
      }
    }

    if (widget.action == TempleAssetMagicAction.starForces && !_isFillStar) {
      if (_TempleAssetMagicStateQueries(this)._amount > _data.assets) {
        return '固定资产余量不足';
      }
    }

    return null;
  }

  /// 生成异常文案
  ///
  /// [error] 捕获到的异常

  /// [fallback] 兜底文案
  String _messageForError(Object error, String fallback) {
    return resolveUserErrorMessage(error, fallback: fallback);
  }
}
