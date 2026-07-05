part of 'auction_history_sheet.dart';

/// 往期拍卖标题区
class _AuctionHistoryHeader extends StatelessWidget {
  /// 创建往期拍卖标题区
  ///
  /// [characterId] 角色 ID
  /// [characterName] 角色名称
  const _AuctionHistoryHeader({
    required this.characterId,
    required this.characterName,
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 构建往期拍卖标题区
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = _displayName;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            LucideIcons.history,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '往期拍卖',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '#$characterId 「$displayName」',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 角色展示名称
  String get _displayName {
    final name = TinygrailFormatters.decodeHtmlEntities(characterName).trim();
    return name.isEmpty ? '角色' : name;
  }
}

/// 往期拍卖当前页统计
class _AuctionHistorySummary extends StatelessWidget {
  /// 创建往期拍卖当前页统计
  ///
  /// [controller] 往期拍卖控制器
  const _AuctionHistorySummary({
    required this.controller,
  });

  /// 往期拍卖控制器
  final AuctionHistorySheetController controller;

  /// 构建往期拍卖当前页统计
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = controller.items;
    final text = _summaryText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: items.isEmpty
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
    );
  }

  /// 当前页统计文案
  String get _summaryText {
    if (controller.isLoading && controller.items.isEmpty) {
      return '正在读取当前页拍卖记录';
    }

    if (controller.loadError != null && controller.items.isEmpty) {
      return '当前页拍卖记录读取失败';
    }

    if (controller.items.isEmpty) {
      return '暂无拍卖数据';
    }

    return '共有${controller.items.length}人参与拍卖，成功'
        '${controller.successCount}人 / '
        '${Formatters.groupedNumber(controller.successAmount)}股';
  }
}

/// 往期拍卖主体内容
class _AuctionHistoryBody extends StatefulWidget {
  /// 创建往期拍卖主体内容
  ///
  /// [controller] 往期拍卖控制器
  /// [currentUserId] 当前登录用户 ID
  const _AuctionHistoryBody({
    required this.controller,
    required this.currentUserId,
  });

  /// 往期拍卖控制器
  final AuctionHistorySheetController controller;

  /// 当前登录用户 ID
  final int? currentUserId;

  /// 创建往期拍卖主体内容状态
  @override
  State<_AuctionHistoryBody> createState() => _AuctionHistoryBodyState();
}

/// 往期拍卖主体内容状态
class _AuctionHistoryBodyState extends State<_AuctionHistoryBody> {
  late final PageController _pageController;

  /// 初始化往期拍卖主体内容状态
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  /// 释放往期拍卖主体内容状态
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 构建往期拍卖主体内容
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        final page = index + 1;
        unawaited(widget.controller.setCurrentPage(page));
      },
      itemBuilder: (context, index) {
        return _AuctionHistoryPageContent(
          controller: widget.controller,
          page: index + 1,
          currentUserId: widget.currentUserId,
        );
      },
    );
  }
}

/// 往期拍卖分页内容
class _AuctionHistoryPageContent extends StatefulWidget {
  /// 创建往期拍卖分页内容
  ///
  /// [controller] 往期拍卖控制器
  /// [page] 目标页码
  /// [currentUserId] 当前登录用户 ID
  const _AuctionHistoryPageContent({
    required this.controller,
    required this.page,
    required this.currentUserId,
  });

  /// 往期拍卖控制器
  final AuctionHistorySheetController controller;

  /// 目标页码
  final int page;

  /// 当前登录用户 ID
  final int? currentUserId;

  /// 创建往期拍卖分页内容状态
  @override
  State<_AuctionHistoryPageContent> createState() =>
      _AuctionHistoryPageContentState();
}

/// 往期拍卖分页内容状态
class _AuctionHistoryPageContentState
    extends State<_AuctionHistoryPageContent> {
  bool _requested = false;

  /// 依赖变更后确保当前页开始加载
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureRequested();
  }

  /// 组件更新后确保目标页开始加载
  ///
  /// [oldWidget] 更新前的分页内容组件
  @override
  void didUpdateWidget(covariant _AuctionHistoryPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) {
      _requested = false;
      _ensureRequested();
    }
  }

  /// 构建往期拍卖分页内容
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    if (widget.controller.isPageLoading(widget.page)) {
      return const _AuctionHistoryLoadingState();
    }

    final loadError = widget.controller.pageErrorAt(widget.page);
    if (loadError != null) {
      return _AuctionHistoryErrorState(
        message: loadError,
        onRetry: () => widget.controller.loadPage(widget.page),
      );
    }

    if (!widget.controller.hasPage(widget.page)) {
      _requestMissingPage();
      return const _AuctionHistoryLoadingState();
    }

    final items = widget.controller.itemsAt(widget.page);
    if (items.isEmpty) {
      return const _AuctionHistoryEmptyState();
    }

    return ListView.separated(
      primary: false,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      itemCount: items.length,
      separatorBuilder: (context, index) => const _AuctionHistoryListDivider(),
      itemBuilder: (context, index) {
        return _AuctionHistoryRow(
          item: items[index],
          currentUserId: widget.currentUserId,
        );
      },
    );
  }

  /// 确保当前分页只触发一次加载
  void _ensureRequested() {
    if (_requested) {
      return;
    }

    _requested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(widget.controller.ensurePage(widget.page));
    });
  }

  /// 重新请求没有加载结果的当前页
  void _requestMissingPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(widget.controller.ensurePage(widget.page));
    });
  }
}

/// 往期拍卖条目
class _AuctionHistoryRow extends StatelessWidget {
  /// 创建往期拍卖条目
  ///
  /// [item] 往期拍卖接口条目
  /// [currentUserId] 当前登录用户 ID
  const _AuctionHistoryRow({
    required this.item,
    required this.currentUserId,
  });

  /// 往期拍卖接口条目
  final AuctionHistoryApiItem item;

  /// 当前登录用户 ID
  final int? currentUserId;

  /// 构建往期拍卖条目
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bidderName = TinygrailFormatters.decodeHtmlEntities(
      item.nickname,
    ).trim();
    final displayName = bidderName.isEmpty ? item.username : bidderName;
    final currentUserId = this.currentUserId;
    final isCurrentUser = currentUserId != null && item.userId == currentUserId;
    final resultColor = _auctionHistoryResultColor(
      colorScheme,
      item.isSuccess,
    );
    final auctionValueText = '${Formatters.tinygrailCurrency(item.price)} / '
        '${Formatters.groupedNumber(item.amount)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  auctionValueText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: resultColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _AuctionHistoryStateChip(isSuccess: item.isSuccess),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Flexible(
                child: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isCurrentUser
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.62),
                    fontSize: 11,
                    fontWeight:
                        isCurrentUser ? FontWeight.w900 : FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                LucideIcons.clock3,
                size: 12,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.58),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  TinygrailFormatters.dateTime(item.bid),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.62),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 往期拍卖结果标签
class _AuctionHistoryStateChip extends StatelessWidget {
  /// 创建往期拍卖结果标签
  ///
  /// [isSuccess] 是否拍卖成功
  const _AuctionHistoryStateChip({
    required this.isSuccess,
  });

  /// 是否拍卖成功
  final bool isSuccess;

  /// 构建往期拍卖结果标签
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = _auctionHistoryResultColor(
      colorScheme,
      isSuccess,
    );
    final backgroundAlpha =
        colorScheme.brightness == Brightness.dark ? 0.18 : 0.11;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: foregroundColor.withValues(alpha: backgroundAlpha),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: foregroundColor.withValues(alpha: isSuccess ? 0.32 : 0.18),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          isSuccess ? '成功' : '失败',
          style: TextStyle(
            color: foregroundColor,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// 解析往期拍卖结果强调色
///
/// [colorScheme] 当前主题色板
/// [isSuccess] 是否拍卖成功
Color _auctionHistoryResultColor(
  ColorScheme colorScheme,
  bool isSuccess,
) {
  return isSuccess ? const Color(0xFF17C964) : colorScheme.onSurfaceVariant;
}

/// 往期拍卖列表分隔线
class _AuctionHistoryListDivider extends StatelessWidget {
  /// 创建往期拍卖列表分隔线
  const _AuctionHistoryListDivider();

  /// 构建往期拍卖列表分隔线
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Divider(
      height: 1,
      thickness: 0.6,
      color: colorScheme.outlineVariant.withValues(
        alpha: isDark ? 0.32 : 0.56,
      ),
    );
  }
}
