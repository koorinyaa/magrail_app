import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 角色删除投票记录
final class CharacterDetailKillVote {
  /// 创建角色删除投票记录
  ///
  /// [characterId] 角色 ID
  /// [userId] 投票用户 ID
  /// [reason] 删除理由
  /// [updateTime] 更新时间原始文本
  /// [voteTime] 投票时间原始文本
  /// [state] 投票状态
  const CharacterDetailKillVote({
    required this.characterId,
    required this.userId,
    required this.reason,
    required this.updateTime,
    required this.voteTime,
    required this.state,
  });

  /// 角色 ID
  final int characterId;

  /// 投票用户 ID
  final int userId;

  /// 删除理由
  final String reason;

  /// 更新时间原始文本
  final String updateTime;

  /// 投票时间原始文本
  final String voteTime;

  /// 投票状态
  final int state;

  /// 从 JSON 创建角色删除投票记录
  ///
  /// [json] 原始投票 JSON
  factory CharacterDetailKillVote.fromJson(Map<String, Object?> json) {
    return CharacterDetailKillVote(
      characterId: TinygrailResponseParser.asInt(json['CharacterId']),
      userId: TinygrailResponseParser.asInt(json['UserId']),
      reason: TinygrailResponseParser.asString(json['Reason']),
      updateTime: TinygrailResponseParser.asString(json['UpdateTime']),
      voteTime: TinygrailResponseParser.asString(json['VoteTime']),
      state: TinygrailResponseParser.asInt(json['State']),
    );
  }
}
