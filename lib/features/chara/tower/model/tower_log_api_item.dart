import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 通天塔日志接口条目
///
/// [icon] 角色头像地址
/// [id] 日志 ID
/// [characterId] 角色 ID
/// [characterName] 角色名称
/// [userId] 用户内部 ID
/// [userName] 用户名
/// [nickname] 用户昵称
/// [amount] 数量
/// [fromCharacterId] 来源角色 ID
/// [stars] 星级
/// [starForces] 星之力
/// [rank] 当前排名
/// [oldRank] 变动前排名
/// [loss] 变动损失
/// [logTime] 日志时间
/// [type] 日志类型
class TowerLogApiItem {
  /// 创建通天塔日志接口条目
  const TowerLogApiItem({
    required this.icon,
    required this.id,
    required this.characterId,
    required this.characterName,
    required this.userId,
    required this.userName,
    required this.nickname,
    required this.amount,
    required this.fromCharacterId,
    required this.stars,
    required this.starForces,
    required this.rank,
    required this.oldRank,
    required this.loss,
    required this.logTime,
    required this.type,
  });

  /// 角色头像地址
  final String icon;

  /// 日志 ID
  final int id;

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String characterName;

  /// 用户内部 ID
  final int userId;

  /// 用户名
  final String userName;

  /// 用户昵称
  final String nickname;

  /// 行为数量
  final int amount;

  /// 来源角色 ID
  final int fromCharacterId;

  /// 星级
  final int stars;

  /// 星之力
  final int starForces;

  /// 当前通天塔排名
  final int rank;

  /// 变动前通天塔排名
  final int oldRank;

  /// 变动损失
  final int loss;

  /// 日志时间
  final String logTime;

  /// 日志类型
  final int type;

  /// 从 JSON 创建通天塔日志接口条目
  ///
  /// [json] 原始条目 JSON
  factory TowerLogApiItem.fromJson(Map<String, Object?> json) {
    return TowerLogApiItem(
      icon: TinygrailResponseParser.asString(json['Icon']),
      id: TinygrailResponseParser.asInt(json['Id']),
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      characterName: TinygrailResponseParser.asString(json['CharacterName']),
      userId: TinygrailResponseParser.asInt(json['UserId']),
      userName: TinygrailResponseParser.asString(json['UserName']),
      nickname: TinygrailResponseParser.asString(json['Nickname']),
      amount: TinygrailResponseParser.asInt(json['Amount']),
      fromCharacterId: TinygrailResponseParser.asInt(json['FromCharacterId']),
      stars: TinygrailResponseParser.asInt(json['Stars']),
      starForces: TinygrailResponseParser.asInt(json['StarForces']),
      rank: TinygrailResponseParser.asInt(json['Rank']),
      oldRank: TinygrailResponseParser.asInt(json['OldRank']),
      loss: TinygrailResponseParser.asInt(json['Loss']),
      logTime: TinygrailResponseParser.asString(json['LogTime']),
      type: TinygrailResponseParser.asInt(json['Type']),
    );
  }
}
