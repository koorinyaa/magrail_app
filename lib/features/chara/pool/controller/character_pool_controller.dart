import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/chara/auction/model/auction_api_item.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 英灵殿角色池账号
const String characterPoolValhallaUsername = 'tinygrail';

/// 幻想乡角色池账号
const String characterPoolGensokyoUsername = 'blueleaf';

/// 角色池一级预览和二级分页每页角色数量
const int characterPoolPageSize = 24;

/// 角色池预览控制器
class CharacterPoolPreviewController extends ChangeNotifier {
  /// 创建角色池预览控制器
  ///
  /// [repository] 用户资产仓库
  /// [username] 角色池账号
  /// [auctionRepository] 拍卖仓库，传入时会同步当前用户竞拍状态
  CharacterPoolPreviewController({
    required UserRepository repository,
    required String username,
    AuctionRepository? auctionRepository,
  })  : _repository = repository,
        _username = username,
        _auctionRepository = auctionRepository;

  final UserRepository _repository;
  final String _username;
  final AuctionRepository? _auctionRepository;

  List<UserCharacterApiItem>? _items;
  Map<int, AuctionApiItem> _auctionMap = const <int, AuctionApiItem>{};
  int? _totalItems;
  bool _isLoading = false;
  bool _isLoadFailed = false;
  bool _isDisposed = false;
  int _auctionSyncSerial = 0;

  /// 当前角色池预览条目
  List<UserCharacterApiItem>? get items => _items;

  /// 当前用户竞拍映射
  Map<int, AuctionApiItem> get auctionMap => _auctionMap;

  /// 角色池总角色数量
  int? get totalItems => _totalItems;

  /// 是否正在首次加载
  bool get isLoading => _isLoading;

  /// 是否加载失败
  bool get isLoadFailed => _isLoadFailed;

  /// 初始化角色池预览
  void initialize() {
    unawaited(load(showSkeleton: true));
  }

  /// 加载角色池预览
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
      final page = await _repository.fetchUserCharacterPage(
        username: _username,
        pageSize: characterPoolPageSize,
      );
      if (_isDisposed) {
        return;
      }

      final items = page.items;
      _items = items;
      _totalItems = page.totalItems;
      _isLoadFailed = false;
      if (_auctionRepository != null) {
        unawaited(_syncAuctionStatuses(items));
      }
    } catch (_) {
      if (_isDisposed) {
        return;
      }

      _items ??= const <UserCharacterApiItem>[];
      _isLoadFailed = true;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _notifyIfActive();
      }
    }
  }

  /// 刷新角色池预览
  Future<void> refresh() async {
    if (_isDisposed || _isLoading) {
      return;
    }

    await load(showSkeleton: _items == null);
  }

  /// 刷新单个角色的竞拍状态
  ///
  /// [characterId] 角色 ID
  Future<void> refreshAuctionStatusForCharacter(int characterId) async {
    final auctionRepository = _auctionRepository;
    if (_isDisposed || characterId <= 0 || auctionRepository == null) {
      return;
    }

    final syncSerial = ++_auctionSyncSerial;
    try {
      final auctionMap = await auctionRepository.fetchAuctionMap(
        [characterId],
      );
      if (_isDisposed || syncSerial != _auctionSyncSerial) {
        return;
      }

      final nextMap = Map<int, AuctionApiItem>.of(_auctionMap);
      final auction = _filterUserBidMap(auctionMap)[characterId];
      if (auction == null) {
        nextMap.remove(characterId);
      } else {
        nextMap[characterId] = auction;
      }

      if (mapEquals(_auctionMap, nextMap)) {
        return;
      }

      _auctionMap = nextMap;
      _notifyIfActive();
    } catch (_) {
      // 拍卖状态只影响按钮文案，失败时保留当前按钮状态
    }
  }

  /// 释放角色池预览控制器
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

  /// 同步当前用户竞拍状态
  ///
  /// [items] 需要同步的角色池条目
  Future<void> _syncAuctionStatuses(List<UserCharacterApiItem> items) async {
    final auctionRepository = _auctionRepository;
    if (items.isEmpty || auctionRepository == null) {
      return;
    }

    final syncSerial = ++_auctionSyncSerial;
    try {
      final characterIds =
          items.map((item) => item.characterId).toSet().toList(growable: false);
      final auctionMap = await auctionRepository.fetchAuctionMap(characterIds);
      if (_isDisposed ||
          syncSerial != _auctionSyncSerial ||
          !identical(_items, items)) {
        return;
      }

      final nextMap = _filterUserBidMap(auctionMap);
      if (mapEquals(_auctionMap, nextMap)) {
        return;
      }

      _auctionMap = nextMap;
      _notifyIfActive();
    } catch (_) {
      // 拍卖状态只影响按钮文案，失败时保留当前按钮状态
    }
  }
}

/// 角色池二级页面控制器
class CharacterPoolPageController extends TinygrailPagedListController<
    UserCharacterApiItem, UserCharacterApiItem> {
  /// 创建角色池二级页面控制器
  ///
  /// [repository] 用户资产仓库
  /// [username] 角色池账号
  /// [auctionRepository] 拍卖仓库，传入时会同步当前用户竞拍状态
  /// [pageSize] 每页角色数量
  CharacterPoolPageController({
    required UserRepository repository,
    required String username,
    AuctionRepository? auctionRepository,
    super.pageSize = characterPoolPageSize,
  })  : _repository = repository,
        _username = username,
        _auctionRepository = auctionRepository;

  final UserRepository _repository;
  final String _username;
  final AuctionRepository? _auctionRepository;
  Map<int, AuctionApiItem> _auctionMap = const <int, AuctionApiItem>{};
  int _auctionSyncSerial = 0;

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
    await _syncAuctionStatuses(result.items, replace: page == 1);
    return result;
  }

  /// 转换角色池展示条目
  ///
  /// [items] 接口返回角色条目
  @override
  List<UserCharacterApiItem> convertPageItems(
    List<UserCharacterApiItem> items,
  ) {
    return items;
  }

  /// 刷新单个角色的竞拍状态
  ///
  /// [characterId] 角色 ID
  Future<void> refreshAuctionStatusForCharacter(int characterId) async {
    final auctionRepository = _auctionRepository;
    if (characterId <= 0 || auctionRepository == null) {
      return;
    }

    final syncSerial = ++_auctionSyncSerial;
    try {
      final auctionMap = await auctionRepository.fetchAuctionMap(
        [characterId],
      );
      if (syncSerial != _auctionSyncSerial) {
        return;
      }

      final nextMap = Map<int, AuctionApiItem>.of(_auctionMap);
      final auction = _filterUserBidMap(auctionMap)[characterId];
      if (auction == null) {
        nextMap.remove(characterId);
      } else {
        nextMap[characterId] = auction;
      }

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
      if (replace && _auctionMap.isNotEmpty) {
        _auctionMap = const <int, AuctionApiItem>{};
        return true;
      }
      return false;
    }

    try {
      final characterIds =
          items.map((item) => item.characterId).toSet().toList(growable: false);
      final syncSerial = ++_auctionSyncSerial;
      final nextMap = _filterUserBidMap(
        await auctionRepository.fetchAuctionMap(characterIds),
      );
      if (syncSerial != _auctionSyncSerial) {
        return false;
      }

      final mergedMap = replace
          ? nextMap
          : <int, AuctionApiItem>{
              ..._auctionMap,
              ...nextMap,
            };
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
