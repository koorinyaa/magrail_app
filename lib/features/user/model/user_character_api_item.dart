import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 用户角色接口条目
class UserCharacterApiItem {
  /// 创建用户角色接口条目
  ///
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [icon] 角色头像地址
  /// [level] 角色等级
  /// [zeroCount] ST 等级
  /// [starForces] 星之力
  /// [userAmount] 用户可用活股数量
  /// [userTotal] 用户持股数量
  /// [sacrifices] 固定资产数量
  /// [current] 当前价
  /// [fluctuation] 当前价涨跌幅
  /// [state] 数量
  /// [price] 价格
  /// [rate] 股息
  const UserCharacterApiItem({
    required this.characterId,
    required this.name,
    required this.icon,
    required this.level,
    required this.zeroCount,
    required this.starForces,
    required this.userAmount,
    required this.userTotal,
    required this.sacrifices,
    required this.current,
    required this.fluctuation,
    required this.state,
    required this.price,
    required this.rate,
  });

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

  /// 星之力
  final int starForces;

  /// 用户可用活股数量
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

  /// 从 JSON 创建用户角色接口条目
  ///
  /// [json] 原始条目 JSON
  factory UserCharacterApiItem.fromJson(Map<String, Object?> json) {
    final characterId = TinygrailResponseParser.asInt(json['CharacterId']);

    return UserCharacterApiItem(
      characterId: characterId == 0
          ? TinygrailResponseParser.asInt(json['Id'])
          : characterId,
      name: TinygrailResponseParser.asString(json['Name']),
      icon: TinygrailResponseParser.asString(json['Icon']),
      level: TinygrailResponseParser.asInt(json['Level']),
      zeroCount: TinygrailResponseParser.asInt(json['ZeroCount']),
      starForces: TinygrailResponseParser.asInt(json['StarForces']),
      userAmount: TinygrailResponseParser.asInt(json['UserAmount']),
      userTotal: TinygrailResponseParser.asInt(json['UserTotal']),
      sacrifices: TinygrailResponseParser.asInt(json['Sacrifices']),
      current: TinygrailResponseParser.asDouble(json['Current']),
      fluctuation: TinygrailResponseParser.asDouble(json['Fluctuation']),
      state: TinygrailResponseParser.asInt(json['State']),
      price: TinygrailResponseParser.asDouble(json['Price']),
      rate: TinygrailResponseParser.asDouble(json['Rate']),
    );
  }

  /// 转换为缓存 JSON
  Map<String, Object?> toJson() {
    return {
      'CharacterId': characterId,
      'Name': name,
      'Icon': icon,
      'Level': level,
      'ZeroCount': zeroCount,
      'StarForces': starForces,
      'UserAmount': userAmount,
      'UserTotal': userTotal,
      'Sacrifices': sacrifices,
      'Current': current,
      'Fluctuation': fluctuation,
      'State': state,
      'Price': price,
      'Rate': rate,
    };
  }
}
