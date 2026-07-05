/// 创建角色详情头像转场标识
///
/// [characterId] 角色 ID
/// [avatarUrl] 入口头像地址
/// [source] 入口条目对象，用于区分同页重复角色头像
String? createCharacterDetailAvatarHeroTag({
  required int characterId,
  required String avatarUrl,
  required Object source,
}) {
  if (characterId <= 0 || avatarUrl.trim().isEmpty) {
    return null;
  }

  return 'character-detail-avatar-$characterId-${identityHashCode(source)}';
}
