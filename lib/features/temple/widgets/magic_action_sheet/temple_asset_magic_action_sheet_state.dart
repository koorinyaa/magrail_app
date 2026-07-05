part of '../temple_asset_magic_action_sheet.dart';

/// 圣殿资产魔法道具操作底部抽屉状态
class _TempleAssetMagicActionSheetState
    extends State<_TempleAssetMagicActionSheet> {
  static const String _guidepostRecentCharacterIdsKeyPrefix =
      'tinygrail_guidepost_recent_character_ids';
  static const String _fisheyeRecentCharacterIdsKeyPrefix =
      'tinygrail_fisheye_recent_character_ids';
  static const String _stardustRecentCharacterIdsKeyPrefix =
      'tinygrail_stardust_recent_character_ids';
  static const String _starbreakRecentCharacterIdsKeyPrefix =
      'tinygrail_starbreak_recent_character_ids';

  final GlobalKey<TempleAssetMagicCharacterSearchPanelState> _searchPanelKey =
      GlobalKey<TempleAssetMagicCharacterSearchPanelState>();
  final TextEditingController _amountController = TextEditingController();
  final ValueNotifier<bool> _stardustDownSacrificesNotifier =
      ValueNotifier<bool>(false);
  final TempleAssetMagicActionController _actionController =
      const TempleAssetMagicActionController();

  var _isSubmitting = false;
  var _isFillStar = false;
  var _progressText = '';
  late TempleAssetCardData _data;
  CharacterDetailSearchItem? _selectedCharacter;

  /// 初始化圣殿资产魔法道具操作底部抽屉状态
  @override
  void initState() {
    super.initState();
    _data = widget.data;
    _amountController.text =
        _TempleAssetMagicStateQueries(this)._defaultAmountText;
  }

  /// 更新外部传入的圣殿资产数据
  ///
  /// [oldWidget] 更新前的圣殿资产魔法道具操作底部抽屉
  @override
  void didUpdateWidget(covariant _TempleAssetMagicActionSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _data = widget.data;
    }
  }

  /// 释放圣殿资产魔法道具操作底部抽屉状态
  @override
  void dispose() {
    _amountController.dispose();
    _stardustDownSacrificesNotifier.dispose();
    super.dispose();
  }

  /// 更新圣殿资产魔法抽屉状态
  ///
  /// [callback] 需要在当前状态中执行的变更
  void _setSheetState(VoidCallback callback) {
    setState(callback);
  }

  /// 构建圣殿资产魔法道具操作底部抽屉
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

    // 冲星会连续请求多个接口，执行中禁止外部关闭打断刷新边界
    return PopScope(
      canPop: !_TempleAssetMagicStateQueries(this)._locksSheetClose,
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
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AppBottomSheetDragHandle(),
                        const SizedBox(height: 10),
                        Flexible(
                          child: _TempleAssetMagicStateQueries(this)
                                  ._isShowingCharacterSearch
                              ? _TempleAssetMagicSearchConfig(this)
                                  ._buildCharacterSearchPanel()
                              : SingleChildScrollView(
                                  child: _buildBody(context),
                                ),
                        ),
                      ],
                    ),
                    if (_TempleAssetMagicStateQueries(this)
                            ._isShowingCharacterSearch &&
                        _isSubmitting &&
                        _progressText.isNotEmpty)
                      Positioned.fill(
                        child: _TempleAssetMagicProgressOverlay(
                          text: _progressText,
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

  /// 构建抽屉主体
  ///
  /// [context] 当前组件树上下文
  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TempleAssetMagicSheetHeader(
              action: widget.action,
              characterName: _TempleAssetMagicStateQueries(this)._characterName,
              characterId: _data.characterId,
            ),
            const SizedBox(height: 16),
            switch (widget.action) {
              TempleAssetMagicAction.chaosCube => _buildChaosConfirm(context),
              TempleAssetMagicAction.starForces => _buildStarForces(context),
              _ when _selectedCharacter == null => const SizedBox.shrink(),
              TempleAssetMagicAction.guidepost => const SizedBox.shrink(),
              TempleAssetMagicAction.fisheye => const SizedBox.shrink(),
              TempleAssetMagicAction.stardust => const SizedBox.shrink(),
              TempleAssetMagicAction.starbreak => const SizedBox.shrink(),
            },
          ],
        ),
        if (_isSubmitting && _progressText.isNotEmpty)
          Positioned.fill(
            child: _TempleAssetMagicProgressOverlay(text: _progressText),
          ),
      ],
    );
  }

  /// 构建混沌魔方确认区
  ///
  /// [context] 当前组件树上下文
  Widget _buildChaosConfirm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TempleAssetChaosConfirmContent(data: _data),
        const SizedBox(height: 16),
        SizedBox(
          height: 42,
          child: FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: _isSubmitting ? null : _showChaosResultDialogFromConfirm,
            child: Text(_isSubmitting ? '处理中' : '使用'),
          ),
        ),
      ],
    );
  }

  /// 构建星之力操作区
  ///
  /// [context] 当前组件树上下文
  Widget _buildStarForces(BuildContext context) {
    final requiredStarForces = math.max(0, 10000 - _data.starForces);
    final requiredTempleAmount = math.min(_data.assets, requiredStarForces);
    final requiredStockAmount =
        ((requiredStarForces - requiredTempleAmount) / 2).ceil();
    final actionContext = _data.actionContext!;
    final canFillStar = requiredStarForces > 0 &&
        _data.sacrifices > 0 &&
        _data.assets >= requiredTempleAmount &&
        actionContext.availableAmount >= requiredStockAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TempleAssetMagicAssetProgress(data: _data),
        const SizedBox(height: 12),
        _TempleAssetUserAssetStatsRow(
          items: [
            _TempleAssetUserAssetStatsItem(
              label: '星之力',
              value: Formatters.groupedNumber(_data.starForces),
              showStarIcon: true,
              starHighlighted: _data.starForces >= 10000,
              accentColor: Theme.of(context).colorScheme.primary,
            ),
            _TempleAssetUserAssetStatsItem(
              label: '可用活股',
              value: Formatters.groupedNumber(actionContext.availableAmount),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (requiredStarForces > 0) ...[
          _TempleAssetMagicSwitchRow(
            label: '冲星',
            value: _isFillStar,
            onChanged: _isSubmitting
                ? null
                : (value) {
                    setState(() {
                      _isFillStar = value;
                    });
                  },
            detail:
                '预计消耗 ${Formatters.groupedNumber(requiredTempleAmount)} 固定资产和 ${Formatters.groupedNumber(requiredStockAmount)} 活股',
          ),
          const SizedBox(height: 12),
        ],
        if (!_isFillStar) ...[
          _TempleAssetMagicNumberField(
            controller: _amountController,
            label: '转化数量',
            suffixText: '',
          ),
          const SizedBox(height: 8),
          _TempleAssetMagicQuickButtons(
            buttons: [
              _TempleAssetMagicQuickButtonData(
                text: '10000',
                onPressed: _isSubmitting
                    ? null
                    : () =>
                        _TempleAssetMagicStateQueries(this)._fillAmount(10000),
              ),
              _TempleAssetMagicQuickButtonData(
                text: '全部',
                onPressed: _isSubmitting
                    ? null
                    : () => _TempleAssetMagicStateQueries(this)
                        ._fillAmount(math.max(0, _data.assets)),
              ),
            ],
          ),
        ],
        if (_isFillStar && !canFillStar)
          const _TempleAssetMagicInlineWarning(
            text: '固定资产或活股数量不足',
          ),
        const SizedBox(height: 16),
        SizedBox(
          height: 42,
          child: FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: !_isSubmitting && (!_isFillStar || canFillStar)
                ? _submitStarForcesAction
                : null,
            child: Text(
              _isSubmitting ? '处理中' : (_isFillStar ? '冲星' : '转化'),
            ),
          ),
        ),
      ],
    );
  }

  /// 选择搜索角色
  ///
  /// [item] 搜索结果条目
  /// [supplementValue] 当前角色附加数值
  void _selectCharacter(
    TempleAssetMagicCharacterSearchItem item,
    int? supplementValue,
  ) {
    if (_isSubmitting) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    final searchItem = item.toSearchItem();
    if (widget.action == TempleAssetMagicAction.fisheye) {
      unawaited(
        _TempleAssetMagicDialogFlow(this)
            ._showFisheyeConfirmDialog(searchItem, supplementValue ?? 0),
      );
      return;
    }

    setState(() {
      _selectedCharacter = searchItem;
      _amountController.text =
          _TempleAssetMagicStateQueries(this)._defaultAmountText;
    });
    _stardustDownSacrificesNotifier.value = false;
    if (widget.action == TempleAssetMagicAction.guidepost) {
      unawaited(_TempleAssetMagicGuidepostFlow(this)
          ._showGuidepostConfirmDialog(searchItem));
    } else if (widget.action == TempleAssetMagicAction.stardust) {
      unawaited(_TempleAssetMagicStardustFlow(this)
          ._showStardustConfirmDialog(searchItem));
    } else if (widget.action == TempleAssetMagicAction.starbreak) {
      unawaited(_TempleAssetMagicDialogFlow(this)
          ._showDetachedStarbreakConfirmDialog(searchItem));
    }
  }

  /// 刷新当前抽屉持有的圣殿资产数据
  Future<void> _refreshActionSheetData() async {
    final refreshedData = await _actionController.refreshActionSheetData(_data);
    if (refreshedData == null || !mounted) {
      return;
    }

    setState(() {
      _data = refreshedData;
    });
  }

  /// 提交星之力操作
  Future<void> _submitStarForcesAction() async {
    final validation = _TempleAssetMagicSubmitLogic(this)._validateSubmit();
    if (validation != null) {
      AppToast.error(context, text: validation);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _progressText = '';
    });
    final submittingFillStar = _isFillStar;

    try {
      final message =
          await _TempleAssetMagicSubmitLogic(this)._submitStarForces();
      if (!mounted) {
        return;
      }

      AppToast.info(context, text: message);
      await _TempleAssetMagicDialogFlow(this)._refreshAfterMagicAction(context);
      if (mounted && submittingFillStar) {
        setState(() {
          _isFillStar = false;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      if (submittingFillStar) {
        try {
          await _TempleAssetMagicDialogFlow(this)
              ._refreshAfterMagicAction(null);
        } catch (_) {}
        if (mounted && _data.starForces >= 10000) {
          setState(() {
            _isFillStar = false;
          });
        }
      }
      if (!mounted) {
        return;
      }

      AppToast.error(
        context,
        text: _TempleAssetMagicSubmitLogic(this)._messageForError(
            error, '${_TempleAssetMagicStateQueries(this)._actionLabel}失败'),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _progressText = '';
        });
      }
    }
  }

  /// 补足 10000 星之力
  Future<String> _fillStarForces() async {
    return _actionController.fillStarForces(
      data: _data,
      onProgress: (remainingStockAmount) {
        if (mounted) {
          setState(() {
            _progressText =
                '剩余 ${Formatters.groupedNumber(remainingStockAmount)} 股';
          });
        }
      },
    );
  }
}
