import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/user/model/user_market_order_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_sliver_list_layout.dart';
import 'package:magrail_app/features/user/widgets/user_market_order_row.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 用户委托订单 sliver 列表
class UserMarketOrderSliverList extends StatelessWidget {
  /// 创建用户委托订单 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 用户委托订单条目
  /// [side] 委托订单方向
  /// [onItemBuilt] 条目构建回调
  /// [onOrderTap] 委托订单点击回调
  const UserMarketOrderSliverList({
    super.key,
    required this.items,
    required this.side,
    this.onItemBuilt,
    this.onOrderTap,
  });

  /// 用户委托订单条目
  final List<UserMarketOrderApiItem> items;

  /// 委托订单方向
  final UserMarketOrderSide side;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 委托订单点击回调
  final void Function(UserMarketOrderApiItem item, String? avatarHeroTag)?
      onOrderTap;

  /// 构建用户委托订单 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        onItemBuilt?.call(index);
        final item = items[index];
        final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
        final avatarHeroTag = createCharacterDetailAvatarHeroTag(
          characterId: item.characterId,
          avatarUrl: avatarUrl,
          source: item,
        );

        return UserMarketOrderRow(
          item: item,
          side: side,
          avatarHeroTag: avatarHeroTag,
          onTap: onOrderTap == null
              ? null
              : () => onOrderTap!(item, avatarHeroTag),
        );
      },
      separatorBuilder: (context, index) => const _UserMarketOrderDivider(),
      itemCount: items.length,
    );
  }
}

/// 用户委托订单骨架 sliver 列表
class UserMarketOrderSkeletonSliverList extends StatelessWidget {
  /// 创建用户委托订单骨架 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  const UserMarketOrderSkeletonSliverList({
    super.key,
    this.itemCount = 12,
  });

  /// 骨架条目数量
  final int itemCount;

  /// 构建用户委托订单骨架 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return const _UserMarketOrderSkeletonRow();
      },
      separatorBuilder: (context, index) => const _UserMarketOrderDivider(),
      itemCount: itemCount,
    );
  }
}

/// 用户委托订单分割线
class _UserMarketOrderDivider extends StatelessWidget {
  /// 创建用户委托订单分割线
  const _UserMarketOrderDivider();

  /// 构建用户委托订单分割线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: UserAssetRecordListMetrics.horizontalPadding +
            UserAssetRecordListMetrics.textIndent,
        top: 0,
        right: UserAssetRecordListMetrics.horizontalPadding,
        bottom: 0,
      ),
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

/// 用户委托订单骨架行
class _UserMarketOrderSkeletonRow extends StatelessWidget {
  /// 创建用户委托订单骨架行
  const _UserMarketOrderSkeletonRow();

  /// 构建用户委托订单骨架行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: Padding(
        padding: AppSafeAreaInsets.symmetricHorizontal(
          context,
          horizontal: UserAssetRecordListMetrics.horizontalPadding,
          vertical: 12,
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Bone(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            SizedBox(width: 10),
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
                              child: Bone.text(width: 132, fontSize: 15),
                            ),
                            SizedBox(width: 6),
                            Bone(
                              width: 38,
                              height: 16,
                              borderRadius: BorderRadius.all(
                                Radius.circular(999),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Bone.text(width: 54, fontSize: 11),
                    ],
                  ),
                  SizedBox(height: 6),
                  Bone.text(width: 92, fontSize: 11),
                  SizedBox(height: 4),
                  Bone(
                    width: 104,
                    height: 15,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
