part of 'user_detail_page.dart';

extension _UserDetailPageActions on _UserDetailPageState {
  /// 复制用户 ID
  ///
  /// [context] 当前组件树上下文
  Future<void> _copyUserId(BuildContext context) async {
    final profile = _controller.profile;
    if (profile == null) {
      return;
    }

    await Clipboard.setData(
      ClipboardData(text: '@${profile.userId}'),
    );
    if (!context.mounted) {
      return;
    }

    AppToast.info(
      context,
      text: '已复制用户ID',
    );
  }

  /// 处理用户菜单入口点击
  ///
  /// [context] 当前组件树上下文
  /// [action] 用户菜单入口
  void _handleActionPressed(
    BuildContext context,
    UserActionEntry action,
  ) {
    switch (action.type) {
      case UserActionType.balanceLog:
        _openUserBalanceLogs();
        return;
      case UserActionType.myAuction:
        _openUserAuctions();
        return;
      case UserActionType.marketOrder:
        _openUserMarketOrders();
        return;
      case UserActionType.myItems:
        _openUserItems();
        return;
      case UserActionType.weeklyBonus:
        unawaited(_claimWeeklyBonus(context));
        return;
      case UserActionType.dailyBonus:
        unawaited(_claimDailyBonus(context));
        return;
      case UserActionType.holidayBonus:
        unawaited(_claimHolidayBonus(context, action));
        return;
      case UserActionType.scratch:
        _openScratchTicket();
        return;
      case UserActionType.dividendForecast:
        _openShareBonusForecast(context);
        return;
      case UserActionType.bot:
        unawaited(_openBotConfigWithRiskConfirmation(context));
        return;
      case UserActionType.block:
        unawaited(_updateUserBanState(context, shouldBan: true));
        return;
      case UserActionType.unblock:
        unawaited(_updateUserBanState(context, shouldBan: false));
        return;
      case UserActionType.tradeLog:
        _openUserTradeLogs();
        return;
    }
  }

  /// 打开股息预测底部抽屉
  ///
  /// [context] 当前组件树上下文
  void _openShareBonusForecast(BuildContext context) {
    final profile = _controller.profile;
    if (profile == null) {
      return;
    }

    unawaited(
      showUserShareBonusForecastSheet(
        context,
        repository: widget.repository,
        username: profile.name,
        nickname: profile.nickname,
      ),
    );
  }

  /// 更新用户封禁状态
  ///
  /// [context] 当前组件树上下文
  /// [shouldBan] 是否执行封禁
  Future<void> _updateUserBanState(
    BuildContext context, {
    required bool shouldBan,
  }) async {
    if (_isUpdatingUserBanState) {
      return;
    }

    final profile = _controller.profile;
    final username = profile?.name.trim() ?? '';
    if (profile == null || username.isEmpty) {
      return;
    }

    final actionType =
        shouldBan ? UserActionType.block : UserActionType.unblock;
    _setActionBusyState(actionType, value: true);

    try {
      final confirmed = await showAppConfirmDialog(
        context,
        title: shouldBan ? '封禁用户' : '解封用户',
        message: shouldBan ? '封禁之后只有管理员才能解除，确认要封禁用户？' : '确认要解除封禁用户？',
        confirmText: shouldBan ? '封禁' : '解封',
        showCancelButton: false,
        icon: shouldBan ? Icons.block_rounded : Icons.lock_open_rounded,
      );
      if (!confirmed || !mounted || !context.mounted) {
        return;
      }

      final message = shouldBan
          ? await widget.repository.banUser(username)
          : await widget.repository.unbanUser(username);
      if (!mounted || !context.mounted) {
        return;
      }

      AppToast.info(context, text: message);
      await _controller.refresh(silent: true);
    } catch (error) {
      if (!mounted || !context.mounted) {
        return;
      }

      AppToast.error(
        context,
        text: _resolveActionErrorMessage(
          error,
          fallback: shouldBan ? '封禁用户失败' : '解除封禁失败',
        ),
      );
    } finally {
      _setActionBusyState(actionType, value: false);
    }
  }

  /// 领取当前用户每周分红
  ///
  /// [context] 当前组件树上下文
  Future<void> _claimWeeklyBonus(BuildContext context) async {
    if (_isClaimingWeeklyBonus) {
      return;
    }

    _setActionBusyState(UserActionType.weeklyBonus, value: true);

    try {
      final shouldClaim = await showAppConfirmDialog(
        context,
        title: '每周分红',
        message: '确定要领取每周分红吗？',
        confirmText: '领取',
        showCancelButton: false,
        icon: Icons.monetization_on_outlined,
      );
      if (!shouldClaim || !mounted || !context.mounted) {
        return;
      }

      final message = await widget.repository.claimWeeklyBonus();
      if (!mounted || !context.mounted) {
        return;
      }

      AppToast.info(context, text: message);
      await _controller.refresh(silent: true);
    } catch (error) {
      if (!mounted || !context.mounted) {
        return;
      }

      AppToast.error(
        context,
        text: _resolveActionErrorMessage(
          error,
          fallback: '领取每周分红失败',
        ),
      );
    } finally {
      _setActionBusyState(UserActionType.weeklyBonus, value: false);
    }
  }

  /// 领取当前用户签到奖励
  ///
  /// [context] 当前组件树上下文
  Future<void> _claimDailyBonus(BuildContext context) async {
    if (_isClaimingDailyBonus) {
      return;
    }

    _setActionBusyState(UserActionType.dailyBonus, value: true);

    try {
      final shouldClaim = await showAppConfirmDialog(
        context,
        title: '签到奖励',
        message: '确定要领取签到奖励吗？',
        confirmText: '领取',
        showCancelButton: false,
        icon: Icons.event_available_outlined,
      );
      if (!shouldClaim || !mounted || !context.mounted) {
        return;
      }

      final message = await widget.repository.claimDailyBonus();
      if (!mounted || !context.mounted) {
        return;
      }

      AppToast.info(context, text: message);
      await _controller.refresh(silent: true);
    } catch (error) {
      if (!mounted || !context.mounted) {
        return;
      }

      AppToast.error(
        context,
        text: _resolveActionErrorMessage(
          error,
          fallback: '领取签到奖励失败',
        ),
      );
    } finally {
      _setActionBusyState(UserActionType.dailyBonus, value: false);
    }
  }

  /// 领取当前用户节日福利
  ///
  /// [context] 当前组件树上下文
  /// [action] 节日福利菜单入口
  Future<void> _claimHolidayBonus(
    BuildContext context,
    UserActionEntry action,
  ) async {
    if (_isClaimingHolidayBonus) {
      return;
    }

    _setActionBusyState(UserActionType.holidayBonus, value: true);

    try {
      final shouldClaim = await showAppConfirmDialog(
        context,
        title: action.label,
        message: '确定要领取${action.label}吗？',
        confirmText: '领取',
        icon: Icons.card_giftcard_outlined,
      );
      if (!shouldClaim || !mounted || !context.mounted) {
        return;
      }

      final message = await widget.repository.claimHolidayBonus();
      if (!mounted || !context.mounted) {
        return;
      }

      AppToast.info(context, text: message);
      await _controller.refresh(silent: true);
    } catch (error) {
      if (!mounted || !context.mounted) {
        return;
      }

      AppToast.error(
        context,
        text: _resolveActionErrorMessage(
          error,
          fallback: '领取节日福利失败',
        ),
      );
    } finally {
      _setActionBusyState(UserActionType.holidayBonus, value: false);
    }
  }

  /// 解析用户菜单操作错误文案
  ///
  /// [error] 原始错误
  /// [fallback] 兜底文案
  String _resolveActionErrorMessage(
    Object error, {
    required String fallback,
  }) {
    return resolveUserErrorMessage(error, fallback: fallback);
  }
}
