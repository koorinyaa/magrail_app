import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/features/user/model/user_market_order_api_item.dart';

/// 用户委托订单行
class UserMarketOrderRow extends StatelessWidget {
  /// 创建用户委托订单行
  ///
  /// [key] Flutter 组件标识
  /// [item] 用户委托订单条目
  /// [side] 委托订单方向
  /// [avatarHeroTag] 头像转场标识
  /// [onTap] 条目点击回调
  const UserMarketOrderRow({
    super.key,
    required this.item,
    required this.side,
    this.avatarHeroTag,
    this.onTap,
  });

  /// 用户委托订单条目
  final UserMarketOrderApiItem item;

  /// 委托订单方向
  final UserMarketOrderSide side;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 条目点击回调
  final VoidCallback? onTap;

  /// 构建用户委托订单行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSafeAreaInsets.symmetricHorizontal(
            context,
            horizontal: 12,
            vertical: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UserMarketOrderAvatar(
                imageUrl: TinygrailAssetUrls.normalizeAvatar(item.icon),
                heroTag: avatarHeroTag,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              LevelBadge(
                                level: item.level,
                                zeroCount: item.zeroCount,
                                isCompact: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          TinygrailFormatters.relativeTime(item.lastOrder),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$_countLabel ${Formatters.groupedNumber(item.state)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 展示角色名称
  String get _displayName {
    final name = TinygrailFormatters.decodeHtmlEntities(item.name).trim();
    if (name.isEmpty) {
      return '#${item.characterId}';
    }

    return name;
  }

  /// 数量标签
  String get _countLabel {
    return switch (side) {
      UserMarketOrderSide.bid => '买单数量',
      UserMarketOrderSide.ask => '卖单数量',
    };
  }
}

/// 用户委托订单角色头像
class _UserMarketOrderAvatar extends StatelessWidget {
  /// 创建用户委托订单角色头像
  ///
  /// [imageUrl] 角色头像地址
  /// [heroTag] 头像转场标识
  const _UserMarketOrderAvatar({
    required this.imageUrl,
    required this.heroTag,
  });

  /// 角色头像地址
  final String imageUrl;

  /// 头像转场标识
  final String? heroTag;

  /// 构建用户委托订单角色头像
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final avatar = CharacterAvatar(
      imageUrl: imageUrl,
      size: 48,
      borderRadius: 16,
    );
    final resolvedHeroTag = heroTag?.trim();
    if (resolvedHeroTag == null || resolvedHeroTag.isEmpty) {
      return avatar;
    }

    return Hero(
      tag: resolvedHeroTag,
      transitionOnUserGestures: true,
      child: avatar,
    );
  }
}
