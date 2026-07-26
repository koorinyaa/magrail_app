import 'package:magrail_app/features/user/assets/model/user_asset_snapshot.dart';

/// 两位用户的资产同步率
final class UserSyncRate {
  /// 创建两位用户的资产同步率
  ///
  /// [commonCharacterCount] 共同角色数量
  /// [commonTempleCount] 共同圣殿数量
  /// [progress] 归一化同步进度
  const UserSyncRate({
    required this.commonCharacterCount,
    required this.commonTempleCount,
    required this.progress,
  });

  /// 根据两位用户的资产标识计算同步率
  ///
  /// [currentUser] 当前登录用户资产标识
  /// [otherUser] 其他用户资产标识
  static UserSyncRate? calculate({
    required UserAssetIdSnapshot currentUser,
    required UserAssetIdSnapshot otherUser,
  }) {
    final hasNoCharacters =
        currentUser.characterIds.isEmpty && otherUser.characterIds.isEmpty;
    final hasNoTemples = currentUser.templeCharacterIds.isEmpty &&
        otherUser.templeCharacterIds.isEmpty;
    if (hasNoCharacters && hasNoTemples) {
      return null;
    }

    final commonCharacterCount = _countCommonIds(
      currentUser.characterIds,
      otherUser.characterIds,
    );
    final commonTempleCount = _countCommonIds(
      currentUser.templeCharacterIds,
      otherUser.templeCharacterIds,
    );
    final characterProgress = currentUser.characterIds.isEmpty
        ? 0.0
        : commonCharacterCount / currentUser.characterIds.length;
    final templeProgress = currentUser.templeCharacterIds.isEmpty
        ? 0.0
        : commonTempleCount / currentUser.templeCharacterIds.length;
    final progress = switch ((hasNoCharacters, hasNoTemples)) {
      (true, false) => templeProgress,
      (false, true) => characterProgress,
      _ => (characterProgress + templeProgress) / 2,
    };

    return UserSyncRate(
      commonCharacterCount: commonCharacterCount,
      commonTempleCount: commonTempleCount,
      progress: progress.clamp(0.0, 1.0).toDouble(),
    );
  }

  /// 共同角色数量
  final int commonCharacterCount;

  /// 共同圣殿数量
  final int commonTempleCount;

  /// 归一化同步进度
  final double progress;

  /// 保留完整精度的同步率百分比
  double get percentage => progress * 100;

  /// 四舍五入后的同步率整数
  int get roundedPercentage => percentage.round().clamp(0, 100).toInt();

  /// 计算两组角色 ID 的交集数量
  ///
  /// [currentIds] 当前登录用户角色 ID
  /// [otherIds] 其他用户角色 ID
  static int _countCommonIds(Set<int> currentIds, Set<int> otherIds) {
    return currentIds.where(otherIds.contains).length;
  }
}
