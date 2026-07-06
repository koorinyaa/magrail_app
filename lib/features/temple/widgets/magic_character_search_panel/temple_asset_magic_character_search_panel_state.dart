part of '../temple_asset_magic_character_search_panel.dart';

/// 魔法道具角色搜索面板状态
class TempleAssetMagicCharacterSearchPanelState
    extends State<TempleAssetMagicCharacterSearchPanel> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _searchScrollController = ScrollController();

  Timer? _searchDebounce;
  var _lastSearchText = '';
  var _searchRequestId = 0;
  var _isSearching = false;
  var _isInitialLoadingMore = false;
  var _initialNextPage = 1;
  var _initialCanLoadMore = true;
  int? _initialLastPreloadItemCount;
  var _searchError = '';
  var _loadMoreError = '';
  List<TempleAssetMagicCharacterSearchItem> _searchResults =
      const <TempleAssetMagicCharacterSearchItem>[];
  List<_MagicRecentSearchItem> _recentResults =
      const <_MagicRecentSearchItem>[];
  final Map<int, int> _supplementValues = <int, int>{};
  final Set<int> _loadedSupplementIds = <int>{};

  /// 初始化魔法道具角色搜索面板状态
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchTextChanged);
    unawaited(_loadInitialSearchResults());
  }

  /// 释放魔法道具角色搜索面板状态
  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController
      ..removeListener(_handleSearchTextChanged)
      ..dispose();
    _searchScrollController.dispose();
    super.dispose();
  }

  /// 保存并刷新最近使用角色
  ///
  /// [characterId] 最近使用的角色 ID
  Future<void> saveRecentCharacterId(int characterId) async {
    await saveTempleAssetMagicRecentCharacterId(
      storageKeyPrefix: widget.recentStorageKeyPrefix,
      username: widget.currentUserName,
      characterId: characterId,
    );
    await _refreshRecentSearchItemsSilently();
  }

  /// 构建魔法道具角色搜索面板
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showSearchBody =
            constraints.maxHeight >= _searchBodyVisibleMinHeight;
        return Stack(
          children: [
            if (showSearchBody)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widget.header,
                  const SizedBox(height: 16),
                  Expanded(child: _buildSearchContent(context)),
                ],
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 6,
              child: _buildSearchFooter(context),
            ),
          ],
        );
      },
    );
  }

  /// 构建角色搜索内容
  ///
  /// [context] 当前组件树上下文
  Widget _buildSearchContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_searchError.isNotEmpty && _searchResults.isNotEmpty) ...[
          _TempleAssetMagicInlineWarning(text: _searchError),
          const SizedBox(height: 12),
        ],
        Text(
          widget.hintText,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.68),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: _buildSearchResultState(context),
          ),
        ),
      ],
    );
  }

  /// 构建角色搜索结果状态
  ///
  /// [context] 当前组件树上下文
  Widget _buildSearchResultState(BuildContext context) {
    if (_isSearching && _searchResults.isEmpty) {
      return const _TempleAssetMagicSearchSkeletonList();
    }

    if (_searchError.isNotEmpty && _searchResults.isEmpty) {
      return AppLoadFailedState(
        message: '请检查网络后重试',
        onActionPressed: _retrySearchAfterError,
      );
    }

    if (_searchResults.isEmpty &&
        _TempleAssetMagicCharacterSearchData(this)._shouldShowRecent) {
      return _buildSearchResultList();
    }

    if (_searchResults.isEmpty) {
      return _TempleAssetMagicEmptyText(
        text: _searchController.text.trim().isEmpty ? '暂无可选角色' : '未找到相关角色',
      );
    }

    return _buildSearchResultList();
  }

  /// 构建角色搜索结果列表
  Widget _buildSearchResultList() {
    final recentRowCount =
        _TempleAssetMagicCharacterSearchData(this)._shouldShowRecent
            ? _recentResults.length * 2
            : 0;
    final searchRowCount =
        _searchResults.isEmpty ? 0 : _searchResults.length * 2 - 1;
    final hasFooter = _isInitialLoadingMore || _loadMoreError.isNotEmpty;
    final itemCount = recentRowCount + searchRowCount + (hasFooter ? 1 : 0);

    return ListView.builder(
      controller: _searchScrollController,
      primary: false,
      padding: const EdgeInsets.only(bottom: 58),
      itemBuilder: (context, index) {
        if (index < recentRowCount) {
          final dividerIndex = _recentResults.length * 2 - 1;
          if (index == dividerIndex) {
            return const _TempleAssetMagicSearchSectionDivider(text: '最近使用');
          }

          if (index.isOdd) {
            return const _TempleAssetMagicSearchDivider();
          }

          final recent = _recentResults[index ~/ 2];
          return _buildSearchRow(recent.item, recent.usedAt);
        }

        final searchIndex = index - recentRowCount;
        if (searchIndex >= searchRowCount) {
          if (_loadMoreError.isNotEmpty) {
            return _TempleAssetMagicSearchLoadMoreError(
              onRetry: _retryNextInitialSearchPage,
            );
          }

          return const _TempleAssetMagicSearchLoadingMore();
        }

        if (searchIndex.isOdd) {
          return const _TempleAssetMagicSearchDivider();
        }

        final itemIndex = searchIndex ~/ 2;
        _handleSearchItemBuilt(itemIndex);
        return _buildSearchRow(_searchResults[itemIndex], '');
      },
      itemCount: itemCount,
    );
  }

  /// 构建搜索结果行
  ///
  /// [item] 搜索结果条目
  /// [usedAt] 最近使用时间
  Widget _buildSearchRow(
    TempleAssetMagicCharacterSearchItem item,
    String usedAt,
  ) {
    final supplementValue = _loadedSupplementIds.contains(item.characterId)
        ? _supplementValues[item.characterId] ?? 0
        : null;
    return _TempleAssetMagicSearchRow(
      item: item,
      secondaryText: widget.secondaryTextBuilder(item, supplementValue),
      usedTimeText:
          _TempleAssetMagicCharacterSearchData(this)._recentTimeText(usedAt),
      onTap: () => widget.onSelected(item, supplementValue),
    );
  }

  /// 构建底部搜索框
  ///
  /// [context] 当前组件树上下文
  Widget _buildSearchFooter(BuildContext context) {
    return _buildSearchField(context);
  }

  /// 构建搜索输入框
  ///
  /// [context] 当前组件树上下文
  Widget _buildSearchField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final borderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.26 : 0.42,
    );
    final focusedBorderColor = colorScheme.primary.withValues(
      alpha: isDark ? 0.34 : 0.30,
    );

    final borderRadius = BorderRadius.circular(999);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: AppBlurStyle.filter,
        child: TextField(
          controller: _searchController,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(LucideIcons.search, size: 18),
            hintText: '搜索角色',
            filled: true,
            fillColor: AppBlurStyle.surfaceColor(context),
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: borderColor, width: 0.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: borderColor, width: 0.8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: focusedBorderColor, width: 0.9),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
          ),
        ),
      ),
    );
  }

  /// 处理搜索输入变化
  void _handleSearchTextChanged() {
    final searchText = _searchController.text;
    if (searchText == _lastSearchText) {
      return;
    }

    _lastSearchText = searchText;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), _search);
  }

  /// 重试当前搜索请求
  Future<void> _retrySearchAfterError() async {
    if (_TempleAssetMagicCharacterSearchData(this)._isInitialSearchMode) {
      await _loadInitialSearchResults();
      return;
    }

    await _search();
  }

  /// 搜索角色
  Future<void> _search() async {
    final requestId = ++_searchRequestId;
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      await _loadInitialSearchResults();
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = '';
      _searchResults = const <TempleAssetMagicCharacterSearchItem>[];
      _isInitialLoadingMore = false;
      _initialCanLoadMore = false;
      _initialLastPreloadItemCount = null;
      _loadMoreError = '';
    });

    try {
      final searchItems = await widget.characterRepository.searchCharacters(
        keyword,
      );
      final items = searchItems
          .map(TempleAssetMagicCharacterSearchItem.fromSearchItem)
          .toList(growable: false);
      final supplementValues = await _TempleAssetMagicCharacterSearchData(this)
          ._loadSupplementValues(items);
      if (!mounted || requestId != _searchRequestId) {
        return;
      }

      setState(() {
        _TempleAssetMagicCharacterSearchData(this)
            ._replaceSupplementValues(items, supplementValues);
        _searchResults = items;
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted || requestId != _searchRequestId) {
        return;
      }

      setState(() {
        _searchError = _messageForError(error, '搜索角色失败');
        _isSearching = false;
      });
    }
  }

  /// 加载初始角色列表
  Future<void> _loadInitialSearchResults() async {
    final requestId = ++_searchRequestId;
    final username = widget.currentUserName.trim();
    _resetInitialPagination();
    if (username.isEmpty) {
      setState(() {
        _searchResults = const <TempleAssetMagicCharacterSearchItem>[];
        _recentResults = const <_MagicRecentSearchItem>[];
        _searchError = '请先授权';
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isInitialLoadingMore = false;
      _searchError = '';
      _searchResults = const <TempleAssetMagicCharacterSearchItem>[];
      _recentResults = const <_MagicRecentSearchItem>[];
      _loadMoreError = '';
    });

    try {
      final page = await widget.userRepository.fetchUserCharacterPage(
        username: username,
        page: 1,
        pageSize: _magicSearchPageSize,
        sort: 'desc',
      );
      final recentItems = await _TempleAssetMagicCharacterSearchData(this)
          ._loadRecentSearchItems(username);
      final items = page.items
          .map(TempleAssetMagicCharacterSearchItem.fromUserCharacter)
          .toList(growable: false);
      final supplementItems = <TempleAssetMagicCharacterSearchItem>[
        ...recentItems.map((item) => item.item),
        ...items,
      ];
      final supplementValues = await _TempleAssetMagicCharacterSearchData(this)
          ._loadSupplementValues(supplementItems);
      if (!mounted || requestId != _searchRequestId) {
        return;
      }

      setState(() {
        _TempleAssetMagicCharacterSearchData(this)
            ._replaceSupplementValues(supplementItems, supplementValues);
        _recentResults = recentItems;
        _searchResults = items;
        _isSearching = false;
        _syncInitialPagination(
          requestedPage: 1,
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          rawItemCount: page.items.length,
        );
      });
    } catch (error) {
      if (!mounted || requestId != _searchRequestId) {
        return;
      }

      setState(() {
        _searchError = _messageForError(error, '加载角色失败');
        _isSearching = false;
      });
    }
  }

  /// 加载初始角色列表下一页
  Future<void> _loadNextInitialSearchPage() async {
    if (!_TempleAssetMagicCharacterSearchData(this)
        ._canLoadNextInitialSearchPage) {
      return;
    }

    final requestId = _searchRequestId;
    final requestedPage = _initialNextPage;
    final username = widget.currentUserName.trim();
    if (username.isEmpty) {
      return;
    }

    setState(() {
      _isInitialLoadingMore = true;
      _loadMoreError = '';
    });

    try {
      final page = await widget.userRepository.fetchUserCharacterPage(
        username: username,
        page: requestedPage,
        pageSize: _magicSearchPageSize,
        sort: 'desc',
      );
      final existingIds =
          _searchResults.map((item) => item.characterId).toSet();
      final items = page.items
          .where((item) => !existingIds.contains(item.characterId))
          .map(TempleAssetMagicCharacterSearchItem.fromUserCharacter)
          .toList(growable: false);
      final supplementValues = await _TempleAssetMagicCharacterSearchData(this)
          ._loadSupplementValues(items);
      if (!mounted ||
          requestId != _searchRequestId ||
          !_TempleAssetMagicCharacterSearchData(this)._isInitialSearchMode) {
        return;
      }

      setState(() {
        _TempleAssetMagicCharacterSearchData(this)
            ._replaceSupplementValues(items, supplementValues);
        _searchResults = <TempleAssetMagicCharacterSearchItem>[
          ..._searchResults,
          ...items,
        ];
        _isInitialLoadingMore = false;
        _syncInitialPagination(
          requestedPage: requestedPage,
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          rawItemCount: page.items.length,
        );
      });
    } catch (error) {
      if (!mounted ||
          requestId != _searchRequestId ||
          !_TempleAssetMagicCharacterSearchData(this)._isInitialSearchMode) {
        return;
      }

      setState(() {
        _loadMoreError = _messageForError(error, '加载角色失败');
        _isInitialLoadingMore = false;
      });
    }
  }

  /// 重试加载初始角色列表下一页
  Future<void> _retryNextInitialSearchPage() async {
    if (_loadMoreError.isEmpty) {
      await _loadNextInitialSearchPage();
      return;
    }

    setState(() {
      _loadMoreError = '';
    });
    await _loadNextInitialSearchPage();
  }

  /// 重置初始列表分页状态
  void _resetInitialPagination() {
    _initialNextPage = 1;
    _initialCanLoadMore = true;
    _initialLastPreloadItemCount = null;
    _isInitialLoadingMore = false;
    _loadMoreError = '';
  }

  /// 同步初始列表分页状态
  ///
  /// [requestedPage] 请求页码
  /// [currentPage] 接口返回页码
  /// [totalPages] 接口返回总页数
  /// [rawItemCount] 接口返回条目数量
  void _syncInitialPagination({
    required int requestedPage,
    required int currentPage,
    required int totalPages,
    required int rawItemCount,
  }) {
    final resolvedPage =
        currentPage > requestedPage ? currentPage : requestedPage;
    _initialNextPage = resolvedPage + 1;
    _initialCanLoadMore = rawItemCount > 0 && resolvedPage < totalPages;
  }

  /// 处理条目构建触发的分页预加载
  ///
  /// [index] 当前构建的条目下标
  void _handleSearchItemBuilt(int index) {
    if (!_TempleAssetMagicCharacterSearchData(this)._isInitialSearchMode) {
      return;
    }

    final itemCount = _searchResults.length;
    if (itemCount == 0 || _initialLastPreloadItemCount == itemCount) {
      return;
    }

    final maxIndex = itemCount - 1;
    final triggerIndex =
        (maxIndex - (_magicSearchPageSize / 2).ceil()).clamp(0, maxIndex);
    if (index < triggerIndex ||
        !_TempleAssetMagicCharacterSearchData(this)
            ._canLoadNextInitialSearchPage) {
      return;
    }

    _initialLastPreloadItemCount = itemCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(_loadNextInitialSearchPage());
    });
  }

  /// 静默刷新最近使用角色
  Future<void> _refreshRecentSearchItemsSilently() async {
    final username = widget.currentUserName.trim();
    if (username.isEmpty) {
      return;
    }

    try {
      final requestId = _searchRequestId;
      final items = await _TempleAssetMagicCharacterSearchData(this)
          ._loadRecentSearchItems(username);
      final supplementItems =
          items.map((item) => item.item).toList(growable: false);
      final supplementValues = await _TempleAssetMagicCharacterSearchData(this)
          ._loadSupplementValues(supplementItems);
      if (!mounted || requestId != _searchRequestId) {
        return;
      }

      final refreshedItemById = <int, TempleAssetMagicCharacterSearchItem>{
        for (final item in items) item.item.characterId: item.item,
      };
      setState(() {
        _TempleAssetMagicCharacterSearchData(this)
            ._replaceSupplementValues(supplementItems, supplementValues);
        _recentResults = items;
        if (refreshedItemById.isNotEmpty) {
          _searchResults = [
            for (final item in _searchResults)
              refreshedItemById[item.characterId] ?? item,
          ];
        }
      });
    } catch (_) {
      return;
    }
  }
}
