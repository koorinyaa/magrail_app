import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/user/analysis/model/user_asset_analysis_calculations.dart';
import 'package:magrail_app/features/user/analysis/model/user_asset_analysis_character_bubble.dart';
import 'package:magrail_app/features/user/assets/model/user_asset_snapshot.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

export 'package:magrail_app/features/user/analysis/model/user_asset_analysis_character_bubble.dart';

// 股息和资产模式各缓存前 24 个角色，避免保存无展示用途的完整聚合列表
const int _cachedCharacterBubblesPerMode = 24;

/// 在后台 isolate 构建用户资产分析结果
///
/// [snapshot] 用户资产快照
Future<UserAssetAnalysis> buildUserAssetAnalysis(
  UserAssetSnapshot snapshot,
) async {
  final metrics = await compute(_buildUserAssetAnalysisMetrics, snapshot);
  return UserAssetAnalysis._fromMetrics(snapshot: snapshot, metrics: metrics);
}

/// 构建用户资产分析指标
///
/// [snapshot] 用户资产快照
_UserAssetAnalysisMetrics _buildUserAssetAnalysisMetrics(
  UserAssetSnapshot snapshot,
) {
  return _UserAssetAnalysisMetrics.fromSnapshot(snapshot);
}

/// 用户资产分析结果
class UserAssetAnalysis {
  /// 创建用户资产分析结果
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [updatedAtMilliseconds] 分析更新时间戳
  /// [characterTotalItems] 角色接口总数
  /// [templeTotalItems] 圣殿接口总数
  /// [starlightTempleCount] 星光圣殿数量
  /// [totalShares] 持股总数
  /// [dividendSegments] 股息构成分段
  /// [levelBuckets] 等级分布
  /// [characterBubbles] 角色圆图数据
  /// [templeCoverage] 圣殿覆盖率
  /// [sourceRevisions] 计算使用的两类原始数据版本
  const UserAssetAnalysis({
    required this.username,
    required this.nickname,
    required this.updatedAtMilliseconds,
    required this.characterTotalItems,
    required this.templeTotalItems,
    required this.starlightTempleCount,
    required this.totalShares,
    required this.dividendSegments,
    required this.levelBuckets,
    required this.characterBubbles,
    required this.templeCoverage,
    required this.sourceRevisions,
  });

  /// 用户名
  final String username;

  /// 用户昵称
  final String nickname;

  /// 分析更新时间戳
  final int updatedAtMilliseconds;

  /// 角色接口总数
  final int characterTotalItems;

  /// 圣殿接口总数
  final int templeTotalItems;

  /// 星光圣殿数量
  final int starlightTempleCount;

  /// 持股总数
  final int totalShares;

  /// 股息构成分段
  final List<UserAssetAnalysisDividendSegment> dividendSegments;

  /// 等级分布
  final List<UserAssetAnalysisLevelBucket> levelBuckets;

  /// 角色圆图数据
  final List<UserAssetAnalysisCharacterBubble> characterBubbles;

  /// 圣殿覆盖率
  final double templeCoverage;

  /// 计算使用的两类原始数据版本
  final UserAssetDataRevisions sourceRevisions;

  /// 分析更新时间
  DateTime get updatedAt {
    return DateTime.fromMillisecondsSinceEpoch(updatedAtMilliseconds);
  }

  /// 从指标创建用户资产分析结果
  ///
  /// [snapshot] 原始资产快照
  /// [metrics] 后台计算指标
  factory UserAssetAnalysis._fromMetrics({
    required UserAssetSnapshot snapshot,
    required _UserAssetAnalysisMetrics metrics,
  }) {
    return UserAssetAnalysis(
      username: snapshot.username,
      nickname: snapshot.nickname,
      updatedAtMilliseconds: DateTime.now().millisecondsSinceEpoch,
      characterTotalItems: snapshot.characterTotalItems,
      templeTotalItems: snapshot.templeTotalItems,
      starlightTempleCount: metrics.starlightTempleCount,
      totalShares: metrics.totalShares,
      dividendSegments: metrics.dividendSegments,
      levelBuckets: metrics.levelBuckets,
      characterBubbles: metrics.characterBubbles,
      templeCoverage: metrics.templeCoverage,
      sourceRevisions: snapshot.revisions,
    );
  }

  /// 从缓存 JSON 创建用户资产分析结果
  ///
  /// [json] 分析缓存 JSON
  factory UserAssetAnalysis.fromJson(Map<String, Object?> json) {
    final sourceRevisionsJson = TinygrailResponseParser.asObjectMap(
      json['sourceRevisions'],
    );
    if (sourceRevisionsJson == null) {
      throw const FormatException('资产分析原始数据版本缺失');
    }
    if (!json.containsKey('starlightTempleCount')) {
      throw const FormatException('资产分析星光圣殿数量缺失');
    }

    return UserAssetAnalysis(
      username: TinygrailResponseParser.asString(json['username']),
      nickname: TinygrailResponseParser.asString(json['nickname']),
      updatedAtMilliseconds: TinygrailResponseParser.asInt(
        json['updatedAtMilliseconds'],
      ),
      characterTotalItems: TinygrailResponseParser.asInt(
        json['characterTotalItems'],
      ),
      templeTotalItems: TinygrailResponseParser.asInt(
        json['templeTotalItems'],
      ),
      starlightTempleCount: TinygrailResponseParser.asInt(
        json['starlightTempleCount'],
      ),
      totalShares: TinygrailResponseParser.asInt(json['totalShares']),
      dividendSegments: List<UserAssetAnalysisDividendSegment>.unmodifiable(
        TinygrailResponseParser.asObjectList(
              json['dividendSegments'],
              UserAssetAnalysisDividendSegment.fromJson,
            ) ??
            const <UserAssetAnalysisDividendSegment>[],
      ),
      levelBuckets: List<UserAssetAnalysisLevelBucket>.unmodifiable(
        TinygrailResponseParser.asObjectList(
              json['levelBuckets'],
              UserAssetAnalysisLevelBucket.fromJson,
            ) ??
            const <UserAssetAnalysisLevelBucket>[],
      ),
      characterBubbles: List<UserAssetAnalysisCharacterBubble>.unmodifiable(
        TinygrailResponseParser.asObjectList(
              json['characterBubbles'],
              UserAssetAnalysisCharacterBubble.fromJson,
            ) ??
            const <UserAssetAnalysisCharacterBubble>[],
      ),
      templeCoverage: TinygrailResponseParser.asDouble(
        json['templeCoverage'],
      ),
      sourceRevisions: UserAssetDataRevisions.fromJson(sourceRevisionsJson),
    );
  }

  /// 转换为分析缓存 JSON
  Map<String, Object?> toJson() {
    return {
      'username': username,
      'nickname': nickname,
      'updatedAtMilliseconds': updatedAtMilliseconds,
      'characterTotalItems': characterTotalItems,
      'templeTotalItems': templeTotalItems,
      'starlightTempleCount': starlightTempleCount,
      'totalShares': totalShares,
      'dividendSegments': [for (final item in dividendSegments) item.toJson()],
      'levelBuckets': [for (final item in levelBuckets) item.toJson()],
      'characterBubbles': [for (final item in characterBubbles) item.toJson()],
      'templeCoverage': templeCoverage,
      'sourceRevisions': sourceRevisions.toJson(),
    };
  }
}

/// 用户资产分析后台指标
class _UserAssetAnalysisMetrics {
  /// 创建用户资产分析后台指标
  ///
  /// [totalShares] 持股总数
  /// [starlightTempleCount] 星光圣殿数量
  /// [dividendSegments] 股息构成分段
  /// [levelBuckets] 等级分布
  /// [characterBubbles] 角色圆图数据
  /// [templeCoverage] 圣殿覆盖率
  const _UserAssetAnalysisMetrics({
    required this.totalShares,
    required this.starlightTempleCount,
    required this.dividendSegments,
    required this.levelBuckets,
    required this.characterBubbles,
    required this.templeCoverage,
  });

  final int totalShares;
  final int starlightTempleCount;
  final List<UserAssetAnalysisDividendSegment> dividendSegments;
  final List<UserAssetAnalysisLevelBucket> levelBuckets;
  final List<UserAssetAnalysisCharacterBubble> characterBubbles;
  final double templeCoverage;

  /// 从快照创建用户资产分析后台指标
  ///
  /// [snapshot] 原始资产快照
  factory _UserAssetAnalysisMetrics.fromSnapshot(UserAssetSnapshot snapshot) {
    final characters = snapshot.characters;
    final temples = snapshot.temples;
    final characterBubbles = buildUserAssetAnalysisCharacterBubbles(
      characters: characters,
      temples: temples,
    );

    final characterDividend = _sumDouble(
      characters.map(userAssetAnalysisCharacterTotalDividend),
    );
    final templeDividend = _sumDouble(
      temples.map(userAssetAnalysisTempleTotalDividend),
    );
    final starlightDividend = _sumDouble(
          characters.map(userAssetAnalysisCharacterStarlightDividend),
        ) +
        _sumDouble(
          temples.map(userAssetAnalysisTempleStarlightDividend),
        );
    final totalDividend = characterDividend + templeDividend;
    final characterIds = {
      for (final item in characters)
        if (item.characterId > 0) item.characterId,
    };
    final templeCharacterIds = {
      for (final item in temples)
        if (item.characterId > 0) item.characterId,
    };

    return _UserAssetAnalysisMetrics(
      totalShares: _sumInt(characters.map((item) => item.userTotal)),
      starlightTempleCount: temples.where((item) {
        return item.starForces >= starlightTempleStarForcesThreshold;
      }).length,
      dividendSegments: [
        UserAssetAnalysisDividendSegment(
          label: '持股',
          value: characterDividend,
          share: _safeShare(characterDividend, totalDividend),
        ),
        UserAssetAnalysisDividendSegment(
          label: '圣殿',
          value: templeDividend,
          share: _safeShare(templeDividend, totalDividend),
        ),
        UserAssetAnalysisDividendSegment(
          label: '星光股息',
          value: starlightDividend,
          share: 0,
        ),
      ],
      levelBuckets: _buildLevelBuckets(
        characters,
        temples,
      ),
      characterBubbles: _buildCachedCharacterBubbles(characterBubbles),
      templeCoverage:
          _safeShare(templeCharacterIds.length, characterIds.length),
    );
  }

  /// 构建资产占比缓存角色
  ///
  /// [bubbles] 全部角色聚合结果
  static List<UserAssetAnalysisCharacterBubble> _buildCachedCharacterBubbles(
    List<UserAssetAnalysisCharacterBubble> bubbles,
  ) {
    final selectedById = <int, UserAssetAnalysisCharacterBubble>{};
    for (final bubble in bubbles.take(_cachedCharacterBubblesPerMode)) {
      selectedById[bubble.characterId] = bubble;
    }

    final byAssets = [...bubbles]..sort((a, b) {
        final assetsCompare = b.totalAssets.compareTo(a.totalAssets);
        if (assetsCompare != 0) {
          return assetsCompare;
        }
        return a.characterId.compareTo(b.characterId);
      });
    for (final bubble in byAssets.take(_cachedCharacterBubblesPerMode)) {
      selectedById[bubble.characterId] = bubble;
    }

    return List<UserAssetAnalysisCharacterBubble>.unmodifiable(
      selectedById.values,
    );
  }

  /// 构建等级分布
  ///
  /// [characters] 用户全部角色
  /// [temples] 用户全部圣殿
  static List<UserAssetAnalysisLevelBucket> _buildLevelBuckets(
    List<UserCharacterApiItem> characters,
    List<UserTempleApiItem> temples,
  ) {
    final buckets = <int, _MutableLevelBucket>{};
    for (final character in characters) {
      final level = character.level;
      final bucket = buckets.putIfAbsent(level, () {
        return _MutableLevelBucket(level);
      });
      bucket.totalShares += character.userTotal;
      bucket.characterDividend +=
          userAssetAnalysisCharacterTotalDividend(character);
    }
    for (final temple in temples) {
      final level = temple.characterLevel;
      final bucket = buckets.putIfAbsent(level, () {
        return _MutableLevelBucket(level);
      });
      bucket.templeDividend += userAssetAnalysisTempleTotalDividend(temple);
    }

    final result = buckets.values.map((bucket) => bucket.toBucket()).toList()
      ..sort((a, b) => b.totalDividend.compareTo(a.totalDividend));
    return List<UserAssetAnalysisLevelBucket>.unmodifiable(result);
  }

  /// 累加整数
  ///
  /// [values] 整数列表
  static int _sumInt(Iterable<int> values) {
    var total = 0;
    for (final value in values) {
      total += value;
    }
    return total;
  }

  /// 累加小数
  ///
  /// [values] 小数列表
  static double _sumDouble(Iterable<double> values) {
    var total = 0.0;
    for (final value in values) {
      total += value;
    }
    return total;
  }

  /// 计算安全占比
  ///
  /// [value] 分子数值
  /// [total] 分母数值
  static double _safeShare(num value, num total) {
    if (total <= 0) {
      return 0;
    }
    return (value / total).clamp(0, 1).toDouble();
  }
}

/// 用户资产分析股息构成分段
class UserAssetAnalysisDividendSegment {
  /// 创建用户资产分析股息构成分段
  ///
  /// [label] 分段文案
  /// [value] 股息数值
  /// [share] 股息占比
  const UserAssetAnalysisDividendSegment({
    required this.label,
    required this.value,
    required this.share,
  });

  /// 从缓存 JSON 创建股息构成分段
  ///
  /// [json] 股息构成分段 JSON
  factory UserAssetAnalysisDividendSegment.fromJson(
    Map<String, Object?> json,
  ) {
    return UserAssetAnalysisDividendSegment(
      label: TinygrailResponseParser.asString(json['label']),
      value: TinygrailResponseParser.asDouble(json['value']),
      share: TinygrailResponseParser.asDouble(json['share']),
    );
  }

  /// 分段文案
  final String label;

  /// 股息数值
  final double value;

  /// 股息占比
  final double share;

  /// 转换为股息构成分段缓存 JSON
  Map<String, Object?> toJson() {
    return {
      'label': label,
      'value': value,
      'share': share,
    };
  }
}

/// 用户资产分析等级分布
class UserAssetAnalysisLevelBucket {
  /// 创建用户资产分析等级分布
  ///
  /// [level] 角色等级
  /// [totalShares] 持股总数
  /// [characterDividend] 角色总息
  /// [templeDividend] 圣殿总息
  const UserAssetAnalysisLevelBucket({
    required this.level,
    required this.totalShares,
    required this.characterDividend,
    required this.templeDividend,
  });

  /// 从缓存 JSON 创建等级分布
  ///
  /// [json] 等级分布 JSON
  factory UserAssetAnalysisLevelBucket.fromJson(
    Map<String, Object?> json,
  ) {
    return UserAssetAnalysisLevelBucket(
      level: TinygrailResponseParser.asInt(json['level']),
      totalShares: TinygrailResponseParser.asInt(json['totalShares']),
      characterDividend: TinygrailResponseParser.asDouble(
        json['characterDividend'],
      ),
      templeDividend: TinygrailResponseParser.asDouble(
        json['templeDividend'],
      ),
    );
  }

  /// 角色等级
  final int level;

  /// 持股总数
  final int totalShares;

  /// 角色总息
  final double characterDividend;

  /// 圣殿总息
  final double templeDividend;

  /// 等级总息合计
  double get totalDividend => characterDividend + templeDividend;

  /// 转换为等级分布缓存 JSON
  Map<String, Object?> toJson() {
    return {
      'level': level,
      'totalShares': totalShares,
      'characterDividend': characterDividend,
      'templeDividend': templeDividend,
    };
  }
}

/// 用户资产分析可变等级分布
class _MutableLevelBucket {
  /// 创建可变等级分布
  ///
  /// [level] 角色等级
  _MutableLevelBucket(this.level);

  final int level;
  int totalShares = 0;
  double characterDividend = 0;
  double templeDividend = 0;

  /// 转换为等级分布
  UserAssetAnalysisLevelBucket toBucket() {
    return UserAssetAnalysisLevelBucket(
      level: level,
      totalShares: totalShares,
      characterDividend: characterDividend,
      templeDividend: templeDividend,
    );
  }
}
