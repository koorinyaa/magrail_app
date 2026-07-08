part of 'character_detail_trade_header_card.dart';

/// 已上市头部操作入口卡片
class CharacterDetailTradeHeaderActions extends StatefulWidget {
  /// 创建已上市头部操作入口区
  ///
  /// [key] Flutter 组件标识
  /// [header] 已上市角色头部资料
  /// [repository] 角色详情仓库
  /// [userRepository] 用户仓库
  /// [auctionRepository] 拍卖仓库
  /// [tradeHistoryRepository] 角色交易记录仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [isGameMaster] 当前用户是否为 GM
  /// [currentUserName] 当前登录用户名
  /// [onSacrificeChanged] 资产重组或股权融资成功回调
  /// [onAuctionChanged] 拍卖变更回调
  /// [onAvatarChanged] 头像更换成功回调
  /// [onVoteKill] 投票删除回调
  /// [onRevokeVote] 撤回投票回调
  const CharacterDetailTradeHeaderActions({
    super.key,
    required this.header,
    required this.repository,
    required this.userRepository,
    required this.auctionRepository,
    required this.tradeHistoryRepository,
    required this.oosRepository,
    required this.isGameMaster,
    required this.currentUserName,
    required this.onSacrificeChanged,
    required this.onAuctionChanged,
    required this.onAvatarChanged,
    required this.onVoteKill,
    required this.onRevokeVote,
  });

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 拍卖仓库
  final AuctionRepository auctionRepository;

  /// 角色交易记录仓库
  final CharacterTradeHistoryRepository tradeHistoryRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 当前用户是否为 GM
  final bool isGameMaster;

  /// 当前登录用户名
  final String currentUserName;

  /// 资产重组或股权融资成功回调
  final Future<void> Function(CharacterDetailSacrificeMode mode)
      onSacrificeChanged;

  /// 拍卖变更回调
  final Future<void> Function() onAuctionChanged;

  /// 头像更换成功回调
  final Future<void> Function() onAvatarChanged;

  /// 投票删除回调
  final Future<String> Function({required String reason}) onVoteKill;

  /// 撤回投票回调
  final Future<String> Function() onRevokeVote;

  /// 创建已上市头部操作入口区状态
  @override
  State<CharacterDetailTradeHeaderActions> createState() =>
      _CharacterDetailTradeHeaderActionsState();
}

/// 已上市头部操作入口卡片状态
class _CharacterDetailTradeHeaderActionsState
    extends State<CharacterDetailTradeHeaderActions> {
  _TradeHeaderActionType? _pendingAction;
  AuctionApiItem? _auction;
  int _auctionSyncSerial = 0;

  /// 初始化并静默同步当前拍卖状态
  @override
  void initState() {
    super.initState();
    unawaited(_syncAuctionStatus());
  }

  /// 在角色或用户状态变化时静默同步拍卖状态
  ///
  /// [oldWidget] 更新前的操作入口组件
  @override
  void didUpdateWidget(covariant CharacterDetailTradeHeaderActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.header.characterId != widget.header.characterId ||
        oldWidget.header.currentUserId != widget.header.currentUserId) {
      _auction = null;
      unawaited(_syncAuctionStatus());
    }
  }

  /// 构建已上市头部操作入口区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final actions = _resolveActions();
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerLow : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: PagedActionGrid(
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return _TradeHeaderActionButton(
            action: action,
            isLoading: _pendingAction == action.type,
            onPressed: _pendingAction == null && _isActionEnabled(action)
                ? () => _handleActionPressed(context, action)
                : null,
          );
        },
      ),
    );
  }

  /// 获取当前应展示的操作入口
  List<_TradeHeaderActionEntry> _resolveActions() {
    final hasUserAuction = _auction != null;
    return [
      const _TradeHeaderActionEntry(
        type: _TradeHeaderActionType.sacrifice,
        label: '资产重组',
        icon: LucideIcons.repeat2,
      ),
      _TradeHeaderActionEntry(
        type: _TradeHeaderActionType.auction,
        label: hasUserAuction ? '已竞拍' : '参与竞拍',
        icon: LucideIcons.gavel,
        isHighlighted: hasUserAuction,
      ),
      const _TradeHeaderActionEntry(
        type: _TradeHeaderActionType.auctionHistory,
        label: '往期拍卖',
        icon: LucideIcons.history,
      ),
      if (widget.header.canChangeAvatar)
        const _TradeHeaderActionEntry(
          type: _TradeHeaderActionType.changeAvatar,
          label: '更换头像',
          icon: LucideIcons.imageUp,
        ),
      const _TradeHeaderActionEntry(
        type: _TradeHeaderActionType.tradeHistory,
        label: '交易记录',
        icon: LucideIcons.clipboardClock,
      ),
      if (widget.isGameMaster) ...[
        const _TradeHeaderActionEntry(
          type: _TradeHeaderActionType.gmTradeHistory,
          label: '交易记录(gm)',
          icon: LucideIcons.clipboardClock,
        ),
        if (widget.header.hasCurrentUserKillVote)
          const _TradeHeaderActionEntry(
            type: _TradeHeaderActionType.revokeVote,
            label: '撤回投票',
            icon: LucideIcons.undo2,
          )
        else
          const _TradeHeaderActionEntry(
            type: _TradeHeaderActionType.voteKill,
            label: '投票删除',
            icon: LucideIcons.trash2,
          ),
        if (widget.header.hasKillVotes)
          const _TradeHeaderActionEntry(
            type: _TradeHeaderActionType.viewVotes,
            label: '查看投票',
            icon: LucideIcons.vote,
          ),
      ],
      if (_shouldShowSyncProfileAction)
        const _TradeHeaderActionEntry(
          type: _TradeHeaderActionType.syncProfile,
          label: '同步资料',
          icon: LucideIcons.refreshCw,
        ),
      const _TradeHeaderActionEntry(
        type: _TradeHeaderActionType.bangumiRelations,
        label: '关联角色',
        icon: LucideIcons.usersRound,
      ),
      const _TradeHeaderActionEntry(
        type: _TradeHeaderActionType.bangumiCasts,
        label: '出演作品',
        icon: LucideIcons.film,
      ),
    ];
  }

  /// 判断操作入口当前是否可点击
  ///
  /// [action] 操作入口
  bool _isActionEnabled(_TradeHeaderActionEntry action) {
    return switch (action.type) {
      _TradeHeaderActionType.sacrifice ||
      _TradeHeaderActionType.auction ||
      _TradeHeaderActionType.auctionHistory =>
        widget.header.currentUserId != null,
      _ => true,
    };
  }

  /// 静默同步当前用户拍卖状态
  Future<void> _syncAuctionStatus() async {
    final syncSerial = ++_auctionSyncSerial;
    final characterId = widget.header.characterId;
    if (characterId <= 0 || widget.header.currentUserId == null) {
      if (_auction != null && mounted) {
        setState(() {
          _auction = null;
        });
      }
      return;
    }

    try {
      final auction = await widget.auctionRepository.fetchAuctionDetail(
        characterId,
      );
      if (!mounted ||
          syncSerial != _auctionSyncSerial ||
          widget.header.characterId != characterId) {
        return;
      }

      final hasUserBid = auction != null &&
          auction.id > 0 &&
          auction.price > 0 &&
          auction.amount > 0;
      setState(() {
        _auction = hasUserBid ? auction : null;
      });
    } catch (_) {
      if (mounted && syncSerial == _auctionSyncSerial && _auction != null) {
        setState(() {
          _auction = null;
        });
      }
    }
  }

  /// 处理操作入口点击
  ///
  /// [context] 当前组件树上下文
  /// [action] 被点击的操作入口
  void _handleActionPressed(
    BuildContext context,
    _TradeHeaderActionEntry action,
  ) async {
    switch (action.type) {
      case _TradeHeaderActionType.sacrifice:
        await _openSacrificeSheet(context);
      case _TradeHeaderActionType.auction:
        await _openAuctionSheet(context);
      case _TradeHeaderActionType.auctionHistory:
        await _openAuctionHistorySheet(context);
      case _TradeHeaderActionType.changeAvatar:
        await _openAvatarUpdateSheet(context);
      case _TradeHeaderActionType.tradeHistory:
        await _openTradeHistorySheet(context);
      case _TradeHeaderActionType.gmTradeHistory:
        await _openGmTradeHistoryPage(context);
      case _TradeHeaderActionType.voteKill:
        await _handleVoteKill(context, action);
      case _TradeHeaderActionType.revokeVote:
        await _handleRevokeVote(context, action);
      case _TradeHeaderActionType.viewVotes:
        await _showKillVotesDialog(context);
      case _TradeHeaderActionType.syncProfile:
        await _handleSyncProfile(context, action);
      case _TradeHeaderActionType.bangumiRelations:
        await _openBangumiRelationsSheet(context);
      case _TradeHeaderActionType.bangumiCasts:
        await _openBangumiCastsSheet(context);
    }
  }

  /// 打开资产重组底部抽屉
  ///
  /// [context] 当前组件树上下文
  Future<void> _openSacrificeSheet(BuildContext context) async {
    final mode = await showCharacterDetailSacrificeSheet(
      context,
      repository: widget.repository,
      userRepository: widget.userRepository,
      characterId: widget.header.characterId,
      currentUserName: widget.currentUserName,
    );
    if (!mounted || mode == null) {
      return;
    }

    await widget.onSacrificeChanged(mode);
  }

  /// 打开角色拍卖底部抽屉
  ///
  /// [context] 当前组件树上下文
  Future<void> _openAuctionSheet(BuildContext context) async {
    await showAuctionBidSheet(
      context,
      repository: widget.auctionRepository,
      characterId: widget.header.characterId,
      characterName: widget.header.name,
      basePrice: widget.header.auctionBasePrice,
      maxAmount: widget.header.auctionMaxAmount,
      initialAuction: _auction,
      onChanged: widget.onAuctionChanged,
    );
    if (mounted) {
      unawaited(_syncAuctionStatus());
    }
  }

  /// 打开角色往期拍卖底部抽屉
  ///
  /// [context] 当前组件树上下文
  Future<void> _openAuctionHistorySheet(BuildContext context) {
    return showAuctionHistorySheet(
      context,
      repository: widget.auctionRepository,
      characterId: widget.header.characterId,
      characterName: widget.header.name,
      currentUserId: widget.header.currentUserId,
    );
  }

  /// 打开角色头像更换抽屉
  ///
  /// [context] 当前组件树上下文
  Future<void> _openAvatarUpdateSheet(BuildContext context) {
    return showCharacterAvatarUpdateSheet(
      context,
      header: widget.header,
      repository: widget.repository,
      oosRepository: widget.oosRepository,
      onAvatarChanged: widget.onAvatarChanged,
    );
  }

  /// 打开角色交易记录底部抽屉
  ///
  /// [context] 当前组件树上下文
  Future<void> _openTradeHistorySheet(BuildContext context) {
    return showCharacterTradeHistorySheet(
      context,
      repository: widget.tradeHistoryRepository,
      characterId: widget.header.characterId,
      characterName: widget.header.name,
    );
  }

  /// 打开 Bangumi 关联角色底部抽屉
  ///
  /// [context] 当前组件树上下文
  Future<void> _openBangumiRelationsSheet(BuildContext context) {
    return showCharacterBangumiRelationsSheet(
      context,
      characterId: widget.header.characterId,
      characterName: widget.header.name,
      characterRepository: widget.repository,
    );
  }

  /// 打开 Bangumi 出演作品底部抽屉
  ///
  /// [context] 当前组件树上下文
  Future<void> _openBangumiCastsSheet(BuildContext context) {
    return showCharacterBangumiCastsSheet(
      context,
      characterId: widget.header.characterId,
      characterName: widget.header.name,
    );
  }

  /// 处理角色资料同步
  ///
  /// [context] 当前组件树上下文
  /// [action] 角色资料同步入口
  Future<void> _handleSyncProfile(
    BuildContext context,
    _TradeHeaderActionEntry action,
  ) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: '同步资料',
      message: '该操作会从 Bangumi 同步当前角色的名称和头像。若角色名称为空、头像缺失，或页面仍显示 ID 占位，请尝试使用此功能。',
      confirmText: '同步资料',
      showCancelButton: false,
      icon: LucideIcons.refreshCw,
    );
    if (!context.mounted || !confirmed) {
      return;
    }

    return _runAction(context, action, () async {
      final message = await widget.repository.syncCharacterProfile(
        widget.header.characterId,
      );
      await widget.onAvatarChanged();
      return message;
    });
  }

  /// 打开角色 GM 交易记录二级页面
  ///
  /// [context] 当前组件树上下文
  Future<void> _openGmTradeHistoryPage(BuildContext context) {
    return context.pushNamed<void>(
      'characterGmTradeHistory',
      queryParameters: {
        'characterId': widget.header.characterId.toString(),
        if (widget.header.name.trim().isNotEmpty)
          'name': widget.header.name.trim(),
      },
    );
  }

  /// 处理投票删除点击
  ///
  /// [context] 当前组件树上下文
  /// [action] 投票删除入口
  Future<void> _handleVoteKill(
    BuildContext context,
    _TradeHeaderActionEntry action,
  ) async {
    final reason = await _showTradeHeaderVoteKillSheet(context);
    if (reason == null || !context.mounted) {
      return;
    }

    await _runAction(
      context,
      action,
      () => widget.onVoteKill(reason: reason),
    );
  }

  /// 处理撤回投票点击
  ///
  /// [context] 当前组件树上下文
  /// [action] 撤回投票入口
  Future<void> _handleRevokeVote(
    BuildContext context,
    _TradeHeaderActionEntry action,
  ) async {
    final shouldRevoke = await showAppConfirmDialog(
      context,
      title: '撤回投票',
      message: '确认撤回当前角色的删除投票',
      confirmText: '撤回',
      icon: LucideIcons.undo2,
    );
    if (!shouldRevoke || !context.mounted) {
      return;
    }

    await _runAction(context, action, widget.onRevokeVote);
  }

  /// 执行需要网络提交的操作入口
  ///
  /// [context] 当前组件树上下文
  /// [action] 操作入口
  /// [request] 网络提交回调
  Future<void> _runAction(
    BuildContext context,
    _TradeHeaderActionEntry action,
    Future<String> Function() request,
  ) async {
    setState(() {
      _pendingAction = action.type;
    });

    try {
      final message = await request();
      if (!context.mounted) {
        return;
      }

      AppToast.info(context, text: message);
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      AppToast.error(context, text: _errorText(error, '${action.label}失败'));
    } finally {
      if (mounted) {
        setState(() {
          _pendingAction = null;
        });
      }
    }
  }

  /// 显示删除投票列表弹窗
  ///
  /// [context] 当前组件树上下文
  Future<void> _showKillVotesDialog(BuildContext context) async {
    await showAppConfirmDialog(
      context,
      title: '删除投票',
      message: '',
      content: _TradeHeaderKillVoteList(
        votes: widget.header.killVotes,
        currentUserId: widget.header.currentUserId,
      ),
      confirmText: '知道了',
      showCancelButton: false,
      icon: LucideIcons.vote,
    );
  }

  /// 解析操作失败文案
  ///
  /// [error] 异常对象
  /// [fallback] 默认文案
  String _errorText(Object error, String fallback) {
    return resolveUserErrorMessage(error, fallback: fallback);
  }

  /// 是否显示角色资料同步入口
  bool get _shouldShowSyncProfileAction {
    return widget.header.name.trim().isEmpty ||
        widget.header.icon.trim().isEmpty;
  }
}
