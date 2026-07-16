part of 'user_detail_page.dart';

extension _UserDetailPageNavigation on _UserDetailPageState {
  /// 打开用户设置二级页面
  void _openSettingsPage() {
    final route = context.pushNamed(
      'userSettings',
      extra: UserSettingsRouteExtra(
        onSignedOut: widget.onSignedOut,
        onLiquidGlassChanged: widget.onLiquidGlassChanged,
      ),
    );
    unawaited(route.whenComplete(() {
      if (mounted) {
        _refreshVisibleActions();
      }
    }));
  }

  /// 打开刮刮乐购买弹层
  void _openScratchTicket() {
    unawaited(showScratchTicketSheet(
      context,
      repository: widget.scratchTicketRepository,
      characterRepository: widget.characterDetailRepository,
      onCompleted: (_) {
        if (!mounted) {
          return;
        }

        unawaited(_controller.refresh(silent: true));
      },
    ));
  }

  /// 打开用户资金日志二级页面
  void _openUserBalanceLogs() {
    context.pushNamed('userBalanceLogs');
  }

  /// 打开用户拍卖二级页面
  void _openUserAuctions() {
    context.pushNamed('userAuctions');
  }

  /// 打开用户委托订单二级页面
  void _openUserMarketOrders() {
    context.pushNamed('userMarketOrders');
  }

  /// 打开用户道具二级页面
  void _openUserItems() {
    context.pushNamed('userItems');
  }

  /// 确认 Bot 第三方托管风险后打开配置页面
  ///
  /// [context] 当前组件树上下文
  Future<void> _openBotConfigWithRiskConfirmation(BuildContext context) async {
    if (!widget.preferences.botRiskAcknowledged) {
      final confirmed = await showAppConfirmDialog(
        context,
        title: 'Bot 托管风险提示',
        message: '这不是官方功能，而是会将账号托管在第三方网站。请确认你了解相关风险后继续使用。',
        confirmText: '继续使用',
        showCancelButton: false,
        icon: Icons.warning_amber_rounded,
      );
      if (!confirmed || !mounted || !context.mounted) {
        return;
      }

      await widget.preferences.setBotRiskAcknowledged(true);
      if (!mounted || !context.mounted) {
        return;
      }
    }

    _openBotConfig();
  }

  /// 打开 Bot 配置二级页面
  void _openBotConfig() {
    context.pushNamed('userBotConfig');
  }

  /// 打开用户交易记录二级页面
  void _openUserTradeLogs() {
    final profile = _controller.profile;
    if (profile == null) {
      return;
    }

    context.pushNamed(
      'userTradeLogs',
      queryParameters: {
        'userId': profile.userId.toString(),
        'username': profile.name,
        'nickname': profile.nickname,
      },
    );
  }

  /// 打开用户资产分析二级页面
  void _openUserAssetAnalysis() {
    final profile = _controller.profile;
    if (profile == null) {
      return;
    }

    context.pushNamed(
      'userAssetAnalysis',
      queryParameters: {
        'username': profile.name,
        'nickname': profile.nickname,
      },
    );
  }

  /// 打开红包记录二级页面
  ///
  /// [profile] 用户资料
  void _openRedPacketLogs(UserDetailProfile profile) {
    final currentUsername =
        widget.repository.readCachedCurrentUserAssets()?.name.trim() ?? '';
    if (currentUsername.isEmpty) {
      AppToast.error(context, text: '该功能需要授权后才能使用');
      return;
    }

    context.pushNamed(
      'userRedPacketLogs',
      queryParameters: {
        'username': profile.name,
        'nickname': profile.nickname,
      },
    );
  }

  /// 打开发送红包弹层
  ///
  /// [profile] 用户资料
  void _openSendRedPacket(UserDetailProfile profile) {
    final currentUsername =
        widget.repository.readCachedCurrentUserAssets()?.name.trim() ?? '';
    if (currentUsername.isEmpty) {
      AppToast.error(context, text: '该功能需要授权后才能使用');
      return;
    }

    unawaited(showUserRedPacketSendSheet(
      context,
      repository: widget.repository,
      username: profile.name,
      nickname: profile.nickname,
      onSuccess: () {
        unawaited(_controller.refresh(silent: true));
      },
    ));
  }

  /// 打开用户连接二级页面
  ///
  /// [profile] 用户资料
  void _openUserLinks(UserDetailProfile profile) {
    context.pushNamed(
      'userLinks',
      queryParameters: {
        'username': profile.name,
        'nickname': profile.nickname,
        if (_controller.isCurrentUser) 'currentUserName': profile.name,
      },
    );
  }

  /// 打开用户圣殿二级页面
  ///
  /// [profile] 用户资料
  void _openUserTemples(UserDetailProfile profile) {
    context.pushNamed(
      'userTemples',
      queryParameters: {
        'username': profile.name,
        'nickname': profile.nickname,
        if (_controller.isCurrentUser) 'currentUserName': profile.name,
      },
    );
  }

  /// 打开用户角色二级页面
  ///
  /// [profile] 用户资料
  void _openUserCharacters(UserDetailProfile profile) {
    context.pushNamed(
      'userCharacters',
      queryParameters: {
        'username': profile.name,
        'nickname': profile.nickname,
        if (_controller.isCurrentUser) 'currentUserName': profile.name,
      },
    );
  }

  /// 打开用户 ICO 二级页面
  ///
  /// [profile] 用户资料
  void _openUserIcos(UserDetailProfile profile) {
    context.pushNamed(
      'userIcos',
      queryParameters: {
        'username': profile.name,
        'nickname': profile.nickname,
      },
    );
  }

  /// 打开圣殿或连接中的角色详情页
  ///
  /// [item] 用户圣殿条目
  void _openTempleCharacterDetail(UserTempleApiItem item) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.name,
    );
  }

  /// 打开圣殿资产弹窗
  ///
  /// [item] 用户圣殿条目
  void _openTempleAssetDialog(UserTempleApiItem item) {
    final profile = _controller.profile;
    if (profile == null) {
      return;
    }

    unawaited(
      showTempleAssetCardDialogFromSource(
        context,
        source: TempleAssetDialogSource(
          ownerName: profile.name,
          ownerNickname: profile.nickname,
          characterId: item.characterId,
        ),
        characterRepository: widget.characterDetailRepository,
        templeRepository: widget.templeRepository,
        magicRepository: widget.templeAssetMagicRepository,
        oosRepository: widget.oosRepository,
        userRepository: widget.repository,
        currentUserName: _controller.isCurrentUser ? profile.name : '',
      ),
    );
  }

  /// 打开角色详情页
  ///
  /// [item] 用户角色条目
  /// [avatarHeroTag] 入口头像转场标识
  void _openCharacterDetail(
    UserCharacterApiItem item,
    String? avatarHeroTag,
  ) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.name,
      avatarUrl: item.icon,
      avatarHeroTag: avatarHeroTag,
    );
  }

  /// 打开 ICO 角色详情页
  ///
  /// [item] 用户 ICO 条目
  /// [avatarHeroTag] 入口头像转场标识
  void _openIcoDetail(
    UserIcoApiItem item,
    String? avatarHeroTag,
  ) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.name,
      avatarUrl: item.icon,
      avatarHeroTag: avatarHeroTag,
    );
  }
}
