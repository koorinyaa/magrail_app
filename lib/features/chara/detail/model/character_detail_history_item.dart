import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 角色详情历史条目
class CharacterDetailHistoryItem {
  /// 创建角色详情历史条目
  ///
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [avatarUrl] 角色头像地址
  const CharacterDetailHistoryItem({
    required this.characterId,
    required this.name,
    required this.avatarUrl,
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 角色头像地址
  final String avatarUrl;

  /// 是否已有角色名称
  bool get hasName => name.trim().isNotEmpty;

  /// 是否已有角色头像
  bool get hasAvatar => avatarUrl.trim().isNotEmpty;

  /// 角色详情顶部展示名称
  String get displayName {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return '#$characterId';
    }

    return trimmedName;
  }

  /// 合并入口资料与已缓存资料
  ///
  /// [cached] 已缓存的角色资料
  CharacterDetailHistoryItem mergeWith(CharacterDetailHistoryItem? cached) {
    if (cached == null) {
      return this;
    }

    final nextName = name.trim().isNotEmpty ? name : cached.name;
    final nextAvatarUrl =
        avatarUrl.trim().isNotEmpty ? avatarUrl : cached.avatarUrl;

    return CharacterDetailHistoryItem(
      characterId: characterId,
      name: nextName,
      avatarUrl: nextAvatarUrl,
    );
  }

  /// 从 JSON 创建角色详情历史条目
  ///
  /// [json] 原始历史条目 JSON
  factory CharacterDetailHistoryItem.fromJson(Map<String, Object?> json) {
    return CharacterDetailHistoryItem(
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      name: TinygrailResponseParser.asString(json['Name']),
      avatarUrl: TinygrailResponseParser.asString(json['AvatarUrl']),
    );
  }

  /// 转换为缓存 JSON
  Map<String, Object?> toJson() {
    return {
      'CharacterId': characterId,
      'Name': name,
      'AvatarUrl': avatarUrl,
    };
  }
}
