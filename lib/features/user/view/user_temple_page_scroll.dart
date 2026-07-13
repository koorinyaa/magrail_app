part of 'user_temple_page.dart';

/// 用户圣殿二级页面滚动交互
extension _UserTemplePageScroll on _UserTemplePageState {
  /// 跳转到指定角色等级
  ///
  /// [level] 目标角色等级
  Future<void> _jumpToLevel(int level) async {
    final generation = ++_levelJumpGeneration;
    _scrollAdjustmentGeneration += 1;
    _isLoadingPreviousPage = false;
    _isProgrammaticLevelJump = true;
    bool success;
    try {
      success = await _currentUserController?.jumpToLevel(
            level,
            beforeItemsReplaced: (itemIndex, entries) {
              if (!mounted ||
                  generation != _levelJumpGeneration ||
                  !_scrollController.hasClients) {
                return;
              }
              final metrics = _resolveGridMetrics();
              final items = [for (final entry in entries) entry.item];
              final position = _scrollController.position;
              // 先停止旧网格滚动，再静默校正像素使目标等级首帧到位
              _scrollController.jumpTo(position.pixels);
              position.correctPixels(
                UserTempleResponsiveGrid.levelGroupOffsetForItem(
                  items,
                  itemIndex,
                  metrics,
                ),
              );
            },
          ) ??
          false;
    } catch (_) {
      if (mounted && generation == _levelJumpGeneration) {
        _isProgrammaticLevelJump = false;
        AppToast.error(context, text: '等级跳转失败，请重试');
      }
      return;
    }
    if (!mounted || generation != _levelJumpGeneration) {
      return;
    }
    if (!success) {
      _isProgrammaticLevelJump = false;
      AppToast.error(context, text: '等级跳转失败，请重试');
      return;
    }
    _isProgrammaticLevelJump = false;
  }

  /// 读取当前视口顶部圣殿在本地分页窗口中的下标
  int? _readVisibleTempleIndex() {
    final controller = _currentUserController;
    if (!mounted ||
        controller == null ||
        !_scrollController.hasClients ||
        controller.items.isEmpty) {
      return null;
    }
    final items = [for (final entry in controller.items) entry.item];
    return UserTempleResponsiveGrid.itemIndexAtContentOffset(
      items,
      _scrollController.offset.clamp(0.0, double.infinity).toDouble(),
      _resolveGridMetrics(),
      showLevelHeaders:
          controller.sort == UserTempleSnapshotSort.characterLevel,
    );
  }

  /// 等待圣殿网格拖动和惯性滚动结束
  Future<void> _waitForScrollIdle() {
    if (!_scrollController.hasClients) {
      return Future<void>.value();
    }
    final scrollingNotifier = _scrollController.position.isScrollingNotifier;
    if (!scrollingNotifier.value) {
      return Future<void>.value();
    }
    final existingCompleter = _scrollIdleCompleter;
    if (existingCompleter != null) {
      return existingCompleter.future;
    }
    final completer = Completer<void>();
    late final VoidCallback listener;
    listener = () {
      if (scrollingNotifier.value) {
        return;
      }
      scrollingNotifier.removeListener(listener);
      _scrollIdleListener = null;
      _scrollIdleNotifier = null;
      _scrollIdleCompleter = null;
      if (!completer.isCompleted) {
        completer.complete();
      }
    };
    _scrollIdleCompleter = completer;
    _scrollIdleListener = listener;
    _scrollIdleNotifier = scrollingNotifier;
    scrollingNotifier.addListener(listener);
    listener();
    return completer.future;
  }

  /// 在分页替换前恢复当前圣殿位置
  ///
  /// [previousItemIndex] 旧分页窗口中的可视条目下标
  /// [replacementItemIndex] 新分页窗口中的目标条目下标
  /// [replacementEntries] 即将提交的圣殿条目
  void _restoreVisibleTemplePosition(
    int previousItemIndex,
    int replacementItemIndex,
    List<UserTempleSnapshotEntry> replacementEntries,
  ) {
    final controller = _currentUserController;
    if (!mounted ||
        controller == null ||
        !_scrollController.hasClients ||
        controller.items.isEmpty ||
        replacementEntries.isEmpty) {
      return;
    }
    _scrollAdjustmentGeneration += 1;
    _isLoadingPreviousPage = true;
    try {
      final currentItemIndex = _readVisibleTempleIndex() ?? previousItemIndex;
      final replacementIndexOffset = replacementItemIndex - previousItemIndex;
      final oldIndex =
          currentItemIndex.clamp(0, controller.items.length - 1).toInt();
      final newIndex = (currentItemIndex + replacementIndexOffset)
          .clamp(0, replacementEntries.length - 1)
          .toInt();
      final showLevelHeaders =
          controller.sort == UserTempleSnapshotSort.characterLevel;
      final metrics = _resolveGridMetrics();
      final oldItems = [for (final entry in controller.items) entry.item];
      final replacementItems = [
        for (final entry in replacementEntries) entry.item,
      ];
      final oldItemOffset = UserTempleResponsiveGrid.itemOffsetForIndex(
        oldItems,
        oldIndex,
        metrics,
        showLevelHeaders: showLevelHeaders,
      );
      final newItemOffset = UserTempleResponsiveGrid.itemOffsetForIndex(
        replacementItems,
        newIndex,
        metrics,
        showLevelHeaders: showLevelHeaders,
      );
      final position = _scrollController.position;
      final correctedPixels = (position.pixels + newItemOffset - oldItemOffset)
          .clamp(position.minScrollExtent, double.infinity)
          .toDouble();
      _scrollController.jumpTo(position.pixels);
      position.correctPixels(correctedPixels);
    } finally {
      _isLoadingPreviousPage = false;
    }
  }

  /// 监听网格顶部并按需加载目标页前一页
  void _handleScroll() {
    final controller = _currentUserController;
    if (controller == null ||
        _isProgrammaticLevelJump ||
        _isLoadingPreviousPage ||
        !_scrollController.hasClients ||
        _scrollController.offset > _resolveGridMetrics().cardHeight / 2 ||
        !controller.canLoadPreviousPage) {
      return;
    }
    _isLoadingPreviousPage = true;
    unawaited(_loadPreviousPage(controller));
  }

  /// 加载目标窗口前一页并保持当前圣殿位置
  ///
  /// [controller] 当前用户圣殿控制器
  Future<void> _loadPreviousPage(
    CurrentUserTemplePageController controller,
  ) async {
    final showLevelHeaders =
        controller.sort == UserTempleSnapshotSort.characterLevel;
    final previousItems = [for (final entry in controller.items) entry.item];
    final adjustmentGeneration = _scrollAdjustmentGeneration;
    late final int count;
    try {
      count = await controller.loadPreviousPage(
        beforeItemsPrepended: (entries) {
          if (!mounted ||
              adjustmentGeneration != _scrollAdjustmentGeneration ||
              !_scrollController.hasClients) {
            return;
          }
          final metrics = _resolveGridMetrics();
          final previousExtent = UserTempleResponsiveGrid.contentExtent(
            previousItems,
            metrics,
            showLevelHeaders: showLevelHeaders,
          );
          final currentItems = [for (final entry in entries) entry.item];
          final currentExtent = UserTempleResponsiveGrid.contentExtent(
            currentItems,
            metrics,
            showLevelHeaders: showLevelHeaders,
          );
          final position = _scrollController.position;
          // 在分页状态提交前校正像素，避免先闪现前一页再滚回锚点
          _scrollController.jumpTo(position.pixels);
          position.correctPixels(
            position.pixels + currentExtent - previousExtent,
          );
        },
      );
    } catch (_) {
      _isLoadingPreviousPage = false;
      if (mounted) {
        AppToast.error(context, text: '加载上一页失败，请重试');
      }
      return;
    }
    if (!mounted || count <= 0) {
      _isLoadingPreviousPage = false;
      return;
    }
    if (adjustmentGeneration == _scrollAdjustmentGeneration) {
      _isLoadingPreviousPage = false;
    }
  }

  /// 在布局更新后回到圣殿网格顶部
  void _scrollToTopAfterLayout() {
    final adjustmentGeneration = _scrollAdjustmentGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          adjustmentGeneration == _scrollAdjustmentGeneration &&
          _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  /// 解析当前页面的圣殿网格布局参数
  UserTempleGridMetrics _resolveGridMetrics() {
    final controller = _currentUserController;
    return UserTempleResponsiveGrid.resolveMetrics(
      MediaQuery.sizeOf(context).width,
      AppSafeAreaInsets.horizontalSum(context),
      showSortValue:
          controller != null && _sortShowsSupplementalValue(controller.sort),
      rightContentInset:
          controller?.sort == UserTempleSnapshotSort.characterLevel
              ? UserTempleResponsiveGrid.levelRailReservedWidth
              : 0,
    );
  }

  /// 判断当前排序是否显示卡片补充数据
  ///
  /// [sort] 当前圣殿排序字段
  bool _sortShowsSupplementalValue(UserTempleSnapshotSort sort) {
    return sort == UserTempleSnapshotSort.singleDividend ||
        sort == UserTempleSnapshotSort.totalDividend ||
        sort == UserTempleSnapshotSort.starForces ||
        sort == UserTempleSnapshotSort.create;
  }
}
