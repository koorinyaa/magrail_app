part of 'user_temple_page.dart';

// 顶部 1px 内视为浮点滚动误差，避免快照切换后残留微小偏移
const double _templeSnapshotTopTolerance = 1;

/// 用户圣殿二级页快照切换
extension _UserTemplePageSnapshot on _UserTemplePageState {
  /// 准备圣殿快照模式
  Future<void> _prepareSnapshotMode() async {
    final fresh = await widget.snapshotCoordinator.isFresh(
      username: widget.username,
      isCurrentUser: _isCurrentUser,
      kind: UserAssetSnapshotKind.temples,
    );
    if (!mounted || _snapshotController != null) {
      return;
    }
    if (fresh) {
      try {
        if (await _activateSnapshotMode()) {
          return;
        }
      } catch (_) {
        // 新鲜标记与实际快照不一致时继续请求完整数据修复本地状态
      }
      if (!mounted) {
        return;
      }
    }

    _isAwaitingSnapshot = true;
    final success = await widget.snapshotCoordinator.ensureForSecondaryPage(
      username: widget.username,
      nickname: widget.nickname ?? '',
      isCurrentUser: _isCurrentUser,
      kind: UserAssetSnapshotKind.temples,
      totalItemsHint: widget.templeTotalItems,
    );
    if (!mounted || !_isAwaitingSnapshot) {
      return;
    }
    _isAwaitingSnapshot = false;
    if (!success) {
      _showAutomaticRefreshFailed();
      return;
    }
    var activated = false;
    try {
      activated = await _activateSnapshotMode();
    } catch (_) {
      // 刷新成功但本地读取失败时按最终激活失败提示
    }
    if (!mounted) {
      return;
    }
    if (!activated) {
      _showAutomaticRefreshFailed();
    }
  }

  /// 处理全局圣殿快照任务结果
  void _handleSnapshotCoordinatorChanged() {
    final event = widget.snapshotCoordinator.lastEvent;
    final controller = _snapshotController;
    if (!mounted ||
        event == null ||
        event.kind != UserAssetSnapshotKind.temples ||
        event.isCurrentUser != _isCurrentUser ||
        event.username.trim().toLowerCase() !=
            widget.username.trim().toLowerCase() ||
        _isAwaitingSnapshot) {
      return;
    }
    // 首次快照等待流程自行提示结果，避免协调事件重复弹出
    if (event.success) {
      if (controller != null) {
        unawaited(controller.reloadLatestSnapshot());
      }
    } else {
      _showAutomaticRefreshFailed();
    }
  }

  /// 将普通后端分页切换为本地圣殿快照
  Future<bool> _activateSnapshotMode() async {
    if (!mounted || _snapshotController != null) {
      return _snapshotController != null;
    }
    await _waitForScrollIdle();
    if (!mounted) {
      return false;
    }

    final backendController = _otherUserController;
    final backendItems =
        backendController?.items ?? const <UserTempleApiItem>[];
    final oldPixels =
        _scrollController.hasClients ? _scrollController.position.pixels : 0.0;
    final oldDistanceFromTop = _scrollController.hasClients
        ? (_scrollController.position.pixels -
                _scrollController.position.minScrollExtent)
            .clamp(0.0, double.infinity)
            .toDouble()
        : 0.0;
    final oldIndex = _readBackendVisibleTempleIndex(backendItems);
    final oldItem = oldIndex == null || backendItems.isEmpty
        ? null
        : backendItems[oldIndex.clamp(0, backendItems.length - 1).toInt()];
    final oldItemOffset = oldIndex == null
        ? 0.0
        : UserTempleResponsiveGrid.itemOffsetForIndex(
            backendItems,
            oldIndex,
            _resolveGridMetrics(),
          );
    final repository = widget.snapshotCoordinator.repositoryFor(
      isCurrentUser: _isCurrentUser,
    );
    final absoluteIndex = oldItem == null
        ? 0
        : await repository.readTempleDefaultAbsoluteIndex(
              username: widget.username,
              templeId: oldItem.id,
            ) ??
            0;
    if (!mounted) {
      return false;
    }

    final controller = UserTempleSnapshotPageController(
      snapshotRepository: repository,
      username: widget.username,
      nickname: widget.nickname ?? '',
      onAutomaticRefreshFailed: _showAutomaticRefreshFailed,
      readVisibleTempleIndex: _readVisibleTempleIndex,
      waitForScrollIdle: _waitForScrollIdle,
      onBeforeTempleDataReplaced: _restoreVisibleTemplePosition,
      onRestoreTempleLevelAnchor: _restoreTempleLevelAnchor,
      automaticRefreshEnabled: false,
      initialAbsoluteIndex: absoluteIndex,
    );
    final loaded = await _initializeSnapshotController(controller);
    if (!mounted || !loaded) {
      controller.dispose();
      return false;
    }

    _snapshotController = controller;
    _rebuildAfterSnapshotActivation();
    _restoreAfterSnapshotActivation(
      controller: controller,
      templeId: oldItem?.id,
      oldPixels: oldPixels,
      oldDistanceFromTop: oldDistanceFromTop,
      oldItemOffset: oldItemOffset,
      fallbackAbsoluteIndex: absoluteIndex,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      backendController?.dispose();
    });
    _otherUserController = null;
    return true;
  }

  /// 等待圣殿快照控制器完成首次本地查询
  ///
  /// [controller] 待初始化的圣殿快照控制器
  Future<bool> _initializeSnapshotController(
    UserTempleSnapshotPageController controller,
  ) {
    final completer = Completer<bool>();
    late final VoidCallback listener;
    listener = () {
      if (controller.isInitialLoading) {
        return;
      }
      if (controller.items.isEmpty &&
          controller.initialError == null &&
          controller.canLoadMore) {
        return;
      }
      controller.removeListener(listener);
      if (!completer.isCompleted) {
        completer.complete(controller.initialError == null);
      }
    };
    controller.addListener(listener);
    controller.initialize();
    return completer.future;
  }

  /// 读取普通分页中当前可见圣殿下标
  ///
  /// [items] 当前普通分页圣殿
  int? _readBackendVisibleTempleIndex(List<UserTempleApiItem> items) {
    if (!_scrollController.hasClients || items.isEmpty) {
      return null;
    }
    return UserTempleResponsiveGrid.itemIndexAtContentOffset(
      items,
      _scrollController.offset.clamp(0.0, double.infinity).toDouble(),
      _resolveGridMetrics(),
    );
  }

  /// 在快照模式首帧恢复原圣殿的视觉位置
  ///
  /// [controller] 新圣殿快照控制器
  /// [templeId] 切换前的可见圣殿 ID
  /// [oldPixels] 切换前滚动像素
  /// [oldDistanceFromTop] 切换前距离滚动顶部的像素
  /// [oldItemOffset] 切换前圣殿内容偏移
  /// [fallbackAbsoluteIndex] 原圣殿在快照中的绝对下标
  void _restoreAfterSnapshotActivation({
    required UserTempleSnapshotPageController controller,
    required int? templeId,
    required double oldPixels,
    required double oldDistanceFromTop,
    required double oldItemOffset,
    required int fallbackAbsoluteIndex,
  }) {
    final adjustmentGeneration = ++_scrollAdjustmentGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          adjustmentGeneration != _scrollAdjustmentGeneration ||
          !_scrollController.hasClients ||
          controller.items.isEmpty) {
        return;
      }
      var newIndex = templeId == null
          ? -1
          : controller.items.indexWhere((entry) => entry.item.id == templeId);
      if (newIndex < 0) {
        newIndex = (fallbackAbsoluteIndex % controller.pageSize)
            .clamp(0, controller.items.length - 1)
            .toInt();
      }
      final newItems = [for (final entry in controller.items) entry.item];
      final newItemOffset = UserTempleResponsiveGrid.itemOffsetForIndex(
        newItems,
        newIndex,
        _resolveGridMetrics(),
      );
      final position = _scrollController.position;
      final double correctedPixels;
      if (oldDistanceFromTop <= _templeSnapshotTopTolerance) {
        correctedPixels = position.minScrollExtent;
      } else if (oldDistanceFromTop < UserTempleResponsiveGrid.topPadding) {
        correctedPixels = (position.minScrollExtent + oldDistanceFromTop)
            .clamp(position.minScrollExtent, position.maxScrollExtent)
            .toDouble();
      } else {
        correctedPixels = (oldPixels + newItemOffset - oldItemOffset)
            .clamp(position.minScrollExtent, position.maxScrollExtent)
            .toDouble();
      }
      _scrollController.jumpTo(correctedPixels);
    });
  }
}
