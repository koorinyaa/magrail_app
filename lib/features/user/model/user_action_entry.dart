/// 用户菜单入口类型
enum UserActionType {
  /// 刮刮乐入口
  scratch,

  /// 每周分红入口
  weeklyBonus,

  /// 签到奖励入口
  dailyBonus,

  /// 资金日志入口
  balanceLog,

  /// 我的拍卖入口
  myAuction,

  /// 委托订单入口
  marketOrder,

  /// 我的道具入口
  myItems,

  /// 节日福利入口
  holidayBonus,

  /// 股息预测入口
  dividendForecast,

  /// 资产分析入口
  assetAnalysis,

  /// bot 配置入口
  bot,

  /// 交易记录入口
  tradeLog,

  /// 封禁入口
  block,

  /// 解封入口
  unblock,
}

/// 用户菜单入口
final class UserActionEntry {
  /// 创建用户菜单入口
  ///
  /// [type] 入口类型
  /// [label] 入口文案
  const UserActionEntry({
    required this.type,
    required this.label,
  });

  /// 入口类型
  final UserActionType type;

  /// 入口文案
  final String label;
}
