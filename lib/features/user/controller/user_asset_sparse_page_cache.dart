import 'dart:collection';

import 'package:magrail_app/core/network/tinygrail_page.dart';

/// 用户资产稀疏分页缓存
class UserAssetSparsePageCache<T> {
  /// 创建用户资产稀疏分页缓存
  ///
  /// [pageSize] 单页条目数量
  UserAssetSparsePageCache({required this.pageSize}) : assert(pageSize > 0);

  // 稀疏缓存最多保留约 500 个完整模型
  static const int _maxCachedItems = 500;

  /// 单页条目数量
  final int pageSize;

  final LinkedHashMap<int, List<T>> _pages = LinkedHashMap<int, List<T>>();
  final Map<int, Future<bool>> _pageOperations = <int, Future<bool>>{};
  int _generation = 0;
  int _totalItems = 0;

  /// 当前虚拟列表条目总数
  int get totalItems => _totalItems;

  /// 重置当前查询对应的分页缓存
  ///
  /// [totalItems] 当前查询条目总数
  /// [firstPage] 已加载窗口的起始页码
  /// [items] 已加载窗口条目
  void configure({
    required int totalItems,
    required int firstPage,
    required List<T> items,
  }) {
    _generation += 1;
    _totalItems = totalItems;
    _pages.clear();
    _pageOperations.clear();
    seedWindow(firstPage: firstPage, items: items);
  }

  /// 清除等级排序分页缓存
  void clear() {
    _generation += 1;
    _totalItems = 0;
    _pages.clear();
    _pageOperations.clear();
  }

  /// 写入连续分页窗口
  ///
  /// [firstPage] 起始页码
  /// [items] 连续分页条目
  void seedWindow({required int firstPage, required List<T> items}) {
    if (firstPage <= 0 || items.isEmpty) {
      return;
    }
    for (var offset = 0; offset < items.length; offset += pageSize) {
      final page = firstPage + offset ~/ pageSize;
      final end = (offset + pageSize).clamp(0, items.length).toInt();
      _storePage(page, items.sublist(offset, end));
    }
  }

  /// 读取指定绝对下标的缓存条目
  ///
  /// [absoluteIndex] 当前排序下的绝对条目下标
  T? itemAt(int absoluteIndex) {
    if (absoluteIndex < 0 || absoluteIndex >= _totalItems) {
      return null;
    }
    final page = absoluteIndex ~/ pageSize + 1;
    final items = _pages.remove(page);
    if (items == null) {
      return null;
    }
    _pages[page] = items;
    final localIndex = absoluteIndex % pageSize;
    return localIndex < items.length ? items[localIndex] : null;
  }

  /// 确保指定绝对下标所在分页已经加载
  ///
  /// [absoluteIndex] 当前排序下的绝对条目下标
  /// [pageLoader] 当前查询分页读取函数
  /// [onChanged] 新分页写入后的页面刷新回调
  Future<bool> ensureItem(
    int absoluteIndex, {
    required Future<TinygrailPage<T>> Function({
      required int page,
      required int pageSize,
    }) pageLoader,
    required void Function() onChanged,
  }) {
    if (absoluteIndex < 0 || absoluteIndex >= _totalItems) {
      return Future<bool>.value(false);
    }
    final page = absoluteIndex ~/ pageSize + 1;
    if (_pages.containsKey(page)) {
      itemAt(absoluteIndex);
      return Future<bool>.value(true);
    }
    final existing = _pageOperations[page];
    if (existing != null) {
      return existing;
    }
    final generation = _generation;
    late final Future<bool> operation;
    operation = pageLoader(page: page, pageSize: pageSize).then((result) {
      if (generation != _generation) {
        return false;
      }
      _storePage(page, result.items);
      onChanged();
      return true;
    }).catchError((Object _) {
      return false;
    }).whenComplete(() {
      if (identical(_pageOperations[page], operation)) {
        _pageOperations.remove(page);
      }
    });
    _pageOperations[page] = operation;
    return operation;
  }

  /// 写入单页缓存并回收远离视口的旧页
  ///
  /// [page] 页码
  /// [items] 当前页条目
  void _storePage(int page, List<T> items) {
    _pages.remove(page);
    _pages[page] = List<T>.unmodifiable(items);
    final maxCachedPages = (_maxCachedItems / pageSize).ceil();
    while (_pages.length > maxCachedPages) {
      _pages.remove(_pages.keys.first);
    }
  }
}
