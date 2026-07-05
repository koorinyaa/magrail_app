import 'package:flutter/foundation.dart';
import 'package:magrail_app/features/temple/model/latest_link_api_item.dart';
import 'package:magrail_app/features/temple/model/latest_link_pair.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';

/// 最新连接控制器
class LatestLinkController extends ChangeNotifier {
  /// 创建最新连接控制器
  ///
  /// [repository] 圣殿仓库
  /// [displayLimit] 首页展示连接组数量
  /// [requestGroupCount] 接口请求连接组数量
  LatestLinkController({
    required TempleRepository repository,
    this.displayLimit = 6,
    this.requestGroupCount = 8,
  }) : _repository = repository;

  final TempleRepository _repository;

  List<LatestLinkPair>? _pairs;
  bool _isLoading = false;
  bool _isLoadFailed = false;
  bool _isDisposed = false;

  /// 首页展示连接组数量
  final int displayLimit;

  /// 接口请求连接组数量
  final int requestGroupCount;

  /// 当前最新连接展示组
  List<LatestLinkPair>? get pairs => _pairs;

  /// 是否正在首次加载
  bool get isLoading => _isLoading;

  /// 是否加载失败
  bool get isLoadFailed => _isLoadFailed;

  /// 初始化最新连接控制器
  void initialize() {
    load(showSkeleton: true);
  }

  /// 加载最新连接展示组
  ///
  /// [showSkeleton] 是否显示首次加载骨架
  Future<void> load({
    required bool showSkeleton,
  }) async {
    if (_isDisposed || _isLoading) {
      return;
    }

    if (showSkeleton) {
      _isLoading = true;
      _notifyIfActive();
    }

    try {
      final page = await _repository.fetchLatestLinkPage(
        pageSize: requestGroupCount * 2,
      );
      if (_isDisposed) {
        return;
      }

      _pairs = _buildValidPairs(page.items);
      _isLoadFailed = false;
    } catch (_) {
      if (_isDisposed) {
        return;
      }

      _pairs ??= const <LatestLinkPair>[];
      _isLoadFailed = true;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _notifyIfActive();
      }
    }
  }

  /// 刷新最新连接展示组
  Future<void> refresh() async {
    if (_isDisposed || _isLoading) {
      return;
    }

    await load(showSkeleton: _pairs == null);
  }

  /// 释放最新连接控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 构建有效连接展示组
  ///
  /// [items] 接口返回的原始圣殿条目
  List<LatestLinkPair> _buildValidPairs(List<LatestLinkApiItem> items) {
    return LatestLinkPair.collectValidPairs(items, limit: displayLimit);
  }

  /// 通知仍挂载的监听者
  void _notifyIfActive() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
