import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/features/chara/tower/model/tower_entry.dart';
import 'package:magrail_app/features/chara/tower/repository/tower_repository.dart';

/// 通天塔二级榜单控制器
class TowerRankingPageController extends ChangeNotifier {
  /// 创建通天塔二级榜单控制器
  ///
  /// [repository] 通天塔仓库
  /// [pageSize] 每页角色数量
  TowerRankingPageController({
    required TowerRepository repository,
    this.pageSize = 20,
  })  : assert(pageSize > 0),
        _repository = repository {
    _nextPage = _segmentStartPage;
  }

  /// 通天塔分段排名跨度
  static const int segmentSize = 100;

  /// 通天塔分红前排边界
  static const int displayLimit = 500;

  final TowerRepository _repository;
  final Map<int, List<TowerEntry>> _pages = <int, List<TowerEntry>>{};
  final Set<int> _loadingPages = <int>{};
  final Map<int, Object> _pageErrors = <int, Object>{};

  int _selectedSegmentIndex = 0;
  late int _nextPage;
  bool _isLoadingMore = false;
  bool _isDisposed = false;

  /// 每页角色数量
  final int pageSize;

  /// 当前选中的排名分段索引
  int get selectedSegmentIndex => _selectedSegmentIndex;

  /// 排名分段数量
  int get segmentCount {
    return (displayLimit / segmentSize).ceil();
  }

  /// 当前分段起始排名
  int get selectedStartRank {
    return _selectedSegmentIndex * segmentSize + 1;
  }

  /// 当前分段结束排名
  int get selectedEndRank {
    final endRank = (_selectedSegmentIndex + 1) * segmentSize;
    return endRank > displayLimit ? displayLimit : endRank;
  }

  /// 当前分段起始页码
  int get selectedStartPage => _segmentStartPage;

  /// 当前通天塔分段条目
  List<TowerEntry> get entries {
    final entries = <TowerEntry>[];
    for (var page = _segmentStartPage; page <= _segmentEndPage; page++) {
      entries.addAll(_pages[page] ?? const <TowerEntry>[]);
    }
    entries.sort((a, b) => a.rank.compareTo(b.rank));

    return List<TowerEntry>.unmodifiable(entries);
  }

  /// 是否正在首次加载当前分段
  bool get isInitialLoading {
    return entries.isEmpty && _loadingPages.contains(_segmentStartPage);
  }

  /// 是否正在加载任意页
  bool get isLoading {
    return _loadingPages.isNotEmpty || _isLoadingMore;
  }

  /// 是否正在加载更多
  bool get isLoadingMore => _isLoadingMore;

  /// 是否还能继续加载当前分段
  bool get canLoadMore {
    return _nextPage <= _segmentEndPage;
  }

  /// 首次加载错误
  Object? get initialError {
    return entries.isEmpty ? _pageErrors[_segmentStartPage] : null;
  }

  /// 加载更多错误
  Object? get loadMoreError {
    return entries.isEmpty ? null : _pageErrors[_nextPage];
  }

  int get _maxPage {
    return (displayLimit / pageSize).ceil();
  }

  int get _segmentStartPage {
    return ((selectedStartRank - 1) ~/ pageSize) + 1;
  }

  int get _segmentEndPage {
    final page = ((selectedEndRank - 1) ~/ pageSize) + 1;
    return page > _maxPage ? _maxPage : page;
  }

  /// 初始化通天塔二级榜单
  void initialize() {
    if (_isDisposed) {
      return;
    }

    loadPage(_segmentStartPage);
  }

  /// 选择通天塔排名分段
  ///
  /// [index] 分段索引
  void selectSegment(int index) {
    if (_isDisposed) {
      return;
    }

    if (index == _selectedSegmentIndex || index < 0 || index >= segmentCount) {
      return;
    }

    _selectedSegmentIndex = index;
    _resetNextPageForSegment();
    _notifySafely();

    if (entries.isEmpty) {
      loadPage(_segmentStartPage);
    }
  }

  /// 刷新当前通天塔分段
  Future<void> refresh() async {
    if (_isDisposed || isLoading) {
      return;
    }

    for (var page = _segmentStartPage; page <= _segmentEndPage; page++) {
      _pages.remove(page);
      _pageErrors.remove(page);
    }
    _nextPage = _segmentStartPage;
    _notifySafely();

    await loadPage(_segmentStartPage, force: true);
  }

  /// 加载指定页
  ///
  /// [page] 目标页码
  /// [force] 是否忽略已加载状态重新请求
  Future<void> loadPage(
    int page, {
    bool force = false,
  }) async {
    if (_isDisposed) {
      return;
    }

    final entries = await _loadPage(
      page,
      force: force,
      reportError: true,
    );

    if (_isDisposed || entries == null) {
      return;
    }

    _pages[page] = entries;
    _advanceNextPage();
    _notifySafely();
  }

  /// 加载当前分段下一页榜单
  Future<void> loadNextPage() async {
    if (_isDisposed || _isLoadingMore || !canLoadMore) {
      return;
    }

    _isLoadingMore = true;
    _notifySafely();

    try {
      await loadPage(_nextPage);
    } finally {
      if (!_isDisposed) {
        _isLoadingMore = false;
        _notifySafely();
      }
    }
  }

  /// 释放通天塔二级榜单控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 执行指定页加载
  ///
  /// [page] 目标页码
  /// [force] 是否忽略已加载状态重新请求
  /// [reportError] 是否记录加载错误
  Future<List<TowerEntry>?> _loadPage(
    int page, {
    required bool force,
    required bool reportError,
  }) async {
    if (_isDisposed || page <= 0 || page > _maxPage) {
      return null;
    }

    if (!force && _pages.containsKey(page)) {
      return _pages[page];
    }

    if (!force && _loadingPages.contains(page)) {
      return null;
    }

    _loadingPages.add(page);
    _pageErrors.remove(page);
    _notifySafely();

    try {
      final items = await _repository.fetchTowerItems(
        page: page,
        pageSize: pageSize,
      );
      if (_isDisposed) {
        return null;
      }

      final entries = items
          .map(
            (item) => TowerEntry(
              characterId: item.characterId,
              rank: item.rank,
              name: item.name,
              level: item.level,
              zeroCount: item.zeroCount,
              stars: item.stars,
              starForces: item.starForces,
              avatarUrl: TinygrailAssetUrls.normalizeAvatar(item.icon),
            ),
          )
          .where((entry) => entry.rank > 0 && entry.rank <= displayLimit)
          .toList(growable: false)
        ..sort((a, b) => a.rank.compareTo(b.rank));

      _pageErrors.remove(page);
      return entries;
    } catch (error) {
      if (_isDisposed) {
        return null;
      }

      if (reportError) {
        _pageErrors[page] = error;
      }
      return null;
    } finally {
      if (!_isDisposed) {
        _loadingPages.remove(page);
        _notifySafely();
      }
    }
  }

  /// 重置当前分段加载游标
  void _resetNextPageForSegment() {
    _nextPage = _segmentStartPage;
    _advanceNextPage();
  }

  /// 推进当前分段加载游标
  void _advanceNextPage() {
    while (_nextPage <= _segmentEndPage && _pages.containsKey(_nextPage)) {
      _nextPage += 1;
    }
  }

  /// 在控制器可用时派发刷新
  void _notifySafely() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
