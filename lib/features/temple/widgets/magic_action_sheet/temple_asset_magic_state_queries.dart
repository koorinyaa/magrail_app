part of '../temple_asset_magic_action_sheet.dart';

extension _TempleAssetMagicStateQueries on _TempleAssetMagicActionSheetState {
  /// [item] 消耗活股角色
  int _stardustRateValue(CharacterDetailSearchItem item) {
    if (item.level + 1 >= _data.characterLevel) {
      return 1;
    }

    final difference = _data.characterLevel - item.level - 1;
    return math.min(math.pow(2, difference).toInt(), 32);
  }

  /// 使用指定圣殿数据计算闪光结晶攻击倍率
  ///
  /// [data] 圣殿资产卡片展示数据

  /// [item] 攻击目标角色
  String _starbreakRateForData(
    TempleAssetCardData data,
    CharacterDetailSearchItem item,
  ) {
    if (item.level <= 0 || data.characterLevel <= 0) {
      return '0';
    }

    if (item.level == data.characterLevel) {
      return '1';
    }

    final ratio =
        (15 * math.log(item.level / data.characterLevel) / math.ln10).abs();
    if (ratio <= 0) {
      return '0';
    }

    final rate = data.characterLevel > item.level ? ratio : 1 / ratio;
    return rate.toStringAsFixed(2);
  }

  /// 当前角色展示名称
  String get _characterName {
    return TinygrailFormatters.decodeHtmlEntities(_data.characterName);
  }

  /// 当前操作标题
  String get _actionLabel {
    return switch (widget.action) {
      TempleAssetMagicAction.guidepost => '虚空道标',
      TempleAssetMagicAction.chaosCube => '混沌魔方',
      TempleAssetMagicAction.fisheye => '鲤鱼之眼',
      TempleAssetMagicAction.stardust => '星光碎片',
      TempleAssetMagicAction.starbreak => '闪光结晶',
      TempleAssetMagicAction.starForces => '星之力',
    };
  }

  /// 搜索提示文案
  String get _searchHint {
    return switch (widget.action) {
      TempleAssetMagicAction.guidepost => '请选择虚空道标的目标角色',
      TempleAssetMagicAction.fisheye => '请选择鲤鱼之眼的目标角色',
      TempleAssetMagicAction.stardust => '请选择星光碎片消耗的角色',
      TempleAssetMagicAction.starbreak => '请选择闪光结晶攻击的角色',
      TempleAssetMagicAction.chaosCube ||
      TempleAssetMagicAction.starForces =>
        '',
    };
  }

  /// 默认数量文本
  String get _defaultAmountText {
    return switch (widget.action) {
      _ => '',
    };
  }

  /// 当前输入数量
  int get _amount {
    return int.tryParse(_amountController.text.trim()) ?? 0;
  }

  /// 填入魔法提交数量
  ///
  /// [amount] 目标数量
  void _fillAmount(int amount) {
    final text = math.max(0, amount).toString();
    if (_amountController.text == text) {
      return;
    }

    _amountController.text = text;
    _amountController.selection = TextSelection.collapsed(offset: text.length);
  }

  /// 当前操作是否需要选择角色
  bool get _requiresSelected {
    return switch (widget.action) {
      TempleAssetMagicAction.guidepost ||
      TempleAssetMagicAction.fisheye ||
      TempleAssetMagicAction.stardust ||
      TempleAssetMagicAction.starbreak =>
        true,
      TempleAssetMagicAction.chaosCube ||
      TempleAssetMagicAction.starForces =>
        false,
    };
  }

  /// 当前操作是否需要数量输入
  bool get _requiresAmount {
    return switch (widget.action) {
      TempleAssetMagicAction.stardust ||
      TempleAssetMagicAction.starForces =>
        !_isFillStar,
      TempleAssetMagicAction.guidepost ||
      TempleAssetMagicAction.fisheye ||
      TempleAssetMagicAction.starbreak ||
      TempleAssetMagicAction.chaosCube =>
        false,
    };
  }

  /// 当前是否显示角色搜索区
  bool get _isShowingCharacterSearch {
    return _requiresSelected &&
        (_selectedCharacter == null ||
            widget.action == TempleAssetMagicAction.guidepost ||
            widget.action == TempleAssetMagicAction.fisheye ||
            widget.action == TempleAssetMagicAction.stardust ||
            widget.action == TempleAssetMagicAction.starbreak);
  }

  /// 当前操作是否为星之力
  bool get _isStarForcesAction {
    return widget.action == TempleAssetMagicAction.starForces;
  }

  /// 是否锁定当前抽屉关闭
  bool get _locksSheetClose {
    return _isStarForcesAction && _isFillStar && _isSubmitting;
  }
}
