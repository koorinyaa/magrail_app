import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/features/chara/tower/model/tower_entry.dart';
import 'package:magrail_app/features/chara/tower/repository/tower_repository.dart';

/// 通天塔控制器
class TowerController extends ChangeNotifier {
  /// 创建通天塔控制器
  ///
  /// [repository] 通天塔仓库
  TowerController({
    required TowerRepository repository,
  }) : _repository = repository;

  static const Duration _autoRefreshInterval = Duration(minutes: 10);
  static const Duration _retryRefreshInterval = Duration(minutes: 1);

  final TowerRepository _repository;

  List<TowerEntry>? _entries;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isLoadFailed = false;
  bool _isDisposed = false;
  Timer? _autoRefreshTimer;

  /// 当前通天塔条目
  List<TowerEntry>? get entries => _entries;

  /// 是否正在首次加载
  bool get isLoading => _isLoading;

  /// 是否正在刷新
  bool get isRefreshing => _isRefreshing;

  /// 是否加载失败
  bool get isLoadFailed => _isLoadFailed;

  /// 初始化通天塔控制器
  void initialize() {
    load(showSkeleton: true);
  }

  /// 加载通天塔条目
  ///
  /// [showSkeleton] 是否显示首次加载骨架
  Future<void> load({
    required bool showSkeleton,
  }) async {
    if (_isDisposed || _isLoading || _isRefreshing) {
      return;
    }

    if (showSkeleton) {
      _isLoading = true;
    } else {
      _isRefreshing = true;
    }
    _notifyIfActive();

    try {
      final items = await _repository.fetchTowerItems();
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
          .toList(growable: false)
        ..sort((a, b) => a.rank.compareTo(b.rank));

      if (_isDisposed) {
        return;
      }

      _entries = entries;
      _isLoadFailed = false;
      _scheduleAutoRefresh(success: true);
    } catch (_) {
      if (_isDisposed) {
        return;
      }

      _entries ??= const <TowerEntry>[];
      _isLoadFailed = true;
      _scheduleAutoRefresh(success: false);
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _isRefreshing = false;
        _notifyIfActive();
      }
    }
  }

  /// 刷新通天塔条目
  Future<void> refresh() async {
    if (_isDisposed || _isLoading || _isRefreshing) {
      return;
    }

    await load(showSkeleton: _entries == null);
  }

  /// 释放通天塔控制器
  @override
  void dispose() {
    _isDisposed = true;
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  /// 安排自动刷新
  ///
  /// [success] 上次刷新是否成功
  void _scheduleAutoRefresh({
    required bool success,
  }) {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer(
      success ? _autoRefreshInterval : _retryRefreshInterval,
      refresh,
    );
  }

  /// 通知仍挂载的监听者
  void _notifyIfActive() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
