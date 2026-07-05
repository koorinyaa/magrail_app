part of 'character_detail_controller.dart';

extension _CharacterDetailControllerRefresh on CharacterDetailController {
  /// 刷新已上市头部补充数据
  ///
  /// [characterId] 角色 ID
  /// [tradeHeader] 已上市头部基础资料
  /// [refreshGeneration] 本次角色详情刷新的请求版本
  Future<void> _refreshTradeHeaderSupplementalStats(
    int characterId,
    CharacterDetailTradeHeader tradeHeader, {
    int? refreshGeneration,
  }) async {
    final valhallaFuture = _repository.fetchValhallaCharacter(characterId);
    final gensokyoFuture = _repository.fetchGensokyoAmount(characterId);
    final poolFuture = _repository.fetchCharacterPoolAmount(characterId);
    final boardMembersFuture =
        _repository.fetchCharacterBoardMembers(characterId);
    final killVotesFuture = _repository.fetchKillVotes(characterId);

    final valhallaCharacter = await valhallaFuture;
    final gensokyoAmount = await gensokyoFuture;
    final poolAmount = await poolFuture;
    final boardMembers = await boardMembersFuture;
    final killVotes = await killVotesFuture;
    if (_isDisposed ||
        !_isExpectedCharacterRefresh(characterId, refreshGeneration)) {
      return;
    }

    final hasHistoryItem = _history.any(
      (item) => item.characterId == characterId,
    );
    if (!hasHistoryItem) {
      return;
    }

    final cachedUserId = _currentUser?.userId ?? 0;
    final currentUserId = cachedUserId > 0 ? cachedUserId : null;
    final hasCurrentUserKillVote = currentUserId != null &&
        killVotes.any((vote) => vote.userId == currentUserId);

    _tradeHeaders[characterId] = tradeHeader.withSupplementalStats(
      valhallaAmount: valhallaCharacter?.amount,
      gensokyoAmount: gensokyoAmount,
      poolAmount: poolAmount,
      auctionBasePrice: valhallaCharacter?.price ?? 0,
      auctionMaxAmount: valhallaCharacter?.amount ?? 0,
      canChangeAvatar: _canChangeAvatar(boardMembers),
      killVotes: killVotes,
      currentUserId: currentUserId,
      hasCurrentUserKillVote: hasCurrentUserKillVote,
    );
    if (_current?.characterId == characterId) {
      _notifyIfActive();
    }
  }

  /// 创建本次角色详情刷新的请求版本
  ///
  /// [characterId] 角色 ID
  int _nextRefreshGeneration(int characterId) {
    final nextGeneration = (_refreshGenerations[characterId] ?? 0) + 1;
    _refreshGenerations[characterId] = nextGeneration;
    return nextGeneration;
  }

  /// 判断角色详情刷新是否仍是最新请求
  ///
  /// [characterId] 角色 ID
  /// [generation] 本次角色详情刷新的请求版本
  bool _isLatestCharacterRefresh(int characterId, int generation) {
    return _refreshGenerations[characterId] == generation;
  }

  /// 判断补充数据是否归属于期望的角色详情刷新
  ///
  /// [characterId] 角色 ID
  /// [refreshGeneration] 本次角色详情刷新的请求版本
  bool _isExpectedCharacterRefresh(int characterId, int? refreshGeneration) {
    if (refreshGeneration == null) {
      return true;
    }

    return _isLatestCharacterRefresh(characterId, refreshGeneration);
  }

  /// 判断当前用户是否可更换角色头像
  ///
  /// [boardMembers] 角色前十持股用户
  bool _canChangeAvatar(List<CharacterDetailBoardMember> boardMembers) {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return false;
    }

    if (currentUser.userId == 702) {
      return true;
    }

    if (boardMembers.isEmpty) {
      return false;
    }

    final currentUserIndex = boardMembers.indexWhere(
      (member) => member.name == currentUser.name,
    );
    if (currentUserIndex < 0) {
      return false;
    }

    final chairman = boardMembers.first;
    if (chairman.isActiveForAvatarEdit) {
      return currentUserIndex == 0;
    }

    return currentUserIndex > 0;
  }
}
