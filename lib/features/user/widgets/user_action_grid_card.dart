import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/features/user/model/user_action_entry.dart';

/// 用户菜单网格卡片
class UserActionGridCard extends StatelessWidget {
  /// 创建用户菜单网格卡片
  ///
  /// [key] Flutter 组件标识
  /// [actions] 用户菜单入口列表
  /// [onActionPressed] 菜单入口点击回调
  const UserActionGridCard({
    super.key,
    required this.actions,
    required this.onActionPressed,
  });

  /// 用户菜单入口列表
  final List<UserActionEntry> actions;

  /// 菜单入口点击回调
  final ValueChanged<UserActionEntry> onActionPressed;

  /// 构建用户菜单网格卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerLow : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const minItemWidth = 88.0;
          final rawColumnCount = (constraints.maxWidth / minItemWidth).floor();
          final columnCount = switch (rawColumnCount) {
            < 1 => 1,
            > 6 => 6,
            _ => rawColumnCount,
          };
          final itemWidth = constraints.maxWidth / columnCount;

          return Wrap(
            alignment: WrapAlignment.start,
            runSpacing: 8,
            spacing: 0,
            children: [
              for (final action in actions)
                SizedBox(
                  width: itemWidth,
                  height: 56,
                  child: _UserActionGridItem(
                    action: action,
                    onPressed: () => onActionPressed(action),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// 用户菜单网格项
class _UserActionGridItem extends StatelessWidget {
  /// 创建用户菜单网格项
  ///
  /// [action] 用户菜单入口
  /// [onPressed] 入口点击回调
  const _UserActionGridItem({
    required this.action,
    required this.onPressed,
  });

  /// 用户菜单入口
  final UserActionEntry action;

  /// 入口点击回调
  final VoidCallback onPressed;

  /// 构建用户菜单网格项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHighlighted = _shouldHighlightAction(action.type);
    final foregroundColor = _resolveForegroundColor(
      colorScheme,
      isHighlighted: isHighlighted,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _iconForType(action.type),
              size: 22,
              color: foregroundColor,
            ),
            const SizedBox(height: 6),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 12,
                fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 判断菜单入口是否需要强调
  ///
  /// [type] 用户菜单入口类型
  bool _shouldHighlightAction(UserActionType type) {
    return type == UserActionType.holidayBonus;
  }

  /// 解析菜单入口前景色
  ///
  /// [colorScheme] 当前主题色板
  /// [isHighlighted] 是否为强调入口
  Color _resolveForegroundColor(
    ColorScheme colorScheme, {
    required bool isHighlighted,
  }) {
    if (!isHighlighted) {
      return colorScheme.onSurface;
    }

    return colorScheme.primary;
  }

  /// 获取菜单入口图标
  ///
  /// [type] 用户菜单入口类型
  IconData _iconForType(UserActionType type) {
    return switch (type) {
      UserActionType.scratch => Icons.casino_outlined,
      UserActionType.weeklyBonus => Icons.monetization_on_outlined,
      UserActionType.dailyBonus => Icons.event_available_outlined,
      UserActionType.balanceLog => Icons.pending_actions_outlined,
      UserActionType.myAuction => LucideIcons.gavel,
      UserActionType.marketOrder => Icons.swap_horiz_rounded,
      UserActionType.myItems => Icons.category_outlined,
      UserActionType.holidayBonus => Icons.card_giftcard_outlined,
      UserActionType.dividendForecast => Icons.show_chart_rounded,
      UserActionType.bot => LucideIcons.bot,
      UserActionType.tradeLog => Icons.receipt_long_outlined,
      UserActionType.block => Icons.block_rounded,
      UserActionType.unblock => Icons.lock_open_rounded,
    };
  }
}
