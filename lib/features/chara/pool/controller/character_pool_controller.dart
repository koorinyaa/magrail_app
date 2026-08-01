import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/chara/auction/model/auction_api_item.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/chara/controller/character_full_list_page_controller.dart';
import 'package:magrail_app/features/chara/model/character_full_list_sort.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 英灵殿角色池账号
const String characterPoolValhallaUsername = 'tinygrail';

/// 幻想乡角色池账号
const String characterPoolGensokyoUsername = 'blueleaf';

/// 角色池二级页面分页每页角色数量
const int characterPoolPageSize = 24;

/// 角色池二级页面控制器
class CharacterPoolPageController
    extends CharacterFullListPageController<UserCharacterApiItem> {
  /// 创建角色池二级页面控制器
  ///
  /// [repository] 用户资产仓库
  /// [username] 角色池账号
  /// [auctionRepository] 拍卖仓库，传入时会同步当前用户竞拍状态
  /// [pageSize] 每页角色数量
  /// [waitForScrollIdle] 等待列表拖动和惯性滚动结束
  /// [onBeforeFullItemsReplaced] 全量数据替换前回调
  /// [onDataRefreshFailed] 全量数据刷新失败回调
  CharacterPoolPageController({
    required UserRepository repository,
    required String username,
    AuctionRepository? auctionRepository,
    super.pageSize = characterPoolPageSize,
    required super.waitForScrollIdle,
    super.onBeforeFullItemsReplaced,
    super.onDataRefreshFailed,
  })  : _repository = repository,
        _username = username,
        _auctionRepository = auctionRepository,
        super(
          availableSorts: const <CharacterFullListSort>[
            CharacterFullListSort.quantity,
            CharacterFullListSort.level,
            CharacterFullListSort.dividend,
            CharacterFullListSort.towerRank,
            CharacterFullListSort.stars,
            CharacterFullListSort.circulation,
            CharacterFullListSort.currentPrice,
            CharacterFullListSort.fluctuation,
            CharacterFullListSort.marketValue,
            CharacterFullListSort.listedDate,
          ],
          initialSort: CharacterFullListSort.quantity,
        );

  final UserRepository _repository;
  final String _username;
  final AuctionRepository? _auctionRepository;
  Map<int, AuctionApiItem> _auctionMap = const <int, AuctionApiItem>{};
  int _auctionSyncSerial = 0;
  final Set<int> _resolvedAuctionCharacterIds = <int>{};
  final Set<int> _loadingAuctionCharacterIds = <int>{};
  final Queue<List<int>> _auctionBatchQueue = Queue<List<int>>();
  Timer? _auctionBatchDebounce;
  int _activeAuctionBatchRequestCount = 0;
  bool _isPageDisposed = false;

  // 全量列表竞拍状态每批读取 100 个角色，最多并发 3 批
  static const int _auctionBatchSize = 100;
  static const int _maxConcurrentAuctionBatchRequests = 3;

  // 快速滚动期间只保留最后触发的批次，停止构建后再加入请求队列
  static const Duration _auctionBatchDebounceDelay =
      Duration(milliseconds: 150);

  /// 当前用户竞拍映射
  Map<int, AuctionApiItem> get auctionMap => _auctionMap;

  /// 请求角色池分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页角色数量
  @override
  Future<TinygrailPage<UserCharacterApiItem>> requestPage({
    required int page,
    required int pageSize,
  }) async {
    final result = await _repository.fetchUserCharacterPage(
      username: _username,
      page: page,
      pageSize: pageSize,
    );
    final auctionChanged = await _syncAuctionStatuses(
      result.items,
      replace: page == 1 && !hasFullData,
    );
    if (auctionChanged && hasFullData && !_isPageDisposed) {
      notifyListeners();
    }
    return result;
  }

  /// 请求角色池完整数据
  @override
  Future<List<UserCharacterApiItem>> requestFullItems() async {
    final page = await _repository.fetchUserCharacterPage(
      username: _username,
      page: 1,
      pageSize: characterFullListRequestPageSize,
    );
    return page.items;
  }

  /// 读取角色池角色 ID
  ///
  /// [item] 角色池条目
  @override
  int characterIdOf(UserCharacterApiItem item) => item.characterId;

  /// 读取角色池角色名称
  ///
  /// [item] 角色池条目
  @override
  String characterNameOf(UserCharacterApiItem item) => item.name;

  /// 读取角色池角色等级
  ///
  /// [item] 角色池条目
  @override
  int characterLevelOf(UserCharacterApiItem item) => item.level;

  /// 读取角色池排序数值
  ///
  /// [item] 角色池条目
  /// [sort] 排序字段
  @override
  num sortValueOf(
    UserCharacterApiItem item,
    CharacterFullListSort sort,
  ) {
    return switch (sort) {
      CharacterFullListSort.quantity => item.state,
      CharacterFullListSort.level => item.level,
      CharacterFullListSort.dividend => item.singleDividend,
      CharacterFullListSort.towerRank => item.rank,
      CharacterFullListSort.stars => item.stars,
      CharacterFullListSort.circulation => item.total,
      CharacterFullListSort.currentPrice => item.current,
      CharacterFullListSort.fluctuation => item.fluctuation,
      CharacterFullListSort.marketValue => item.marketValue,
      CharacterFullListSort.listedDate => item.listedDateTimestamp,
      _ => 0,
    };
  }

  /// 处理角色构建并按可视批次加载竞拍状态
  ///
  /// [index] 当前构建的展示条目下标
  @override
  void handleItemBuilt(int index) {
    super.handleItemBuilt(index);
    if (!hasFullData || _auctionRepository == null) {
      return;
    }
    _scheduleVisibleAuctionBatch(index);
  }

  /// 释放角色池二级页面控制器
  @override
  void dispose() {
    _isPageDisposed = true;
    _auctionBatchDebounce?.cancel();
    _auctionBatchQueue.clear();
    _loadingAuctionCharacterIds.clear();
    super.dispose();
  }

  /// 刷新单个角色的竞拍状态
  ///
  /// [characterId] 角色 ID
  Future<void> refreshAuctionStatusForCharacter(int characterId) async {
    final auctionRepository = _auctionRepository;
    if (_isPageDisposed || characterId <= 0 || auctionRepository == null) {
      return;
    }

    final syncSerial = ++_auctionSyncSerial;
    try {
      final auctionMap = await auctionRepository.fetchAuctionMap(
        [characterId],
      );
      if (_isPageDisposed || syncSerial != _auctionSyncSerial) {
        return;
      }

      final nextMap = Map<int, AuctionApiItem>.of(_auctionMap);
      final auction = _filterUserBidMap(auctionMap)[characterId];
      if (auction == null) {
        nextMap.remove(characterId);
      } else {
        nextMap[characterId] = auction;
      }
      _resolvedAuctionCharacterIds.add(characterId);

      if (mapEquals(_auctionMap, nextMap)) {
        return;
      }

      _auctionMap = nextMap;
      notifyListeners();
    } catch (_) {
      // 拍卖状态只影响按钮文案，失败时保留当前按钮状态
    }
  }

  /// 同步当前用户竞拍状态
  ///
  /// [items] 需要同步的角色池条目
  /// [replace] 是否替换现有竞拍映射
  Future<bool> _syncAuctionStatuses(
    List<UserCharacterApiItem> items, {
    required bool replace,
  }) async {
    final auctionRepository = _auctionRepository;
    if (auctionRepository == null) {
      return false;
    }

    if (items.isEmpty) {
      if (!replace) {
        return false;
      }
      final changed = _auctionMap.isNotEmpty;
      _auctionMap = const <int, AuctionApiItem>{};
      _resolvedAuctionCharacterIds.clear();
      return changed;
    }

    try {
      final characterIdSet = items.map((item) => item.characterId).toSet();
      final characterIds = characterIdSet.toList(growable: false);
      final syncSerial = ++_auctionSyncSerial;
      final nextMap = _filterUserBidMap(
        await auctionRepository.fetchAuctionMap(characterIds),
      );
      if (_isPageDisposed || syncSerial != _auctionSyncSerial) {
        return false;
      }
      if (replace) {
        _resolvedAuctionCharacterIds
          ..clear()
          ..addAll(characterIds);
      } else {
        _resolvedAuctionCharacterIds.addAll(characterIds);
      }

      final mergedMap = replace
          ? nextMap
          : (Map<int, AuctionApiItem>.of(_auctionMap)
            ..removeWhere(
              (characterId, _) => characterIdSet.contains(characterId),
            )
            ..addAll(nextMap));
      if (mapEquals(_auctionMap, mergedMap)) {
        return false;
      }

      _auctionMap = mergedMap;
      return true;
    } catch (_) {
      // 拍卖状态只影响按钮文案，失败时保留当前按钮状态
      return false;
    }
  }

  /// 防抖调度当前可视位置附近的竞拍状态
  ///
  /// [visibleIndex] 当前构建的角色下标
  void _scheduleVisibleAuctionBatch(int visibleIndex) {
    final currentItems = items;
    if (_isPageDisposed ||
        _auctionRepository == null ||
        visibleIndex < 0 ||
        visibleIndex >= currentItems.length) {
      return;
    }
    _auctionBatchDebounce?.cancel();
    _auctionBatchDebounce = null;
    final batchStart = (visibleIndex ~/ _auctionBatchSize) * _auctionBatchSize;
    final batchEnd =
        (batchStart + _auctionBatchSize).clamp(0, currentItems.length);
    final characterIds = <int>[
      for (var index = batchStart; index < batchEnd; index += 1)
        if (!_resolvedAuctionCharacterIds
                .contains(currentItems[index].characterId) &&
            !_loadingAuctionCharacterIds
                .contains(currentItems[index].characterId))
          currentItems[index].characterId,
    ];
    if (characterIds.isEmpty) {
      return;
    }

    _auctionBatchDebounce = Timer(_auctionBatchDebounceDelay, () {
      _auctionBatchDebounce = null;
      _enqueueAuctionBatch(characterIds);
    });
  }

  /// 将防抖完成的竞拍批次加入 FIFO 队列
  ///
  /// [characterIds] 当前批次角色 ID
  void _enqueueAuctionBatch(List<int> characterIds) {
    if (_isPageDisposed) {
      return;
    }
    final pendingCharacterIds = characterIds
        .where(
          (characterId) =>
              !_resolvedAuctionCharacterIds.contains(characterId) &&
              !_loadingAuctionCharacterIds.contains(characterId),
        )
        .toList(growable: false);
    if (pendingCharacterIds.isEmpty) {
      return;
    }
    _loadingAuctionCharacterIds.addAll(pendingCharacterIds);
    _auctionBatchQueue.addLast(pendingCharacterIds);
    _pumpAuctionBatchQueue();
  }

  /// 在并发上限内启动等待中的竞拍批次
  void _pumpAuctionBatchQueue() {
    while (!_isPageDisposed &&
        _activeAuctionBatchRequestCount < _maxConcurrentAuctionBatchRequests &&
        _auctionBatchQueue.isNotEmpty) {
      final characterIds = _auctionBatchQueue.removeFirst();
      _activeAuctionBatchRequestCount += 1;
      assert(
        _activeAuctionBatchRequestCount <= _maxConcurrentAuctionBatchRequests,
      );
      unawaited(_loadAuctionBatch(characterIds));
    }
  }

  /// 请求并合并单个竞拍批次
  ///
  /// [characterIds] 当前批次角色 ID
  Future<void> _loadAuctionBatch(List<int> characterIds) async {
    try {
      final nextMap = _filterUserBidMap(
        await _auctionRepository!.fetchAuctionMap(characterIds),
      );
      if (_isPageDisposed) {
        return;
      }
      _resolvedAuctionCharacterIds.addAll(characterIds);
      final characterIdSet = characterIds.toSet();
      final mergedMap = Map<int, AuctionApiItem>.of(_auctionMap)
        ..removeWhere(
          (characterId, _) => characterIdSet.contains(characterId),
        )
        ..addAll(nextMap);
      if (!mapEquals(_auctionMap, mergedMap)) {
        _auctionMap = mergedMap;
        notifyListeners();
      }
    } catch (_) {
      // 可视竞拍状态失败时保留当前按钮，后续再次构建该批次时允许重试
    } finally {
      _loadingAuctionCharacterIds.removeAll(characterIds);
      _activeAuctionBatchRequestCount -= 1;
      if (!_isPageDisposed) {
        _pumpAuctionBatchQueue();
      }
    }
  }
}

/// 过滤当前用户已出价的竞拍映射
///
/// [auctionMap] 接口返回的拍卖映射
Map<int, AuctionApiItem> _filterUserBidMap(
  Map<int, AuctionApiItem> auctionMap,
) {
  return {
    for (final entry in auctionMap.entries)
      if (_hasUserBid(entry.value)) entry.key: entry.value,
  };
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
