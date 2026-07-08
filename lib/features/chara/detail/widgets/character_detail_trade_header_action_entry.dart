part of 'character_detail_trade_header_card.dart';

/// 已上市头部操作入口类型
enum _TradeHeaderActionType {
  /// 资产重组入口
  sacrifice,

  /// 竞拍入口
  auction,

  /// 往期拍卖入口
  auctionHistory,

  /// 更换头像入口
  changeAvatar,

  /// 交易记录入口
  tradeHistory,

  /// GM 交易记录入口
  gmTradeHistory,

  /// GM 投票删除入口
  voteKill,

  /// GM 撤回投票入口
  revokeVote,

  /// GM 查看投票入口
  viewVotes,

  /// 角色资料同步入口
  syncProfile,

  /// Bangumi 关联角色入口
  bangumiRelations,

  /// Bangumi 出演作品入口
  bangumiCasts,
}

/// 已上市头部操作入口
final class _TradeHeaderActionEntry {
  /// 创建已上市头部操作入口
  ///
  /// [type] 操作入口类型
  /// [label] 操作入口文案
  /// [icon] 操作入口图标
  /// [isHighlighted] 是否使用强调色
  const _TradeHeaderActionEntry({
    required this.type,
    required this.label,
    required this.icon,
    this.isHighlighted = false,
  });

  /// 操作入口类型
  final _TradeHeaderActionType type;

  /// 操作入口文案
  final String label;

  /// 操作入口图标
  final IconData icon;

  /// 是否使用强调色
  final bool isHighlighted;
}

/// 已上市头部操作入口按钮
class _TradeHeaderActionButton extends StatelessWidget {
  /// 创建已上市头部操作入口按钮
  ///
  /// [action] 操作入口
  /// [onPressed] 点击回调
  /// [isLoading] 是否正在提交
  const _TradeHeaderActionButton({
    required this.action,
    required this.onPressed,
    required this.isLoading,
  });

  /// 操作入口
  final _TradeHeaderActionEntry action;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 是否正在提交
  final bool isLoading;

  /// 构建已上市头部操作入口按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor =
        action.isHighlighted ? colorScheme.primary : colorScheme.onSurface;
    final resolvedForegroundColor = onPressed == null && !isLoading
        ? colorScheme.onSurface.withValues(alpha: 0.48)
        : foregroundColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: resolvedForegroundColor,
                ),
              )
            else
              Icon(
                action.icon,
                size: 22,
                color: resolvedForegroundColor,
              ),
            const SizedBox(height: 6),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: resolvedForegroundColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
