import 'package:magrail_app/features/user/assets/model/user_asset_snapshot.dart';

/// 用户资产快照持久化记录
class UserAssetSnapshotRecord {
  /// 创建用户资产快照持久化记录
  ///
  /// [username] 用户名
  /// [nickname] 用户昵称
  /// [characterRows] 用户角色快照明细
  /// [templeRows] 用户圣殿快照明细
  /// [characterTotalItems] 角色接口总数
  /// [templeTotalItems] 圣殿接口总数
  /// [sourceState] 读取时返回的两类原始数据状态
  const UserAssetSnapshotRecord({
    required this.username,
    required this.nickname,
    required this.characterRows,
    required this.templeRows,
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
  final List<UserTempleSnapshotPayload> templeRows;

  /// 角色接口总数
  final int characterTotalItems;

  /// 圣殿接口总数
  final int templeTotalItems;

  /// 读取时返回的两类原始数据状态
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

/// 用户圣殿快照数据库明细
class UserTempleSnapshotPayload extends UserAssetSnapshotPayload {
  /// 创建用户圣殿快照数据库明细
  ///
  /// [id] 圣殿 ID
  /// [payloadJson] 圣殿 JSON
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [assets] 圣殿资产值
  /// [sacrifices] 圣殿资产上限
  /// [characterLevel] 角色等级
  /// [damaged] 圣殿受损程度
  /// [singleDividend] 修正后的圣殿单元股息
  /// [totalDividend] 修正后的圣殿总息
  /// [starForces] 圣殿星之力
  /// [refine] 圣殿精炼等级
  /// [create] 建塔日期
  const UserTempleSnapshotPayload({
    required super.id,
    required super.payloadJson,
    required this.characterId,
    required this.name,
    required this.assets,
    required this.sacrifices,
    required this.characterLevel,
    required this.damaged,
    required this.singleDividend,
    required this.totalDividend,
    required super.starForces,
    required this.refine,
    required this.create,
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 圣殿资产值
  final int assets;

  /// 圣殿资产上限
  final int sacrifices;

  /// 角色等级
  final int characterLevel;

  /// 圣殿受损程度
  final int damaged;

  /// 修正后的圣殿单元股息
  final double singleDividend;

  /// 修正后的圣殿总息
  final double totalDividend;

  /// 圣殿精炼等级
  final int refine;

  /// 建塔日期
  final String create;
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
