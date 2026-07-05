import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/chara/top_week/model/top_week_history_api_item.dart';
import 'package:magrail_app/features/chara/top_week/repository/top_week_repository.dart';

/// 往期萌王分页控制器
class TopWeekHistoryController extends ChangeNotifier {
  /// 创建往期萌王分页控制器
  ///
  /// [repository] 每周萌王仓库
  TopWeekHistoryController({
    required TopWeekRepository repository,
  }) : _repository = repository;

  final TopWeekRepository _repository;
  final Map<int, TinygrailPage<TopWeekHistoryApiItem>> _pages =
      <int, TinygrailPage<TopWeekHistoryApiItem>>{};
  final Set<int> _loadingPages = <int>{};
  final Map<int, Object> _pageErrors = <int, Object>{};

  int _currentPage = 1;
  int? _totalPages;
  bool _disposed = false;

  /// 当前页码
  int get currentPage => _currentPage;

  /// 总页数
  int? get totalPages => _totalPages;

  /// PageView 可用页数
  int get pageCount => _totalPages ?? 1;

  /// 是否处于首次加载状态
  bool get isInitialLoading => _pages.isEmpty && _loadingPages.contains(1);

  /// 初始化往期萌王数据
  Future<void> initialize() async {
    if (_disposed) {
      return;
    }

    await loadPage(1);
    if (_disposed) {
      return;
    }

    await preloadNextPage(1);
  }

  /// 读取指定页数据
  ///
  /// [page] 目标页码
  TinygrailPage<TopWeekHistoryApiItem>? pageAt(int page) => _pages[page];

  /// 判断指定页是否正在加载
  ///
  /// [page] 目标页码
  bool isPageLoading(int page) => _loadingPages.contains(page);

  /// 读取指定页错误
  ///
  /// [page] 目标页码
  Object? pageErrorAt(int page) => _pageErrors[page];

  /// 更新当前页并触发下一页预加载
  ///
  /// [page] 当前显示页码
  Future<void> setCurrentPage(int page) async {
    if (_disposed) {
      return;
    }

    if (_currentPage != page) {
      _currentPage = page;
      _notifySafely();
    }

    await ensurePageReady(page);
    if (_disposed) {
      return;
    }

    await preloadNextPage(page);
  }

  /// 确保目标页数据可用
  ///
  /// [page] 目标页码
  Future<void> ensurePageReady(int page) async {
    if (_disposed) {
      return;
    }

    if (_pages.containsKey(page) || _loadingPages.contains(page)) {
      return;
    }

    await loadPage(page);
  }

  /// 加载指定页
  ///
  /// [page] 目标页码
  /// [force] 是否忽略已缓存数据重新请求
  Future<void> loadPage(
    int page, {
    bool force = false,
  }) async {
    await _loadPage(
      page,
      force: force,
      reportError: true,
    );
  }

  /// 执行指定页加载
  ///
  /// [page] 目标页码
  /// [force] 是否忽略已缓存数据重新请求
  /// [reportError] 是否记录加载错误
  Future<void> _loadPage(
    int page, {
    required bool force,
    required bool reportError,
  }) async {
    if (_disposed || page <= 0) {
      return;
    }

    if (_totalPages != null && page > _totalPages!) {
      return;
    }

    if (!force && (_pages.containsKey(page) || _loadingPages.contains(page))) {
      return;
    }

    _loadingPages.add(page);
    _pageErrors.remove(page);
    _notifySafely();

    try {
      final response = await _repository.fetchTopWeekHistory(page: page);
      if (_disposed) {
        return;
      }

      _pages[page] = response;
      _totalPages = response.totalPages;
      _pageErrors.remove(page);
    } catch (error) {
      if (_disposed) {
        return;
      }

      if (reportError) {
        _pageErrors[page] = error;
      }
    } finally {
      if (!_disposed) {
        _loadingPages.remove(page);
        _notifySafely();
      }
    }
  }

  /// 预加载下一页
  ///
  /// [page] 当前页码
  Future<void> preloadNextPage(int page) async {
    if (_disposed) {
      return;
    }

    final nextPage = page + 1;
    if (_totalPages != null && nextPage > _totalPages!) {
      return;
    }

    await _loadPage(
      nextPage,
      force: false,
      reportError: false,
    );
  }

  /// 释放往期萌王分页控制器
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// 在控制器可用时派发刷新
  void _notifySafely() {
    if (_disposed) {
      return;
    }

    notifyListeners();
  }
}
