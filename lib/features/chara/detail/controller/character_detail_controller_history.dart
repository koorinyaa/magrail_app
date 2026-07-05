part of 'character_detail_controller.dart';

extension _CharacterDetailControllerHistory on CharacterDetailController {
  /// 使用请求结果更新角色历史数据
  ///
  /// [item] 请求返回的角色资料
  /// [pageType] 请求返回后解析出的页面类型
  /// [icoInfo] 请求返回的 ICO 头部资料
  void _updateCharacterInfo(
    CharacterDetailHistoryItem item, {
    required CharacterDetailPageType pageType,
    CharacterDetailIcoInfo? icoInfo,
  }) {
    var didUpdate = false;
    CharacterDetailHistoryItem? nextCurrent = _current;
    final nextHistory = <CharacterDetailHistoryItem>[];
    _pageTypes[item.characterId] = pageType;
    if (pageType != CharacterDetailPageType.trade) {
      _tradeHeaders.remove(item.characterId);
      _userAssets.remove(item.characterId);
    }
    if (pageType == CharacterDetailPageType.ico && icoInfo != null) {
      _icoInfos[item.characterId] = icoInfo;
    } else {
      _icoInfos.remove(item.characterId);
    }

    for (final historyItem in _history) {
      if (historyItem.characterId == item.characterId) {
        final mergedItem = item.mergeWith(historyItem);
        nextHistory.add(mergedItem);
        didUpdate = true;
        if (_current?.characterId == item.characterId) {
          nextCurrent = mergedItem;
        }
        continue;
      }

      nextHistory.add(historyItem);
    }

    if (!didUpdate) {
      _pageTypes.remove(item.characterId);
      _tradeHeaders.remove(item.characterId);
      _icoInfos.remove(item.characterId);
      _userAssets.remove(item.characterId);
      return;
    }

    _current = nextCurrent;
    _history = List<CharacterDetailHistoryItem>.unmodifiable(nextHistory);
    _persistHistory();
    _notifyIfActive();
  }

  /// 读取本地角色打开历史
  List<CharacterDetailHistoryItem> _readHistory() {
    final rawCache = _preferences.characterDetailHistoryCache;
    if (rawCache == null || rawCache.trim().isEmpty) {
      return const <CharacterDetailHistoryItem>[];
    }

    try {
      final decoded = jsonDecode(rawCache);
      if (decoded is! List) {
        return const <CharacterDetailHistoryItem>[];
      }

      final seenIds = <int>{};
      final items = <CharacterDetailHistoryItem>[];
      for (final rawItem in decoded) {
        if (rawItem is! Map) {
          continue;
        }

        final item = CharacterDetailHistoryItem.fromJson(
          Map<String, Object?>.from(rawItem),
        );
        if (item.characterId <= 0 || seenIds.contains(item.characterId)) {
          continue;
        }

        seenIds.add(item.characterId);
        items.add(item);
        if (items.length >= CharacterDetailController._maxHistoryItems) {
          break;
        }
      }

      return List<CharacterDetailHistoryItem>.unmodifiable(items);
    } catch (_) {
      return const <CharacterDetailHistoryItem>[];
    }
  }

  /// 持久化角色打开历史
  void _persistHistory() {
    final encoded = jsonEncode(
      _history.map((item) => item.toJson()).toList(growable: false),
    );
    unawaited(_preferences.setCharacterDetailHistoryCache(encoded));
  }
}
