part of 'user_character_page.dart';

/// 用户角色二级页快照切换
extension _UserCharacterPageSnapshot on _UserCharacterPageState {
  /// 准备角色快照模式
  Future<void> _prepareSnapshotMode() async {
    final fresh = await widget.snapshotCoordinator.isFresh(
      username: widget.username,
      isCurrentUser: _isCurrentUser,
      kind: UserAssetSnapshotKind.characters,
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
      kind: UserAssetSnapshotKind.characters,
      totalItemsHint: widget.characterTotalItems,
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

  /// 处理全局角色快照任务结果
  void _handleSnapshotCoordinatorChanged() {
    final event = widget.snapshotCoordinator.lastEvent;
    final controller = _snapshotController;
    if (!mounted ||
        event == null ||
        event.kind != UserAssetSnapshotKind.characters ||
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

  /// 将普通后端分页切换为本地角色快照
  Future<bool> _activateSnapshotMode() async {
    if (!mounted || _snapshotController != null) {
      return _snapshotController != null;
    }
    await _waitForScrollIdle();
    if (!mounted) {
      return false;
    }

    final backendController = _backendController;
    final backendItems =
        backendController?.items ?? const <UserCharacterApiItem>[];
    final oldPixels = _scrollController.hasClients
        ? _scrollController.position.pixels
        : 0.0;
    final oldIndex = _readBackendVisibleCharacterIndex(backendItems);
    final oldItem = oldIndex == null || backendItems.isEmpty
        ? null
        : backendItems[oldIndex.clamp(0, backendItems.length - 1).toInt()];
    final oldItemOffset = oldIndex == null
        ? 0.0
        : UserCharacterAssetSliverList.itemOffsetForIndex(
            backendItems,
            oldIndex,
            showLevelHeaders: false,
          );
    final repository = widget.snapshotCoordinator.repositoryFor(
      isCurrentUser: _isCurrentUser,
    );
    final absoluteIndex = oldItem == null
        ? 0
        : await repository.readCharacterDefaultAbsoluteIndex(
                username: widget.username,
                characterId: oldItem.characterId,
              ) ??
              0;
    if (!mounted) {
      return false;
    }

    final controller = UserCharacterSnapshotPageController(
      snapshotRepository: repository,
      username: widget.username,
      nickname: widget.nickname ?? '',
      onAutomaticRefreshFailed: _showAutomaticRefreshFailed,
      readVisibleCharacterIndex: _readVisibleCharacterIndex,
      waitForScrollIdle: _waitForScrollIdle,
      onBeforeCharacterDataReplaced: _restoreVisibleCharacterPosition,
      onRestoreCharacterLevelAnchor: _restoreCharacterLevelAnchor,
      automaticRefreshEnabled: false,
      initialAbsoluteIndex: absoluteIndex,
    );
    final loaded = await _initializeSnapshotController(controller);
    if (!mounted || !loaded) {
      controller.dispose();
      return false;
    }

    _snapshotController = controller;
    _controller = controller;
    _rebuildAfterSnapshotActivation();
    _restoreAfterSnapshotActivation(
      controller: controller,
      characterId: oldItem?.characterId,
      oldPixels: oldPixels,
      oldItemOffset: oldItemOffset,
      fallbackAbsoluteIndex: absoluteIndex,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      backendController?.dispose();
    });
    _backendController = null;
    return true;
  }

  /// 等待角色快照控制器完成首次本地查询
  ///
  /// [controller] 待初始化的角色快照控制器
  Future<bool> _initializeSnapshotController(
    UserCharacterSnapshotPageController controller,
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

  /// 读取普通分页中当前可见角色下标
  ///
  /// [items] 当前普通分页角色
  int? _readBackendVisibleCharacterIndex(List<UserCharacterApiItem> items) {
    if (!_scrollController.hasClients || items.isEmpty) {
      return null;
    }
    return UserCharacterAssetSliverList.itemIndexAtListOffset(
      items,
      _scrollController.offset.clamp(0.0, double.infinity).toDouble(),
      showLevelHeaders: false,
    );
  }

  /// 在快照模式首帧恢复原角色的视觉位置
  ///
  /// [controller] 新角色快照控制器
  /// [characterId] 切换前的可见角色 ID
  /// [oldPixels] 切换前滚动像素
  /// [oldItemOffset] 切换前角色内容偏移
  /// [fallbackAbsoluteIndex] 原角色在快照中的绝对下标
  void _restoreAfterSnapshotActivation({
    required UserCharacterSnapshotPageController controller,
    required int? characterId,
    required double oldPixels,
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
      var newIndex = characterId == null
          ? -1
          : controller.items.indexWhere(
              (item) => item.characterId == characterId,
            );
      if (newIndex < 0) {
        newIndex = (fallbackAbsoluteIndex % controller.pageSize)
            .clamp(0, controller.items.length - 1)
            .toInt();
      }
      final newItemOffset = UserCharacterAssetSliverList.itemOffsetForIndex(
        controller.items,
        newIndex,
        showLevelHeaders: false,
      );
      final position = _scrollController.position;
      final correctedPixels = (oldPixels + newItemOffset - oldItemOffset)
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble();
      _scrollController.jumpTo(correctedPixels);
    });
  }
}
