part of 'character_detail_bangumi_related_sheet.dart';

/// 角色出演作品抽屉
class _CharacterBangumiCastsSheet extends StatefulWidget {
  /// 创建角色出演作品抽屉
  ///
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  const _CharacterBangumiCastsSheet({
    required this.characterId,
    required this.characterName,
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 创建角色出演作品抽屉状态
  @override
  State<_CharacterBangumiCastsSheet> createState() =>
      _CharacterBangumiCastsSheetState();
}

/// 角色出演作品抽屉状态
class _CharacterBangumiCastsSheetState
    extends State<_CharacterBangumiCastsSheet> {
  late final NextBangumiRepository _repository;

  List<NextBangumiCharacterCastItem> _items =
      const <NextBangumiCharacterCastItem>[];
  var _isInitialLoading = true;
  var _initialError = '';
  var _isLoadingMore = false;
  var _loadMoreError = '';
  var _canLoadMore = false;
  var _nextOffset = 0;
  var _requestId = 0;
  int? _lastPreloadItemCount;

  /// 初始化角色出演作品抽屉状态
  @override
  void initState() {
    super.initState();
    _repository = NextBangumiRepository();
    unawaited(_loadCasts(reset: true));
  }

  /// 释放角色出演作品抽屉状态
  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }

  /// 构建角色出演作品抽屉
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _CharacterBangumiRelatedSheetSurface(
      title: '出演作品',
      subtitle: _characterBangumiRelatedSubtitle(
        widget.characterId,
        widget.characterName,
      ),
      icon: LucideIcons.film,
      child: _buildContent(context),
    );
  }

  /// 构建出演作品内容
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
      return const _CharacterBangumiCastSkeletonList();
    }

    if (_initialError.isNotEmpty) {
      return AppLoadFailedState(
        message: _initialError,
        onActionPressed: () => _loadCasts(reset: true),
      );
    }

    if (_items.isEmpty) {
      return const _CharacterBangumiRelatedEmptyState(
        title: '暂无出演作品',
        description: '当前角色没有可展示的出演作品',
      );
    }

    return ListView.separated(
      primary: false,
      padding: EdgeInsets.zero,
      itemCount: _items.length + 1,
      separatorBuilder: (context, index) {
        if (index >= _items.length - 1) {
          return const SizedBox.shrink();
        }

        return const _CharacterBangumiCastDivider();
      },
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return PaginationFooter(
            isLoadingMore: _isLoadingMore,
            hasLoadMoreError: _loadMoreError.isNotEmpty,
            canLoadMore: _canLoadMore,
            completedLabel: '没有更多作品了',
            onRetry: _retryNextPage,
          );
        }

        final item = _items[index];
        _handleItemBuilt(index);
        return NextBangumiSubjectSearchRow(
          item: item.subject,
          thirdLineTags: switch (item.type) {
            1 => const ['主角'],
            2 => const ['配角'],
            3 => const ['客串'],
            _ => const [],
          },
          onTap: () => openNextBangumiSubject(
            context,
            subjectId: item.subject.subjectId,
          ),
        );
      },
    );
  }

  /// 加载出演作品
  ///
  /// [reset] 是否重新加载第一页
  Future<void> _loadCasts({required bool reset}) async {
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
        _items = const <NextBangumiCharacterCastItem>[];
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
      final page = await _repository.fetchCharacterCasts(
        widget.characterId,
        limit: _characterBangumiRelatedPageSize,
        offset: requestedOffset,
      );
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        if (reset) {
          _items = page.items;
          _isInitialLoading = false;
        } else {
          _items = <NextBangumiCharacterCastItem>[..._items, ...page.items];
          _isLoadingMore = false;
        }
        _syncPagination(
          requestedOffset: requestedOffset,
          total: page.total,
          rawItemCount: page.rawItemCount,
        );
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        final message = resolveUserErrorMessage(
          error,
          fallback: '获取出演作品失败',
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

  /// 重试下一页出演作品
  Future<void> _retryNextPage() async {
    if (_loadMoreError.isNotEmpty) {
      setState(() {
        _loadMoreError = '';
      });
    }

    await _loadCasts(reset: false);
  }

  /// 重置出演作品分页状态
  void _resetPagination() {
    _nextOffset = 0;
    _canLoadMore = false;
    _isLoadingMore = false;
    _loadMoreError = '';
    _lastPreloadItemCount = null;
  }

  /// 同步出演作品分页状态
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

  /// 处理出演作品构建触发的预加载
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

      unawaited(_loadCasts(reset: false));
    });
  }

  /// 当前是否允许加载下一页出演作品
  bool get _canLoadNextPage {
    return _canLoadMore &&
        !_isInitialLoading &&
        !_isLoadingMore &&
        _loadMoreError.isEmpty;
  }
}

/// 出演作品骨架列表
class _CharacterBangumiCastSkeletonList extends StatelessWidget {
  /// 创建出演作品骨架列表
  const _CharacterBangumiCastSkeletonList();

  /// 构建出演作品骨架列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      padding: EdgeInsets.zero,
      itemCount: 19,
      itemBuilder: (context, index) {
        if (index.isOdd) {
          return const _CharacterBangumiCastDivider();
        }

        return const Skeletonizer(
          enabled: true,
          child: _CharacterBangumiCastSkeletonRow(),
        );
      },
    );
  }
}

/// 出演作品条目分割线
class _CharacterBangumiCastDivider extends StatelessWidget {
  /// 创建出演作品条目分割线
  const _CharacterBangumiCastDivider();

  /// 构建出演作品条目分割线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 52, right: 4),
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: colorScheme.outlineVariant.withValues(alpha: 0.52),
      ),
    );
  }
}

/// 出演作品骨架行
class _CharacterBangumiCastSkeletonRow extends StatelessWidget {
  /// 创建出演作品骨架行
  const _CharacterBangumiCastSkeletonRow();

  /// 构建出演作品骨架行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 4),
          Bone(
            width: 42,
            height: 60,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Bone(
                  width: 132,
                  height: 13,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                SizedBox(height: 8),
                Bone(
                  width: double.infinity,
                  height: 11,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                SizedBox(height: 5),
                Bone(
                  width: 168,
                  height: 11,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Bone(
            width: 44,
            height: 14,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          SizedBox(width: 4),
        ],
      ),
    );
  }
}
