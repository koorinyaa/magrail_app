part of '../temple_asset_magic_character_search_panel.dart';

extension _TempleAssetMagicCharacterSearchData
    on TempleAssetMagicCharacterSearchPanelState {
  /// 加载搜索条目附加数值
  ///
  /// [items] 搜索结果条目
  Future<Map<int, int>?> _loadSupplementValues(
    List<TempleAssetMagicCharacterSearchItem> items,
  ) async {
    final loader = widget.supplementLoader;
    if (loader == null || items.isEmpty) {
      return const <int, int>{};
    }

    try {
      return await loader(items);
    } catch (_) {
      return null;
    }
  }

  /// 替换搜索条目附加数值
  ///
  /// [items] 搜索结果条目
  /// [values] 附加数值，空值表示请求失败
  void _replaceSupplementValues(
    List<TempleAssetMagicCharacterSearchItem> items,
    Map<int, int>? values,
  ) {
    for (final item in items) {
      _supplementValues.remove(item.characterId);
      _loadedSupplementIds.remove(item.characterId);
    }

    if (values == null) {
      return;
    }

    _loadedSupplementIds.addAll(
      items.map((item) => item.characterId),
    );
    _supplementValues.addAll(values);
  }

  /// 加载最近使用角色
  ///
  /// [username] 当前登录用户名
  Future<List<_MagicRecentSearchItem>> _loadRecentSearchItems(
    String username,
  ) async {
    final records = await _readRecentMagicCharacterRecords(
      storageKeyPrefix: widget.recentStorageKeyPrefix,
      username: username,
    );
    if (records.isEmpty) {
      return const <_MagicRecentSearchItem>[];
    }

    final page = await widget.userRepository.fetchUserCharacterPage(
      username: username,
      page: 1,
      pageSize: records.length,
      characterIds: records.map((record) => record.characterId).toList(
            growable: false,
          ),
    );
    final itemById = <int, UserCharacterApiItem>{
      for (final item in page.items) item.characterId: item,
    };

    final items = <_MagicRecentSearchItem>[];
    for (final record in records) {
      final item = itemById[record.characterId];
      if (item != null) {
        items.add(
          _MagicRecentSearchItem(
            item: TempleAssetMagicCharacterSearchItem.fromUserCharacter(item),
            usedAt: record.usedAt,
          ),
        );
      }
    }

    return items;
  }

  /// 格式化最近使用时间
  ///
  /// [value] 最近使用时间
  String _recentTimeText(String value) {
    final text = value.trim();
    return text.isEmpty ? '' : TinygrailFormatters.relativeTime(text);
  }

  /// 生成异常文案
  ///
  /// [error] 捕获到的异常
  /// [fallback] 兜底文案
  String _messageForError(Object error, String fallback) {
    return resolveUserErrorMessage(error, fallback: fallback);
  }

  /// 当前是否为初始搜索模式
  bool get _isInitialSearchMode => _searchController.text.trim().isEmpty;

  /// 当前是否显示最近使用区域
  bool get _shouldShowRecent =>
      _isInitialSearchMode && _recentResults.isNotEmpty;

  /// 当前是否允许加载下一页
  bool get _canLoadNextInitialSearchPage {
    return _isInitialSearchMode &&
        _initialCanLoadMore &&
        !_isSearching &&
        !_isInitialLoadingMore &&
        _loadMoreError.isEmpty;
  }
}
