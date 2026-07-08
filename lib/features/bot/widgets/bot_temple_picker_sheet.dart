part of 'bot_selection_sheet.dart';

/// bot 圣殿多选搜索抽屉
class _BotTempleMultiSearchSheet extends StatefulWidget {
  /// 创建 bot 圣殿多选搜索抽屉
  ///
  /// [title] 抽屉标题
  /// [headerSubtitle] 抽屉副标题
  /// [description] 抽屉说明文案
  /// [emptyText] 未搜索时的空状态文案
  /// [icon] 抽屉图标
  /// [imageAsset] 抽屉图片资源
  /// [useErrorColor] 是否使用错误色图标
  /// [search] 分页搜索回调
  /// [selected] 当前已选圣殿列表
  /// [onChanged] 选择变更回调
  /// [onSelected] 单选回调
  const _BotTempleMultiSearchSheet({
    required this.title,
    required this.headerSubtitle,
    required this.description,
    required this.emptyText,
    required this.icon,
    required this.imageAsset,
    required this.useErrorColor,
    required this.search,
    required this.selected,
    this.onChanged,
    this.onSelected,
  });

  /// 抽屉标题
  final String title;

  /// 抽屉副标题
  final String headerSubtitle;

  /// 抽屉说明文案
  final String description;

  /// 未搜索时的空状态文案
  final String emptyText;

  /// 抽屉图标
  final IconData icon;

  /// 抽屉图片资源
  final String imageAsset;

  /// 是否使用错误色图标
  final bool useErrorColor;

  /// 分页搜索回调
  final BotTemplePagedSearchLoader search;

  /// 当前已选圣殿列表
  final List<BotTempleOption> selected;

  /// 选择变更回调
  final ValueChanged<List<BotTempleOption>>? onChanged;

  /// 单选回调
  final ValueChanged<BotTempleOption>? onSelected;

  /// 创建 bot 圣殿多选搜索抽屉状态
  @override
  State<_BotTempleMultiSearchSheet> createState() =>
      _BotTempleMultiSearchSheetState();
}

/// bot 圣殿多选搜索抽屉状态
class _BotTempleMultiSearchSheetState
    extends State<_BotTempleMultiSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<int, BotTempleOption> _selected = <int, BotTempleOption>{};
  Timer? _searchDebounce;
  List<BotTempleOption> _items = const <BotTempleOption>[];
  String _lastSearchText = '';
  int _requestId = 0;
  int _nextPage = 1;
  bool _canLoadMore = true;
  int? _lastPreloadItemCount;
  bool _isSearching = false;
  bool _isLoadingMore = false;
  String _searchError = '';
  String _loadMoreError = '';

  /// 初始化 bot 圣殿多选搜索抽屉状态
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchTextChanged);
    for (final item in widget.selected) {
      _selected[item.characterId] = item;
    }
    _items = _selected.values.toList(growable: false);
  }

  /// 释放 bot 圣殿多选搜索抽屉状态
  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController
      ..removeListener(_handleSearchTextChanged)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 构建 bot 圣殿多选搜索抽屉
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerLowest;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.32 : 0.58,
                ),
              ),
            ),
          ),
          child: SafeArea(
            left: false,
            right: false,
            top: false,
            child: Padding(
              padding: AppSafeAreaInsets.fromLTRB(
                context,
                left: 20,
                top: 10,
                right: 20,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppBottomSheetDragHandle(),
                  const SizedBox(height: 10),
                  Flexible(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final showSearchBody = constraints.maxHeight >=
                            _botTempleBlacklistBodyVisibleMinHeight;
                        return Stack(
                          children: [
                            if (showSearchBody)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _BotTempleBlacklistHeader(
                                    title: widget.title,
                                    subtitle: _headerSubtitle,
                                    icon: widget.icon,
                                    imageAsset: widget.imageAsset,
                                    useErrorColor: widget.useErrorColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(child: _buildSearchContent(context)),
                                ],
                              ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 6,
                              child: _BotTempleBlacklistSearchField(
                                controller: _searchController,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建圣殿黑名单搜索内容
  ///
  /// [context] 当前组件树上下文
  Widget _buildSearchContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_searchError.isNotEmpty && _items.isNotEmpty) ...[
          _BotTempleBlacklistInlineWarning(text: _searchError),
          const SizedBox(height: 12),
        ],
        Text(
          widget.description,
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

  /// 构建圣殿黑名单搜索结果状态
  ///
  /// [context] 当前组件树上下文
  Widget _buildSearchResultState(BuildContext context) {
    if (_isSearching && _items.isEmpty) {
      return const _BotTempleBlacklistSkeletonGrid();
    }

    if (_searchError.isNotEmpty && _items.isEmpty) {
      return AppLoadFailedState(
        message: '请检查网络后重试',
        onActionPressed: () => unawaited(_loadFirstPage()),
      );
    }

    if (_items.isEmpty) {
      final hasKeyword = _searchController.text.trim().isNotEmpty;
      return _BotTempleBlacklistEmptyText(
        text: hasKeyword ? '未找到相关圣殿' : widget.emptyText,
      );
    }

    return _buildGrid();
  }

  /// 构建圣殿黑名单网格
  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _BotTempleBlacklistGridLayout.resolve(
          constraints.maxWidth,
        );

        return CustomScrollView(
          controller: _scrollController,
          primary: false,
          slivers: [
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: layout.crossAxisCount,
                mainAxisSpacing: _botTempleBlacklistGridSpacing,
                crossAxisSpacing: _botTempleBlacklistGridSpacing,
                childAspectRatio: layout.childAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  _handleItemBuilt(index);
                  final item = _items[index];
                  return _BotTempleBlacklistTile(
                    item: item,
                    width: layout.tileWidth,
                    isSelected: _selected.containsKey(item.characterId),
                    onPressed: () => _handleItemPressed(item),
                  );
                },
                childCount: _items.length,
              ),
            ),
            PaginationFooterSliver(
              isLoadingMore: _isLoadingMore,
              hasLoadMoreError: _loadMoreError.isNotEmpty,
              canLoadMore: _canLoadMore,
              completedLabel: '没有更多圣殿了',
              onRetry: () => unawaited(_retryNextPage()),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 58),
            ),
          ],
        );
      },
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
    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
      _loadFirstPage,
    );
  }

  /// 加载第一页圣殿搜索结果
  Future<void> _loadFirstPage() async {
    final text = _searchController.text.trim();
    final requestId = ++_requestId;
    _resetPagination();
    if (text.isEmpty) {
      setState(() {
        _items = _selected.values.toList(growable: false);
        _isSearching = false;
        _searchError = '';
        _loadMoreError = '';
      });
      return;
    }

    setState(() {
      _items = const <BotTempleOption>[];
      _isSearching = true;
      _searchError = '';
      _loadMoreError = '';
    });

    try {
      final page = await widget.search(
        page: 1,
        pageSize: _botTempleBlacklistPageSize,
        keyword: text,
      );
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        _items = page.items;
        _isSearching = false;
        _syncPagination(
          requestedPage: 1,
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          rawItemCount: page.items.length,
        );
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        _searchError = '搜索圣殿失败，请稍后重试';
      });
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  /// 加载下一页圣殿搜索结果
  Future<void> _loadNextPage() async {
    if (!_canLoadNextPage) {
      return;
    }

    final requestId = _requestId;
    final requestedPage = _nextPage;
    final text = _searchController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _loadMoreError = '';
    });

    try {
      final page = await widget.search(
        page: requestedPage,
        pageSize: _botTempleBlacklistPageSize,
        keyword: text,
      );
      final existingIds = _items.map((item) => item.characterId).toSet();
      final items = page.items
          .where((item) => !existingIds.contains(item.characterId))
          .toList(growable: false);
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        _items = <BotTempleOption>[
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
    } catch (_) {
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        _loadMoreError = '加载失败';
        _isLoadingMore = false;
      });
    }
  }

  /// 重试加载下一页
  Future<void> _retryNextPage() async {
    if (_loadMoreError.isNotEmpty) {
      setState(() {
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

  /// 处理网格条目构建触发的分页预加载
  ///
  /// [index] 当前构建的条目下标
  void _handleItemBuilt(int index) {
    final itemCount = _items.length;
    if (itemCount == 0 || _lastPreloadItemCount == itemCount) {
      return;
    }

    final maxIndex = itemCount - 1;
    final triggerIndex = (maxIndex - (_botTempleBlacklistPageSize / 2).ceil())
        .clamp(0, maxIndex);
    if (index < triggerIndex || !_canLoadNextPage) {
      return;
    }

    _lastPreloadItemCount = itemCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_loadNextPage());
      }
    });
  }

  /// 是否可以加载下一页
  bool get _canLoadNextPage {
    return _canLoadMore &&
        !_isSearching &&
        !_isLoadingMore &&
        _loadMoreError.isEmpty &&
        _searchController.text.trim().isNotEmpty;
  }

  /// 当前抽屉标题副文案
  String get _headerSubtitle {
    if (widget.useErrorColor) {
      return '已选择 ${_selected.length} 个圣殿';
    }

    return widget.headerSubtitle;
  }

  /// 处理圣殿卡片点击
  ///
  /// [item] 圣殿选择项
  void _handleItemPressed(BotTempleOption item) {
    final onSelected = widget.onSelected;
    if (onSelected != null) {
      onSelected(item);
      return;
    }

    setState(() {
      if (_selected.containsKey(item.characterId)) {
        _selected.remove(item.characterId);
      } else {
        _selected[item.characterId] = item;
      }
      if (_searchController.text.trim().isEmpty) {
        _items = _selected.values.toList(growable: false);
      }
    });
    widget.onChanged?.call(_selected.values.toList(growable: false));
  }
}
