import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_database.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_repository.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 其他用户资产快照有效期
const Duration otherUserAssetSnapshotLifetime = Duration(minutes: 10);

/// 用户资产快照数据类型
enum UserAssetSnapshotKind {
  /// 用户角色
  characters,

  /// 用户圣殿
  temples,
}

/// 用户资产快照任务结果
class UserAssetSnapshotEvent {
  /// 创建用户资产快照任务结果
  ///
  /// [username] 用户名
  /// [isCurrentUser] 是否为当前登录用户
  /// [kind] 快照数据类型
  /// [success] 本次任务是否成功
  const UserAssetSnapshotEvent({
    required this.username,
    required this.isCurrentUser,
    required this.kind,
    required this.success,
  });

  /// 用户名
  final String username;

  /// 是否为当前登录用户
  final bool isCurrentUser;

  /// 快照数据类型
  final UserAssetSnapshotKind kind;

  /// 本次任务是否成功
  final bool success;
}

/// 用户资产快照全局协调器
class UserAssetSnapshotCoordinator extends ChangeNotifier {
  /// 创建用户资产快照全局协调器
  ///
  /// [userRepository] 用户仓库
  /// [persistentDatabase] 当前用户持久化快照数据库
  /// [temporaryDatabase] 其他用户临时快照数据库
  UserAssetSnapshotCoordinator({
    required UserRepository userRepository,
    required UserAssetSnapshotDatabase persistentDatabase,
    required UserAssetSnapshotDatabase temporaryDatabase,
  })  : _persistentRepository = UserAssetSnapshotRepository(
          userRepository: userRepository,
          database: persistentDatabase,
        ),
        _temporaryRepository = UserAssetSnapshotRepository(
          userRepository: userRepository,
          database: temporaryDatabase,
          protectCurrentUserSession: false,
        ),
        _temporaryDatabase = temporaryDatabase;

  // 同一用户和数据类型的协调任务在页面、预览和冷启动之间合并
  final Map<String, Future<bool>> _operations = {};
  final Map<String, Future<void>> _pendingOtherUserEvictions = {};
  final LinkedHashMap<String, _OtherUserSnapshotUsage> _otherUserUsages =
      LinkedHashMap<String, _OtherUserSnapshotUsage>();
  final UserAssetSnapshotRepository _persistentRepository;
  final UserAssetSnapshotRepository _temporaryRepository;
  final UserAssetSnapshotDatabase _temporaryDatabase;
  UserAssetSnapshotEvent? _lastEvent;
  bool _isDisposed = false;

  /// 最近一次快照任务结果
  UserAssetSnapshotEvent? get lastEvent => _lastEvent;

  /// 读取指定用户对应的快照仓库
  ///
  /// [isCurrentUser] 是否为当前登录用户
  UserAssetSnapshotRepository repositoryFor({required bool isCurrentUser}) {
    return isCurrentUser ? _persistentRepository : _temporaryRepository;
  }

  /// 冷启动预加载当前用户角色和圣殿
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  Future<void> preloadCurrentUser({
    required String username,
    required String nickname,
  }) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      return;
    }
    final sessionGeneration =
        _persistentRepository.captureCurrentUserSessionGeneration();
    if (sessionGeneration == null) {
      return;
    }
    final characterTotalItems = await _probeTotalSafely(
      () => _persistentRepository.probeCharacterTotalItems(resolvedUsername),
    );
    final templeTotalItems = await _probeTotalSafely(
      () => _persistentRepository.probeTempleTotalItems(resolvedUsername),
    );
    await _refreshInTotalOrder(
      username: resolvedUsername,
      nickname: nickname,
      isCurrentUser: true,
      characterTotalItems: characterTotalItems,
      templeTotalItems: templeTotalItems,
      priority: UserAssetSnapshotRefreshPriority.currentUser,
      force: true,
      sessionGeneration: sessionGeneration,
    );
  }

  /// 根据用户页预览结果刷新角色和圣殿
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [isCurrentUser] 是否为当前登录用户
  /// [characterTotalItems] 本次角色预览返回的总数
  /// [templeTotalItems] 本次圣殿预览返回的总数
  Future<void> refreshFromOverview({
    required String username,
    required String nickname,
    required bool isCurrentUser,
    required int? characterTotalItems,
    required int? templeTotalItems,
  }) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      return;
    }
    if (!isCurrentUser) {
      _touchOtherUser(resolvedUsername);
    }
    final repository = repositoryFor(isCurrentUser: isCurrentUser);
    final sessionGeneration =
        isCurrentUser ? repository.captureCurrentUserSessionGeneration() : null;
    if (isCurrentUser && sessionGeneration == null) {
      return;
    }
    final resolvedCharacterTotal = characterTotalItems ??
        await _probeTotalSafely(
          () => repository.probeCharacterTotalItems(resolvedUsername),
        );
    final resolvedTempleTotal = templeTotalItems ??
        await _probeTotalSafely(
          () => repository.probeTempleTotalItems(resolvedUsername),
        );
    await _refreshInTotalOrder(
      username: resolvedUsername,
      nickname: nickname,
      isCurrentUser: isCurrentUser,
      characterTotalItems: resolvedCharacterTotal,
      templeTotalItems: resolvedTempleTotal,
      priority: isCurrentUser
          ? UserAssetSnapshotRefreshPriority.currentUser
          : UserAssetSnapshotRefreshPriority.userPage,
      force: isCurrentUser,
      sessionGeneration: sessionGeneration,
    );
  }

  /// 确保二级页对应的快照可用
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [isCurrentUser] 是否为当前登录用户
  /// [kind] 快照数据类型
  /// [totalItemsHint] 用户页预览得到的总数
  Future<bool> ensureForSecondaryPage({
    required String username,
    required String nickname,
    required bool isCurrentUser,
    required UserAssetSnapshotKind kind,
    int? totalItemsHint,
  }) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      return false;
    }
    if (!isCurrentUser) {
      _touchOtherUser(resolvedUsername);
    }
    final repository = repositoryFor(isCurrentUser: isCurrentUser);
    final sessionGeneration =
        isCurrentUser ? repository.captureCurrentUserSessionGeneration() : null;
    if (isCurrentUser && sessionGeneration == null) {
      return false;
    }
    if (await isFresh(
      username: resolvedUsername,
      isCurrentUser: isCurrentUser,
      kind: kind,
    )) {
      return true;
    }
    return _refreshKind(
      username: resolvedUsername,
      nickname: nickname,
      isCurrentUser: isCurrentUser,
      kind: kind,
      totalItemsHint: totalItemsHint,
      priority: UserAssetSnapshotRefreshPriority.secondaryPage,
      force: true,
      sessionGeneration: sessionGeneration,
    );
  }

  /// 判断指定快照是否仍在有效期内
  ///
  /// [username] 用户名
  /// [isCurrentUser] 是否为当前登录用户
  /// [kind] 快照数据类型
  Future<bool> isFresh({
    required String username,
    required bool isCurrentUser,
    required UserAssetSnapshotKind kind,
  }) async {
    if (!isCurrentUser) {
      final pendingEviction =
          _pendingOtherUserEvictions[_normalizeUsername(username)];
      if (pendingEviction != null) {
        // 同一用户重新进入时先等待旧淘汰结束，避免读取即将被删除的快照
        await pendingEviction;
      }
    }
    final repository = repositoryFor(isCurrentUser: isCurrentUser);
    try {
      final sourceState = await repository.readSourceState(username);
      if (sourceState == null) {
        return false;
      }
      final now = DateTime.now();
      return switch (kind) {
        UserAssetSnapshotKind.characters => sourceState.isCharacterDataFreshAt(
            now,
            lifetime: repository.cacheLifetime,
          ),
        UserAssetSnapshotKind.temples => sourceState.isTempleDataFreshAt(
            now,
            lifetime: repository.cacheLifetime,
          ),
      };
    } catch (_) {
      // 本地数据库不可读时按快照不可用处理，由上层回退到网络刷新
      return false;
    }
  }

  /// 标记其他用户页面正在使用临时快照
  ///
  /// [username] 用户名
  void retainOtherUser(String username) {
    final key = _normalizeUsername(username);
    if (key.isEmpty) {
      return;
    }
    final usage = _touchOtherUser(username);
    usage.retainCount += 1;
    unawaited(_evictOtherUsers());
  }

  /// 释放其他用户页面的临时快照占用
  ///
  /// [username] 用户名
  void releaseOtherUser(String username) {
    final key = _normalizeUsername(username);
    final usage = _otherUserUsages[key];
    if (usage == null) {
      return;
    }
    if (usage.retainCount > 0) {
      usage.retainCount -= 1;
    }
    unawaited(_evictOtherUsers());
  }

  /// 释放快照协调器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 按数据总数顺序提交两类刷新
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [isCurrentUser] 是否为当前登录用户
  /// [characterTotalItems] 本次角色总数
  /// [templeTotalItems] 本次圣殿总数
  /// [priority] 全量刷新优先级
  /// [force] 是否忽略快照有效期
  /// [sessionGeneration] 当前用户任务开始时捕获的会话代际
  Future<void> _refreshInTotalOrder({
    required String username,
    required String nickname,
    required bool isCurrentUser,
    required int? characterTotalItems,
    required int? templeTotalItems,
    required UserAssetSnapshotRefreshPriority priority,
    required bool force,
    required int? sessionGeneration,
  }) async {
    if (!isCurrentUser) {
      // 避免临时快照被提前淘汰
      retainOtherUser(username);
    }
    try {
      final kinds = characterTotalItems != null &&
              templeTotalItems != null &&
              templeTotalItems < characterTotalItems
          ? const [
              UserAssetSnapshotKind.temples,
              UserAssetSnapshotKind.characters
            ]
          : const [
              UserAssetSnapshotKind.characters,
              UserAssetSnapshotKind.temples
            ];
      for (final kind in kinds) {
        await _refreshKind(
          username: username,
          nickname: nickname,
          isCurrentUser: isCurrentUser,
          kind: kind,
          totalItemsHint: kind == UserAssetSnapshotKind.characters
              ? characterTotalItems
              : templeTotalItems,
          priority: priority,
          force: force,
          sessionGeneration: sessionGeneration,
        );
      }
    } finally {
      if (!isCurrentUser) {
        releaseOtherUser(username);
      }
    }
  }

  /// 刷新单类用户资产快照
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [isCurrentUser] 是否为当前登录用户
  /// [kind] 快照数据类型
  /// [totalItemsHint] 本次已知的数据总数
  /// [priority] 全量刷新优先级
  /// [force] 是否忽略快照有效期
  /// [sessionGeneration] 当前用户任务开始时捕获的会话代际
  Future<bool> _refreshKind({
    required String username,
    required String nickname,
    required bool isCurrentUser,
    required UserAssetSnapshotKind kind,
    required int? totalItemsHint,
    required UserAssetSnapshotRefreshPriority priority,
    required bool force,
    required int? sessionGeneration,
  }) async {
    if (!force) {
      try {
        if (await isFresh(
          username: username,
          isCurrentUser: isCurrentUser,
          kind: kind,
        )) {
          return true;
        }
      } catch (_) {
        // 本地状态读取失败时按缓存不可用处理，继续请求最新数据
      }
    }
    final operationKey =
        '${isCurrentUser ? 'persistent|$sessionGeneration' : 'temporary'}|${_normalizeUsername(username)}|${kind.name}';
    final repository = repositoryFor(isCurrentUser: isCurrentUser);
    final refreshOperation = switch (kind) {
      UserAssetSnapshotKind.characters => repository.refreshCharacters(
          username: username,
          nickname: nickname,
          totalItemsHint: totalItemsHint,
          priority: priority,
          expectedSessionGeneration: sessionGeneration,
        ),
      UserAssetSnapshotKind.temples => repository.refreshTemples(
          username: username,
          nickname: nickname,
          totalItemsHint: totalItemsHint,
          priority: priority,
          expectedSessionGeneration: sessionGeneration,
        ),
    };
    final existing = _operations[operationKey];
    if (existing != null) {
      // 重复触发仍进入仓库调度器，以提升等待任务优先级并更新总数
      return existing;
    }
    late final Future<bool> operation;
    operation = refreshOperation
        .then((_) => true, onError: (_) => false)
        .then((success) {
      if (!_isDisposed) {
        _lastEvent = UserAssetSnapshotEvent(
          username: username,
          isCurrentUser: isCurrentUser,
          kind: kind,
          success: success,
        );
        notifyListeners();
      }
      return success;
    }).whenComplete(() {
      if (identical(_operations[operationKey], operation)) {
        _operations.remove(operationKey);
      }
      if (!isCurrentUser) {
        unawaited(_evictOtherUsers());
      }
    });
    _operations[operationKey] = operation;
    return operation;
  }

  /// 安全探测单类数据总数
  ///
  /// [probe] 总数探测请求
  Future<int?> _probeTotalSafely(Future<int> Function() probe) async {
    try {
      return await probe();
    } catch (_) {
      return null;
    }
  }

  /// 更新其他用户临时快照的最近使用顺序
  ///
  /// [username] 用户名
  _OtherUserSnapshotUsage _touchOtherUser(String username) {
    final key = _normalizeUsername(username);
    final existing = _otherUserUsages.remove(key);
    final usage = existing ?? _OtherUserSnapshotUsage(username: username);
    _otherUserUsages[key] = usage;
    return usage;
  }

  /// 淘汰最近未使用的其他用户临时快照
  Future<void> _evictOtherUsers() async {
    while (_otherUserUsages.length > 2) {
      final candidate = _otherUserUsages.entries
          .where(
            (entry) =>
                entry.value.retainCount == 0 &&
                !_hasActiveTemporaryOperation(entry.key),
          )
          .firstOrNull;
      if (candidate == null) {
        return;
      }
      _otherUserUsages.remove(candidate.key);
      final eviction = _deleteTemporarySnapshot(candidate.value.username);
      _pendingOtherUserEvictions[candidate.key] = eviction;
      await eviction;
      if (identical(_pendingOtherUserEvictions[candidate.key], eviction)) {
        _pendingOtherUserEvictions.remove(candidate.key);
      }
    }
  }

  /// 删除不再使用的其他用户临时快照
  ///
  /// [username] 用户名
  Future<void> _deleteTemporarySnapshot(String username) async {
    try {
      await _temporaryDatabase.deleteSnapshot(username);
    } catch (_) {
      // 运行期淘汰失败不影响页面，临时数据库仍会在下次启动时整体清理
    }
  }

  /// 判断其他用户是否仍有临时快照任务
  ///
  /// [normalizedUsername] 标准化用户名
  bool _hasActiveTemporaryOperation(String normalizedUsername) {
    final operationPrefix = 'temporary|$normalizedUsername|';
    return _operations.keys.any((key) => key.startsWith(operationPrefix));
  }

  /// 标准化用户名
  ///
  /// [username] 用户名
  String _normalizeUsername(String username) => username.trim().toLowerCase();
}

/// 其他用户临时快照使用状态
class _OtherUserSnapshotUsage {
  /// 创建其他用户临时快照使用状态
  ///
  /// [username] 用户名
  _OtherUserSnapshotUsage({required this.username});

  final String username;
  int retainCount = 0;
}
