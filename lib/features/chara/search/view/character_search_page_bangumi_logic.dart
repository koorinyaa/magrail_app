part of 'character_search_page.dart';

/// 角色搜索页 BGM 扩展逻辑
extension _CharacterSearchPageBangumiLogic on _CharacterSearchPageState {
  /// 构建 Bangumi 搜索结果列表
  ///
  /// [context] 当前组件树上下文
  Widget _buildBangumiResultList(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom > 0
        ? mediaQuery.viewInsets.bottom
        : mediaQuery.padding.bottom;
    final resultRowCount =
        _bangumiResults.isEmpty ? 0 : _bangumiResults.length * 2 - 1;
    final emptyText = _bangumiResults.isEmpty
        ? _bangumiEmptyTextForCurrentKeyword
        : null;
    final hasFooter = _bangumiResults.isNotEmpty;
    final itemCount =
        1 + resultRowCount + (emptyText == null ? 0 : 1) + (hasFooter ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      primary: false,
      padding: EdgeInsets.only(
        bottom: bottomInset + _characterSearchBottomContentPadding,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _CharacterSearchSectionLabel(text: '角色');
        }

        final resultIndex = index - 1;
        if (emptyText != null && resultIndex == 0) {
          return _CharacterSearchEmptyText(text: emptyText);
        }

        if (resultIndex >= resultRowCount) {
          return PaginationFooter(
            isLoadingMore: _isBangumiLoadingMore,
            hasLoadMoreError: _bangumiLoadMoreError.isNotEmpty,
            canLoadMore: _bangumiCanLoadMore,
            completedLabel: '没有更多角色了',
            onRetry: _retryNextBangumiSearchPage,
          );
        }

        if (resultIndex.isOdd) {
          return const _CharacterSearchDivider();
        }

        final itemIndex = resultIndex ~/ 2;
        _handleBangumiSearchItemBuilt(itemIndex);
        final item = _bangumiResults[itemIndex];
        final status = _bangumiStatuses[item.characterId];
        final avatarUrl = _avatarUrlForBangumiCharacter(item, status);
        final avatarHeroTag = createCharacterDetailAvatarHeroTag(
          characterId: item.characterId,
          avatarUrl: avatarUrl,
          source: item,
        );

        return _BangumiCharacterSearchRow(
          item: item,
          status: status,
          avatarUrl: avatarUrl,
          avatarHeroTag: avatarHeroTag,
          onTap: () => _selectBangumiCharacter(
            item,
            avatarUrl,
            avatarHeroTag,
          ),
        );
      },
    );
  }

  /// 处理搜索来源变化
  ///
  /// [source] 新的搜索来源
  void _handleSearchSourceChanged(_CharacterSearchSource source) {
    if (_searchSource == source) {
      return;
    }

    _searchDebounce?.cancel();
    _updateSearchState(() {
      _searchSource = source;
      _requestId += 1;
      _isSearching = false;
      _isSearchingTemples = false;
      _hasSearched = false;
      _hasSearchedTemples = false;
      _errorMessage = '';
      _templeErrorMessage = '';
      _results = const <CharacterDetailSearchItem>[];
      _templeResults = const <UserTempleApiItem>[];
      _bangumiResults = const <NextBangumiCharacterSearchItem>[];
      _bangumiSubjectResults = const <NextBangumiSubjectSearchItem>[];
      _bangumiStatuses = const <int, CharacterDetailBasicInfo>{};
      _resetBangumiPagination();
      _resetBangumiSubjectPagination();
    });

    if (source == _CharacterSearchSource.tinygrail ||
        _searchController.text.trim().isNotEmpty) {
      unawaited(_searchNow());
    }
  }

  /// 立即执行小圣杯搜索
  Future<void> _searchTinygrailNow() async {
    final keyword = _searchController.text.trim();
    final requestId = ++_requestId;
    final cachedUsername = _cachedCurrentUserName;
    final shouldSearchTemples = keyword.isNotEmpty && cachedUsername.isNotEmpty;

    _updateSearchState(() {
      _isSearching = true;
      _isSearchingTemples = shouldSearchTemples;
      _errorMessage = '';
      _templeErrorMessage = '';
      _results = const <CharacterDetailSearchItem>[];
      _templeResults = const <UserTempleApiItem>[];
      _bangumiResults = const <NextBangumiCharacterSearchItem>[];
      _bangumiSubjectResults = const <NextBangumiSubjectSearchItem>[];
      _bangumiStatuses = const <int, CharacterDetailBasicInfo>{};
      _resetBangumiPagination();
      _resetBangumiSubjectPagination();
      _hasSearchedTemples = false;
    });

    final resultsFuture = widget.repository.searchCharacters(
      keyword,
      allowEmptyKeyword: true,
    );
    final templesFuture = shouldSearchTemples
        ? widget.userRepository.fetchUserTemplePage(
            username: cachedUsername,
            keyword: keyword,
            pageSize: 12,
          )
        : null;

    Object? searchError;
    Object? templeError;
    var results = const <CharacterDetailSearchItem>[];
    var temples = const <UserTempleApiItem>[];

    try {
      results = await resultsFuture;
    } catch (error) {
      searchError = error;
    }

    if (templesFuture != null) {
      try {
        final page = await templesFuture;
        temples = page.items;
      } catch (error) {
        templeError = error;
      }
    }

    if (!mounted || requestId != _requestId) {
      return;
    }

    if (searchError == null) {
      _updateSearchState(() {
        _hasSearched = true;
        _hasSearchedTemples = shouldSearchTemples;
        _isSearching = false;
        _isSearchingTemples = false;
        _results = results;
      });
    } else {
      _updateSearchState(() {
        _hasSearched = true;
        _hasSearchedTemples = shouldSearchTemples;
        _isSearching = false;
        _isSearchingTemples = false;
        _errorMessage = _messageForError(searchError!);
      });
    }

    if (templeError == null) {
      _updateSearchState(() {
        _templeResults = temples;
      });
    } else {
      _updateSearchState(() {
        _templeErrorMessage = _messageForError(templeError!);
      });
    }
  }

  /// 立即执行 Bangumi 搜索
  Future<void> _searchBangumiNow() async {
    final keyword = _searchController.text.trim();
    final requestId = ++_requestId;
    if (keyword.isEmpty) {
      _updateSearchState(() {
        _isSearching = false;
        _isSearchingTemples = false;
        _hasSearched = false;
        _hasSearchedTemples = false;
        _errorMessage = '';
        _templeErrorMessage = '';
        _results = const <CharacterDetailSearchItem>[];
        _templeResults = const <UserTempleApiItem>[];
        _bangumiResults = const <NextBangumiCharacterSearchItem>[];
        _bangumiSubjectResults = const <NextBangumiSubjectSearchItem>[];
        _bangumiStatuses = const <int, CharacterDetailBasicInfo>{};
        _resetBangumiPagination();
        _resetBangumiSubjectPagination();
      });
      return;
    }

    _updateSearchState(() {
      _isSearching = true;
      _isSearchingTemples = false;
      _errorMessage = '';
      _templeErrorMessage = '';
      _results = const <CharacterDetailSearchItem>[];
      _templeResults = const <UserTempleApiItem>[];
      _bangumiResults = const <NextBangumiCharacterSearchItem>[];
      _bangumiSubjectResults = const <NextBangumiSubjectSearchItem>[];
      _bangumiStatuses = const <int, CharacterDetailBasicInfo>{};
      _resetBangumiPagination();
      _resetBangumiSubjectPagination();
      _hasSearchedTemples = false;
    });

    try {
      final page = await _bangumiRepository.searchCharacters(
        keyword,
        limit: _bangumiSearchPageSize,
        offset: 0,
      );
      final ids = page.items
          .map((item) => item.characterId)
          .where((characterId) => characterId > 0)
          .toList(growable: false);
      final statuses = await widget.repository.fetchCharacterBasicInfoList(ids);
      if (!mounted || requestId != _requestId) {
        return;
      }

      _updateSearchState(() {
        _hasSearched = true;
        _isSearching = false;
        _bangumiResults = page.items;
        _bangumiStatuses = statuses;
        _syncBangumiPagination(
          requestedOffset: 0,
          total: page.total,
          rawItemCount: page.rawItemCount,
        );
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) {
        return;
      }

      _updateSearchState(() {
        _hasSearched = true;
        _isSearching = false;
        _errorMessage = _messageForError(error);
      });
    }
  }

  /// 加载 Bangumi 搜索结果下一页
  Future<void> _loadNextBangumiSearchPage() async {
    if (!_canLoadNextBangumiSearchPage) {
      return;
    }

    final requestId = _requestId;
    final keyword = _searchController.text.trim();
    final requestedOffset = _bangumiNextOffset;
    if (keyword.isEmpty) {
      return;
    }

    _updateSearchState(() {
      _isBangumiLoadingMore = true;
      _bangumiLoadMoreError = '';
    });

    try {
      final page = await _bangumiRepository.searchCharacters(
        keyword,
        limit: _bangumiSearchPageSize,
        offset: requestedOffset,
      );
      final existingIds =
          _bangumiResults.map((item) => item.characterId).toSet();
      final items = page.items
          .where((item) => !existingIds.contains(item.characterId))
          .toList(growable: false);
      final statuses = await widget.repository.fetchCharacterBasicInfoList(
        items.map((item) => item.characterId).toList(growable: false),
      );
      if (!mounted ||
          requestId != _requestId ||
          _searchSource != _CharacterSearchSource.bangumi) {
        return;
      }

      _updateSearchState(() {
        _bangumiResults = <NextBangumiCharacterSearchItem>[
          ..._bangumiResults,
          ...items,
        ];
        _bangumiStatuses = <int, CharacterDetailBasicInfo>{
          ..._bangumiStatuses,
          ...statuses,
        };
        _isBangumiLoadingMore = false;
        _syncBangumiPagination(
          requestedOffset: requestedOffset,
          total: page.total,
          rawItemCount: page.rawItemCount,
        );
      });
    } catch (error) {
      if (!mounted ||
          requestId != _requestId ||
          _searchSource != _CharacterSearchSource.bangumi) {
        return;
      }

      _updateSearchState(() {
        _bangumiLoadMoreError = _messageForError(error);
        _isBangumiLoadingMore = false;
      });
    }
  }

  /// 重试加载 Bangumi 搜索结果下一页
  Future<void> _retryNextBangumiSearchPage() async {
    if (_bangumiLoadMoreError.isNotEmpty) {
      _updateSearchState(() {
        _bangumiLoadMoreError = '';
      });
    }

    await _loadNextBangumiSearchPage();
  }

  /// 重置 Bangumi 分页状态
  void _resetBangumiPagination() {
    _bangumiNextOffset = 0;
    _bangumiCanLoadMore = false;
    _isBangumiLoadingMore = false;
    _bangumiLoadMoreError = '';
    _bangumiLastPreloadItemCount = null;
  }

  /// 同步 Bangumi 分页状态
  ///
  /// [requestedOffset] 请求起始偏移量
  /// [total] 接口返回总数
  /// [rawItemCount] 接口返回原始条目数量
  void _syncBangumiPagination({
    required int requestedOffset,
    required int total,
    required int rawItemCount,
  }) {
    final nextOffset = requestedOffset + _bangumiSearchPageSize;
    _bangumiNextOffset = nextOffset;
    _bangumiCanLoadMore = rawItemCount > 0 && nextOffset < total;
  }

  /// 处理 BGM 角色构建触发的分页预加载
  ///
  /// [index] 当前构建的条目下标
  void _handleBangumiSearchItemBuilt(int index) {
    final itemCount = _bangumiResults.length;
    if (itemCount == 0 || _bangumiLastPreloadItemCount == itemCount) {
      return;
    }

    final maxIndex = itemCount - 1;
    final triggerIndex =
        (maxIndex - (_bangumiSearchPageSize / 2).ceil()).clamp(0, maxIndex);
    if (index < triggerIndex || !_canLoadNextBangumiSearchPage) {
      return;
    }

    _bangumiLastPreloadItemCount = itemCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(_loadNextBangumiSearchPage());
    });
  }

  /// 选择 Bangumi 搜索结果角色
  ///
  /// [item] Bangumi 搜索结果角色
  /// [avatarUrl] 合并后头像地址
  /// [avatarHeroTag] 头像转场标识
  void _selectBangumiCharacter(
    NextBangumiCharacterSearchItem item,
    String avatarUrl,
    String? avatarHeroTag,
  ) {
    if (item.characterId <= 0) {
      return;
    }

    final name = item.nameCn.trim().isNotEmpty ? item.nameCn : item.name;
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: name,
      avatarUrl: avatarUrl,
      avatarHeroTag: avatarHeroTag,
    );
  }

  /// 解析 Bangumi 搜索结果应展示的头像
  ///
  /// [item] Bangumi 搜索结果角色
  /// [status] 小圣杯角色状态
  String _avatarUrlForBangumiCharacter(
    NextBangumiCharacterSearchItem item,
    CharacterDetailBasicInfo? status,
  ) {
    final tinygrailAvatar = status?.icon.trim();
    if (tinygrailAvatar != null && tinygrailAvatar.isNotEmpty) {
      return tinygrailAvatar;
    }

    return item.avatarUrl;
  }

  /// 是否存在当前来源可展示的结果
  bool get _hasVisibleResults {
    return switch (_searchSource) {
      _CharacterSearchSource.tinygrail =>
        _results.isNotEmpty || _templeResults.isNotEmpty,
      _CharacterSearchSource.bangumi => _bangumiResults.isNotEmpty,
      _CharacterSearchSource.bangumiSubject =>
        _bangumiSubjectResults.isNotEmpty,
    };
  }

  /// 当前 Bangumi 空结果文案
  String get _bangumiEmptyTextForCurrentKeyword {
    return _searchController.text.trim().isEmpty
        ? '输入角色名称开始搜索'
        : '未找到相关角色';
  }

  /// 当前是否允许加载下一页 Bangumi 搜索结果
  bool get _canLoadNextBangumiSearchPage {
    return _searchSource == _CharacterSearchSource.bangumi &&
        _bangumiCanLoadMore &&
        !_isSearching &&
        !_isBangumiLoadingMore &&
        _bangumiLoadMoreError.isEmpty;
  }

}
