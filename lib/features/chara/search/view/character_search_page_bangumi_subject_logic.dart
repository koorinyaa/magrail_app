part of 'character_search_page.dart';

/// 角色搜索页 BGM 条目扩展逻辑
extension _CharacterSearchPageBangumiSubjectLogic on _CharacterSearchPageState {
  /// 构建 Bangumi 条目搜索结果列表
  ///
  /// [context] 当前组件树上下文
  Widget _buildBangumiSubjectResultList(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom > 0
        ? mediaQuery.viewInsets.bottom
        : mediaQuery.padding.bottom;
    final resultRowCount = _bangumiSubjectResults.isEmpty
        ? 0
        : _bangumiSubjectResults.length * 2 - 1;
    final emptyText = _bangumiSubjectResults.isEmpty
        ? _bangumiSubjectEmptyTextForCurrentKeyword
        : null;
    final hasFooter = _bangumiSubjectResults.isNotEmpty;
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
          return const _CharacterSearchSectionLabel(text: '条目');
        }

        final resultIndex = index - 1;
        if (emptyText != null && resultIndex == 0) {
          return _CharacterSearchEmptyText(text: emptyText);
        }

        if (resultIndex >= resultRowCount) {
          return PaginationFooter(
            isLoadingMore: _isBangumiSubjectLoadingMore,
            hasLoadMoreError: _bangumiSubjectLoadMoreError.isNotEmpty,
            canLoadMore: _bangumiSubjectCanLoadMore,
            completedLabel: '没有更多条目了',
            onRetry: _retryNextBangumiSubjectSearchPage,
          );
        }

        if (resultIndex.isOdd) {
          return const _CharacterSearchDivider();
        }

        final itemIndex = resultIndex ~/ 2;
        _handleBangumiSubjectSearchItemBuilt(itemIndex);
        final item = _bangumiSubjectResults[itemIndex];

        return NextBangumiSubjectSearchRow(
          item: item,
          onTap: () => _selectBangumiSubject(item),
        );
      },
    );
  }

  /// 立即执行 Bangumi 条目搜索
  Future<void> _searchBangumiSubjectNow() async {
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
      final page = await _bangumiRepository.searchSubjects(
        keyword,
        limit: _bangumiSearchPageSize,
        offset: 0,
      );
      if (!mounted || requestId != _requestId) {
        return;
      }

      _updateSearchState(() {
        _hasSearched = true;
        _isSearching = false;
        _bangumiSubjectResults = page.items;
        _syncBangumiSubjectPagination(
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
        _errorMessage = _messageForError(
          error,
          fallback: '搜索 BGM 条目失败',
        );
      });
    }
  }

  /// 加载 Bangumi 条目搜索结果下一页
  Future<void> _loadNextBangumiSubjectSearchPage() async {
    if (!_canLoadNextBangumiSubjectSearchPage) {
      return;
    }

    final requestId = _requestId;
    final keyword = _searchController.text.trim();
    final requestedOffset = _bangumiSubjectNextOffset;
    if (keyword.isEmpty) {
      return;
    }

    _updateSearchState(() {
      _isBangumiSubjectLoadingMore = true;
      _bangumiSubjectLoadMoreError = '';
    });

    try {
      final page = await _bangumiRepository.searchSubjects(
        keyword,
        limit: _bangumiSearchPageSize,
        offset: requestedOffset,
      );
      final existingIds =
          _bangumiSubjectResults.map((item) => item.subjectId).toSet();
      final items = page.items
          .where((item) => !existingIds.contains(item.subjectId))
          .toList(growable: false);
      if (!mounted ||
          requestId != _requestId ||
          _searchSource != _CharacterSearchSource.bangumiSubject) {
        return;
      }

      _updateSearchState(() {
        _bangumiSubjectResults = <NextBangumiSubjectSearchItem>[
          ..._bangumiSubjectResults,
          ...items,
        ];
        _isBangumiSubjectLoadingMore = false;
        _syncBangumiSubjectPagination(
          requestedOffset: requestedOffset,
          total: page.total,
          rawItemCount: page.rawItemCount,
        );
      });
    } catch (error) {
      if (!mounted ||
          requestId != _requestId ||
          _searchSource != _CharacterSearchSource.bangumiSubject) {
        return;
      }

      _updateSearchState(() {
        _bangumiSubjectLoadMoreError = _messageForError(
          error,
          fallback: '搜索 BGM 条目失败',
        );
        _isBangumiSubjectLoadingMore = false;
      });
    }
  }

  /// 重试加载 Bangumi 条目搜索结果下一页
  Future<void> _retryNextBangumiSubjectSearchPage() async {
    if (_bangumiSubjectLoadMoreError.isNotEmpty) {
      _updateSearchState(() {
        _bangumiSubjectLoadMoreError = '';
      });
    }

    await _loadNextBangumiSubjectSearchPage();
  }

  /// 重置 Bangumi 条目分页状态
  void _resetBangumiSubjectPagination() {
    _bangumiSubjectNextOffset = 0;
    _bangumiSubjectCanLoadMore = false;
    _isBangumiSubjectLoadingMore = false;
    _bangumiSubjectLoadMoreError = '';
    _bangumiSubjectLastPreloadItemCount = null;
  }

  /// 同步 Bangumi 条目分页状态
  ///
  /// [requestedOffset] 请求起始偏移量
  /// [total] 接口返回总数
  /// [rawItemCount] 接口返回原始条目数量
  void _syncBangumiSubjectPagination({
    required int requestedOffset,
    required int total,
    required int rawItemCount,
  }) {
    final nextOffset = requestedOffset + _bangumiSearchPageSize;
    _bangumiSubjectNextOffset = nextOffset;
    _bangumiSubjectCanLoadMore = rawItemCount > 0 && nextOffset < total;
  }

  /// 处理 BGM 条目构建触发的分页预加载
  ///
  /// [index] 当前构建的条目下标
  void _handleBangumiSubjectSearchItemBuilt(int index) {
    final itemCount = _bangumiSubjectResults.length;
    if (itemCount == 0 || _bangumiSubjectLastPreloadItemCount == itemCount) {
      return;
    }

    final maxIndex = itemCount - 1;
    final triggerIndex =
        (maxIndex - (_bangumiSearchPageSize / 2).ceil()).clamp(0, maxIndex);
    if (index < triggerIndex || !_canLoadNextBangumiSubjectSearchPage) {
      return;
    }

    _bangumiSubjectLastPreloadItemCount = itemCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(_loadNextBangumiSubjectSearchPage());
    });
  }

  /// 当前 Bangumi 条目空结果文案
  String get _bangumiSubjectEmptyTextForCurrentKeyword {
    return _searchController.text.trim().isEmpty ? '输入条目名称开始搜索' : '未找到相关条目';
  }

  /// 当前是否允许加载下一页 Bangumi 条目搜索结果
  bool get _canLoadNextBangumiSubjectSearchPage {
    return _searchSource == _CharacterSearchSource.bangumiSubject &&
        _bangumiSubjectCanLoadMore &&
        !_isSearching &&
        !_isBangumiSubjectLoadingMore &&
        _bangumiSubjectLoadMoreError.isEmpty;
  }
}
