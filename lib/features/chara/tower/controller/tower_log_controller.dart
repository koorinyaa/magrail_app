import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/chara/tower/model/tower_log_api_item.dart';
import 'package:magrail_app/features/chara/tower/repository/tower_log_realtime_client.dart';
import 'package:magrail_app/features/chara/tower/repository/tower_repository.dart';

/// 通天塔日志控制器
class TowerLogController extends ChangeNotifier {
  /// 创建通天塔日志控制器
  ///
  /// [repository] 通天塔仓库
  /// [pageSize] 每页日志数量
  TowerLogController({
    required TowerRepository repository,
    this.pageSize = 30,
  }) : _repository = repository {
    _realtimeClient = TowerLogRealtimeClient(onLog: receiveRealtimeLog);
  }

  // 实时日志最多直接合并 60 条，第 61 条起只提示刷新
  static const int _realtimeMergeLimit = 60;

  // 单次加载更多最多扫描 3 个服务端页，避免重复数据导致连续请求过多
  static const int _maxLoadMoreScanPages = 3;

  // 服务端分页缓存只作为扫描来源，不直接等同于最终展示列表
  final TowerRepository _repository;
  late final TowerLogRealtimeClient _realtimeClient;
  final Map<int, TinygrailPage<TowerLogApiItem>> _pages =
      <int, TinygrailPage<TowerLogApiItem>>{};

  // 展示列表拆成历史分页数据和实时增量数据，避免 SignalR 污染服务端分页
  final List<TowerLogApiItem> _historyItems = <TowerLogApiItem>[];
  final List<TowerLogApiItem> _realtimeItems = <TowerLogApiItem>[];

  // 实时日志 ID 包含已提示但未展示的日志，用于统计待刷新数量
  final Set<int> _realtimeIds = <int>{};

  // 分页加载状态和错误按服务端页码记录，支持首次加载和加载更多分别展示
  final Set<int> _loadingPages = <int>{};
  final Map<int, Object> _pageErrors = <int, Object>{};

  // 历史分页游标独立于缓存最大页码，避免已缓存页导致加载更多跳页
  int _nextHistoryPage = 1;
  int? _totalPages;

  // 大量实时更新时只累计数量，保留已展示的前 60 条实时日志
  int _pendingRealtimeCount = 0;
  bool _isLoadingMore = false;
  bool _hasLargeRealtimeUpdate = false;
  int? _lastPreloadHistoryItemCount;

  bool _disposed = false;

  /// 每页日志数量
  final int pageSize;

  /// 触发下一页预加载的历史日志条目阈值
  int get itemPreloadThreshold {
    return (pageSize / 2).ceil();
  }

  /// 是否存在大量实时更新
  bool get hasLargeRealtimeUpdate => _hasLargeRealtimeUpdate;

  /// 实时更新日志数量
  int get realtimeUpdateCount {
    if (_hasLargeRealtimeUpdate) {
      return _pendingRealtimeCount;
    }

    return _realtimeItems.length;
  }

  /// 已展示的实时日志条目
  List<TowerLogApiItem> get realtimeItems {
    return List<TowerLogApiItem>.unmodifiable(_realtimeItems);
  }

  /// 已展示的历史日志条目
  List<TowerLogApiItem> get historyItems {
    return List<TowerLogApiItem>.unmodifiable(_historyItems);
  }

  /// 是否处于首次加载状态
  bool get isInitialLoading {
    return _historyItems.isEmpty && _loadingPages.contains(1);
  }

  /// 是否正在加载任意页
  bool get isLoading => _loadingPages.isNotEmpty || _isLoadingMore;

  /// 是否正在加载更多
  bool get isLoadingMore => _isLoadingMore;

  /// 是否还能继续加载
  bool get canLoadMore {
    if (_hasLargeRealtimeUpdate) {
      return false;
    }

    final totalPages = _totalPages;
    if (totalPages == null) {
      return _pages.isEmpty || _pageErrors.isEmpty;
    }

    return _nextHistoryPage <= totalPages;
  }

  /// 首次加载错误
  Object? get initialError {
    return _historyItems.isEmpty ? _pageErrors[1] : null;
  }

  /// 加载更多错误
  Object? get loadMoreError {
    if (_historyItems.isEmpty) {
      return null;
    }

    return _pageErrors[_nextHistoryPage];
  }

  /// 初始化通天塔日志数据
  Future<void> initialize() async {
    if (_disposed) {
      return;
    }

    await loadPage(1);
    if (!_disposed) {
      await _realtimeClient.start();
    }
  }

  /// 接收实时通天塔日志
  ///
  /// [item] SignalR 推送的日志条目
  void receiveRealtimeLog(TowerLogApiItem item) {
    if (_disposed) {
      return;
    }

    if (_containsVisibleLog(item.id) || _realtimeIds.contains(item.id)) {
      return;
    }

    _realtimeIds.add(item.id);

    if (_hasLargeRealtimeUpdate) {
      // 大量更新状态下不继续插入列表，只更新顶部刷新提示数量
      _pendingRealtimeCount = _realtimeIds.length;
      _notifySafely();
      return;
    }

    if (_realtimeIds.length > _realtimeMergeLimit) {
      // 超过直接合并上限后保留已展示日志，后续交给用户刷新重建分页
      _hasLargeRealtimeUpdate = true;
      _pendingRealtimeCount = _realtimeIds.length;
      _notifySafely();
      return;
    }

    _realtimeItems.insert(0, item);
    _notifySafely();
  }

  /// 刷新到最新日志
  Future<void> refreshLatest() async {
    if (_disposed || isLoading) {
      return;
    }

    _nextHistoryPage = 1;
    _totalPages = null;
    _pendingRealtimeCount = 0;
    _hasLargeRealtimeUpdate = false;
    _lastPreloadHistoryItemCount = null;
    _pages.clear();
    _historyItems.clear();
    _realtimeItems.clear();
    _realtimeIds.clear();
    _pageErrors.clear();
    _notifySafely();

    await loadPage(1, force: true);
    if (!_disposed) {
      // 刷新后重试实时连接，兼容首次 SignalR 握手失败
      unawaited(_realtimeClient.start());
    }
  }

  /// 加载指定页
  ///
  /// [page] 目标页码
  /// [force] 是否忽略已缓存数据重新请求
  Future<void> loadPage(
    int page, {
    bool force = false,
  }) async {
    if (_disposed) {
      return;
    }

    final response = await _loadPage(
      page,
      force: force,
      reportError: true,
    );

    if (_disposed || response == null) {
      return;
    }

    if (page == 1 && (force || _historyItems.isEmpty)) {
      _historyItems
        ..clear()
        ..addAll(response.items);
      _nextHistoryPage = 2;
      _lastPreloadHistoryItemCount = null;
      _notifySafely();
      return;
    }

    _appendHistoryItems(response.items);
    if (page >= _nextHistoryPage) {
      _nextHistoryPage = page + 1;
    }
  }

  /// 执行指定页加载
  ///
  /// [page] 目标页码
  /// [force] 是否忽略已缓存数据重新请求
  /// [reportError] 是否记录加载错误
  Future<TinygrailPage<TowerLogApiItem>?> _loadPage(
    int page, {
    required bool force,
    required bool reportError,
  }) async {
    if (_disposed || page <= 0) {
      return null;
    }

    if (_totalPages != null && page > _totalPages!) {
      return null;
    }

    if (!force && _pages.containsKey(page)) {
      return _pages[page];
    }

    if (_loadingPages.contains(page)) {
      return null;
    }

    _loadingPages.add(page);
    _pageErrors.remove(page);
    _notifySafely();

    try {
      final response = await _repository.fetchTowerLogPage(
        page: page,
        pageSize: pageSize,
      );
      if (_disposed) {
        return null;
      }

      _pages[page] = response;
      _totalPages = response.totalPages;
      _pageErrors.remove(page);
      return response;
    } catch (error) {
      if (_disposed) {
        return null;
      }

      if (reportError) {
        _pageErrors[page] = error;
      }
      return null;
    } finally {
      if (!_disposed) {
        _loadingPages.remove(page);
        _notifySafely();
      }
    }
  }

  /// 加载下一页日志
  Future<void> loadNextPage() async {
    if (_disposed || _isLoadingMore || !canLoadMore) {
      return;
    }

    _isLoadingMore = true;
    _notifySafely();

    var scannedPages = 0;
    var appendedItems = 0;

    try {
      // 实时日志会推移服务端分页边界，加载更多时按页扫描并只追加未展示日志
      while (appendedItems < pageSize &&
          scannedPages < _maxLoadMoreScanPages &&
          canLoadMore) {
        final page = _nextHistoryPage;
        final response = await _loadPage(
          page,
          force: false,
          reportError: true,
        );

        if (_disposed || response == null) {
          break;
        }

        scannedPages += 1;
        _nextHistoryPage = page + 1;

        final unseenItems = response.items
            .where((item) => !_containsVisibleLog(item.id))
            .toList(growable: false);
        final remainingItems = pageSize - appendedItems;
        final acceptedItems = unseenItems.take(remainingItems).toList();
        if (acceptedItems.isNotEmpty) {
          _historyItems.addAll(acceptedItems);
          appendedItems += acceptedItems.length;
          _notifySafely();
        }

        if (response.items.isEmpty) {
          break;
        }
      }
    } finally {
      if (!_disposed) {
        _isLoadingMore = false;
        _notifySafely();
      }
    }
  }

  /// 处理历史日志条目构建触发的分页预加载
  ///
  /// [index] 当前构建的历史日志下标
  void handleHistoryItemBuilt(int index) {
    final itemCount = _historyItems.length;
    if (_disposed ||
        itemCount == 0 ||
        _lastPreloadHistoryItemCount == itemCount) {
      return;
    }

    final maxIndex = itemCount - 1;
    final triggerIndex =
        (maxIndex - itemPreloadThreshold).clamp(0, maxIndex).toInt();
    if (index < triggerIndex) {
      return;
    }

    if (isLoading || !canLoadMore) {
      return;
    }

    _lastPreloadHistoryItemCount = itemCount;
    unawaited(loadNextPage());
  }

  /// 释放通天塔日志控制器
  @override
  void dispose() {
    _disposed = true;
    unawaited(_realtimeClient.stop());
    super.dispose();
  }

  /// 追加历史日志条目
  ///
  /// [items] 服务端返回的日志条目
  void _appendHistoryItems(List<TowerLogApiItem> items) {
    final unseenItems = items.where((item) => !_containsVisibleLog(item.id));
    final beforeLength = _historyItems.length;
    _historyItems.addAll(unseenItems);
    if (_historyItems.length != beforeLength) {
      _notifySafely();
    }
  }

  /// 判断日志是否已经展示
  ///
  /// [id] 日志 ID
  bool _containsVisibleLog(int id) {
    return _historyItems.any((item) => item.id == id) ||
        _realtimeItems.any((item) => item.id == id);
  }

  /// 在控制器可用时派发刷新
  void _notifySafely() {
    if (_disposed) {
      return;
    }

    notifyListeners();
  }
}
