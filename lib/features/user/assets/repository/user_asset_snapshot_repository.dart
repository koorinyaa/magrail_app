import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/user/assets/model/user_asset_snapshot.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_database.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_database_models.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

part 'user_asset_snapshot_repository_codec.dart';

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
    final charactersFuture = _fetchAllCharacters(
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
      ),
    );
    final sourceState = await _database.upsertSnapshotEntry(
      UserAssetSnapshotEntry(
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

  /// 从本地原始数据读取有效的用户资产快照
  ///
  /// [username] 用户名
  Future<UserAssetSnapshot?> readSnapshot(String username) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      return null;
    }

    final entry = await _database.readSnapshotEntry(resolvedUsername);
    if (entry == null) {
      return null;
    }
    final sourceState = entry.sourceState;
    if (sourceState == null ||
        !sourceState.revisions.isComplete ||
        !sourceState.isFreshAt(DateTime.now())) {
      return null;
    }

    try {
      final rows = await _deserializeSnapshotRows(entry);
      return UserAssetSnapshot(
        username: entry.username,
        nickname: entry.nickname,
        characters: List<UserCharacterApiItem>.unmodifiable(rows.characters),
        temples: List<UserTempleApiItem>.unmodifiable(rows.temples),
        characterHeaders: List<CharacterDetailTradeHeader>.unmodifiable(
          rows.characterHeaders,
        ),
        characterTotalItems: entry.characterTotalItems,
        templeTotalItems: entry.templeTotalItems,
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

  /// 拉取全部用户角色
  ///
  /// [username] 用户名
  /// [requestGate] 服务器请求并发阀门
  /// [onProgress] 拉取进度回调
  Future<_AllCharactersResult> _fetchAllCharacters({
    required String username,
    required _UserAssetSnapshotRequestGate requestGate,
    required void Function(UserAssetSnapshotLoadProgress progress) onProgress,
  }) async {
    onProgress(
      const UserAssetSnapshotLoadProgress(
        kind: UserAssetSnapshotLoadKind.characters,
        label: '正在读取角色数量',
        completedPages: 0,
        totalPages: 2,
      ),
    );
    final totalPage = await _fetchUserCharacterPage(
      username: username,
      pageNumber: 1,
      pageSize: _totalProbePageSize,
      requestGate: requestGate,
    );
    final totalItems = totalPage.totalItems > 0
        ? totalPage.totalItems
        : totalPage.items.length;
    if (totalItems <= 0) {
      onProgress(
        const UserAssetSnapshotLoadProgress(
          kind: UserAssetSnapshotLoadKind.characters,
          label: '正在整理角色数据',
          completedPages: 2,
          totalPages: 2,
        ),
      );
      return const _AllCharactersResult(
        items: <UserCharacterApiItem>[],
        totalItems: 0,
      );
    }

    onProgress(
      const UserAssetSnapshotLoadProgress(
        kind: UserAssetSnapshotLoadKind.characters,
        label: '正在获取角色数据',
        completedPages: 1,
        totalPages: 2,
      ),
    );
    final fullPage = await _fetchUserCharacterPage(
      username: username,
      pageNumber: 1,
      pageSize: totalItems,
      requestGate: requestGate,
    );
    if (fullPage.items.length < totalItems) {
      // 全量页未返回完整数据时不写入快照，避免上游使用半截资产
      throw StateError('角色数据未完整返回：${fullPage.items.length}/$totalItems');
    }
    final items = <UserCharacterApiItem>[];
    final seenIds = <int>{};
    onProgress(
      const UserAssetSnapshotLoadProgress(
        kind: UserAssetSnapshotLoadKind.characters,
        label: '正在整理角色数据',
        completedPages: 2,
        totalPages: 2,
      ),
    );

    for (final item in fullPage.items) {
      if (seenIds.add(item.characterId)) {
        items.add(item);
      }
    }

    return _AllCharactersResult(
      items: List<UserCharacterApiItem>.unmodifiable(items),
      totalItems: totalItems,
    );
  }

  /// 拉取全部用户圣殿
  ///
  /// [username] 用户名
  /// [requestGate] 服务器请求并发阀门
  /// [onProgress] 拉取进度回调
  Future<_AllTemplesResult> _fetchAllTemples({
    required String username,
    required _UserAssetSnapshotRequestGate requestGate,
    required void Function(UserAssetSnapshotLoadProgress progress) onProgress,
  }) async {
    onProgress(
      const UserAssetSnapshotLoadProgress(
        kind: UserAssetSnapshotLoadKind.temples,
        label: '正在读取圣殿数量',
        completedPages: 0,
        totalPages: 2,
      ),
    );
    final totalPage = await _fetchUserTemplePage(
      username: username,
      pageNumber: 1,
      pageSize: _totalProbePageSize,
      requestGate: requestGate,
    );
    final totalItems = totalPage.totalItems > 0
        ? totalPage.totalItems
        : totalPage.items.length;
    if (totalItems <= 0) {
      onProgress(
        const UserAssetSnapshotLoadProgress(
          kind: UserAssetSnapshotLoadKind.temples,
          label: '正在整理圣殿数据',
          completedPages: 2,
          totalPages: 2,
        ),
      );
      return const _AllTemplesResult(
        items: <UserTempleApiItem>[],
        totalItems: 0,
      );
    }

    onProgress(
      const UserAssetSnapshotLoadProgress(
        kind: UserAssetSnapshotLoadKind.temples,
        label: '正在获取圣殿数据',
        completedPages: 1,
        totalPages: 2,
      ),
    );
    final fullPage = await _fetchUserTemplePage(
      username: username,
      pageNumber: 1,
      pageSize: totalItems,
      requestGate: requestGate,
    );
    if (fullPage.items.length < totalItems) {
      // 全量页未返回完整数据时不写入快照，避免上游使用半截资产
      throw StateError('圣殿数据未完整返回：${fullPage.items.length}/$totalItems');
    }
    final items = <UserTempleApiItem>[];
    final seenIds = <int>{};
    onProgress(
      const UserAssetSnapshotLoadProgress(
        kind: UserAssetSnapshotLoadKind.temples,
        label: '正在整理圣殿数据',
        completedPages: 2,
        totalPages: 2,
      ),
    );

    for (final item in fullPage.items) {
      if (seenIds.add(item.id)) {
        items.add(item);
      }
    }

    return _AllTemplesResult(
      items: List<UserTempleApiItem>.unmodifiable(items),
      totalItems: totalItems,
    );
  }

  /// 拉取全部角色头部资料
  ///
  /// [requestGate] 服务器请求并发阀门
  /// [onProgress] 拉取进度回调
  Future<List<CharacterDetailTradeHeader>> _fetchAllCharacterHeaders({
    required _UserAssetSnapshotRequestGate requestGate,
    required void Function(UserAssetSnapshotLoadProgress progress) onProgress,
  }) async {
    onProgress(
      const UserAssetSnapshotLoadProgress(
        kind: UserAssetSnapshotLoadKind.characterHeaders,
        label: '正在获取角色资料',
        completedPages: 0,
        totalPages: 1,
      ),
    );
    final fullItems = await requestGate.run(
      _characterDetailRepository.fetchAllListedCharacterHeaders,
    );
    final items = <CharacterDetailTradeHeader>[];
    final seenIds = <int>{};
    for (final item in fullItems) {
      if (seenIds.add(item.characterId)) {
        items.add(item);
      }
    }
    onProgress(
      const UserAssetSnapshotLoadProgress(
        kind: UserAssetSnapshotLoadKind.characterHeaders,
        label: '正在整理角色资料',
        completedPages: 1,
        totalPages: 1,
      ),
    );

    return List<CharacterDetailTradeHeader>.unmodifiable(items);
  }

  /// 拉取用户角色分页
  ///
  /// [username] 用户名
  /// [pageNumber] 页码
  /// [pageSize] 每页条目数量
  /// [requestGate] 服务器请求并发阀门
  Future<TinygrailPage<UserCharacterApiItem>> _fetchUserCharacterPage({
    required String username,
    required int pageNumber,
    required int pageSize,
    required _UserAssetSnapshotRequestGate requestGate,
  }) {
    return requestGate.run(() {
      return _userRepository.fetchUserCharacterPage(
        username: username,
        page: pageNumber,
        pageSize: pageSize,
      );
    });
  }

  /// 拉取用户圣殿分页
  ///
  /// [username] 用户名
  /// [pageNumber] 页码
  /// [pageSize] 每页条目数量
  /// [requestGate] 服务器请求并发阀门
  Future<TinygrailPage<UserTempleApiItem>> _fetchUserTemplePage({
    required String username,
    required int pageNumber,
    required int pageSize,
    required _UserAssetSnapshotRequestGate requestGate,
  }) {
    return requestGate.run(() {
      return _userRepository.fetchUserTemplePage(
        username: username,
        page: pageNumber,
        pageSize: pageSize,
      );
    });
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
  /// [entry] 本地资产快照行
  Future<_DeserializedSnapshotRows> _deserializeSnapshotRows(
    UserAssetSnapshotEntry entry,
  ) {
    return compute(_deserializeUserAssetSnapshotRows, entry);
  }
}

/// 用户资产快照请求阀门
class _UserAssetSnapshotRequestGate {
  /// 创建用户资产快照请求阀门
  ///
  /// [maxConcurrent] 最大并发请求数
  _UserAssetSnapshotRequestGate(int maxConcurrent)
      : _maxConcurrent = maxConcurrent < 1 ? 1 : maxConcurrent;

  final int _maxConcurrent;
  final List<void Function()> _queue = [];
  int _runningCount = 0;

  /// 加入请求队列
  ///
  /// [action] 请求任务
  Future<T> run<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _queue.add(() {
      _runningCount += 1;
      Future.sync(action)
          .then(
        completer.complete,
        onError: completer.completeError,
      )
          .whenComplete(() {
        _runningCount -= 1;
        _pump();
      });
    });
    _pump();
    return completer.future;
  }

  /// 调度等待中的请求
  void _pump() {
    while (_runningCount < _maxConcurrent && _queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      next();
    }
  }
}

/// 全量用户角色拉取结果
class _AllCharactersResult {
  /// 创建全量用户角色结果
  ///
  /// [items] 用户全部角色
  /// [totalItems] 接口返回总数
  const _AllCharactersResult({
    required this.items,
    required this.totalItems,
  });

  /// 用户全部角色
  final List<UserCharacterApiItem> items;

  /// 接口返回总数
  final int totalItems;
}

/// 全量用户圣殿拉取结果
class _AllTemplesResult {
  /// 创建全量用户圣殿结果
  ///
  /// [items] 用户全部圣殿
  /// [totalItems] 接口返回总数
  const _AllTemplesResult({
    required this.items,
    required this.totalItems,
  });

  /// 用户全部圣殿
  final List<UserTempleApiItem> items;

  /// 接口返回总数
  final int totalItems;
}

/// 用户资产快照加载类型
enum UserAssetSnapshotLoadKind {
  /// 角色分页加载
  characters,

  /// 圣殿分页加载
  temples,

  /// 角色头部资料分页加载
  characterHeaders,
}

/// 用户资产快照加载进度
class UserAssetSnapshotLoadProgress {
  /// 创建用户资产快照加载进度
  ///
  /// [kind] 加载类型
  /// [label] 加载进度文案
  /// [completedPages] 已完成页数
  /// [totalPages] 总页数
  const UserAssetSnapshotLoadProgress({
    required this.kind,
    required this.label,
    required this.completedPages,
    required this.totalPages,
  });

  /// 加载类型
  final UserAssetSnapshotLoadKind kind;

  /// 加载进度文案
  final String label;

  /// 已完成页数
  final int completedPages;

  /// 总页数
  final int totalPages;
}
