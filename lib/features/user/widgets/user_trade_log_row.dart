import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/tinygrail_trade_parties_line.dart';
import 'package:magrail_app/features/user/model/user_trade_log_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_pill.dart';

/// 用户交易记录行
class UserTradeLogRow extends StatelessWidget {
  /// 创建用户交易记录行
  ///
  /// [key] Flutter 组件标识
  /// [item] 用户交易记录条目
  /// [ownerUsername] 当前记录归属用户名
  /// [onUserTap] 用户点击回调
  /// [onCharacterTap] 角色点击回调
  const UserTradeLogRow({
    super.key,
    required this.item,
    required this.ownerUsername,
    this.onUserTap,
    this.onCharacterTap,
  });

  /// 用户交易记录条目
  final UserTradeLogApiItem item;

  /// 当前记录归属用户名
  final String ownerUsername;

  /// 用户点击回调
  final ValueChanged<String>? onUserTap;

  /// 角色点击回调
  final ValueChanged<int>? onCharacterTap;

  static const Color _buyColor = Color(0xFFFF5A91);
  static const Color _sellColor = Color(0xFF38A8E8);
  static const Color _sameIpColor = Color(0xFFF31260);

  /// 构建用户交易记录行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final direction = _resolveDirection();
    final directionColor = _directionColor(direction);
    final isSameIpTrade = item.isSameIpTrade;
    final userLineColor = isSameIpTrade ? _sameIpColor : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: _CharacterLabel(
                        characterId: item.characterId,
                        name: _characterName,
                        onTap: onCharacterTap,
                      ),
                    ),
                    const SizedBox(width: 6),
                    UserAssetRecordPill(
                      text: direction.label,
                      accentColor: directionColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
            sellerLabel: '$_sellerName ($_sellerIpLabel)',
            buyerUsername: item.buyer,
            buyerLabel: '$_buyerName ($_buyerIpLabel)',
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
            ),
          ),
        ],
      ),
    );
  }

  /// 展示角色名称
  String get _characterName {
    final name = TinygrailFormatters.decodeHtmlEntities(item.name).trim();
    if (name.isEmpty) {
      return '#${item.characterId}';
    }

    return name;
  }

  /// 展示卖家名称
  String get _sellerName {
    final nickname = TinygrailFormatters.decodeHtmlEntities(
      item.sellerName,
    ).trim();
    if (nickname.isNotEmpty) {
      return nickname;
    }

    return item.seller.trim().isEmpty ? '未知卖家' : item.seller;
  }

  /// 展示买家名称
  String get _buyerName {
    final nickname = TinygrailFormatters.decodeHtmlEntities(
      item.buyerName,
    ).trim();
    if (nickname.isNotEmpty) {
      return nickname;
    }

    return item.buyer.trim().isEmpty ? '未知买家' : item.buyer;
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

  /// 解析交易方向
  _TradeDirection _resolveDirection() {
    final owner = ownerUsername.trim();
    if (owner.isNotEmpty && item.buyer == owner) {
      return _TradeDirection.buy;
    }

    if (owner.isNotEmpty && item.seller == owner) {
      return _TradeDirection.sell;
    }

    return _TradeDirection.neutral;
  }

  /// 解析交易方向颜色
  ///
  /// [direction] 交易方向
  Color? _directionColor(_TradeDirection direction) {
    return switch (direction) {
      _TradeDirection.buy => _buyColor,
      _TradeDirection.sell => _sellColor,
      _TradeDirection.neutral => null,
    };
  }
}

/// 交易方向
enum _TradeDirection {
  /// 买入
  buy('买入'),

  /// 卖出
  sell('卖出'),

  /// 普通交易
  neutral('交易');

  /// 创建交易方向
  ///
  /// [label] 展示文案
  const _TradeDirection(this.label);

  /// 展示文案
  final String label;
}

/// 交易记录角色标签
class _CharacterLabel extends StatelessWidget {
  /// 创建交易记录角色标签
  ///
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [onTap] 点击回调
  const _CharacterLabel({
    required this.characterId,
    required this.name,
    this.onTap,
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 点击回调
  final ValueChanged<int>? onTap;

  /// 构建交易记录角色标签
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final text = '#$characterId「$name」';
    final textStyle = TextStyle(
      color: colorScheme.onSurface,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 1.1,
    );

    if (onTap == null || characterId <= 0) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap?.call(characterId),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}
