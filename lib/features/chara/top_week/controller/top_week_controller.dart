import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/features/chara/auction/model/auction_api_item.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/chara/top_week/model/top_week_entry.dart';
import 'package:magrail_app/features/chara/top_week/repository/top_week_repository.dart';

/// 每周萌王控制器
class TopWeekController extends ChangeNotifier {
  /// 创建每周萌王控制器
  ///
  /// [repository] 每周萌王仓库
  /// [auctionRepository] 拍卖仓库
  TopWeekController({
    required TopWeekRepository repository,
    required AuctionRepository auctionRepository,
  })  : _repository = repository,
        _auctionRepository = auctionRepository;

  static const Duration _statusRefreshInterval = Duration(seconds: 10);
  static const Duration _autoRefreshInterval = Duration(minutes: 10);
  static const Duration _retryRefreshInterval = Duration(minutes: 1);

  final TopWeekRepository _repository;
  final AuctionRepository _auctionRepository;

  List<TopWeekEntry>? _entries;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isLoadFailed = false;
  DateTime? _lastUpdatedAt;
  Timer? _statusTimer;
  Timer? _autoRefreshTimer;
  bool _isDisposed = false;
  int _auctionSyncSerial = 0;

  /// 当前每周萌王条目
  List<TopWeekEntry>? get entries => _entries;

  /// 是否正在首次加载
  bool get isLoading => _isLoading;

  /// 是否正在刷新
  bool get isRefreshing => _isRefreshing;

  /// 是否加载失败
  bool get isLoadFailed => _isLoadFailed;

  /// 刷新状态文案
  String get refreshLabel {
    if (_isLoading && _entries == null) {
      return '加载中';
    }

    if (_isRefreshing) {
      return '更新中';
    }

    if (_isLoadFailed) {
      return '加载失败';
    }

    final lastUpdatedAt = _lastUpdatedAt;
    if (lastUpdatedAt == null) {
      return '加载中';
    }

    final difference = DateTime.now().difference(lastUpdatedAt);
    if (difference < const Duration(minutes: 1)) {
      return '刚刚更新';
    }

    return '${difference.inMinutes}分钟前刷新';
  }

  /// 初始化每周萌王控制器
  void initialize() {
    if (_isDisposed) {
      return;
    }

    _startStatusTimer();
    unawaited(load(showSkeleton: true));
  }

  /// 加载每周萌王条目
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
    _auctionSyncSerial++;
    _notifyIfActive();

    List<TopWeekEntry>? entriesToSync;
    try {
      final entries = await _repository.fetchTopWeekEntries();
      if (_isDisposed) {
        return;
      }

      _entries = entries;
      _lastUpdatedAt = DateTime.now();
      _isLoadFailed = false;
      _scheduleAutoRefresh(success: true);
      entriesToSync = entries;
    } catch (_) {
      if (_isDisposed) {
        return;
      }

      _entries ??= const <TopWeekEntry>[];
      _isLoadFailed = true;
      _scheduleAutoRefresh(success: false);
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _isRefreshing = false;
        _notifyIfActive();
      }
    }

    final syncEntries = entriesToSync;
    if (!_isDisposed && syncEntries != null) {
      unawaited(_syncAuctionStatuses(syncEntries));
    }
  }

  /// 刷新每周萌王条目
  Future<void> refresh() async {
    if (_isDisposed || _isLoading || _isRefreshing) {
      return;
    }

    await load(showSkeleton: _entries == null);
  }

  /// 静默刷新当前条目的拍卖状态
  Future<void> refreshAuctionStatuses() async {
    final entries = _entries;
    if (_isDisposed || entries == null || entries.isEmpty) {
      return;
    }

    await _syncAuctionStatuses(entries);
  }

  /// 释放每周萌王控制器
  @override
  void dispose() {
    _isDisposed = true;
    _statusTimer?.cancel();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  /// 启动状态文案刷新定时器
  void _startStatusTimer() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(_statusRefreshInterval, (_) {
      _notifyIfActive();
    });
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

  /// 静默同步当前用户拍卖状态
  ///
  /// [entries] 需要同步的每周萌王条目
  Future<void> _syncAuctionStatuses(List<TopWeekEntry> entries) async {
    if (entries.isEmpty) {
      return;
    }

    final syncSerial = ++_auctionSyncSerial;
    try {
      final characterIds = entries
          .map((entry) => entry.characterId)
          .toSet()
          .toList(growable: false);
      final auctionMap = await _auctionRepository.fetchAuctionMap(
        characterIds,
      );
      if (_isDisposed ||
          syncSerial != _auctionSyncSerial ||
          !identical(_entries, entries)) {
        return;
      }

      final nextEntries = <TopWeekEntry>[];
      var hasChanged = false;
      for (final entry in entries) {
        final auction = auctionMap[entry.characterId];
        final nextAuction = _hasUserBid(auction) ? auction : null;
        if (!hasChanged && !_isSameAuction(entry.auction, nextAuction)) {
          hasChanged = true;
        }
        nextEntries.add(entry.copyWithAuction(nextAuction));
      }

      if (!hasChanged) {
        return;
      }

      _entries = nextEntries;
      _notifyIfActive();
    } catch (_) {
      // 拍卖状态只影响按钮文案，失败时保留榜单默认状态
    }
  }

  /// 判断拍卖详情是否代表当前用户已出价
  ///
  /// [auction] 拍卖详情
  bool _hasUserBid(AuctionApiItem? auction) {
    return auction != null &&
        auction.id > 0 &&
        auction.price > 0 &&
        auction.amount > 0;
  }

  /// 判断两份拍卖详情是否等价
  ///
  /// [left] 左侧拍卖详情
  /// [right] 右侧拍卖详情
  bool _isSameAuction(AuctionApiItem? left, AuctionApiItem? right) {
    if (left == null || right == null) {
      return left == right;
    }

    return left.id == right.id &&
        left.characterId == right.characterId &&
        left.state == right.state &&
        left.type == right.type &&
        left.price == right.price &&
        left.amount == right.amount;
  }

  /// 通知仍挂载的监听者
  void _notifyIfActive() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
