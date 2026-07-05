import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/tinygrail_trade_parties_line.dart';
import 'package:magrail_app/features/chara/trade_history/model/character_gm_trade_history_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_pill.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_sliver_list_layout.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 角色 GM 交易记录 sliver 列表
class CharacterGmTradeHistorySliverList extends StatelessWidget {
  /// 创建角色 GM 交易记录 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 角色 GM 交易记录条目
  /// [onItemBuilt] 条目构建回调
  /// [onUserTap] 用户点击回调
  const CharacterGmTradeHistorySliverList({
    super.key,
    required this.items,
    this.onItemBuilt,
    this.onUserTap,
  });

  /// 角色 GM 交易记录条目
  final List<CharacterGmTradeHistoryItem> items;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 用户点击回调
  final ValueChanged<String>? onUserTap;

  /// 构建角色 GM 交易记录 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        onItemBuilt?.call(index);
        return UserAssetRecordListItem(
          child: _CharacterGmTradeHistoryRow(
            item: items[index],
            onUserTap: onUserTap,
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const _CharacterGmTradeHistoryDivider(),
      itemCount: items.length,
    );
  }
}

/// 角色 GM 交易记录骨架 sliver 列表
class CharacterGmTradeHistorySkeletonSliverList extends StatelessWidget {
  /// 创建角色 GM 交易记录骨架 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  const CharacterGmTradeHistorySkeletonSliverList({
    super.key,
    this.itemCount = 12,
  });

  /// 骨架条目数量
  final int itemCount;

  /// 构建角色 GM 交易记录骨架 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return const UserAssetRecordListItem(
          child: _CharacterGmTradeHistorySkeletonRow(),
        );
      },
      separatorBuilder: (context, index) =>
          const _CharacterGmTradeHistoryDivider(),
      itemCount: itemCount,
    );
  }
}

/// 角色 GM 交易记录行
class _CharacterGmTradeHistoryRow extends StatelessWidget {
  /// 创建角色 GM 交易记录行
  ///
  /// [item] 角色 GM 交易记录条目
  /// [onUserTap] 用户点击回调
  const _CharacterGmTradeHistoryRow({
    required this.item,
    this.onUserTap,
  });

  /// 角色 GM 交易记录条目
  final CharacterGmTradeHistoryItem item;

  /// 用户点击回调
  final ValueChanged<String>? onUserTap;

  /// 构建角色 GM 交易记录行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSameIpTrade = item.isSameIpTrade;
    final userLineColor = isSameIpTrade ? _sameIpColor : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UserAssetRecordPill(text: '交易'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                LucideIcons.clock3,
                size: 12,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.58),
              ),
              const SizedBox(width: 4),
              Text(
                TinygrailFormatters.relativeTime(item.tradeTime),
                maxLines: 1,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          TinygrailTradePartiesLine(
            sellerUsername: item.seller,
            sellerLabel: '${item.sellerDisplayName} ($_sellerIpLabel)',
            buyerUsername: item.buyer,
            buyerLabel: '${item.buyerDisplayName} ($_buyerIpLabel)',
            color: userLineColor,
            arrowColor: isSameIpTrade
                ? userLineColor
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
            onUserTap: onUserTap,
          ),
          const SizedBox(height: 6),
          Text(
            '${Formatters.tinygrailCurrency(item.price)} · ${Formatters.groupedNumber(item.amount)} 股',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.15,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  /// 展示卖家 IP
  String get _sellerIpLabel => _resolveIpLabel(item.sellerIp);

  /// 展示买家 IP
  String get _buyerIpLabel => _resolveIpLabel(item.buyerIp);

  /// 解析 IP 展示文案
  ///
  /// [ip] 原始 IP 记录
  String _resolveIpLabel(String ip) {
    final resolvedIp = ip.trim();
    if (resolvedIp.isEmpty || resolvedIp.toLowerCase() == 'no record') {
      return '无记录';
    }

    return resolvedIp;
  }
}

/// 角色 GM 交易记录分割线
class _CharacterGmTradeHistoryDivider extends StatelessWidget {
  /// 创建角色 GM 交易记录分割线
  const _CharacterGmTradeHistoryDivider();

  /// 构建角色 GM 交易记录分割线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return UserAssetRecordListItem(
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: colorScheme.outlineVariant.withValues(
          alpha: isDark ? 0.32 : 0.58,
        ),
      ),
    );
  }
}

/// 角色 GM 交易记录骨架行
class _CharacterGmTradeHistorySkeletonRow extends StatelessWidget {
  /// 创建角色 GM 交易记录骨架行
  const _CharacterGmTradeHistorySkeletonRow();

  /// 构建角色 GM 交易记录骨架行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Skeletonizer.zone(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Bone(
                        width: 42,
                        height: 20,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Bone(
                  width: 12,
                  height: 12,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                SizedBox(width: 4),
                Bone.text(width: 54, fontSize: 11),
              ],
            ),
            SizedBox(height: 7),
            Row(
              children: [
                Bone.text(width: 116, fontSize: 12),
                SizedBox(width: 6),
                Bone(
                  width: 14,
                  height: 14,
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                SizedBox(width: 6),
                Bone.text(width: 116, fontSize: 12),
              ],
            ),
            SizedBox(height: 6),
            Bone.text(width: 132, fontSize: 12),
          ],
        ),
      ),
    );
  }
}

const Color _sameIpColor = Color(0xFFF31260);
