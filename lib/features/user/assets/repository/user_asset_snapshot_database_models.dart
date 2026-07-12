import 'package:magrail_app/features/user/assets/model/user_asset_snapshot.dart';

/// 用户资产快照持久化记录
class UserAssetSnapshotRecord {
  /// 创建用户资产快照持久化记录
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [characterRows] 用户角色快照明细
  /// [templeRows] 用户圣殿快照明细
  /// [characterHeaderRows] 角色头部资料快照明细
  /// [characterTotalItems] 角色接口总数
  /// [templeTotalItems] 圣殿接口总数
  /// [sourceState] 读取时返回的三类原始数据状态
  const UserAssetSnapshotRecord({
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
  final List<UserCharacterSnapshotPayload> characterRows;

  /// 用户圣殿快照明细
  final List<UserAssetSnapshotPayload> templeRows;

  /// 角色头部资料快照明细
  final List<UserCharacterHeaderSnapshotPayload> characterHeaderRows;

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
  /// [starForces] 角色或圣殿星之力
  const UserAssetSnapshotPayload({
    required this.id,
    required this.payloadJson,
    this.starForces = 0,
  });

  /// 资产主键
  final int id;

  /// 资产 JSON
  final String payloadJson;

  /// 角色或圣殿星之力
  final int starForces;
}

/// 用户角色快照数据库明细
class UserCharacterSnapshotPayload extends UserAssetSnapshotPayload {
  /// 创建用户角色快照数据库明细
  ///
  /// [id] 角色 ID
  /// [payloadJson] 角色 JSON
  /// [name] 角色名称
  /// [icon] 角色头像地址
  /// [level] 角色等级
  /// [zeroCount] ST 等级
  /// [starForces] 星之力
  /// [stars] 角色星级
  /// [userAmount] 用户可用持股数量
  /// [userTotal] 用户持股数量
  /// [sacrifices] 固定资产数量
  /// [current] 当前价
  /// [fluctuation] 当前价涨跌幅
  /// [state] 数量
  /// [price] 价格
  /// [rate] 股息
  /// [rank] 通天塔排名
  /// [singleDividend] 角色单期股息
  /// [totalDividend] 角色持股总息
  const UserCharacterSnapshotPayload({
    required super.id,
    required super.payloadJson,
    required this.name,
    required this.icon,
    required this.level,
    required this.zeroCount,
    required super.starForces,
    required this.stars,
    required this.userAmount,
    required this.userTotal,
    required this.sacrifices,
    required this.current,
    required this.fluctuation,
    required this.state,
    required this.price,
    required this.rate,
    required this.rank,
    required this.singleDividend,
    required this.totalDividend,
  });

  /// 角色名称
  final String name;

  /// 角色头像地址
  final String icon;

  /// 角色等级
  final int level;

  /// ST 等级
  final int zeroCount;

  /// 角色星级
  final int stars;

  /// 用户可用持股数量
  final int userAmount;

  /// 用户持股数量
  final int userTotal;

  /// 固定资产数量
  final int sacrifices;

  /// 当前价
  final double current;

  /// 当前价涨跌幅
  final double fluctuation;

  /// 数量
  final int state;

  /// 价格
  final double price;

  /// 股息
  final double rate;

  /// 通天塔排名
  final int rank;

  /// 角色单期股息
  final double singleDividend;

  /// 角色持股总息
  final double totalDividend;
}

/// 全部角色资料快照数据库明细
class UserCharacterHeaderSnapshotPayload extends UserAssetSnapshotPayload {
  /// 创建全部角色资料快照数据库明细
  ///
  /// [id] 角色 ID
  /// [payloadJson] 角色资料 JSON
  /// [rank] 通天塔排名
  const UserCharacterHeaderSnapshotPayload({
    required super.id,
    required super.payloadJson,
    required this.rank,
  });

  /// 通天塔排名
  final int rank;
}
