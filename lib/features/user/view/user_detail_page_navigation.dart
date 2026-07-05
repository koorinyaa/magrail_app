part of 'user_detail_page.dart';

extension _UserDetailPageNavigation on _UserDetailPageState {
  /// 打开用户设置二级页面
  void _openSettingsPage() {
    context.pushNamed('userSettings', extra: widget.onSignedOut);
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

  /// 打开红包记录二级页面
  ///
  /// [profile] 用户资料
  void _openRedPacketLogs(UserDetailProfile profile) {
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
      avatarUrl: item.avatar,
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
