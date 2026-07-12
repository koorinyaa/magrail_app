import 'dart:convert';

import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/user/analysis/model/user_asset_analysis.dart';
import 'package:magrail_app/features/user/analysis/repository/user_asset_analysis_database.dart';
import 'package:magrail_app/features/user/assets/model/user_asset_snapshot.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_repository.dart';

/// 用户资产分析仓库
class UserAssetAnalysisRepository {
  // 原始数据持续变化时最多重算三次，避免后台高频写入导致页面无限等待
  static const int _maxLocalRebuildAttempts = 3;

  /// 创建用户资产分析仓库
  ///
  /// [snapshotRepository] 用户资产快照仓库
  /// [database] 用户资产分析缓存数据库
  const UserAssetAnalysisRepository({
    required UserAssetSnapshotRepository snapshotRepository,
    required UserAssetAnalysisDatabase database,
  })  : _snapshotRepository = snapshotRepository,
        _database = database;

  final UserAssetSnapshotRepository _snapshotRepository;
  final UserAssetAnalysisDatabase _database;

  /// 加载有效且原始数据版本一致的用户资产分析
  ///
  /// [username] 用户名
  Future<UserAssetAnalysis?> loadAnalysis(String username) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      return null;
    }

    final cachedAnalysis = await _readCachedAnalysis(resolvedUsername);
    final sourceState = await _snapshotRepository.readSourceState(
      resolvedUsername,
    );
    if (sourceState == null || !sourceState.isFreshAt(DateTime.now())) {
      return null;
    }
    if (cachedAnalysis != null &&
        cachedAnalysis.sourceRevisions.matches(sourceState.revisions)) {
      return cachedAnalysis;
    }

    return _rebuildAnalysisFromLocalSnapshot(resolvedUsername);
  }

  /// 读取用户资产分析缓存内容
  ///
  /// [username] 用户名
  Future<UserAssetAnalysis?> _readCachedAnalysis(String username) async {
    final entry = await _database.readEntry(username);
    if (entry == null) {
      return null;
    }
    if (entry.payloadJson.isEmpty) {
      await _deleteInvalidAnalysis(username);
      return null;
    }

    try {
      final json = TinygrailResponseParser.asObjectMap(
        jsonDecode(entry.payloadJson),
      );
      if (json == null) {
        throw const FormatException('资产分析缓存 JSON 损坏');
      }
      final analysis = UserAssetAnalysis.fromJson(json);
      final usernameMatches =
          analysis.username.toLowerCase() == username.toLowerCase();
      final timestampMatches =
          analysis.updatedAtMilliseconds == entry.updatedAtMilliseconds;
      if (!usernameMatches || !timestampMatches) {
        throw const FormatException('资产分析缓存与索引不匹配');
      }
      if (!_isAnalysisFresh(analysis.updatedAtMilliseconds, DateTime.now())) {
        await _deleteInvalidAnalysis(username);
        return null;
      }
      return analysis;
    } catch (_) {
      // 分析缓存损坏只清除派生结果，不影响可供其他功能复用的原始资产快照
      await _deleteInvalidAnalysis(username);
      return null;
    }
  }

  /// 尝试删除无效的资产分析缓存
  ///
  /// [username] 用户名
  Future<void> _deleteInvalidAnalysis(String username) async {
    try {
      await _database.deleteEntry(username);
    } catch (_) {
      // 无效缓存清理失败时仍允许上层重新获取数据
    }
  }

  /// 刷新并缓存用户资产分析
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [onProgress] 加载进度回调
  Future<UserAssetAnalysis> refreshAnalysis({
    required String username,
    required String nickname,
    required void Function(UserAssetAnalysisLoadProgress progress) onProgress,
  }) async {
    final snapshot = await _snapshotRepository.refreshSnapshot(
      username: username,
      nickname: nickname,
      onProgress: (progress) {
        onProgress(
          UserAssetAnalysisLoadProgress(
            kind: switch (progress.kind) {
              UserAssetSnapshotLoadKind.characters =>
                UserAssetAnalysisLoadKind.characters,
              UserAssetSnapshotLoadKind.temples =>
                UserAssetAnalysisLoadKind.temples,
              UserAssetSnapshotLoadKind.characterHeaders =>
                UserAssetAnalysisLoadKind.characterHeaders,
            },
            label: progress.label,
            completedSteps: progress.completedSteps,
            totalSteps: progress.totalSteps,
          ),
        );
      },
    );
    onProgress(
      const UserAssetAnalysisLoadProgress(
        kind: UserAssetAnalysisLoadKind.analysis,
        label: '正在计算资产分析',
        completedSteps: 0,
        totalSteps: 2,
      ),
    );
    var analysis = await buildUserAssetAnalysis(snapshot);
    onProgress(
      const UserAssetAnalysisLoadProgress(
        kind: UserAssetAnalysisLoadKind.analysis,
        label: '正在缓存资产分析',
        completedSteps: 1,
        totalSteps: 2,
      ),
    );
    if (!await _cacheAnalysisIfCurrent(analysis)) {
      final rebuilt = await _rebuildAnalysisFromLocalSnapshot(username);
      if (rebuilt == null) {
        throw StateError('资产原始数据已变化，请重新刷新');
      }
      analysis = rebuilt;
    }
    onProgress(
      const UserAssetAnalysisLoadProgress(
        kind: UserAssetAnalysisLoadKind.analysis,
        label: '正在完成资产分析',
        completedSteps: 2,
        totalSteps: 2,
      ),
    );
    return analysis;
  }

  /// 从本地原始数据重建分析缓存
  ///
  /// [username] 用户名
  Future<UserAssetAnalysis?> _rebuildAnalysisFromLocalSnapshot(
    String username,
  ) async {
    for (var attempt = 0; attempt < _maxLocalRebuildAttempts; attempt += 1) {
      final snapshot = await _snapshotRepository.readSnapshot(username);
      if (snapshot == null) {
        return null;
      }
      if (!snapshot.sourceState.isFreshAt(DateTime.now())) {
        return null;
      }
      final analysis = await buildUserAssetAnalysis(snapshot);
      if (await _cacheAnalysisIfCurrent(analysis)) {
        return analysis;
      }
    }

    throw StateError('资产原始数据持续更新，请稍后重试');
  }

  /// 在原始数据版本未变化时写入分析缓存
  ///
  /// [analysis] 待写入的资产分析
  Future<bool> _cacheAnalysisIfCurrent(UserAssetAnalysis analysis) async {
    final beforeWrite = await _snapshotRepository.readSourceState(
      analysis.username,
    );
    if (beforeWrite == null ||
        !beforeWrite.isFreshAt(DateTime.now()) ||
        !analysis.sourceRevisions.matches(beforeWrite.revisions)) {
      return false;
    }

    await _database.upsertEntry(
      UserAssetAnalysisCacheEntry(
        username: analysis.username,
        updatedAtMilliseconds: analysis.updatedAtMilliseconds,
        payloadJson: jsonEncode(analysis.toJson()),
      ),
    );
    final afterWrite = await _snapshotRepository.readSourceState(
      analysis.username,
    );
    return afterWrite != null &&
        afterWrite.isFreshAt(DateTime.now()) &&
        analysis.sourceRevisions.matches(afterWrite.revisions);
  }

  /// 判断资产分析缓存是否仍在有效期内
  ///
  /// [updatedAtMilliseconds] 分析更新时间戳
  /// [now] 有效期判断基准时间
  bool _isAnalysisFresh(int updatedAtMilliseconds, DateTime now) {
    if (updatedAtMilliseconds <= 0) {
      return false;
    }
    final elapsedMilliseconds =
        now.millisecondsSinceEpoch - updatedAtMilliseconds;
    return elapsedMilliseconds >= 0 &&
        elapsedMilliseconds < userAssetCacheLifetime.inMilliseconds;
  }
}

/// 用户资产分析加载类型
enum UserAssetAnalysisLoadKind {
  /// 用户角色加载
  characters,

  /// 用户圣殿加载
  temples,

  /// 全部角色资料加载
  characterHeaders,

  /// 分析计算与缓存
  analysis,
}

/// 用户资产分析加载进度
class UserAssetAnalysisLoadProgress {
  /// 创建用户资产分析加载进度
  ///
  /// [kind] 加载类型
  /// [label] 加载状态文案
  /// [completedSteps] 已完成阶段数
  /// [totalSteps] 总阶段数
  const UserAssetAnalysisLoadProgress({
    required this.kind,
    required this.label,
    required this.completedSteps,
    required this.totalSteps,
  });

  /// 加载类型
  final UserAssetAnalysisLoadKind kind;

  /// 加载状态文案
  final String label;

  /// 已完成阶段数
  final int completedSteps;

  /// 总阶段数
  final int totalSteps;
}
