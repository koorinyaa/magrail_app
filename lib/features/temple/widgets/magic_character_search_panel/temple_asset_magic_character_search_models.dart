part of '../temple_asset_magic_character_search_panel.dart';

final class TempleAssetMagicCharacterSearchItem {
  /// 创建魔法道具角色搜索展示条目
  ///
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [icon] 角色头像地址
  /// [level] 角色等级
  /// [zeroCount] ST 等级
  /// [stars] 星级
  /// [starForces] 星之力
  /// [userTotal] 当前用户持股数量
  /// [userAmount] 当前用户可用活股数量
  /// [sacrifices] 当前用户固定资产数量
  const TempleAssetMagicCharacterSearchItem({
    required this.characterId,
    required this.name,
    required this.icon,
    required this.level,
    required this.zeroCount,
    required this.stars,
    required this.starForces,
    required this.userTotal,
    required this.userAmount,
    required this.sacrifices,
  });

  /// 从角色搜索条目创建展示条目
  ///
  /// [item] 角色搜索条目
  factory TempleAssetMagicCharacterSearchItem.fromSearchItem(
    CharacterDetailSearchItem item,
  ) {
    return TempleAssetMagicCharacterSearchItem(
      characterId: item.characterId,
      name: item.name,
      icon: item.icon,
      level: item.level,
      zeroCount: item.zeroCount,
      stars: item.stars,
      starForces: item.starForces,
      userTotal: item.userTotal,
      userAmount: item.userAmount,
      sacrifices: item.sacrifices,
    );
  }

  /// 从用户角色接口条目创建展示条目
  ///
  /// [item] 用户角色接口条目
  factory TempleAssetMagicCharacterSearchItem.fromUserCharacter(
    UserCharacterApiItem item,
  ) {
    return TempleAssetMagicCharacterSearchItem(
      characterId: item.characterId,
      name: item.name,
      icon: item.icon,
      level: item.level,
      zeroCount: item.zeroCount,
      stars: 0,
      starForces: item.starForces,
      userTotal: item.userTotal,
      userAmount: item.userAmount,
      sacrifices: item.sacrifices,
    );
  }

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 角色头像地址
  final String icon;

  /// 角色等级
  final int level;

  /// ST 等级
  final int zeroCount;

  /// 星级
  final int stars;

  /// 星之力
  final int starForces;

  /// 当前用户持股数量
  final int userTotal;

  /// 当前用户可用活股数量
  final int userAmount;

  /// 当前用户固定资产数量
  final int sacrifices;

  /// 转换为角色详情搜索条目
  CharacterDetailSearchItem toSearchItem() {
    return CharacterDetailSearchItem(
      characterId: characterId,
      name: name,
      icon: icon,
      level: level,
      zeroCount: zeroCount,
      stars: stars,
      starForces: starForces,
      userTotal: userTotal,
      userAmount: userAmount,
      sacrifices: sacrifices,
    );
  }
}

/// 魔法道具最近使用角色记录
class _MagicRecentCharacterRecord {
  /// 创建魔法道具最近使用角色记录
  ///
  /// [characterId] 最近使用的目标角色 ID
  /// [usedAt] 最近使用时间
  const _MagicRecentCharacterRecord({
    required this.characterId,
    required this.usedAt,
  });

  /// 最近使用的目标角色 ID
  final int characterId;

  /// 最近使用时间
  final String usedAt;

  /// 从本地缓存文本创建魔法道具最近使用角色记录
  ///
  /// [value] 本地缓存文本
  static _MagicRecentCharacterRecord? fromStorage(String value) {
    final parts = value.split('|');
    final characterId = int.tryParse(parts.first.trim()) ?? 0;
    if (characterId <= 0) {
      return null;
    }

    return _MagicRecentCharacterRecord(
      characterId: characterId,
      usedAt: parts.length > 1 ? parts[1].trim() : '',
    );
  }

  /// 转换为本地缓存文本
  String toStorage() {
    return '$characterId|$usedAt';
  }
}

/// 魔法道具最近使用搜索条目
class _MagicRecentSearchItem {
  /// 创建魔法道具最近使用搜索条目
  ///
  /// [item] 角色搜索条目
  /// [usedAt] 最近使用时间
  const _MagicRecentSearchItem({
    required this.item,
    required this.usedAt,
  });

  /// 角色搜索条目
  final TempleAssetMagicCharacterSearchItem item;

  /// 最近使用时间
  final String usedAt;
}

/// 读取魔法道具角色搜索最近使用记录
///
/// [storageKeyPrefix] 本地缓存键前缀
/// [username] 当前登录用户名
Future<List<_MagicRecentCharacterRecord>> _readRecentMagicCharacterRecords({
  required String storageKeyPrefix,
  required String username,
}) async {
  final trimmedUsername = username.trim();
  if (storageKeyPrefix.trim().isEmpty || trimmedUsername.isEmpty) {
    return const <_MagicRecentCharacterRecord>[];
  }

  final preferences = await SharedPreferences.getInstance();
  final values = preferences.getStringList(
        _recentMagicCharacterIdsKey(
          storageKeyPrefix: storageKeyPrefix,
          username: trimmedUsername,
        ),
      ) ??
      const <String>[];
  final records = <_MagicRecentCharacterRecord>[];
  for (final value in values) {
    final record = _MagicRecentCharacterRecord.fromStorage(value);
    if (record != null &&
        !records.any((item) => item.characterId == record.characterId)) {
      records.add(record);
    }
    if (records.length >= _recentMagicCharacterLimit) {
      break;
    }
  }

  return records;
}

/// 生成魔法道具角色搜索最近使用缓存键
///
/// [storageKeyPrefix] 本地缓存键前缀
/// [username] 当前登录用户名
String _recentMagicCharacterIdsKey({
  required String storageKeyPrefix,
  required String username,
}) {
  return '${storageKeyPrefix.trim()}:${username.trim()}';
}
