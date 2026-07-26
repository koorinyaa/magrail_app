import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/user/assets/model/user_asset_level_layout.dart';
import 'package:magrail_app/features/user/assets/model/user_temple_snapshot_query.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_repository.dart';
import 'package:magrail_app/features/user/controller/user_asset_sparse_page_cache.dart';

part 'user_temple_snapshot_page_controller_refresh.dart';
part 'user_temple_snapshot_page_controller_level.dart';
part 'user_temple_snapshot_page_controller_query.dart';

/// 用户圣殿快照二级页面控制器
class UserTempleSnapshotPageController extends TinygrailPagedListController<
    UserTempleSnapshotEntry, UserTempleSnapshotEntry> {
  /// 创建用户圣殿快照二级页面控制器
  ///
  /// [snapshotRepository] 用户资产快照仓库
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [onAutomaticRefreshSucceeded] 后台刷新成功回调
  /// [onAutomaticRefreshFailed] 后台刷新失败回调
  /// [readVisibleTempleIndex] 读取当前可视圣殿下标，等级排序使用绝对下标
  /// [waitForScrollIdle] 等待列表滚动结束
  /// [onBeforeTempleDataReplaced] 圣殿分页替换前的滚动位置校正回调
  /// [onRestoreTempleLevelAnchor] 等级刷新后的圣殿位置恢复回调
  /// [automaticRefreshEnabled] 首屏缓存展示后是否自动刷新
  /// [initialAbsoluteIndex] 首屏优先读取的圣殿绝对下标
  /// [pageSize] 每页圣殿数量
  UserTempleSnapshotPageController({
    required UserAssetSnapshotRepository snapshotRepository,
    required String username,
    required String nickname,
    required VoidCallback onAutomaticRefreshSucceeded,
    required VoidCallback onAutomaticRefreshFailed,
    required int? Function() readVisibleTempleIndex,
    required Future<void> Function() waitForScrollIdle,
    required void Function(
      int previousItemIndex,
      int replacementItemIndex,
      List<UserTempleSnapshotEntry> items,
    ) onBeforeTempleDataReplaced,
    required void Function(int absoluteIndex) onRestoreTempleLevelAnchor,
    bool automaticRefreshEnabled = true,
    int initialAbsoluteIndex = 0,
    super.pageSize = defaultPageSize,
  })  : _snapshotRepository = snapshotRepository,
        _username = username.trim(),
        _nickname = nickname.trim(),
        _onAutomaticRefreshSucceeded = onAutomaticRefreshSucceeded,
        _onAutomaticRefreshFailed = onAutomaticRefreshFailed,
        _readVisibleTempleIndex = readVisibleTempleIndex,
        _waitForScrollIdle = waitForScrollIdle,
        _onBeforeTempleDataReplaced = onBeforeTempleDataReplaced,
        _onRestoreTempleLevelAnchor = onRestoreTempleLevelAnchor,
        _automaticRefreshEnabled = automaticRefreshEnabled,
        _initialAbsoluteIndex =
            initialAbsoluteIndex < 0 ? 0 : initialAbsoluteIndex;

  /// 用户圣殿快照本地分页数量
  static const int defaultPageSize = 50;

  final UserAssetSnapshotRepository _snapshotRepository;
  final String _username;
  final String _nickname;
  final VoidCallback _onAutomaticRefreshSucceeded;
  final VoidCallback _onAutomaticRefreshFailed;
  final int? Function() _readVisibleTempleIndex;
  final Future<void> Function() _waitForScrollIdle;
  final void Function(
    int previousItemIndex,
    int replacementItemIndex,
    List<UserTempleSnapshotEntry> items,
  ) _onBeforeTempleDataReplaced;
  final void Function(int absoluteIndex) _onRestoreTempleLevelAnchor;
  final bool _automaticRefreshEnabled;
  final int _initialAbsoluteIndex;

  bool _isDisposed = false;
  bool _isPageBlockingRefresh = false;
  // 新快照写入后暂停普通分页，直到页面窗口提交同一版本
  bool _isRefreshSnapshotPending = false;
  bool _isChangingQuery = false;
  bool _initialPageRequested = false;
  bool _shouldLoadNextPageAfterRefreshPause = false;
  bool _suppressAutomaticRefreshFailure = false;
  Future<TinygrailPage<UserTempleSnapshotEntry>>? _initialPageOperation;
  Future<bool>? _templeRefreshOperation;
  Future<bool>? _automaticRefreshOperation;
  Future<bool>? _queryChangeOperation;
  Future<int>? _prependPageOperation;
  UserTempleSnapshotSort _sort = UserTempleSnapshotSort.assets;
  UserTempleSnapshotSortDirection _direction =
      UserTempleSnapshotSortDirection.descending;
  UserTempleSnapshotSort _committedSort = UserTempleSnapshotSort.assets;
  UserTempleSnapshotSortDirection _committedDirection =
      UserTempleSnapshotSortDirection.descending;
  String _searchKeyword = '';
  String _committedSearchKeyword = '';
  List<UserTempleLevelPosition> _levelPositions = const [];
  List<UserTempleLevelPosition> _committedLevelPositions = const [];
  // 等级目录版本用于确保快速跳转下标与目标分页来自同一快照
  int? _levelIndexRevision;
  int? _committedLevelIndexRevision;
  final UserAssetSparsePageCache<UserTempleSnapshotEntry> _levelPageCache =
      UserAssetSparsePageCache<UserTempleSnapshotEntry>(
    pageSize: defaultPageSize,
  );
  int _levelLayoutVersion = 0;
  // 可视分页版本用于判断哈希一致时页面是否仍需同步
  int? _windowRevision;
  int _windowFirstPage = 1;
  int _queryGeneration = 0;

  /// 当前排序字段
  UserTempleSnapshotSort get sort => _sort;

  /// 当前排序方向
  UserTempleSnapshotSortDirection get direction => _direction;

  /// 当前角色 ID 或名称筛选词
  String get searchKeyword => _searchKeyword;

  /// 当前角色等级快速跳转位置
  List<UserTempleLevelPosition> get levelPositions => _levelPositions;

  /// 等级排序虚拟布局分组
  List<UserAssetLevelGroup> get levelGroups => [
        for (final position in _levelPositions)
          UserAssetLevelGroup(
            level: position.level,
            absoluteIndex: position.absoluteIndex,
            itemCount: position.itemCount,
          ),
      ];

  /// 等级排序虚拟布局版本
  int get levelLayoutVersion => _levelLayoutVersion;

  /// 等级排序条目总数
  int get levelItemCount => _levelPageCache.totalItems;

  /// 是否使用等级虚拟网格
  bool get usesVirtualLevelGrid =>
      _sort == UserTempleSnapshotSort.characterLevel;

  /// 当前页面使用的圣殿快照版本
  int? get templeSnapshotRevision => _windowRevision;

  /// 是否可以向前加载相邻页
  bool get canLoadPreviousPage =>
      !_isChangingQuery &&
      !_isPageBlockingRefresh &&
      !_isRefreshSnapshotPending &&
      _windowFirstPage > 1;

  /// 首屏无可用数据或新快照待提交时暂停下一页请求
  @override
  bool get isNextPageLoadPaused =>
      _isPageBlockingRefresh || _isRefreshSnapshotPending || _isChangingQuery;

  /// 首屏无可用数据时显示底部分页加载状态
  @override
  bool get showPausedLoadMoreIndicator => _isPageBlockingRefresh;

  /// 切换排序或筛选时显示原有首屏骨架
  @override
  bool get forceInitialLoading => _isChangingQuery;

  /// 校验用户圣殿快照分页请求
  @override
  Object? validatePageRequest() {
    if (_username.isEmpty) {
      return StateError('用户名不能为空');
    }
    return null;
  }

  /// 读取用户圣殿本地分页
  ///
  /// [page] 页码
  /// [pageSize] 每页圣殿数量
  @override
  Future<TinygrailPage<UserTempleSnapshotEntry>> requestPage({
    required int page,
    required int pageSize,
  }) {
    if (page == 1 && !_initialPageRequested) {
      _initialPageRequested = true;
      late final Future<TinygrailPage<UserTempleSnapshotEntry>> operation;
      operation = _loadInitialPage(pageSize).whenComplete(() {
        if (identical(_initialPageOperation, operation)) {
          _initialPageOperation = null;
        }
      });
      _initialPageOperation = operation;
      return operation;
    }
    return _readRequiredPage(page: page, pageSize: pageSize);
  }

  /// 向当前窗口前方加载相邻页
  ///
  /// [beforeItemsPrepended] 相邻页提交前的滚动位置校正回调
  Future<int> loadPreviousPage({
    void Function(List<UserTempleSnapshotEntry> items)? beforeItemsPrepended,
  }) {
    final existing = _prependPageOperation;
    if (existing != null) {
      return existing;
    }
    if (!canLoadPreviousPage) {
      return Future.value(0);
    }
    final targetPage = _windowFirstPage - 1;
    late final Future<int> operation;
    operation = prependPage(
      targetPage,
      beforeCommit: beforeItemsPrepended,
    ).then((count) {
      if (count > 0 && !_isDisposed) {
        _windowFirstPage = targetPage;
      }
      return count;
    }).whenComplete(() {
      if (identical(_prependPageOperation, operation)) {
        _prependPageOperation = null;
      }
    });
    _prependPageOperation = operation;
    return operation;
  }

  /// 刷新用户圣殿并替换当前分页窗口
  @override
  Future<bool> refresh() async {
    final initialOperation = _initialPageOperation;
    if (initialOperation != null) {
      try {
        await initialOperation;
        return !_isDisposed;
      } catch (_) {
        // 首屏失败后继续执行手动刷新作为重试
      }
    }
    if (_isDisposed) {
      return false;
    }
    final automaticOperation = _automaticRefreshOperation;
    if (automaticOperation != null) {
      _suppressAutomaticRefreshFailure = true;
      return automaticOperation;
    }
    return _startOrJoinTempleRefresh(blockPageLoading: items.isEmpty);
  }

  /// 记录刷新暂停期间触发的预加载位置
  ///
  /// [index] 当前构建的展示条目下标
  @override
  void handleItemBuilt(int index) {
    if (!_isPageBlockingRefresh && !_isRefreshSnapshotPending) {
      super.handleItemBuilt(index);
      return;
    }
    final itemCount = items.length;
    if (itemCount == 0) {
      return;
    }
    final maxIndex = itemCount - 1;
    final triggerIndex =
        (maxIndex - itemPreloadThreshold).clamp(0, maxIndex).toInt();
    if (index >= triggerIndex) {
      _shouldLoadNextPageAfterRefreshPause = true;
    }
  }

  /// 释放用户圣殿快照控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 使用最新查询替换当前可视分页窗口
  ///
  /// [expectedRevision] 刷新完成时确认的圣殿快照版本
  Future<bool> _replaceWithLatestTempleWindow({
    required int expectedRevision,
  }) async {
    var replacementRevision = expectedRevision;
    while (!_isDisposed) {
      await waitForPagingIdle();
      final prependPageOperation = _prependPageOperation;
      if (prependPageOperation != null) {
        await prependPageOperation;
      }
      if (_isDisposed) {
        return false;
      }
      final generation = _queryGeneration;
      final replacementSort = _sort;
      final replacementDirection = _direction;
      final replacementSearchKeyword = _searchKeyword;
      final targetRevision = replacementRevision;
      late final TinygrailPage<UserTempleSnapshotEntry> replacementCountPage;
      try {
        replacementCountPage = await _readRequiredPage(
          page: 1,
          pageSize: 1,
          expectedRevision: targetRevision,
        );
      } on StateError {
        final latestRevision =
            (await _snapshotRepository.readSourceState(_username))
                ?.revisions
                .temples;
        if (latestRevision != null && latestRevision != targetRevision) {
          replacementRevision = latestRevision;
          continue;
        }
        rethrow;
      }
      final replacementLevelIndex =
          replacementSort == UserTempleSnapshotSort.characterLevel
              ? await _snapshotRepository.readTempleLevelIndex(
                  username: _username,
                  direction: replacementDirection,
                  searchKeyword: replacementSearchKeyword,
                )
              : null;
      if (replacementLevelIndex != null &&
          replacementLevelIndex.revision != targetRevision) {
        replacementRevision = replacementLevelIndex.revision;
        continue;
      }
      await waitForPagingIdle();
      final latestPrependPageOperation = _prependPageOperation;
      if (latestPrependPageOperation != null) {
        await latestPrependPageOperation;
      }
      if (_isDisposed) {
        return false;
      }
      if (generation != _queryGeneration ||
          replacementSort != _sort ||
          replacementDirection != _direction ||
          replacementSearchKeyword != _searchKeyword) {
        continue;
      }
      await _waitForScrollIdle();
      if (_isDisposed) {
        return false;
      }
      if (generation != _queryGeneration ||
          replacementSort != _sort ||
          replacementDirection != _direction ||
          replacementSearchKeyword != _searchKeyword) {
        continue;
      }
      final anchorItemIndex = _readVisibleTempleIndex();
      final isVirtualLevelGrid =
          replacementSort == UserTempleSnapshotSort.characterLevel;
      final previousAnchorEntry = isVirtualLevelGrid && anchorItemIndex != null
          ? levelItemAt(anchorItemIndex)
          : null;
      final previousAnchorLevel = previousAnchorEntry?.item.level ??
          (isVirtualLevelGrid ? _levelAtAbsoluteIndex(anchorItemIndex) : null);
      final visibleAbsoluteIndex = isVirtualLevelGrid
          ? anchorItemIndex ?? 0
          : anchorItemIndex == null
              ? (_windowFirstPage - 1) * pageSize
              : (_windowFirstPage - 1) * pageSize + anchorItemIndex;
      var anchorAbsoluteIndex = replacementCountPage.totalItems <= 0
          ? 0
          : visibleAbsoluteIndex
              .clamp(0, replacementCountPage.totalItems - 1)
              .toInt();
      if (isVirtualLevelGrid && replacementCountPage.totalItems > 0) {
        final persistedAnchorIndex = previousAnchorEntry == null
            ? null
            : await _snapshotRepository.readTempleLevelAbsoluteIndex(
                username: _username,
                templeId: previousAnchorEntry.item.id,
                direction: replacementDirection,
                searchKeyword: replacementSearchKeyword,
                expectedRevision: targetRevision,
              );
        anchorAbsoluteIndex = persistedAnchorIndex ??
            _fallbackLevelAbsoluteIndex(
              replacementLevelIndex?.positions ??
                  const <UserTempleLevelPosition>[],
              previousLevel: previousAnchorLevel,
              previousAbsoluteIndex: visibleAbsoluteIndex,
              totalItems: replacementCountPage.totalItems,
            );
      }
      final anchorPage = anchorAbsoluteIndex ~/ pageSize + 1;
      final firstPage =
          (anchorPage - _refreshAdjacentPageCount).clamp(1, anchorPage).toInt();
      final lastPage = anchorPage + _refreshAdjacentPageCount;
      final followingPageCount = lastPage - firstPage;
      final success = await replaceFromPage(
        firstPage,
        followingPageCount: followingPageCount,
        shouldCommit: () =>
            !_isDisposed &&
            generation == _queryGeneration &&
            replacementSort == _sort &&
            replacementDirection == _direction &&
            replacementSearchKeyword == _searchKeyword,
        beforeCommit: anchorItemIndex == null || isVirtualLevelGrid
            ? null
            : (replacementItems) => _onBeforeTempleDataReplaced(
                  anchorItemIndex,
                  anchorAbsoluteIndex - (firstPage - 1) * pageSize,
                  replacementItems,
                ),
        pageLoader: ({required page, required pageSize}) => _readRequiredPage(
          page: page,
          pageSize: pageSize,
          expectedRevision: targetRevision,
        ),
      );
      if (_isDisposed) {
        return false;
      }
      if (!success) {
        final queryChanged = generation != _queryGeneration ||
            replacementSort != _sort ||
            replacementDirection != _direction ||
            replacementSearchKeyword != _searchKeyword;
        if (queryChanged) {
          continue;
        }
        final latestRevision =
            (await _snapshotRepository.readSourceState(_username))
                ?.revisions
                .temples;
        if (latestRevision != null && latestRevision != targetRevision) {
          replacementRevision = latestRevision;
          continue;
        }
        return false;
      }
      _levelPositions =
          replacementLevelIndex?.positions ?? const <UserTempleLevelPosition>[];
      _levelIndexRevision = replacementLevelIndex?.revision;
      _windowFirstPage = firstPage;
      _windowRevision = targetRevision;
      _commitLevelPageCache();
      _committedSort = _sort;
      _committedDirection = _direction;
      _committedSearchKeyword = _searchKeyword;
      _committedLevelPositions = _levelPositions;
      _committedLevelIndexRevision = _levelIndexRevision;
      notifyListeners();
      if (isVirtualLevelGrid && replacementCountPage.totalItems > 0) {
        _onRestoreTempleLevelAnchor(anchorAbsoluteIndex);
      }
      return true;
    }
    return false;
  }

  /// 通知页面刷新状态变化
  void _notifyRefreshStateChanged() => notifyListeners();

  /// 等待当前分页读写结束
  Future<void> _waitForPagingToSettle() => waitForPagingIdle();

  /// 使用当前查询从第一页替换圣殿窗口
  ///
  /// [shouldCommit] 提交前的查询代次校验
  Future<bool> _replaceQueryFromFirstPage({
    required bool Function() shouldCommit,
  }) {
    return replaceFromPage(1, shouldCommit: shouldCommit);
  }

  /// 转换用户圣殿展示条目
  ///
  /// [items] 本地圣殿条目
  @override
  List<UserTempleSnapshotEntry> convertPageItems(
    List<UserTempleSnapshotEntry> items,
  ) =>
      items;
}
