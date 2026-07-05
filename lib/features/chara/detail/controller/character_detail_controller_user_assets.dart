part of 'character_detail_controller.dart';

extension _CharacterDetailControllerUserAssets on CharacterDetailController {
  /// 静默刷新当前用户在指定角色上的资产
  ///
  /// [characterId] 角色 ID
  /// [refreshGeneration] 本次角色详情刷新的请求版本
  Future<void> _refreshCurrentUserAssets(
    int characterId, {
    int? refreshGeneration,
  }) async {
    final currentUser = _currentUser;
    final username = currentUser?.name.trim() ?? '';
    final previousAssets = _userAssets[characterId];
    // 刷新保留旧卡片，避免回到骨架态
    final shouldKeepReadyAssets =
        previousAssets?.status == CharacterDetailUserAssetsStatus.ready;
    if (currentUser == null || username.isEmpty) {
      _userAssets[characterId] = const CharacterDetailUserAssets.signedOut();
      if (_current?.characterId == characterId) {
        _notifyIfActive();
      }
      return;
    }

    if (!shouldKeepReadyAssets) {
      _userAssets[characterId] = const CharacterDetailUserAssets.loading();
      if (_current?.characterId == characterId) {
        _notifyIfActive();
      }
    }

    try {
      final userCharacterPageFuture = _userRepository.fetchUserCharacterPage(
        username: username,
        page: 1,
        pageSize: 1,
        characterIds: <int>[characterId],
      );
      final templePageFuture = _userRepository.fetchUserTemplePage(
        username: username,
        page: 1,
        pageSize: 1,
        characterIds: <int>[characterId],
      );

      final results = await Future.wait<Object>([
        userCharacterPageFuture,
        templePageFuture,
      ]);
      final userCharacterPage =
          results[0] as TinygrailPage<UserCharacterApiItem>;
      final templePage = results[1] as TinygrailPage<UserTempleApiItem>;
      if (_isDisposed ||
          !_CharacterDetailControllerRefresh(this)
              ._isExpectedCharacterRefresh(characterId, refreshGeneration)) {
        return;
      }

      final hasHistoryItem = _history.any(
        (item) => item.characterId == characterId,
      );
      if (!hasHistoryItem) {
        return;
      }

      _userAssets[characterId] = CharacterDetailUserAssets.ready(
        character: _toUserCharacter(
          _findMatchedUserCharacter(userCharacterPage.items, characterId),
        ),
        temple: _findMatchedTemple(templePage.items, characterId),
      );
      if (_current?.characterId == characterId) {
        _notifyIfActive();
      }
    } catch (error) {
      if (_isDisposed ||
          !_CharacterDetailControllerRefresh(this)
              ._isExpectedCharacterRefresh(characterId, refreshGeneration)) {
        return;
      }

      if (!shouldKeepReadyAssets) {
        _userAssets[characterId] = CharacterDetailUserAssets.failure(
          errorMessage: _userAssetsErrorMessage(error),
        );
        if (_current?.characterId == characterId) {
          _notifyIfActive();
        }
      }
    }
  }

  /// 查找与当前角色精确匹配的用户角色
  ///
  /// [items] 用户角色分页条目
  /// [characterId] 角色 ID
  UserCharacterApiItem? _findMatchedUserCharacter(
    List<UserCharacterApiItem> items,
    int characterId,
  ) {
    for (final item in items) {
      if (item.characterId == characterId) {
        return item;
      }
    }

    return null;
  }

  /// 转换用户角色分页条目为角色详情持股数据
  ///
  /// [item] 用户角色分页条目
  CharacterDetailUserCharacter _toUserCharacter(UserCharacterApiItem? item) {
    if (item == null) {
      return const CharacterDetailUserCharacter.empty();
    }

    return CharacterDetailUserCharacter(
      amount: item.userAmount,
      total: item.userTotal,
      sacrifices: item.sacrifices,
      price: item.current * item.userTotal,
    );
  }

  /// 查找与当前角色精确匹配的圣殿
  ///
  /// [items] 圣殿分页条目
  /// [characterId] 角色 ID
  UserTempleApiItem? _findMatchedTemple(
    List<UserTempleApiItem> items,
    int characterId,
  ) {
    for (final item in items) {
      if (item.characterId == characterId) {
        return item;
      }
    }

    return null;
  }

  /// 获取当前用户资产加载失败文案
  ///
  /// [error] 捕获到的异常
  String _userAssetsErrorMessage(Object error) {
    if (error is StateError && error.message.trim().isNotEmpty) {
      return error.message;
    }

    return '获取当前用户资产失败';
  }

  /// 清空当前用户在角色详情中的资产状态
  void _clearCurrentUserAssets() {
    _userAssets.clear();
  }
}
