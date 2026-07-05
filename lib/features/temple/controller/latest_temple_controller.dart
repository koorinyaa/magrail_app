import 'package:flutter/foundation.dart';
import 'package:magrail_app/features/temple/model/temple_api_item.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';

/// 最新圣殿控制器
class LatestTempleController extends ChangeNotifier {
  /// 创建最新圣殿控制器
  ///
  /// [repository] 圣殿仓库
  /// [pageSize] 每页圣殿数量
  LatestTempleController({
    required TempleRepository repository,
    this.pageSize = 12,
  }) : _repository = repository;

  final TempleRepository _repository;

  List<TempleApiItem>? _items;
  bool _isLoading = false;
  bool _isLoadFailed = false;
  bool _isDisposed = false;

  /// 每页圣殿数量
  final int pageSize;

  /// 当前最新圣殿条目
  List<TempleApiItem>? get items => _items;

  /// 是否正在首次加载
  bool get isLoading => _isLoading;

  /// 是否加载失败
  bool get isLoadFailed => _isLoadFailed;

  /// 初始化最新圣殿控制器
  void initialize() {
    load(showSkeleton: true);
  }

  /// 加载最新圣殿条目
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
      final page = await _repository.fetchLatestTemplePage(
        pageSize: pageSize,
      );
      if (_isDisposed) {
        return;
      }

      _items = page.items;
      _isLoadFailed = false;
    } catch (_) {
      if (_isDisposed) {
        return;
      }

      _items ??= const <TempleApiItem>[];
      _isLoadFailed = true;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _notifyIfActive();
      }
    }
  }

  /// 刷新最新圣殿条目
  Future<void> refresh() async {
    if (_isDisposed || _isLoading) {
      return;
    }

    await load(showSkeleton: _items == null);
  }

  /// 释放最新圣殿控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 通知仍挂载的监听者
  void _notifyIfActive() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
