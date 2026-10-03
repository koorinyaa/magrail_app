part of 'character_search_page.dart';

/// 小圣杯搜索结果装配与交互
extension _CharacterSearchPageTinygrailLogic on _CharacterSearchPageState {
  /// 构建圣殿、用户与角色结果列表
  ///
  /// [context] 当前组件树上下文
  Widget _buildTinygrailResultList(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom > 0
        ? mediaQuery.viewInsets.bottom
        : mediaQuery.padding.bottom;
    final search = _tinygrailSearchController;
    final user = search.user;
    final searchCharacters = search.searchKeyword.searchCharacters;

    return ListView(
      controller: _scrollController,
      primary: false,
      padding: EdgeInsets.only(
        bottom: bottomInset + _characterSearchBottomContentPadding,
      ),
      children: [
        if (searchCharacters &&
            (search.temples.isNotEmpty || search.templeError.isNotEmpty)) ...[
          const _CharacterSearchSectionLabel(text: '圣殿'),
          if (search.templeError.isNotEmpty)
            _CharacterSearchInlineWarning(text: search.templeError)
          else
            _CharacterSearchTempleResultList(
              items: search.temples,
              ownerLabel: _cachedCurrentUserDisplayName,
              onTap: _selectTemple,
            ),
          const SizedBox(height: 14),
        ],
        if (user != null) ...[
          const _CharacterSearchSectionLabel(text: '用户'),
          UserSearchResultRow(profile: user, onTap: () => _closeSearch(user)),
          if (searchCharacters) const SizedBox(height: 14),
        ],
        if (!searchCharacters && user == null)
          const _CharacterSearchEmptyText(text: '未找到该用户'),
        if (searchCharacters) ...[
          const _CharacterSearchSectionLabel(text: '角色'),
          if (search.characterError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CharacterSearchInlineWarning(text: search.characterError),
            )
          else if (search.characters.isEmpty)
            const _CharacterSearchEmptyText(text: '未找到相关角色')
          else
            for (
              var index = 0;
              index < search.characters.length;
              index += 1
            ) ...[
              if (index > 0) const _CharacterSearchDivider(),
              Builder(
                builder: (context) {
                  final item = search.characters[index];
                  return _CharacterSearchRow(
                    item: item,
                    onTap: () => _selectCharacter(item),
                  );
                },
              ),
            ],
        ],
      ],
    );
  }

  /// 同步当前小圣杯搜索结果到页面
  void _handleTinygrailSearchChanged() {
    if (mounted &&
        !_isClosing &&
        _searchSource == _CharacterSearchSource.tinygrail) {
      _updateSearchState(() {});
    }
  }

  /// 启动当前关键词搜索并提示用户查询失败
  Future<void> _searchTinygrailNow() async {
    final requestId = ++_requestId;
    _updateSearchState(() {
      _isSearching = false;
      _errorMessage = '';
      _bangumiResults = const <NextBangumiCharacterSearchItem>[];
      _bangumiSubjectResults = const <NextBangumiSubjectSearchItem>[];
      _bangumiStatuses = const <int, CharacterDetailBasicInfo>{};
      _resetBangumiPagination();
      _resetBangumiSubjectPagination();
    });
    await _tinygrailSearchController.search(
      rawKeyword: _searchController.text,
      currentUsername: _cachedCurrentUserName,
    );
    if (!mounted ||
        _isClosing ||
        requestId != _requestId ||
        _searchSource != _CharacterSearchSource.tinygrail) {
      return;
    }

    final userError = _tinygrailSearchController.userError;
    if (userError.isNotEmpty &&
        _tinygrailSearchController.searchKeyword.searchCharacters) {
      AppToast.error(context, text: userError);
    }
  }
}
