import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/user/assets/model/user_character_snapshot_query.dart';
import 'package:magrail_app/features/user/assets/model/user_asset_snapshot.dart';
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
  /// [characterDetailRepository] 角色详情仓库
  /// [database] 用户资产快照数据库
  const UserAssetSnapshotRepository({
    required UserRepository userRepository,
    required CharacterDetailRepository characterDetailRepository,
    required UserAssetSnapshotDatabase database,
  })  : _userRepository = userRepository,
        _characterDetailRepository = characterDetailRepository,
        _database = database;

  // 全量资产快照先用 1 条探测总数，再用总数一次取完整列表
  static const int _totalProbePageSize = 1;

  // 角色、圣殿和角色资料共用请求阀门
  static const int _maxServerConcurrency = 3;

  // 同一用户的角色全量请求合并，避免启动刷新与页面刷新重复访问服务器
  static final Map<String, Future<_AllCharactersResult>>
      _characterFetchOperations = {};

  final UserRepository _userRepository;
  final CharacterDetailRepository _characterDetailRepository;
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
    late int characterHeadersUpdatedAtMilliseconds;
    final charactersFuture = _fetchAllCharactersShared(
      username: resolvedUsername,
      requestGate: requestGate,
      onProgress: onProgress,
    ).then((result) {
      charactersUpdatedAtMilliseconds = DateTime.now().millisecondsSinceEpoch;
      return result;
    });
    final templesFuture = _fetchAllTemples(
      username: resolvedUsername,
      requestGate: requestGate,
      onProgress: onProgress,
    ).then((result) {
      templesUpdatedAtMilliseconds = DateTime.now().millisecondsSinceEpoch;
      return result;
    });
    final characterHeadersFuture = _fetchAllCharacterHeaders(
      requestGate: requestGate,
      onProgress: onProgress,
    ).then((result) {
      characterHeadersUpdatedAtMilliseconds =
          DateTime.now().millisecondsSinceEpoch;
      return result;
    });
    final results = await Future.wait<Object>([
      charactersFuture,
      templesFuture,
      characterHeadersFuture,
    ]);
    final characterResult = results[0] as _AllCharactersResult;
    final templeResult = results[1] as _AllTemplesResult;
    final characterHeaders = results[2] as List<CharacterDetailTradeHeader>;
    final serializedRows = await _serializeSnapshotRows(
      _SnapshotRowsSerializeRequest(
        characters: characterResult.items,
        temples: templeResult.items,
        characterHeaders: characterHeaders,
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
        characterHeaderRows: serializedRows.characterHeaderRows,
        characterTotalItems: characterResult.totalItems,
        templeTotalItems: templeResult.totalItems,
      ),
      charactersUpdatedAtMilliseconds: charactersUpdatedAtMilliseconds,
      templesUpdatedAtMilliseconds: templesUpdatedAtMilliseconds,
      characterHeadersUpdatedAtMilliseconds:
          characterHeadersUpdatedAtMilliseconds,
      characterContentHash: serializedRows.characterContentHash,
      templeContentHash: serializedRows.templeContentHash,
      characterHeaderContentHash: serializedRows.characterHeaderContentHash,
    );
    return UserAssetSnapshot(
      username: resolvedUsername,
      nickname: nickname.trim(),
      characters: characterResult.items,
      temples: templeResult.items,
      characterHeaders: characterHeaders,
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

  /// 单独刷新并缓存当前用户角色
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [onProgress] 拉取进度回调
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

  /// 从本地快照分页读取有效的用户角色
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页角色数量
  /// [sort] 排序字段
  /// [direction] 排序方向
  /// [searchKeyword] 角色 ID 或名称筛选词
  Future<TinygrailPage<UserCharacterApiItem>?> readCharacterPage({
    required String username,
    required int page,
    required int pageSize,
    required UserCharacterSnapshotSort sort,
    required UserCharacterSnapshotSortDirection direction,
    required String searchKeyword,
  }) async {
    final resolvedUsername = username.trim();
    final payloadPage = await _database.readCharacterPage(
      username: resolvedUsername,
      page: page,
      pageSize: pageSize,
      sort: sort,
      direction: direction,
      searchKeyword: searchKeyword,
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

  /// 读取等级排序下的快速跳转位置
  ///
  /// [username] 用户名
  /// [direction] 等级排序方向
  /// [searchKeyword] 角色 ID 或名称筛选词
  Future<List<UserCharacterLevelPosition>> readCharacterLevelPositions({
    required String username,
    required UserCharacterSnapshotSortDirection direction,
    required String searchKeyword,
  }) {
    return _database.readCharacterLevelPositions(
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
        characterHeaders: List<CharacterDetailTradeHeader>.unmodifiable(
          rows.characterHeaders,
        ),
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
