import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

/// 用户资产两类缓存统一有效期
const Duration userAssetCacheLifetime = Duration(days: 7);

/// 用户资产快照当前结构版本
const int userAssetSnapshotSchemaVersion = 11;

/// 圣殿星之力达到该值时点亮星星
const int starlightTempleStarForcesThreshold = 10000;

/// 用户资产快照
class UserAssetSnapshot {
  /// 创建用户资产快照
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [characters] 用户全部角色
  /// [temples] 用户全部圣殿
  /// [characterTotalItems] 角色接口总数
  /// [templeTotalItems] 圣殿接口总数
  /// [sourceState] 两类原始数据状态
  const UserAssetSnapshot({
    required this.username,
    required this.nickname,
    required this.characters,
    required this.temples,
    required this.characterTotalItems,
    required this.templeTotalItems,
    required this.sourceState,
  });

  /// 用户名
  final String username;

  /// 用户昵称
  final String nickname;

  /// 用户全部角色
  final List<UserCharacterApiItem> characters;

  /// 用户全部圣殿
  final List<UserTempleApiItem> temples;

  /// 角色接口总数
  final int characterTotalItems;

  /// 圣殿接口总数
  final int templeTotalItems;

  /// 两类原始数据状态
  final UserAssetSourceState sourceState;

  /// 两类原始数据版本
  UserAssetDataRevisions get revisions => sourceState.revisions;
}

/// 用户资产两类原始数据版本
class UserAssetDataRevisions {
  /// 创建用户资产原始数据版本
  ///
  /// [characters] 用户角色版本
  /// [temples] 用户圣殿版本
  /// [schemaVersion] 快照数据库结构版本
  const UserAssetDataRevisions({
    required this.characters,
    required this.temples,
    required this.schemaVersion,
  });

  /// 从缓存 JSON 创建原始数据版本
  ///
  /// [json] 原始数据版本 JSON
  factory UserAssetDataRevisions.fromJson(Map<String, Object?> json) {
    if (!json.containsKey('characters') ||
        !json.containsKey('temples') ||
        !json.containsKey('schemaVersion')) {
      throw const FormatException('资产原始数据版本字段缺失');
    }

    final revisions = UserAssetDataRevisions(
      characters: TinygrailResponseParser.asInt(json['characters']),
      temples: TinygrailResponseParser.asInt(json['temples']),
      schemaVersion: TinygrailResponseParser.asInt(json['schemaVersion']),
    );
    if (!revisions.isComplete) {
      throw const FormatException('资产原始数据版本无效');
    }
    return revisions;
  }

  /// 用户角色版本
  final int characters;

  /// 用户圣殿版本
  final int temples;

  /// 快照数据库结构版本
  final int schemaVersion;

  /// 两类原始数据是否都已形成完整版本
  bool get isComplete {
    return characters > 0 &&
        temples > 0 &&
        schemaVersion == userAssetSnapshotSchemaVersion;
  }

  /// 判断是否与另一组原始数据版本一致
  ///
  /// [other] 待比较的原始数据版本
  bool matches(UserAssetDataRevisions other) {
    return characters == other.characters &&
        temples == other.temples &&
        schemaVersion == other.schemaVersion;
  }

  /// 转换为缓存 JSON
  Map<String, Object?> toJson() {
    return {
      'characters': characters,
      'temples': temples,
      'schemaVersion': schemaVersion,
    };
  }
}

/// 用户资产两类原始数据状态
class UserAssetSourceState {
  /// 创建用户资产原始数据状态
  ///
  /// [revisions] 两类原始数据版本
  /// [charactersUpdatedAtMilliseconds] 用户角色更新时间戳
  /// [templesUpdatedAtMilliseconds] 用户圣殿更新时间戳
  const UserAssetSourceState({
    required this.revisions,
    required this.charactersUpdatedAtMilliseconds,
    required this.templesUpdatedAtMilliseconds,
  });

  /// 两类原始数据版本
  final UserAssetDataRevisions revisions;

  /// 用户角色更新时间戳
  final int charactersUpdatedAtMilliseconds;

  /// 用户圣殿更新时间戳
  final int templesUpdatedAtMilliseconds;

  /// 两类原始数据是否仍在有效期内
  ///
  /// [now] 有效期判断基准时间
  bool isFreshAt(DateTime now) {
    if (!revisions.isComplete) {
      return false;
    }
    return _isTimestampFresh(
          charactersUpdatedAtMilliseconds,
          now.millisecondsSinceEpoch,
        ) &&
        isTempleDataFreshAt(now);
  }

  /// 用户角色数据是否仍在有效期内
  ///
  /// [now] 有效期判断基准时间
  bool isCharacterDataFreshAt(DateTime now) {
    return revisions.characters > 0 &&
        revisions.schemaVersion == userAssetSnapshotSchemaVersion &&
        _isTimestampFresh(
          charactersUpdatedAtMilliseconds,
          now.millisecondsSinceEpoch,
        );
  }

  /// 用户圣殿数据是否仍在有效期内
  ///
  /// [now] 有效期判断基准时间
  bool isTempleDataFreshAt(DateTime now) {
    return revisions.temples > 0 &&
        revisions.schemaVersion == userAssetSnapshotSchemaVersion &&
        _isTimestampFresh(
          templesUpdatedAtMilliseconds,
          now.millisecondsSinceEpoch,
        );
  }

  /// 判断单个原始数据时间是否仍有效
  ///
  /// [updatedAtMilliseconds] 原始数据更新时间戳
  /// [nowMilliseconds] 有效期判断基准时间戳
  bool _isTimestampFresh(
    int updatedAtMilliseconds,
    int nowMilliseconds,
  ) {
    if (updatedAtMilliseconds <= 0) {
      return false;
    }
    final elapsedMilliseconds = nowMilliseconds - updatedAtMilliseconds;
    return elapsedMilliseconds >= 0 &&
        elapsedMilliseconds < userAssetCacheLifetime.inMilliseconds;
  }
}
