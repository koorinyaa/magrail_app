part of 'bot_config_page.dart';

/// bot 配置页面状态方法
extension _BotConfigPageStateMethods on _BotConfigPageState {
  /// 处理页面返回请求
  ///
  /// [didPop] 当前返回请求是否已经完成
  /// [result] 路由返回结果
  void _handlePopInvoked(bool didPop, Object? result) {
    if (didPop || _allowPagePop) {
      return;
    }

    unawaited(_confirmLeaveIfNeeded());
  }

  /// 构建顶部栏操作按钮
  ///
  /// [config] 当前 bot 配置
  List<Widget> _buildAppBarActions(BotConfig? config) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDisabled = config == null ||
        _controller.isLoading ||
        _controller.isSaving ||
        _controller.isRevoking;

    return [
      IconButton(
        onPressed: isDisabled ? null : _handleRevokeAuthorization,
        icon: Icon(
          Icons.link_off_rounded,
          size: 22,
          color: isDisabled ? null : colorScheme.error,
        ),
      ),
      IconButton(
        onPressed: isDisabled ? null : _handleSave,
        icon: const Icon(Icons.save_outlined, size: 22),
      ),
      const SizedBox(width: 8),
    ];
  }

  /// 刷新 bot 配置
  Future<void> _refresh() async {
    await _controller.refresh();
    if (!mounted || _controller.config == null) {
      return;
    }

    final message = _controller.errorMessage;
    if (message != null && message.isNotEmpty) {
      AppToast.error(context, text: message);
    }
  }

  /// 重试加载 bot 配置
  void _retry() {
    unawaited(_controller.refresh());
  }

  /// 保存 Bot 配置
  Future<void> _handleSave() async {
    await _saveConfig(showLoading: true);
  }

  /// 保存当前 Bot 配置
  ///
  /// [showSuccessToast] 是否显示保存成功提示
  /// [showLoading] 是否显示全局加载蒙版
  Future<bool> _saveConfig({
    bool showSuccessToast = true,
    bool showLoading = false,
  }) async {
    final config = _controller.config;
    if (config == null) {
      return false;
    }

    if (config.icoState) {
      final investmentAmount = _parseAmount(_icoInvestmentController.text);
      final reserveAmount = _parseAmount(_icoReserveController.text);
      if (investmentAmount == null) {
        AppToast.error(context, text: '请输入有效的投入金额');
        return false;
      }

      if (reserveAmount == null) {
        AppToast.error(context, text: '请输入有效的保留金额');
        return false;
      }

      if (investmentAmount < 5000) {
        AppToast.error(context, text: '投入金额不能低于 5000');
        return false;
      }

      if (reserveAmount < 0) {
        AppToast.error(context, text: '保留金额不能小于 0');
        return false;
      }

      config.icoInvestmentAmount = investmentAmount;
      config.icoReserveAmount = reserveAmount;
    }

    try {
      if (showLoading) {
        await _runWithLoading(
          message: '正在保存配置',
          request: _controller.save,
        );
      } else {
        await _controller.save();
      }
      if (!mounted) {
        return false;
      }

      _recordConfigSnapshot(config);
      if (showSuccessToast) {
        AppToast.info(context, text: '保存成功');
      }
      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }

      AppToast.error(
        context,
        text: resolveUserErrorMessage(
          error,
          fallback: '保存失败，请稍后重试',
        ),
      );
      return false;
    }
  }

  /// 取消 Bot 授权
  Future<void> _handleRevokeAuthorization() async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showAppConfirmDialog(
      context,
      title: '取消 Bot 授权？',
      message: '确定要取消 Bot 托管授权吗？',
      confirmText: '取消授权',
      icon: Icons.link_off_rounded,
      confirmColor: colorScheme.error,
    );
    if (!mounted || !confirmed) {
      return;
    }

    try {
      await _runWithLoading(
        message: '正在取消授权',
        request: _controller.revokeAuthorization,
      );
      if (!mounted) {
        return;
      }

      await widget.preferences.clearBotRiskAcknowledged();
      if (!mounted) {
        return;
      }

      AppToast.info(context, text: '已取消 Bot 授权');
      _leavePage();
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.error(
        context,
        text: resolveUserErrorMessage(
          error,
          fallback: '取消授权失败，请稍后重试',
        ),
      );
    }
  }

  /// 执行请求时显示全局加载蒙版
  ///
  /// [message] 加载提示文案
  /// [request] 需要等待完成的请求
  Future<T> _runWithLoading<T>({
    required String message,
    required Future<T> Function() request,
  }) async {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    unawaited(showAppLoadingDialog(context, message: message));
    try {
      return await request();
    } finally {
      if (rootNavigator.mounted) {
        rootNavigator.pop();
      }
    }
  }

  /// 打开圣殿单选抽屉
  ///
  /// [title] 抽屉标题
  /// [selectedId] 当前已选圣殿角色 ID
  /// [imageUrl] 标题图片地址
  /// [fallbackIcon] 标题图片失败图标
  /// [onSelected] 选择回调
  Future<void> _openTemplePicker({
    required String title,
    required int? selectedId,
    required String imageUrl,
    required IconData fallbackIcon,
    required ValueChanged<BotTempleOption> onSelected,
  }) async {
    final selected = _controller.templeOptionFor(selectedId);
    final item = await showBotTemplePickerSheet(
      context,
      title: title,
      selected: selected,
      imageUrl: imageUrl,
      fallbackIcon: fallbackIcon,
      search: _controller.searchTemplePage,
    );
    if (!mounted || item == null) {
      return;
    }

    _updateConfig(() {
      _controller.rememberTempleOption(item);
      onSelected(item);
    });
  }

  /// 打开魔法道具目标角色抽屉
  ///
  /// [title] 抽屉标题
  /// [description] 抽屉说明文案
  /// [recentStorageKeyPrefix] 最近使用缓存键前缀
  /// [imageUrl] 标题图片地址
  /// [fallbackIcon] 标题图片失败图标
  /// [onSelected] 选择回调
  /// [useFisheyeSupplement] 是否加载幻想乡持股补充数据
  Future<void> _openMagicTargetPicker({
    required String title,
    required String description,
    required String recentStorageKeyPrefix,
    required String imageUrl,
    required IconData fallbackIcon,
    required ValueChanged<BotCharacterOption> onSelected,
    bool useFisheyeSupplement = false,
  }) async {
    final config = _controller.config;
    if (config == null) {
      return;
    }

    final item = await showBotMagicCharacterPickerSheet(
      context,
      title: title,
      description: description,
      currentUserName: config.userId,
      recentStorageKeyPrefix: recentStorageKeyPrefix,
      characterRepository: widget.characterRepository,
      userRepository: widget.userRepository,
      imageUrl: imageUrl,
      fallbackIcon: fallbackIcon,
      secondaryTextBuilder: useFisheyeSupplement
          ? _fisheyeSearchSecondaryTextFor
          : TempleAssetMagicCharacterSearchPanel.defaultSecondaryText,
      supplementLoader:
          useFisheyeSupplement ? _loadFisheyeGensokyoAmounts : null,
    );
    if (!mounted || item == null) {
      return;
    }

    _updateConfig(() {
      _controller.rememberCharacterOption(item);
      onSelected(item);
    });
  }

  /// 加载鲤鱼之眼幻想乡持股
  ///
  /// [items] 当前批次角色搜索条目
  Future<Map<int, int>> _loadFisheyeGensokyoAmounts(
    List<TempleAssetMagicCharacterSearchItem> items,
  ) async {
    final characterIds = items
        .map((item) => item.characterId)
        .where((characterId) => characterId > 0)
        .toSet()
        .toList(growable: false);
    if (characterIds.isEmpty) {
      return const <int, int>{};
    }

    final page = await widget.userRepository.fetchUserCharacterPage(
      username: 'blueleaf',
      page: 1,
      pageSize: characterIds.length,
      characterIds: characterIds,
    );
    return <int, int>{
      for (final item in page.items) item.characterId: item.userTotal,
    };
  }

  /// 生成鲤鱼之眼搜索结果第二行文案
  ///
  /// [item] 搜索条目
  /// [supplementValue] 幻想乡持股数量
  String _fisheyeSearchSecondaryTextFor(
    TempleAssetMagicCharacterSearchItem item,
    int? supplementValue,
  ) {
    final amountText = supplementValue == null
        ? '???'
        : Formatters.groupedNumber(supplementValue);
    return '幻想乡 $amountText';
  }

  /// 打开 ICO 金额编辑弹窗
  ///
  /// [title] 弹窗标题
  /// [controller] 金额输入控制器
  /// [minimum] 最小允许金额
  /// [invalidMessage] 金额无效提示
  /// [minimumMessage] 金额低于下限提示
  Future<void> _openIcoAmountEditor({
    required String title,
    required TextEditingController controller,
    required double minimum,
    required String invalidMessage,
    required String minimumMessage,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final fillColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.48)
        : colorScheme.surfaceContainerLowest;
    final borderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.26 : 0.58,
    );
    final currentAmount = _parseAmount(controller.text);
    final editController = TextEditingController(
      text: currentAmount == 0 ? '' : controller.text,
    );
    try {
      await showAppConfirmDialog(
        context,
        title: title,
        message: '',
        confirmText: '确认',
        showCancelButton: false,
        content: TextField(
          controller: editController,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
          decoration: InputDecoration(
            labelText: title,
            labelStyle: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            floatingLabelStyle: TextStyle(
              color: colorScheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
          ),
        ),
        onConfirm: () async {
          final amount = _parseAmount(editController.text);
          if (amount == null) {
            AppToast.error(context, text: invalidMessage);
            return false;
          }

          if (amount < minimum) {
            AppToast.error(context, text: minimumMessage);
            return false;
          }

          controller.text = Formatters.plainDecimal(amount);
          _controller.notifyConfigChanged();
          return true;
        },
      );
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      editController.dispose();
    }
  }

  /// 打开 bot 操作日志二级页面
  void _openLogPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _BotLogPage(controller: _controller),
      ),
    );
  }

  /// 打开圣殿黑名单多选抽屉
  ///
  /// [config] 当前 bot 配置
  Future<void> _openTempleBlacklistPicker(BotConfig config) async {
    final selected = config.templeBlacklist
        .map(_templeOptionFromId)
        .whereType<BotTempleOption>()
        .toList(growable: false);
    await showBotTempleMultiPickerSheet(
      context,
      title: '圣殿黑名单',
      selected: selected,
      search: _controller.searchTemplePage,
      onChanged: (items) {
        if (!mounted) {
          return;
        }

        _updateConfig(() {
          for (final item in items) {
            _controller.rememberTempleOption(item);
          }
          config.templeBlacklist =
              items.map((item) => item.characterId).toList(growable: false);
        });
      },
    );
  }

  /// 更新当前 bot 配置
  ///
  /// [callback] 配置变更回调
  void _updateConfig(VoidCallback callback) {
    callback();
    _controller.notifyConfigChanged();
  }

  /// 有未保存变更时确认是否离开页面
  Future<void> _confirmLeaveIfNeeded() async {
    if (_isConfirmingLeave) {
      return;
    }

    if (!_hasUnsavedConfigChanges()) {
      _leavePage();
      return;
    }

    _isConfirmingLeave = true;
    final confirmed = await showAppConfirmDialog(
      context,
      title: '未保存的配置',
      message: '还有未保存的配置更改，是否保存后退出？',
      middleButtonText: '放弃更改',
      confirmText: '保存后退出',
      showCancelButton: false,
      icon: Icons.warning_amber_rounded,
      onConfirm: () => _saveConfig(showSuccessToast: false),
      onMiddleButtonPressed: () async => true,
    );
    _isConfirmingLeave = false;
    if (!mounted || !confirmed) {
      return;
    }

    _leavePage();
  }

  /// 允许当前页面执行一次返回
  void _leavePage() {
    if (!mounted) {
      return;
    }

    _markPagePopAllowed();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  /// 判断当前配置是否存在未保存变更
  bool _hasUnsavedConfigChanges() {
    final config = _controller.config;
    final savedConfigFingerprint = _savedConfigFingerprint;
    if (config == null || savedConfigFingerprint == null) {
      return false;
    }

    if (config.icoState &&
        (_parseAmount(_icoInvestmentController.text) == null ||
            _parseAmount(_icoReserveController.text) == null)) {
      return true;
    }

    return _configFingerprint(config) != savedConfigFingerprint;
  }

  /// 同步金额输入框
  ///
  /// [config] 当前 bot 配置
  void _syncAmountControllers(BotConfig? config) {
    if (config == null || identical(_syncedTextConfig, config)) {
      return;
    }

    _syncedTextConfig = config;
    _icoInvestmentController.text =
        Formatters.plainDecimal(config.icoInvestmentAmount);
    _icoReserveController.text =
        Formatters.plainDecimal(config.icoReserveAmount);
    _recordConfigSnapshot(config);
  }

  /// 处理 ICO 投入金额输入变化
  void _handleIcoInvestmentChanged() {
    final config = _controller.config;
    final value = _parseAmount(_icoInvestmentController.text);
    if (config == null || value == null) {
      return;
    }

    config.icoInvestmentAmount = value;
  }

  /// 处理 ICO 保留金额输入变化
  void _handleIcoReserveChanged() {
    final config = _controller.config;
    final value = _parseAmount(_icoReserveController.text);
    if (config == null || value == null) {
      return;
    }

    config.icoReserveAmount = value;
  }

  /// 解析金额输入
  ///
  /// [text] 原始输入文本
  double? _parseAmount(String text) {
    return double.tryParse(text.replaceAll(',', '').trim());
  }
}
