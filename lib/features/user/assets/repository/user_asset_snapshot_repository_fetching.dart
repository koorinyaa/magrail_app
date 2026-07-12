part of 'user_asset_snapshot_repository.dart';

/// 用户资产快照网络拉取实现
extension _UserAssetSnapshotRepositoryFetching on UserAssetSnapshotRepository {
  /// 合并同一用户正在进行的角色全量请求
  ///
  /// [username] 用户名
  /// [requestGate] 服务器请求并发阀门
  /// [onProgress] 拉取进度回调
  Future<_AllCharactersResult> _fetchAllCharactersShared({
    required String username,
    required _UserAssetSnapshotRequestGate requestGate,
    required void Function(UserAssetSnapshotLoadProgress progress) onProgress,
  }) {
    final operationKey = username.toLowerCase();
    final existing =
        UserAssetSnapshotRepository._characterFetchOperations[operationKey];
    if (existing != null) {
      return existing;
    }

    late final Future<_AllCharactersResult> operation;
    operation = _fetchAllCharacters(
      username: username,
      requestGate: requestGate,
      onProgress: onProgress,
    ).whenComplete(() {
      if (identical(
        UserAssetSnapshotRepository._characterFetchOperations[operationKey],
        operation,
      )) {
        UserAssetSnapshotRepository._characterFetchOperations.remove(
          operationKey,
        );
      }
    });
    UserAssetSnapshotRepository._characterFetchOperations[operationKey] =
        operation;
    return operation;
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
        completedSteps: 0,
        totalSteps: 2,
      ),
    );
    final totalPage = await _fetchUserCharacterPage(
      username: username,
      pageNumber: 1,
      pageSize: UserAssetSnapshotRepository._totalProbePageSize,
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
          completedSteps: 2,
          totalSteps: 2,
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
        completedSteps: 1,
        totalSteps: 2,
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
        completedSteps: 2,
        totalSteps: 2,
      ),
    );

    for (final item in fullPage.items) {
      if (seenIds.add(item.characterId)) {
        items.add(item);
      }
    }
    if (items.length != totalItems) {
      throw StateError('角色数据去重后数量不一致：${items.length}/$totalItems');
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
        completedSteps: 0,
        totalSteps: 2,
      ),
    );
    final totalPage = await _fetchUserTemplePage(
      username: username,
      pageNumber: 1,
      pageSize: UserAssetSnapshotRepository._totalProbePageSize,
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
          completedSteps: 2,
          totalSteps: 2,
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
        completedSteps: 1,
        totalSteps: 2,
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
        completedSteps: 2,
        totalSteps: 2,
      ),
    );

    for (final item in fullPage.items) {
      if (seenIds.add(item.id)) {
        items.add(item);
      }
    }
    if (items.length != totalItems) {
      throw StateError('圣殿数据去重后数量不一致：${items.length}/$totalItems');
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
        completedSteps: 0,
        totalSteps: 1,
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
        completedSteps: 1,
        totalSteps: 1,
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
}

/// 忽略用户资产快照加载进度
///
/// [progress] 当前加载进度
void _ignoreSnapshotProgress(UserAssetSnapshotLoadProgress progress) {}

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
  /// 用户角色数据加载
  characters,

  /// 用户圣殿数据加载
  temples,

  /// 全部角色资料加载
  characterHeaders,
}

/// 用户资产快照加载进度
class UserAssetSnapshotLoadProgress {
  /// 创建用户资产快照加载进度
  ///
  /// [kind] 加载类型
  /// [label] 加载进度文案
  /// [completedSteps] 已完成阶段数
  /// [totalSteps] 总阶段数
  const UserAssetSnapshotLoadProgress({
    required this.kind,
    required this.label,
    required this.completedSteps,
    required this.totalSteps,
  });

  /// 加载类型
  final UserAssetSnapshotLoadKind kind;

  /// 加载进度文案
  final String label;

  /// 已完成阶段数
  final int completedSteps;

  /// 总阶段数
  final int totalSteps;
}
