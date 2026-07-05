/// 圣殿资产弹窗入口数据
class TempleAssetDialogSource {
  /// 创建圣殿资产弹窗入口数据
  ///
  /// [ownerName] 圣殿所属用户名
  /// [ownerNickname] 圣殿所属用户昵称
  /// [characterId] 圣殿角色 ID
  const TempleAssetDialogSource({
    required this.ownerName,
    required this.ownerNickname,
    required this.characterId,
  });

  /// 圣殿所属用户名
  final String ownerName;

  /// 圣殿所属用户昵称
  final String ownerNickname;

  /// 圣殿角色 ID
  final int characterId;
}
