import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/user/analysis/model/user_asset_analysis_calculations.dart';
import 'package:magrail_app/features/user/assets/model/user_character_snapshot_query.dart';
import 'package:magrail_app/features/user/assets/model/user_asset_snapshot.dart';
import 'package:magrail_app/features/user/assets/model/user_temple_snapshot_query.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_database.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_database_models.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

part 'user_asset_snapshot_repository_codec.dart';
part 'user_asset_snapshot_repository_fetching.dart';
part 'user_asset_snapshot_repository_repair.dart';
part 'user_asset_snapshot_repository_scheduler.dart';

/// 用户资产全量刷新优先级
enum UserAssetSnapshotRefreshPriority {
  /// 普通后台预加载
  background,

  /// 其他用户详情页预加载
  userPage,

  /// 当前登录用户预加载
  currentUser,

  /// 用户角色或圣殿二级页等待
  secondaryPage,

  /// 用户主动刷新
  manual,
}

/// 用户资产快照仓库
class UserAssetSnapshotRepository {
  /// 创建用户资产快照仓库
  ///
  /// [userRepository] 用户仓库
  /// [database] 用户资产快照数据库
  const UserAssetSnapshotRepository({
    required UserRepository userRepository,
    required UserAssetSnapshotDatabase database,
  })  : _userRepository = userRepository,
        _database = database;

  // 全量资产快照先用 1 条探测总数，再用总数一次取完整列表
  static const int _totalProbePageSize = 1;

  // 角色和圣殿共用请求阀门
  static const int _maxServerConcurrency = 2;

  // 同一用户的角色全量请求合并，避免启动刷新与页面刷新重复访问服务器
  static final Map<String, Future<_AllCharactersResult>>
      _characterFetchOperations = {};

  // 同一用户的圣殿全量请求合并，避免启动刷新与页面刷新重复访问服务器
  static final Map<String, Future<_AllTemplesResult>> _templeFetchOperations =
      {};

  static final _UserAssetSnapshotRefreshScheduler _refreshScheduler =
      _UserAssetSnapshotRefreshScheduler();

  final UserRepository _userRepository;
  final UserAssetSnapshotDatabase _database;

  /// 当前快照数据库的有效期
  Duration get cacheLifetime => _database.cacheLifetime;

  /// 刷新并缓存用户资产快照
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [onProgress] 拉取进度回调
  Future<UserAssetSnapshot> refreshSnapshot({
    required String username,
    required String nickname,
    required void Function(UserAssetSnapshotLoadProgress progress) onProgress,
  }) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      throw StateError('缺少用户名');
    }

    await Future.wait([
      refreshCharacters(
        username: resolvedUsername,
        nickname: nickname,
        onProgress: onProgress,
        priority: UserAssetSnapshotRefreshPriority.manual,
      ),
      refreshTemples(
        username: resolvedUsername,
        nickname: nickname,
        onProgress: onProgress,
        priority: UserAssetSnapshotRefreshPriority.manual,
      ),
    ]);
    final snapshot = await readSnapshot(resolvedUsername);
    if (snapshot == null) {
      throw StateError('用户资产快照不可用');
    }
    return snapshot;
  }

  /// 探测用户角色总数
  ///
  /// [username] 用户名
  Future<int> probeCharacterTotalItems(String username) async {
    final page = await _fetchUserCharacterPage(
      username: username.trim(),
      pageNumber: 1,
      pageSize: _totalProbePageSize,
      requestGate: _UserAssetSnapshotRequestGate(1),
    );
    return page.totalItems > 0 ? page.totalItems : page.items.length;
  }

  /// 探测用户圣殿总数
  ///
  /// [username] 用户名
  Future<int> probeTempleTotalItems(String username) async {
    final page = await _fetchUserTemplePage(
      username: username.trim(),
      pageNumber: 1,
      pageSize: _totalProbePageSize,
      requestGate: _UserAssetSnapshotRequestGate(1),
    );
    return page.totalItems > 0 ? page.totalItems : page.items.length;
  }

  /// 读取用户资产原始数据状态
  ///
  /// [username] 用户名
  Future<UserAssetSourceState?> readSourceState(String username) {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      return Future.value();
    }
    return _database.readSourceState(resolvedUsername);
  }

  /// 读取角色在默认持股排序中的绝对下标
  ///
  /// [username] 用户名
  /// [characterId] 角色 ID
  Future<int?> readCharacterDefaultAbsoluteIndex({
    required String username,
    required int characterId,
  }) {
    return _database.readCharacterDefaultAbsoluteIndex(
      username: username.trim(),
      characterId: characterId,
    );
  }

  /// 读取圣殿在默认资产排序中的绝对下标
  ///
  /// [username] 用户名
  /// [templeId] 圣殿 ID
  Future<int?> readTempleDefaultAbsoluteIndex({
    required String username,
    required int templeId,
  }) {
    return _database.readTempleDefaultAbsoluteIndex(
      username: username.trim(),
      templeId: templeId,
    );
  }

  /// 单独刷新当前用户角色并判断是否需要重新读取页面
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [onProgress] 拉取进度回调
  /// [totalItemsHint] 本次预览或探测得到的角色总数
  /// [priority] 全量刷新优先级
  /// 返回是否需要重新读取快照窗口
  Future<bool> refreshCharacters({
    required String username,
    required String nickname,
    void Function(UserAssetSnapshotLoadProgress progress)? onProgress,
    int? totalItemsHint,
    UserAssetSnapshotRefreshPriority priority =
        UserAssetSnapshotRefreshPriority.manual,
  }) {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      throw StateError('缺少用户名');
    }
    return _refreshScheduler.schedule(
      key:
          '${_database.storageKey}|${resolvedUsername.toLowerCase()}|characters',
      priority: priority,
      totalItemsHint: totalItemsHint,
      action: (latestTotalItemsHint) => _refreshCharactersNow(
        username: resolvedUsername,
        nickname: nickname,
        onProgress: onProgress,
        totalItemsHint: latestTotalItemsHint,
      ),
    );
  }

  /// 执行单次角色全量刷新
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [onProgress] 拉取进度回调
  /// [totalItemsHint] 开始请求前最后一次确认的角色总数
  Future<bool> _refreshCharactersNow({
    required String username,
    required String nickname,
    required void Function(UserAssetSnapshotLoadProgress progress)? onProgress,
    required int? totalItemsHint,
  }) async {
    final result = await _fetchAllCharactersShared(
      username: username,
      requestGate: _UserAssetSnapshotRequestGate(1),
      onProgress: onProgress ?? _ignoreSnapshotProgress,
      totalItemsHint: totalItemsHint,
    );
    final serialized = await compute(
      _serializeUserCharacterSnapshotRows,
      _CharacterRowsSerializeRequest(
        characters: result.items,
        totalItems: result.totalItems,
      ),
    );
    return _database.upsertCharacterSnapshot(
      username: username,
      nickname: nickname.trim(),
      rows: serialized.rows,
      totalItems: result.totalItems,
      updatedAtMilliseconds: DateTime.now().millisecondsSinceEpoch,
      contentHash: serialized.contentHash,
    );
  }

  /// 刷新用户圣殿并判断是否需要重新读取页面
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [onProgress] 拉取进度回调
  /// [totalItemsHint] 本次预览或探测得到的圣殿总数
  /// [priority] 全量刷新优先级
  /// 返回是否需要重新读取快照窗口
  Future<bool> refreshTemples({
    required String username,
    required String nickname,
    void Function(UserAssetSnapshotLoadProgress progress)? onProgress,
    int? totalItemsHint,
    UserAssetSnapshotRefreshPriority priority =
        UserAssetSnapshotRefreshPriority.manual,
  }) {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      throw StateError('缺少用户名');
    }
    return _refreshScheduler.schedule(
      key: '${_database.storageKey}|${resolvedUsername.toLowerCase()}|temples',
      priority: priority,
      totalItemsHint: totalItemsHint,
      action: (latestTotalItemsHint) => _refreshTemplesNow(
        username: resolvedUsername,
        nickname: nickname,
        onProgress: onProgress,
        totalItemsHint: latestTotalItemsHint,
      ),
    );
  }

  /// 执行单次圣殿全量刷新
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [onProgress] 拉取进度回调
  /// [totalItemsHint] 开始请求前最后一次确认的圣殿总数
  Future<bool> _refreshTemplesNow({
    required String username,
    required String nickname,
    required void Function(UserAssetSnapshotLoadProgress progress)? onProgress,
    required int? totalItemsHint,
  }) async {
    final templeResult = await _fetchAllTemplesShared(
      username: username,
      requestGate: _UserAssetSnapshotRequestGate(1),
      onProgress: onProgress ?? _ignoreSnapshotProgress,
      totalItemsHint: totalItemsHint,
    );
    final serialized = await compute(
      _serializeUserTempleSnapshotRows,
      _TempleRowsSerializeRequest(
        temples: templeResult.items,
      ),
    );
    return _database.upsertTempleSnapshot(
      username: username,
      nickname: nickname.trim(),
      templeRows: serialized.rows,
      templeTotalItems: templeResult.totalItems,
      templesUpdatedAtMilliseconds: DateTime.now().millisecondsSinceEpoch,
      templeContentHash: serialized.templeContentHash,
    );
  }

  /// 从本地快照分页读取有效的用户角色
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页角色数量
  /// [sort] 排序字段
  /// [direction] 排序方向
  /// [searchKeyword] 角色 ID 或名称筛选词
  /// [expectedRevision] 必须匹配的角色快照版本
  Future<TinygrailPage<UserCharacterApiItem>?> readCharacterPage({
    required String username,
    required int page,
    required int pageSize,
    required UserCharacterSnapshotSort sort,
    required UserCharacterSnapshotSortDirection direction,
    required String searchKeyword,
    int? expectedRevision,
  }) async {
    final resolvedUsername = username.trim();
    final payloadPage = await _database.readCharacterPage(
      username: resolvedUsername,
      page: page,
      pageSize: pageSize,
      sort: sort,
      direction: direction,
      searchKeyword: searchKeyword,
      expectedRevision: expectedRevision,
    );
    if (payloadPage == null) {
      return null;
    }
    try {
      return TinygrailPage(
        items: List<UserCharacterApiItem>.unmodifiable(
          payloadPage.items.map(
            (row) => _decodeSnapshotRow(
              row,
              UserCharacterApiItem.fromJson,
              (item) => item.characterId,
            ),
          ),
        ),
        currentPage: payloadPage.currentPage,
        totalPages: payloadPage.totalPages,
        totalItems: payloadPage.totalItems,
        itemsPerPage: payloadPage.itemsPerPage,
      );
    } on FormatException {
      await _database.invalidateCharacterSnapshot(resolvedUsername);
      return null;
    }
  }

  /// 读取等级排序下的快速跳转目录与角色快照版本
  ///
  /// [username] 用户名
  /// [direction] 等级排序方向
  /// [searchKeyword] 角色 ID 或名称筛选词
  Future<
      ({
        List<UserCharacterLevelPosition> positions,
        int revision,
      })> readCharacterLevelIndex({
    required String username,
    required UserCharacterSnapshotSortDirection direction,
    required String searchKeyword,
  }) {
    return _database.readCharacterLevelIndex(
      username: username.trim(),
      direction: direction,
      searchKeyword: searchKeyword,
    );
  }

  /// 读取角色在等级排序结果中的绝对下标
  ///
  /// [username] 用户名
  /// [characterId] 角色 ID
  /// [direction] 等级排序方向
  /// [searchKeyword] 角色 ID 或名称筛选词
  /// [expectedRevision] 必须匹配的角色快照版本
  Future<int?> readCharacterLevelAbsoluteIndex({
    required String username,
    required int characterId,
    required UserCharacterSnapshotSortDirection direction,
    required String searchKeyword,
    required int expectedRevision,
  }) {
    return _database.readCharacterLevelAbsoluteIndex(
      username: username.trim(),
      characterId: characterId,
      direction: direction,
      searchKeyword: searchKeyword,
      expectedRevision: expectedRevision,
    );
  }

  /// 从本地原始数据读取有效的用户资产快照
  ///
  /// [username] 用户名
  Future<UserAssetSnapshot?> readSnapshot(String username) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      return null;
    }

    final record = await _database.readSnapshotRecord(resolvedUsername);
    if (record == null) {
      return null;
    }
    final sourceState = record.sourceState;
    if (sourceState == null ||
        !sourceState.revisions.isComplete ||
        !sourceState.isFreshAt(
          DateTime.now(),
          lifetime: _database.cacheLifetime,
        )) {
      return null;
    }

    try {
      final rows = await _deserializeSnapshotRows(record);
      return UserAssetSnapshot(
        username: record.username,
        nickname: record.nickname,
        characters: List<UserCharacterApiItem>.unmodifiable(rows.characters),
        temples: List<UserTempleApiItem>.unmodifiable(rows.temples),
        characterTotalItems: record.characterTotalItems,
        templeTotalItems: record.templeTotalItems,
        sourceState: sourceState,
      );
    } catch (_) {
      // 原始数据损坏时清除整组快照，避免后续持续读取同一份无效数据
      try {
        await _database.deleteSnapshot(resolvedUsername);
      } catch (_) {
        // 清理失败不阻止上层回退到网络刷新
      }
      return null;
    }
  }

  /// 从本地圣殿快照分页读取当前用户圣殿
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页圣殿数量
  /// [sort] 排序字段
  /// [direction] 排序方向
  /// [searchKeyword] 角色 ID 或名称筛选词
  /// [expectedRevision] 必须匹配的圣殿快照版本
  Future<TinygrailPage<UserTempleSnapshotEntry>?> readTemplePage({
    required String username,
    required int page,
    required int pageSize,
    required UserTempleSnapshotSort sort,
    required UserTempleSnapshotSortDirection direction,
    required String searchKeyword,
    int? expectedRevision,
  }) async {
    final payloadPage = await _database.readTemplePage(
      username: username.trim(),
      page: page,
      pageSize: pageSize,
      sort: sort,
      direction: direction,
      searchKeyword: searchKeyword,
      expectedRevision: expectedRevision,
    );
    if (payloadPage == null) {
      return null;
    }
    try {
      return TinygrailPage(
        items: List<UserTempleSnapshotEntry>.unmodifiable(
          payloadPage.items.map((row) {
            final item = _decodeSnapshotRow(
              row,
              UserTempleApiItem.fromJson,
              (value) => value.id,
            );
            return UserTempleSnapshotEntry(
              item: item,
              singleDividend: row.singleDividend,
              totalDividend: row.totalDividend,
            );
          }),
        ),
        currentPage: payloadPage.currentPage,
        totalPages: payloadPage.totalPages,
        totalItems: payloadPage.totalItems,
        itemsPerPage: payloadPage.itemsPerPage,
      );
    } on FormatException {
      await _database.invalidateTempleSnapshot(username.trim());
      return null;
    }
  }

  /// 读取当前用户圣殿等级排序下的快速跳转目录与快照版本
  ///
  /// [username] 用户名
  /// [direction] 排序方向
  /// [searchKeyword] 角色 ID 或名称筛选词
  Future<
      ({
        List<UserTempleLevelPosition> positions,
        int revision,
      })> readTempleLevelIndex({
    required String username,
    required UserTempleSnapshotSortDirection direction,
    required String searchKeyword,
  }) {
    return _database.readTempleLevelIndex(
      username: username.trim(),
      direction: direction,
      searchKeyword: searchKeyword,
    );
  }

  /// 读取圣殿在角色等级排序结果中的绝对下标
  ///
  /// [username] 用户名
  /// [templeId] 圣殿 ID
  /// [direction] 等级排序方向
  /// [searchKeyword] 角色 ID 或名称筛选词
  /// [expectedRevision] 必须匹配的圣殿快照版本
  Future<int?> readTempleLevelAbsoluteIndex({
    required String username,
    required int templeId,
    required UserTempleSnapshotSortDirection direction,
    required String searchKeyword,
    required int expectedRevision,
  }) {
    return _database.readTempleLevelAbsoluteIndex(
      username: username.trim(),
      templeId: templeId,
      direction: direction,
      searchKeyword: searchKeyword,
      expectedRevision: expectedRevision,
    );
  }

  /// 从本地快照分页读取星光圣殿
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页圣殿数量
  Future<TinygrailPage<UserTempleApiItem>> readStarlightTemplePage({
    required String username,
    required int page,
    required int pageSize,
  }) async {
    final payloadPage = await _database.readStarlightTemplePage(
      username: username.trim(),
      page: page,
      pageSize: pageSize,
    );
    return TinygrailPage(
      items: List<UserTempleApiItem>.unmodifiable(
        payloadPage.items.map((row) {
          return _decodeSnapshotRow(
            row,
            UserTempleApiItem.fromJson,
            (item) => item.id,
          );
        }),
      ),
      currentPage: payloadPage.currentPage,
      totalPages: payloadPage.totalPages,
      totalItems: payloadPage.totalItems,
      itemsPerPage: payloadPage.itemsPerPage,
    );
  }

  /// 反序列化快照明细
  ///
  /// [record] 本地资产快照持久化记录
  Future<_DeserializedSnapshotRows> _deserializeSnapshotRows(
    UserAssetSnapshotRecord record,
  ) {
    return compute(_deserializeUserAssetSnapshotRows, record);
  }
}
