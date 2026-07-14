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

  final UserRepository _userRepository;
  final UserAssetSnapshotDatabase _database;

  /// 刷新并缓存用户资产快照
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [onProgress] 拉取进度回调
  /// [maxServerConcurrency] 当前刷新允许的最大服务器并发请求数
  Future<UserAssetSnapshot> refreshSnapshot({
    required String username,
    required String nickname,
    required void Function(UserAssetSnapshotLoadProgress progress) onProgress,
    int maxServerConcurrency = _maxServerConcurrency,
  }) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      throw StateError('缺少用户名');
    }

    final requestGate = _UserAssetSnapshotRequestGate(maxServerConcurrency);
    late int charactersUpdatedAtMilliseconds;
    late int templesUpdatedAtMilliseconds;
    final charactersFuture = _fetchAllCharactersShared(
      username: resolvedUsername,
      requestGate: requestGate,
      onProgress: onProgress,
    ).then((result) {
      charactersUpdatedAtMilliseconds = DateTime.now().millisecondsSinceEpoch;
      return result;
    });
    final templesFuture = _fetchAllTemplesShared(
      username: resolvedUsername,
      requestGate: requestGate,
      onProgress: onProgress,
    ).then((result) {
      templesUpdatedAtMilliseconds = DateTime.now().millisecondsSinceEpoch;
      return result;
    });
    final results = await Future.wait<Object>([
      charactersFuture,
      templesFuture,
    ]);
    final characterResult = results[0] as _AllCharactersResult;
    final templeResult = results[1] as _AllTemplesResult;
    final serializedRows = await _serializeSnapshotRows(
      _SnapshotRowsSerializeRequest(
        characters: characterResult.items,
        temples: templeResult.items,
        characterTotalItems: characterResult.totalItems,
        templeTotalItems: templeResult.totalItems,
      ),
    );
    final sourceState = await _database.upsertSnapshotRecord(
      UserAssetSnapshotRecord(
        username: resolvedUsername,
        nickname: nickname.trim(),
        characterRows: serializedRows.characterRows,
        templeRows: serializedRows.templeRows,
        characterTotalItems: characterResult.totalItems,
        templeTotalItems: templeResult.totalItems,
      ),
      charactersUpdatedAtMilliseconds: charactersUpdatedAtMilliseconds,
      templesUpdatedAtMilliseconds: templesUpdatedAtMilliseconds,
      characterContentHash: serializedRows.characterContentHash,
      templeContentHash: serializedRows.templeContentHash,
    );
    if (sourceState.charactersUpdatedAtMilliseconds !=
            charactersUpdatedAtMilliseconds ||
        sourceState.templesUpdatedAtMilliseconds !=
            templesUpdatedAtMilliseconds) {
      // 旧批次被数据库拒绝时返回已持久化的新快照，避免分析结果与来源版本错位
      final latestSnapshot = await readSnapshot(resolvedUsername);
      if (latestSnapshot != null) {
        return latestSnapshot;
      }
    }
    return UserAssetSnapshot(
      username: resolvedUsername,
      nickname: nickname.trim(),
      characters: characterResult.items,
      temples: templeResult.items,
      characterTotalItems: characterResult.totalItems,
      templeTotalItems: templeResult.totalItems,
      sourceState: sourceState,
    );
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

  /// 单独刷新当前用户角色并判断是否需要重新读取页面
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [onProgress] 拉取进度回调
  /// 返回是否需要重新读取快照窗口
  Future<bool> refreshCharacters({
    required String username,
    required String nickname,
    void Function(UserAssetSnapshotLoadProgress progress)? onProgress,
  }) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      throw StateError('缺少用户名');
    }
    final result = await _fetchAllCharactersShared(
      username: resolvedUsername,
      requestGate: _UserAssetSnapshotRequestGate(1),
      onProgress: onProgress ?? _ignoreSnapshotProgress,
    );
    final serialized = await compute(
      _serializeUserCharacterSnapshotRows,
      _CharacterRowsSerializeRequest(
        characters: result.items,
        totalItems: result.totalItems,
      ),
    );
    return _database.upsertCharacterSnapshot(
      username: resolvedUsername,
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
  /// 返回是否需要重新读取快照窗口
  Future<bool> refreshTemples({
    required String username,
    required String nickname,
  }) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      throw StateError('缺少用户名');
    }
    final templeResult = await _fetchAllTemplesShared(
      username: resolvedUsername,
      requestGate: _UserAssetSnapshotRequestGate(1),
      onProgress: _ignoreSnapshotProgress,
    );
    final serialized = await compute(
      _serializeUserTempleSnapshotRows,
      _TempleRowsSerializeRequest(
        temples: templeResult.items,
      ),
    );
    return _database.upsertTempleSnapshot(
      username: resolvedUsername,
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
        !sourceState.isFreshAt(DateTime.now())) {
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

  /// 序列化快照明细
  ///
  /// [request] 待序列化资产列表
  Future<_SerializedSnapshotRows> _serializeSnapshotRows(
    _SnapshotRowsSerializeRequest request,
  ) {
    return compute(_serializeUserAssetSnapshotRows, request);
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
