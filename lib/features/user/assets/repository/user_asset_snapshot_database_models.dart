import 'package:magrail_app/features/user/assets/model/user_asset_snapshot.dart';

/// 用户资产快照数据库行
class UserAssetSnapshotEntry {
  /// 创建用户资产快照数据库行
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [characterRows] 用户角色快照明细
  /// [templeRows] 用户圣殿快照明细
  /// [characterHeaderRows] 角色头部资料快照明细
  /// [characterTotalItems] 角色接口总数
  /// [templeTotalItems] 圣殿接口总数
  /// [sourceState] 读取时返回的三类原始数据状态
  const UserAssetSnapshotEntry({
    required this.username,
    required this.nickname,
    required this.characterRows,
    required this.templeRows,
    required this.characterHeaderRows,
    required this.characterTotalItems,
    required this.templeTotalItems,
    this.sourceState,
  });

  /// 用户名
  final String username;

  /// 用户昵称
  final String nickname;

  /// 用户角色快照明细
  final List<UserAssetSnapshotPayload> characterRows;

  /// 用户圣殿快照明细
  final List<UserAssetSnapshotPayload> templeRows;

  /// 角色头部资料快照明细
  final List<UserAssetSnapshotPayload> characterHeaderRows;

  /// 角色接口总数
  final int characterTotalItems;

  /// 圣殿接口总数
  final int templeTotalItems;

  /// 读取时返回的三类原始数据状态
  final UserAssetSourceState? sourceState;
}

/// 用户资产快照数据库明细
class UserAssetSnapshotPayload {
  /// 创建用户资产快照数据库明细
  ///
  /// [id] 资产主键
  /// [payloadJson] 资产 JSON
  /// [starForces] 圣殿星之力，非圣殿明细为零
  const UserAssetSnapshotPayload({
    required this.id,
    required this.payloadJson,
    this.starForces = 0,
  });

  /// 资产主键
  final int id;

  /// 资产 JSON
  final String payloadJson;

  /// 圣殿星之力
  final int starForces;
}
