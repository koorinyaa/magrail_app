part of 'user_asset_snapshot_repository.dart';

/// 用户资产快照仓库的圣殿修复数据实现
extension UserAssetSnapshotRepositoryRepair on UserAssetSnapshotRepository {
  /// 获取受损圣殿补塔需要的完整原始数据
  ///
  /// [username] 用户名
  Future<
    ({List<UserTempleApiItem> temples, List<UserCharacterApiItem> characters})
  >
  fetchTempleRepairSource({required String username}) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      throw StateError('缺少用户名');
    }
    final requestGate = _UserAssetSnapshotRequestGate(
      UserAssetSnapshotRepository._maxServerConcurrency,
    );
    final results = await Future.wait<Object>([
      _fetchAllTemplesShared(
        username: resolvedUsername,
        requestGate: requestGate,
        onProgress: _ignoreSnapshotProgress,
        totalItemsHint: null,
      ),
      _fetchAllCharactersShared(
        username: resolvedUsername,
        requestGate: requestGate,
        onProgress: _ignoreSnapshotProgress,
        totalItemsHint: null,
      ),
    ]);
    final templeResult = results[0] as _AllTemplesResult;
    final characterResult = results[1] as _AllCharactersResult;
    return (temples: templeResult.items, characters: characterResult.items);
  }
}
