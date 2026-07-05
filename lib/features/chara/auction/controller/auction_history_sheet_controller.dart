import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/features/chara/auction/model/auction_history_api_item.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';

/// 角色往期拍卖底部抽屉控制器
class AuctionHistorySheetController extends ChangeNotifier {
  /// 创建角色往期拍卖底部抽屉控制器
  ///
  /// [repository] 拍卖仓库
  /// [characterId] 角色 ID
  AuctionHistorySheetController({
    required AuctionRepository repository,
    required int characterId,
  })  : _repository = repository,
        _characterId = characterId;

  final AuctionRepository _repository;
  final int _characterId;
  final _pageItems = <int, List<AuctionHistoryApiItem>>{};
  final _pageErrors = <int, String>{};
  final _loadingPages = <int>{};
  var _currentPage = 1;
  var _isDisposed = false;

  /// 当前页拍卖记录
  List<AuctionHistoryApiItem> get items => itemsAt(_currentPage);

  /// 当前页码
  int get currentPage => _currentPage;

  /// 当前页是否正在加载
  bool get isLoading => isPageLoading(_currentPage);

  /// 当前页加载失败文案
  String? get loadError => pageErrorAt(_currentPage);

  /// 当前页竞拍成功人数
  int get successCount {
    return items.where((item) => item.isSuccess).length;
  }

  /// 当前页竞拍成功股数
  int get successAmount {
    return items.fold<int>(
      0,
      (total, item) => item.isSuccess ? total + item.amount : total,
    );
  }

  /// 初始化往期拍卖数据
  Future<void> initialize() async {
    await loadPage(1);
    if (_isDisposed) {
      return;
    }

    if (hasPage(1)) {
      await preloadNextPage(1);
    }
  }

  /// 读取指定页拍卖记录
  ///
  /// [page] 目标页码
  List<AuctionHistoryApiItem> itemsAt(int page) {
    return _pageItems[page] ?? const <AuctionHistoryApiItem>[];
  }

  /// 判断指定页是否正在加载
  ///
  /// [page] 目标页码
  bool isPageLoading(int page) {
    return _loadingPages.contains(page);
  }

  /// 判断指定页是否已有加载结果
  ///
  /// [page] 目标页码
  bool hasPage(int page) {
    return _pageItems.containsKey(page);
  }

  /// 读取指定页加载失败文案
  ///
  /// [page] 目标页码
  String? pageErrorAt(int page) {
    return _pageErrors[page];
  }

  /// 切换当前页
  ///
  /// [page] 目标页码
  Future<void> setCurrentPage(int page) async {
    if (_isDisposed || page <= 0) {
      return;
    }

    if (_currentPage != page) {
      _currentPage = page;
      _notifyIfActive();
    }

    await ensurePage(page);
    if (_isDisposed) {
      return;
    }

    if (hasPage(page)) {
      await preloadNextPage(page);
    }
  }

  /// 确保指定页已开始加载
  ///
  /// [page] 目标页码
  Future<void> ensurePage(int page) {
    if (_pageItems.containsKey(page) || _loadingPages.contains(page)) {
      return Future<void>.value();
    }

    return loadPage(page);
  }

  /// 加载指定页码
  ///
  /// [page] 目标页码
  Future<void> loadPage(int page) {
    return _loadPage(
      page,
      reportError: true,
    );
  }

  /// 预加载下一页拍卖记录
  ///
  /// [page] 当前页码
  Future<void> preloadNextPage(int page) {
    return _loadPage(
      page + 1,
      reportError: false,
    );
  }

  /// 执行指定页码加载
  ///
  /// [page] 目标页码
  /// [reportError] 是否记录加载失败文案
  Future<void> _loadPage(
    int page, {
    required bool reportError,
  }) async {
    if (_loadingPages.contains(page) || page <= 0) {
      return;
    }

    if (_pageItems.containsKey(page)) {
      return;
    }

    _loadingPages.add(page);
    _pageErrors.remove(page);
    _notifyIfActive();

    try {
      final items = await _repository.fetchAuctionHistory(
        characterId: _characterId,
        page: page,
      );
      if (_isDisposed) {
        return;
      }

      _pageItems[page] = List<AuctionHistoryApiItem>.unmodifiable(items);
      _pageErrors.remove(page);
    } catch (error) {
      if (_isDisposed) {
        return;
      }

      if (reportError) {
        _pageErrors[page] = _resolveErrorText(error);
      }
    } finally {
      _loadingPages.remove(page);
      _notifyIfActive();
    }
  }

  /// 释放角色往期拍卖底部抽屉控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 解析加载失败文案
  ///
  /// [error] 异常对象
  String _resolveErrorText(Object error) {
    return resolveUserErrorMessage(error, fallback: '获取往期拍卖失败');
  }

  /// 通知仍处于活动状态的监听者
  void _notifyIfActive() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
