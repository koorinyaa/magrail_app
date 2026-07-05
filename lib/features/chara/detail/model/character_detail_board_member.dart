import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';

/// 角色董事会成员资料
final class CharacterDetailBoardMember {
  /// 创建角色董事会成员资料
  ///
  /// [id] 用户内部 ID
  /// [name] 用户名
  /// [nickname] 用户昵称
  /// [avatar] 用户头像地址
  /// [balance] 角色持股数量
  /// [sacrifices] 圣殿数量
  /// [lastActiveDate] 最后活跃时间原始文本
  /// [lastIndex] 番市首富排名
  /// [state] 用户状态
  const CharacterDetailBoardMember({
    required this.id,
    required this.name,
    required this.nickname,
    required this.avatar,
    required this.balance,
    required this.sacrifices,
    required this.lastActiveDate,
    required this.lastIndex,
    required this.state,
  });

  /// 用户内部 ID
  final int id;

  /// 用户名
  final String name;

  /// 用户昵称
  final String nickname;

  /// 用户头像地址
  final String avatar;

  /// 角色持股数量
  final int balance;

  /// 圣殿数量
  final int sacrifices;

  /// 最后活跃时间原始文本
  final String lastActiveDate;

  /// 番市首富排名
  final int lastIndex;

  /// 用户状态
  final int state;

  /// 是否为小圣杯封禁状态
  bool get isBanned => state == 666;

  /// 用户展示名称
  String get displayName {
    final trimmedNickname = nickname.trim();
    if (trimmedNickname.isNotEmpty) {
      return TinygrailFormatters.decodeHtmlEntities(trimmedNickname);
    }

    return name;
  }

  /// 是否处于头像权限判定所需的活跃状态
  bool get isActiveForAvatarEdit {
    if (isBanned) {
      return false;
    }

    final parsed = TinygrailFormatters.parseServerTime(lastActiveDate);
    if (parsed == null) {
      return false;
    }

    return DateTime.now().difference(parsed.toLocal()) <
        const Duration(days: 5);
  }

  /// 从 JSON 创建角色董事会成员资料
  ///
  /// [json] 原始持股用户 JSON
  factory CharacterDetailBoardMember.fromJson(Map<String, Object?> json) {
    return CharacterDetailBoardMember(
      id: TinygrailResponseParser.asInt(json['Id']),
      name: TinygrailResponseParser.asString(json['Name']),
      nickname: TinygrailResponseParser.asString(json['Nickname']),
      avatar: TinygrailResponseParser.asString(json['Avatar']),
      balance: TinygrailResponseParser.asInt(json['Balance']),
      sacrifices: TinygrailResponseParser.asInt(json['Sacrifices']),
      lastActiveDate: TinygrailResponseParser.asString(json['LastActiveDate']),
      lastIndex: TinygrailResponseParser.asInt(json['LastIndex']),
      state: TinygrailResponseParser.asInt(json['State']),
    );
  }
}
