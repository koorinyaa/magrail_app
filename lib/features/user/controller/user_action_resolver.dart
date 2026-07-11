import 'package:magrail_app/features/user/model/user_action_entry.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';

/// 用户菜单入口解析器
class UserActionResolver {
  /// 创建用户菜单入口解析器
  const UserActionResolver();

  /// 解析当前可见的用户菜单入口
  ///
  /// [profile] 当前展示的用户资料
  /// [cachedUser] 当前登录用户缓存资料
  /// [isCurrentUserRequest] 是否为当前登录用户入口
  List<UserActionEntry> resolve({
    required UserDetailProfile profile,
    required UserDetailProfile? cachedUser,
    required bool isCurrentUserRequest,
  }) {
    // 当前用户入口不依赖本地缓存判断，避免缓存失效时隐藏自己的操作区
    final isSelf = isCurrentUserRequest || cachedUser?.name == profile.name;
    if (isSelf) {
      return [
        const UserActionEntry(type: UserActionType.scratch, label: '刮刮乐'),
        if (profile.showWeekly)
          const UserActionEntry(
            type: UserActionType.weeklyBonus,
            label: '每周分红',
          ),
        if (profile.showDaily)
          const UserActionEntry(
            type: UserActionType.dailyBonus,
            label: '签到奖励',
          ),
        const UserActionEntry(type: UserActionType.balanceLog, label: '资金日志'),
        const UserActionEntry(type: UserActionType.myAuction, label: '我的拍卖'),
        const UserActionEntry(type: UserActionType.marketOrder, label: '委托订单'),
        const UserActionEntry(type: UserActionType.myItems, label: '我的道具'),
        if (profile.showHoliday)
          UserActionEntry(
            type: UserActionType.holidayBonus,
            label: '${profile.holidayName ?? '节日'}福利',
          ),
        const UserActionEntry(
          type: UserActionType.dividendForecast,
          label: '股息预测',
        ),
        const UserActionEntry(
          type: UserActionType.assetAnalysis,
          label: '资产分析',
        ),
        const UserActionEntry(type: UserActionType.bot, label: 'Bot配置'),
        if (profile.isGameMaster)
          const UserActionEntry(type: UserActionType.tradeLog, label: '交易记录'),
      ];
    }

    if (cachedUser?.isGameMaster != true) {
      return const [];
    }

    return [
      const UserActionEntry(
        type: UserActionType.dividendForecast,
        label: '股息预测',
      ),
      const UserActionEntry(type: UserActionType.tradeLog, label: '交易记录'),
      if (profile.isBanned)
        const UserActionEntry(type: UserActionType.unblock, label: '解封')
      else
        const UserActionEntry(type: UserActionType.block, label: '封禁'),
    ];
  }
}
