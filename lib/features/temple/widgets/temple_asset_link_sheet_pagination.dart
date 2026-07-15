part of 'temple_asset_link_sheet.dart';

/// 圣殿 LINK 抽屉分页逻辑
extension _TempleAssetLinkSheetPagination on _TempleAssetLinkSheetState {
  /// 加载第一页圣殿数据
  Future<void> _loadFirstPage() async {
    final actionContext = widget.data.actionContext;
    final username = actionContext?.currentUserName.trim() ?? '';
    final requestId = ++_requestId;
    _resetPagination();

    _setSheetState(() {
      _isSearching = true;
      _isLoadingMore = false;
      _searchError = '';
      _loadMoreError = '';
      _items = const <UserTempleApiItem>[];
    });

    if (actionContext == null || username.isEmpty) {
      if (!mounted || requestId != _requestId) {
        return;
      }

      _setSheetState(() {
        _isSearching = false;
        _searchError = '请先授权';
      });
      return;
    }

    try {
      final page = await actionContext.userRepository.fetchUserTemplePage(
        username: username,
        page: 1,
        pageSize: _templeAssetLinkPageSize,
        keyword: _searchController.text.trim(),
      );
      if (!mounted || requestId != _requestId) {
        return;
      }

      _setSheetState(() {
        _items = page.items;
        _isSearching = false;
        _syncPagination(
          requestedPage: 1,
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          rawItemCount: page.items.length,
        );
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) {
        return;
      }

      _setSheetState(() {
        _searchError = _messageForError(error);
        _isSearching = false;
      });
    }
  }

  /// 加载下一页圣殿数据
  Future<void> _loadNextPage() async {
    if (!_canLoadNextPage) {
      return;
    }

    final actionContext = widget.data.actionContext;
    final username = actionContext?.currentUserName.trim() ?? '';
    final requestId = _requestId;
    final requestedPage = _nextPage;
    if (actionContext == null || username.isEmpty) {
      return;
    }

    _setSheetState(() {
      _isLoadingMore = true;
      _loadMoreError = '';
    });

    try {
      final page = await actionContext.userRepository.fetchUserTemplePage(
        username: username,
        page: requestedPage,
        pageSize: _templeAssetLinkPageSize,
        keyword: _searchController.text.trim(),
      );
      final existingIds = _items.map((item) => item.characterId).toSet();
      final items = page.items
          .where((item) => !existingIds.contains(item.characterId))
          .toList(growable: false);
      if (!mounted || requestId != _requestId) {
        return;
      }

      _setSheetState(() {
        _items = <UserTempleApiItem>[
          ..._items,
          ...items,
        ];
        _isLoadingMore = false;
        _syncPagination(
          requestedPage: requestedPage,
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          rawItemCount: page.items.length,
        );
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) {
        return;
      }

      _setSheetState(() {
        _loadMoreError = _messageForError(error);
        _isLoadingMore = false;
      });
    }
  }

  /// 重试加载下一页圣殿数据
  Future<void> _retryNextPage() async {
    if (_loadMoreError.isNotEmpty) {
      _setSheetState(() {
        _loadMoreError = '';
      });
    }
    await _loadNextPage();
  }

  /// 重置分页状态
  void _resetPagination() {
    _nextPage = 1;
    _canLoadMore = true;
    _lastPreloadItemCount = null;
    _isLoadingMore = false;
    _loadMoreError = '';
  }

  /// 同步分页状态
  ///
  /// [requestedPage] 请求页码
  /// [currentPage] 接口返回页码
  /// [totalPages] 接口返回总页数
  /// [rawItemCount] 接口返回条目数量
  void _syncPagination({
    required int requestedPage,
    required int currentPage,
    required int totalPages,
    required int rawItemCount,
  }) {
    final resolvedPage =
        currentPage > requestedPage ? currentPage : requestedPage;
    _nextPage = resolvedPage + 1;
    _canLoadMore = rawItemCount > 0 && resolvedPage < totalPages;
  }

  /// 处理圣殿网格条目构建触发的分页预加载
  ///
  /// [index] 当前构建的条目下标
  void _handleItemBuilt(int index) {
    final itemCount = _items.length;
    if (itemCount == 0 || _lastPreloadItemCount == itemCount) {
      return;
    }

    final maxIndex = itemCount - 1;
    final triggerIndex =
        (maxIndex - (_templeAssetLinkPageSize / 2).ceil()).clamp(0, maxIndex);
    if (index < triggerIndex || !_canLoadNextPage) {
      return;
    }

    _lastPreloadItemCount = itemCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(_loadNextPage());
    });
  }

  /// 是否可以加载下一页
  bool get _canLoadNextPage {
    return _canLoadMore &&
        !_isSearching &&
        !_isLoadingMore &&
        _loadMoreError.isEmpty;
  }

  /// 转换圣殿 LINK 错误文案
  ///
  /// [error] 捕获到的异常
  String _messageForError(Object error) {
    return resolveUserErrorMessage(error, fallback: '连接圣殿失败');
  }
}
