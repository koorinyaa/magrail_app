part of 'character_detail_bangumi_related_sheet.dart';

/// 角色关联角色抽屉
class _CharacterBangumiRelationsSheet extends StatefulWidget {
  /// 创建角色关联角色抽屉
  ///
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  /// [characterRepository] 角色详情仓库
  const _CharacterBangumiRelationsSheet({
    required this.characterId,
    required this.characterName,
    required this.characterRepository,
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 角色详情仓库
  final CharacterDetailRepository characterRepository;

  /// 创建角色关联角色抽屉状态
  @override
  State<_CharacterBangumiRelationsSheet> createState() =>
      _CharacterBangumiRelationsSheetState();
}

/// 角色关联角色抽屉状态
class _CharacterBangumiRelationsSheetState
    extends State<_CharacterBangumiRelationsSheet> {
  late final NextBangumiRepository _repository;
  final Set<int> _seenCharacterIds = <int>{};

  List<NextBangumiSubjectCharacterItem> _items =
      const <NextBangumiSubjectCharacterItem>[];
  Map<int, CharacterDetailBasicInfo> _statuses =
      const <int, CharacterDetailBasicInfo>{};
  var _isInitialLoading = true;
  var _initialError = '';
  var _isLoadingMore = false;
  var _loadMoreError = '';
  var _canLoadMore = false;
  var _nextOffset = 0;
  var _requestId = 0;
  int? _lastPreloadItemCount;

  /// 初始化角色关联角色抽屉状态
  @override
  void initState() {
    super.initState();
    _repository = NextBangumiRepository();
    unawaited(_loadRelations(reset: true));
  }

  /// 释放角色关联角色抽屉状态
  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  /// 构建角色关联角色抽屉
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _CharacterBangumiRelatedSheetSurface(
      title: '关联角色',
      subtitle: _characterBangumiRelatedSubtitle(
        widget.characterId,
        widget.characterName,
      ),
      icon: LucideIcons.usersRound,
      child: _buildContent(context),
    );
  }

  /// 构建关联角色内容
  ///
  /// [context] 当前组件树上下文
  Widget _buildContent(BuildContext context) {
    if (widget.characterId <= 0) {
      return const AppLoadFailedState(
        title: '角色无效',
        message: '当前角色不存在',
        actionLabel: null,
      );
    }

    if (_isInitialLoading) {
      return const _CharacterBangumiRelationSkeletonGrid();
    }

    if (_initialError.isNotEmpty) {
      return AppLoadFailedState(
        message: _initialError,
        onActionPressed: () => _loadRelations(reset: true),
      );
    }

    if (_items.isEmpty) {
      return const _CharacterBangumiRelatedEmptyState(
        title: '暂无关联角色',
        description: '当前角色没有可展示的关联角色',
      );
    }

    return CustomScrollView(
      primary: false,
      slivers: [
        SliverGrid(
          gridDelegate: _CharacterBangumiRelationGridMetrics.delegate,
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = _items[index];
              _handleItemBuilt(index);
              return NextBangumiCharacterGridItem(
                item: item,
                status: _statuses[item.characterId],
                onTap: () => _openCharacter(item),
              );
            },
            childCount: _items.length,
          ),
        ),
        SliverToBoxAdapter(
          child: PaginationFooter(
            isLoadingMore: _isLoadingMore,
            hasLoadMoreError: _loadMoreError.isNotEmpty,
            canLoadMore: _canLoadMore,
            completedLabel: '没有更多角色了',
            onRetry: _retryNextPage,
          ),
        ),
      ],
    );
  }

  /// 加载关联角色
  ///
  /// [reset] 是否重新加载第一页
  Future<void> _loadRelations({required bool reset}) async {
    if (widget.characterId <= 0) {
      setState(() {
        _isInitialLoading = false;
        _initialError = '';
      });
      return;
    }

    final requestId = reset ? ++_requestId : _requestId;
    final requestedOffset = reset ? 0 : _nextOffset;
    if (reset) {
      _resetPagination();
      setState(() {
        _items = const <NextBangumiSubjectCharacterItem>[];
        _statuses = const <int, CharacterDetailBasicInfo>{};
        _isInitialLoading = true;
        _initialError = '';
      });
    } else if (!_canLoadNextPage) {
      return;
    } else {
      setState(() {
        _isLoadingMore = true;
        _loadMoreError = '';
      });
    }

    try {
      final page = await _repository.fetchCharacterRelations(
        widget.characterId,
        limit: _characterBangumiRelatedPageSize,
        offset: requestedOffset,
      );
      final newItems = _dedupeNewItems(page.items);
      final statuses =
          await widget.characterRepository.fetchCharacterBasicInfoList(
        newItems.map((item) => item.characterId).toList(growable: false),
      );
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        if (reset) {
          _items = newItems;
          _statuses = statuses;
          _isInitialLoading = false;
        } else {
          _items = <NextBangumiSubjectCharacterItem>[..._items, ...newItems];
          _statuses = <int, CharacterDetailBasicInfo>{
            ..._statuses,
            ...statuses,
          };
          _isLoadingMore = false;
        }
        _seenCharacterIds.addAll(newItems.map((item) => item.characterId));
        _syncPagination(
          requestedOffset: requestedOffset,
          total: page.total,
          rawItemCount: page.rawItemCount,
        );
        if (!reset && newItems.isEmpty) {
          // 当前页全部为重复角色时允许现有网格继续触发下一页扫描
          _lastPreloadItemCount = null;
        }
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        final message = resolveUserErrorMessage(
          error,
          fallback: '获取关联角色失败',
        );
        if (reset) {
          _isInitialLoading = false;
          _initialError = message;
        } else {
          _isLoadingMore = false;
          _loadMoreError = message;
        }
      });
    }
  }

  /// 去重当前页新增角色
  ///
  /// [items] 接口返回角色列表
  List<NextBangumiSubjectCharacterItem> _dedupeNewItems(
    List<NextBangumiSubjectCharacterItem> items,
  ) {
    final nextItems = <NextBangumiSubjectCharacterItem>[];
    final pageIds = <int>{};
    for (final item in items) {
      if (!_seenCharacterIds.contains(item.characterId) &&
          pageIds.add(item.characterId)) {
        nextItems.add(item);
      }
    }

    return nextItems;
  }

  /// 重试下一页关联角色
  Future<void> _retryNextPage() async {
    if (_loadMoreError.isNotEmpty) {
      setState(() {
        _loadMoreError = '';
      });
    }

    await _loadRelations(reset: false);
  }

  /// 重置关联角色分页状态
  void _resetPagination() {
    _seenCharacterIds.clear();
    _nextOffset = 0;
    _canLoadMore = false;
    _isLoadingMore = false;
    _loadMoreError = '';
    _lastPreloadItemCount = null;
  }

  /// 同步关联角色分页状态
  ///
  /// [requestedOffset] 当前请求偏移量
  /// [total] 接口返回总数
  /// [rawItemCount] 当前页原始条目数
  void _syncPagination({
    required int requestedOffset,
    required int total,
    required int rawItemCount,
  }) {
    final nextOffset = requestedOffset + _characterBangumiRelatedPageSize;
    _nextOffset = nextOffset;
    _canLoadMore = rawItemCount > 0 && nextOffset < total;
  }

  /// 处理关联角色构建触发的预加载
  ///
  /// [index] 当前构建下标
  void _handleItemBuilt(int index) {
    final itemCount = _items.length;
    if (itemCount == 0 || _lastPreloadItemCount == itemCount) {
      return;
    }

    final maxIndex = itemCount - 1;
    final triggerIndex =
        (maxIndex - (_characterBangumiRelatedPageSize / 2).ceil())
            .clamp(0, maxIndex);
    if (index < triggerIndex || !_canLoadNextPage) {
      return;
    }

    _lastPreloadItemCount = itemCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(_loadRelations(reset: false));
    });
  }

  /// 打开关联角色详情
  ///
  /// [item] 关联角色
  void _openCharacter(NextBangumiSubjectCharacterItem item) {
    final avatarUrl = resolveNextBangumiCharacterAvatarUrl(
      item,
      _statuses[item.characterId],
    );
    final heroTag = createCharacterDetailAvatarHeroTag(
      characterId: item.characterId,
      avatarUrl: avatarUrl,
      source: item,
    );

    _closeCharacterBangumiRelatedSheetAndNavigate(
      context,
      (navigationContext) => openCharacterDetail(
        navigationContext,
        characterId: item.characterId,
        name: item.displayName,
        avatarUrl: avatarUrl,
        avatarHeroTag: heroTag,
      ),
    );
  }

  /// 当前是否允许加载下一页关联角色
  bool get _canLoadNextPage {
    return _canLoadMore &&
        !_isInitialLoading &&
        !_isLoadingMore &&
        _loadMoreError.isEmpty;
  }
}

/// 关联角色骨架网格
class _CharacterBangumiRelationSkeletonGrid extends StatelessWidget {
  /// 创建关联角色骨架网格
  const _CharacterBangumiRelationSkeletonGrid();

  /// 构建关联角色骨架网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      primary: false,
      padding: EdgeInsets.zero,
      gridDelegate: _CharacterBangumiRelationGridMetrics.delegate,
      itemCount: _characterBangumiRelatedPageSize,
      itemBuilder: (context, index) {
        return const _CharacterBangumiRelationSkeletonItem();
      },
    );
  }
}

/// 关联角色骨架条目
class _CharacterBangumiRelationSkeletonItem extends StatelessWidget {
  /// 创建关联角色骨架条目
  const _CharacterBangumiRelationSkeletonItem();

  /// 构建关联角色骨架条目
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Skeletonizer.zone(
        child: SizedBox(
          width: 104,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Bone(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Bone(
                      width: 52,
                      height: 12,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  SizedBox(width: 4),
                  Bone(
                    width: 28,
                    height: 15,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Bone(
                width: 38,
                height: 10,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 关联角色网格尺寸
final class _CharacterBangumiRelationGridMetrics {
  /// 禁止创建关联角色网格尺寸实例
  const _CharacterBangumiRelationGridMetrics._();

  /// 关联角色网格代理
  static const SliverGridDelegateWithMaxCrossAxisExtent delegate =
      SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 118,
    mainAxisExtent: 116,
    mainAxisSpacing: 14,
    crossAxisSpacing: 10,
  );
}
