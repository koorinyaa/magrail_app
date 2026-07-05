import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';

/// 用户详情页展示资料
final class UserDetailProfile {
  /// 创建用户详情页展示资料
  ///
  /// [userId] 用户 ID
  /// [name] 用户名
  /// [nickname] 用户昵称
  /// [rank] 用户排名
  /// [avatar] 用户头像地址
  /// [balance] 余额
  /// [assets] 资产
  /// [type] 用户类型
  /// [state] 用户状态
  /// [showDaily] 是否显示签到奖励
  /// [showWeekly] 是否显示每周分红
  /// [showHoliday] 是否显示节日福利
  /// [holidayName] 节日福利名称
  const UserDetailProfile({
    required this.userId,
    required this.name,
    required this.nickname,
    required this.rank,
    required this.avatar,
    required this.balance,
    required this.assets,
    required this.type,
    required this.state,
    required this.showDaily,
    required this.showWeekly,
    this.showHoliday = false,
    this.holidayName,
  });

  /// 用户 ID
  final int userId;

  /// 用户名
  final String name;

  /// 用户昵称
  final String nickname;

  /// 用户排名
  final int rank;

  /// 用户头像地址
  final String avatar;

  /// 余额
  final num balance;

  /// 资产
  final num assets;

  /// 用户类型
  final int type;

  /// 用户状态
  final int state;

  /// 是否显示签到奖励
  final bool showDaily;

  /// 是否显示每周分红
  final bool showWeekly;

  /// 是否显示节日福利
  final bool showHoliday;

  /// 节日福利名称
  final String? holidayName;

  /// 是否为小圣杯封禁状态
  bool get isBanned => state == 666;

  /// 是否为 GM 用户
  bool get isGameMaster => type >= 999 || userId == 702;

  /// 合并节日福利状态
  ///
  /// [showHoliday] 是否显示节日福利
  /// [holidayName] 节日福利名称
  UserDetailProfile copyWithHoliday({
    required bool showHoliday,
    String? holidayName,
  }) {
    return UserDetailProfile(
      userId: userId,
      name: name,
      nickname: nickname,
      rank: rank,
      avatar: avatar,
      balance: balance,
      assets: assets,
      type: type,
      state: state,
      showDaily: showDaily,
      showWeekly: showWeekly,
      showHoliday: showHoliday,
      holidayName: holidayName,
    );
  }

  /// 从 JSON 创建用户详情页展示资料
  ///
  /// [json] 原始响应 JSON
  factory UserDetailProfile.fromJson(Map<String, Object?> json) {
    return UserDetailProfile(
      userId: TinygrailResponseParser.asInt(json['Id']),
      name: TinygrailResponseParser.asString(json['Name']),
      nickname: TinygrailFormatters.decodeHtmlEntities(
        TinygrailResponseParser.asString(json['Nickname']),
      ),
      rank: TinygrailResponseParser.asInt(json['LastIndex']),
      avatar: TinygrailResponseParser.asString(json['Avatar']),
      balance: TinygrailResponseParser.asDouble(json['Balance']),
      assets: TinygrailResponseParser.asDouble(json['Assets']),
      type: TinygrailResponseParser.asInt(json['Type']),
      state: TinygrailResponseParser.asInt(json['State']),
      showDaily: TinygrailResponseParser.asInt(json['ShowDaily']) != 0 ||
          json['ShowDaily'] == true,
      showWeekly: TinygrailResponseParser.asInt(json['ShowWeekly']) != 0 ||
          json['ShowWeekly'] == true,
      showHoliday: TinygrailResponseParser.asInt(json['ShowHoliday']) != 0 ||
          json['ShowHoliday'] == true,
      holidayName: TinygrailResponseParser.asNullableString(
        json['HolidayName'],
      ),
    );
  }

  /// 转换为缓存 JSON
  Map<String, Object?> toJson() {
    return {
      'Id': userId,
      'Name': name,
      'Nickname': nickname,
      'LastIndex': rank,
      'Avatar': avatar,
      'Balance': balance,
      'Assets': assets,
      'Type': type,
      'State': state,
      'ShowDaily': showDaily,
      'ShowWeekly': showWeekly,
      'ShowHoliday': showHoliday,
      'HolidayName': holidayName,
    };
  }
}
