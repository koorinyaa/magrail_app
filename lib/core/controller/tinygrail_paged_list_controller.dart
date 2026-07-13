import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';

/// Tinygrail 分页列表控制器
abstract class TinygrailPagedListController<ItemType, RawItemType>
    extends ChangeNotifier {
  /// 创建 Tinygrail 分页列表控制器
  ///
  /// [pageSize] 每页请求条目数量
  /// [emptyPageScanLimit] 空展示页连续扫描上限
  TinygrailPagedListController({
    required this.pageSize,
    this.emptyPageScanLimit = 1,
  })  : assert(pageSize > 0),
        assert(emptyPageScanLimit > 0) {
    _pagingController = PagingController<int, ItemType>(
      getNextPageKey: _resolveNextPageKey,
      fetchPage: _fetchPageForPagingController,
    )..addListener(_notifySafely);
  }

  late final PagingController<int, ItemType> _pagingController;

  int _nextPage = 1;
  bool _canLoadMore = true;
  bool _isRefreshing = false;
  bool _isReplacingPages = false;
  bool _isPrependingPage = false;
  bool _isDisposed = false;
  final Set<Completer<void>> _pagingIdleWaiters = <Completer<void>>{};
  // 自动预加载只针对当前已加载条目数量触发一次
  int? _lastPreloadItemCount;

  /// 每页请求条目数量
  final int pageSize;

  /// 空展示页连续扫描上限
  final int emptyPageScanLimit;

  /// 触发下一页预加载的展示条目阈值
  int get itemPreloadThreshold {
    return (pageSize / 2).ceil();
  }

  /// 当前已加载的展示条目
  List<ItemType> get items {
    return _pagingController.items ?? <ItemType>[];
  }

  /// 是否正在首次加载
  bool get isInitialLoading {
    return forceInitialLoading ||
        (_pagingController.isLoading && _pagingController.pages == null);
  }

  /// 是否正在下拉刷新
  bool get isRefreshing => _isRefreshing;

  /// 是否正在加载下一页
  bool get isLoadingMore {
    return (_pagingController.isLoading && _pagingController.pages != null) ||
        (items.isNotEmpty && showPausedLoadMoreIndicator);
  }

  /// 是否还有下一页
  bool get canLoadMore => _pagingController.hasNextPage && _canLoadMore;

  /// 是否暂停下一页请求
  @protected
  bool get isNextPageLoadPaused => false;

  /// 暂停下一页时是否显示底部加载状态
  @protected
  bool get showPausedLoadMoreIndicator => false;

  /// 是否强制显示首屏加载状态
  @protected
  bool get forceInitialLoading => false;

  /// 首次加载错误
  Object? get initialError {
    return items.isEmpty ? _pagingController.error : null;
  }

  /// 加载更多错误
  Object? get loadMoreError {
    return items.isEmpty ? null : _pagingController.error;
  }

  /// 初始化分页列表
  void initialize() {
    if (_isDisposed) {
      return;
    }

    final validationError = validatePageRequest();
    if (validationError != null) {
      _setInitialError(validationError);
      return;
    }

    if (_pagingController.pages != null || _pagingController.isLoading) {
      return;
    }

    loadNextPage();
  }

  /// 刷新分页列表
  Future<bool> refresh() async {
    if (_isDisposed || _hasActiveRequest) {
      return true;
    }

    final validationError = validatePageRequest();
    if (validationError != null) {
      _setInitialError(validationError);
      return false;
    }

    final previousState = _pagingController.value;
    final previousNextPage = _nextPage;
    final previousCanLoadMore = _canLoadMore;
    final shouldShowInitialLoading = items.isEmpty;

    _isRefreshing = !shouldShowInitialLoading;
    if (shouldShowInitialLoading) {
      _pagingController.value = PagingState<int, ItemType>(
        isLoading: true,
      );
    } else {
      _pagingController.value = previousState.copyWith(error: null);
    }
    _notifySafely();

    try {
      _resetCursor();
      _lastPreloadItemCount = null;
      final replacementItems = await _fetchDisplayPageBatch(1);
      if (_isDisposed) {
        return false;
      }

      _pagingController.value = PagingState<int, ItemType>(
        pages: <List<ItemType>>[replacementItems],
        keys: const <int>[1],
        hasNextPage: _canLoadMore,
      );
      return true;
    } catch (error) {
      _nextPage = previousNextPage;
      _canLoadMore = previousCanLoadMore;
      if (_isDisposed) {
        return false;
      }

      if (previousState.items?.isEmpty ?? true) {
        _pagingController.value = PagingState<int, ItemType>(
          error: _wrapError(error),
          hasNextPage: false,
        );
      } else {
        // 刷新失败时保留旧分页数据，只通过页面 toast 告知失败
        _pagingController.value = previousState.copyWith(error: null);
      }
      return false;
    } finally {
      if (!_isDisposed) {
        _isRefreshing = false;
        _notifySafely();
      }
    }
  }

  /// 加载下一页条目
  Future<void> loadNextPage() async {
    if (!_canRequestNextPage) {
      return;
    }

    await _fetchNextPageAndWait();
  }

  /// 等待分页控制器结束当前请求
  @protected
  Future<void> waitForPagingIdle() {
    if (_isDisposed || !_hasActiveRequest) {
      return Future.value();
    }
    final completer = Completer<void>();
    _pagingIdleWaiters.add(completer);

    void listener() {
      if (!_isDisposed && _hasActiveRequest) {
        return;
      }
      removeListener(listener);
      _pagingIdleWaiters.remove(completer);
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    addListener(listener);
    listener();
    return completer.future;
  }

  /// 从指定页面替换当前分页窗口
  ///
  /// [page] 目标页码
  /// [followingPageCount] 一并预取的后续页数
  /// [shouldCommit] 数据读取完成后是否仍应提交本次分页窗口
  /// [beforeCommit] 提交分页窗口前接收新条目的同步回调
  @protected
  Future<bool> replaceFromPage(
    int page, {
    int followingPageCount = 0,
    bool Function()? shouldCommit,
    void Function(List<ItemType> items)? beforeCommit,
  }) async {
    if (_isDisposed ||
        page <= 0 ||
        followingPageCount < 0 ||
        _hasActiveRequest) {
      return false;
    }
    final validationError = validatePageRequest();
    if (validationError != null) {
      _setInitialError(validationError);
      return false;
    }
    final previousState = _pagingController.value;
    final previousNextPage = _nextPage;
    final previousCanLoadMore = _canLoadMore;
    _isReplacingPages = true;
    _notifySafely();
    try {
      _nextPage = page;
      _canLoadMore = true;
      _lastPreloadItemCount = null;
      final replacementPages = <List<ItemType>>[];
      final replacementKeys = <int>[];
      var nextPage = page;
      for (var index = 0; index <= followingPageCount; index += 1) {
        replacementKeys.add(nextPage);
        replacementPages.add(await _fetchDisplayPageBatch(nextPage));
        if (_isDisposed || !(shouldCommit?.call() ?? true)) {
          _nextPage = previousNextPage;
          _canLoadMore = previousCanLoadMore;
          return false;
        }
        if (!_canLoadMore) {
          break;
        }
        nextPage = _nextPage;
      }
      if (beforeCommit != null) {
        beforeCommit(
          replacementPages.expand((items) => items).toList(growable: false),
        );
      }
      _pagingController.value = PagingState<int, ItemType>(
        pages: replacementPages,
        keys: replacementKeys,
        hasNextPage: _canLoadMore,
      );
      return true;
    } catch (_) {
      _nextPage = previousNextPage;
      _canLoadMore = previousCanLoadMore;
      if (!_isDisposed) {
        _pagingController.value = previousState;
      }
      return false;
    } finally {
      _isReplacingPages = false;
      _notifySafely();
    }
  }

  /// 在当前分页窗口前插入指定页面
  ///
  /// [page] 目标页码
  /// [beforeCommit] 提交分页窗口前接收合并后条目的同步回调
  @protected
  Future<int> prependPage(
    int page, {
    void Function(List<ItemType> items)? beforeCommit,
  }) async {
    if (_isDisposed || page <= 0 || _hasActiveRequest) {
      return 0;
    }
    final pages = _pagingController.pages;
    final keys = _pagingController.keys;
    if (pages == null || keys == null || pages.isEmpty) {
      return 0;
    }
    _isPrependingPage = true;
    _notifySafely();
    try {
      final result = await requestPage(page: page, pageSize: pageSize);
      if (_isDisposed) {
        return 0;
      }
      final prependedItems = convertPageItems(result.items);
      final combinedPages = <List<ItemType>>[prependedItems, ...pages];
      beforeCommit?.call(
        combinedPages.expand((items) => items).toList(growable: false),
      );
      _pagingController.value = _pagingController.value.copyWith(
        pages: combinedPages,
        keys: <int>[page, ...keys],
        error: null,
      );
      _lastPreloadItemCount = null;
      return prependedItems.length;
    } finally {
      _isPrependingPage = false;
      _notifySafely();
    }
  }

  /// 处理展示条目构建触发的分页预加载
  ///
  /// [index] 当前构建的展示条目下标
  void handleItemBuilt(int index) {
    final itemCount = items.length;
    if (itemCount == 0 || _lastPreloadItemCount == itemCount) {
      return;
    }

    final maxIndex = itemCount - 1;
    final triggerIndex =
        (maxIndex - itemPreloadThreshold).clamp(0, maxIndex).toInt();
    if (index < triggerIndex) {
      return;
    }

    if (!_canRequestNextPage) {
      return;
    }

    _lastPreloadItemCount = itemCount;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) {
        return;
      }

      unawaited(loadNextPage());
    });
  }

  /// 释放分页列表控制器
  @override
  void dispose() {
    _isDisposed = true;
    for (final waiter in _pagingIdleWaiters) {
      if (!waiter.isCompleted) {
        waiter.complete();
      }
    }
    _pagingIdleWaiters.clear();
    _pagingController
      ..removeListener(_notifySafely)
      ..dispose();
    super.dispose();
  }

  /// 校验分页请求边界
  @protected
  Object? validatePageRequest() {
    return null;
  }

  /// 请求分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页请求条目数量
  @protected
  Future<TinygrailPage<RawItemType>> requestPage({
    required int page,
    required int pageSize,
  });

  /// 转换分页原始条目
  ///
  /// [items] 接口返回原始条目
  @protected
  List<ItemType> convertPageItems(List<RawItemType> items);

  /// 是否存在正在执行的分页请求
  bool get _hasActiveRequest {
    return _pagingController.isLoading ||
        _isRefreshing ||
        _isReplacingPages ||
        _isPrependingPage;
  }

  /// 是否允许请求下一页
  bool get _canRequestNextPage {
    return !_isDisposed &&
        !_hasActiveRequest &&
        !isNextPageLoadPaused &&
        canLoadMore &&
        validatePageRequest() == null &&
        !(items.isEmpty && initialError != null);
  }

  /// 解析下一页页码
  ///
  /// [state] 当前分页状态
  int? _resolveNextPageKey(PagingState<int, ItemType> state) {
    if (!_canLoadMore || !state.hasNextPage) {
      return null;
    }

    return _nextPage;
  }

  /// 为分页库请求一页展示条目
  ///
  /// [page] 页码
  Future<List<ItemType>> _fetchPageForPagingController(int page) async {
    try {
      final items = await _fetchDisplayPageBatch(page);
      if (!_isDisposed) {
        _pagingController.value = _pagingController.value.copyWith(
          hasNextPage: _canLoadMore,
        );
      }
      return items;
    } catch (error) {
      throw _wrapError(error);
    }
  }

  /// 请求并转换一批可展示条目
  ///
  /// [page] 起始页码
  Future<List<ItemType>> _fetchDisplayPageBatch(int page) async {
    final previousNextPage = _nextPage;
    final previousCanLoadMore = _canLoadMore;
    final batchItems = <ItemType>[];
    var nextPage = page;
    var scannedPageCount = 0;

    try {
      do {
        scannedPageCount += 1;
        final result = await requestPage(
          page: nextPage,
          pageSize: pageSize,
        );
        if (_isDisposed) {
          return <ItemType>[];
        }

        batchItems.addAll(convertPageItems(result.items));
        _syncPageCursor(
          requestedPage: nextPage,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          rawItemCount: result.items.length,
        );
        nextPage = _nextPage;
        // 原始条目过滤后可能无展示内容，需要按页面配置继续寻找下一页
      } while (batchItems.isEmpty &&
          _canLoadMore &&
          scannedPageCount < emptyPageScanLimit);
    } catch (_) {
      _nextPage = previousNextPage;
      _canLoadMore = previousCanLoadMore;
      rethrow;
    }

    return batchItems;
  }

  /// 等待分页库完成下一页请求
  Future<void> _fetchNextPageAndWait() {
    final completer = Completer<void>();

    void listener() {
      if (_pagingController.isLoading) {
        return;
      }

      _pagingController.removeListener(listener);
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    _pagingController.addListener(listener);
    _pagingController.fetchNextPage();
    listener();
    return completer.future;
  }

  /// 重置分页游标
  void _resetCursor() {
    _nextPage = 1;
    _canLoadMore = true;
  }

  /// 设置首屏错误状态
  ///
  /// [error] 原始错误
  void _setInitialError(Object error) {
    _canLoadMore = false;
    _pagingController.value = PagingState<int, ItemType>(
      error: _wrapError(error),
      hasNextPage: false,
    );
    _notifySafely();
  }

  /// 同步分页游标
  ///
  /// [requestedPage] 请求页码
  /// [currentPage] 接口返回页码
  /// [totalPages] 接口返回总页数
  /// [rawItemCount] 接口返回原始条目数量
  void _syncPageCursor({
    required int requestedPage,
    required int currentPage,
    required int totalPages,
    required int rawItemCount,
  }) {
    // 接口页码异常回退时至少按请求页推进，避免空展示页扫描卡住
    final resolvedPage =
        currentPage > requestedPage ? currentPage : requestedPage;
    _nextPage = resolvedPage + 1;
    _canLoadMore = rawItemCount > 0 && resolvedPage < totalPages;
  }

  /// 包装分页错误
  ///
  /// [error] 原始错误
  TinygrailPagedListException _wrapError(Object error) {
    if (error is TinygrailPagedListException) {
      return error;
    }

    return TinygrailPagedListException(error);
  }

  /// 在控制器可用时派发刷新
  void _notifySafely() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}

/// Tinygrail 分页列表异常
class TinygrailPagedListException implements Exception {
  /// 创建 Tinygrail 分页列表异常
  ///
  /// [source] 原始错误
  const TinygrailPagedListException(this.source);

  /// 原始错误
  final Object source;

  /// 生成调试文案
  @override
  String toString() {
    return source.toString();
  }
}
