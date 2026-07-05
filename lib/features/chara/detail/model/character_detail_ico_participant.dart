import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';

/// 角色详情 ICO 参与者资料
final class CharacterDetailIcoParticipant {
  /// 创建角色详情 ICO 参与者资料
  ///
  /// [name] 用户名
  /// [nickname] 用户昵称
  /// [avatar] 用户头像地址
  /// [amount] 投入金额
  /// [lastIndex] 番市首富排名
  /// [state] 用户状态
  const CharacterDetailIcoParticipant({
    required this.name,
    required this.nickname,
    required this.avatar,
    required this.amount,
    required this.lastIndex,
    required this.state,
  });

  /// 用户名
  final String name;

  /// 用户昵称
  final String nickname;

  /// 用户头像地址
  final String avatar;

  /// 投入金额
  final double amount;

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

  /// 投入金额展示文案
  String get amountLabel {
    if (amount <= 0) {
      return '+???';
    }

    return '+${Formatters.groupedNumber(amount)}';
  }

  /// 从 JSON 创建角色详情 ICO 参与者资料
  ///
  /// [json] 原始参与者 JSON
  factory CharacterDetailIcoParticipant.fromJson(
    Map<String, Object?> json,
  ) {
    return CharacterDetailIcoParticipant(
      name: TinygrailResponseParser.asString(json['Name']),
      nickname: TinygrailResponseParser.asString(
        json['NickName'] ?? json['Nickname'],
      ),
      avatar: TinygrailResponseParser.asString(json['Avatar']),
      amount: TinygrailResponseParser.asDouble(json['Amount']),
      lastIndex: TinygrailResponseParser.asInt(json['LastIndex']),
      state: TinygrailResponseParser.asInt(json['State']),
    );
  }
}
