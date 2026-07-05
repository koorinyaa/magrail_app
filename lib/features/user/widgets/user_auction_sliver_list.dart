import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/user/model/user_auction_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_sliver_list_layout.dart';
import 'package:magrail_app/features/user/widgets/user_auction_row.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 用户拍卖 sliver 列表
class UserAuctionSliverList extends StatelessWidget {
  /// 创建用户拍卖 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 用户拍卖条目
  /// [onItemBuilt] 条目构建回调
  /// [onAuctionTap] 拍卖条目点击回调
  /// [onCharacterTap] 角色详情点击回调
  /// [onCancelAuction] 取消竞拍回调
  /// [hideCharacterInfo] 是否隐藏角色资料
  const UserAuctionSliverList({
    super.key,
    required this.items,
    this.onItemBuilt,
    this.onAuctionTap,
    this.onCharacterTap,
    this.onCancelAuction,
    this.hideCharacterInfo = false,
  });

  /// 用户拍卖条目
  final List<UserAuctionApiItem> items;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 拍卖条目点击回调
  final ValueChanged<UserAuctionApiItem>? onAuctionTap;

  /// 角色详情点击回调
  final void Function(UserAuctionApiItem item, String? avatarHeroTag)?
      onCharacterTap;

  /// 取消竞拍回调
  final ValueChanged<UserAuctionApiItem>? onCancelAuction;

  /// 是否隐藏角色资料
  final bool hideCharacterInfo;

  /// 构建用户拍卖 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        onItemBuilt?.call(index);
        final item = items[index];
        final avatarUrl = hideCharacterInfo
            ? ''
            : TinygrailAssetUrls.normalizeAvatar(item.icon);
        final avatarHeroTag = createCharacterDetailAvatarHeroTag(
          characterId: item.characterId,
          avatarUrl: avatarUrl,
          source: item,
        );

        return UserAuctionRow(
          item: item,
          avatarHeroTag: avatarHeroTag,
          onTap: onAuctionTap == null ? null : () => onAuctionTap!(item),
          onCharacterTap: onCharacterTap,
          onCancelAuction: onCancelAuction,
          hideCharacterInfo: hideCharacterInfo,
        );
      },
      separatorBuilder: (context, index) {
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
      },
      itemCount: items.length,
    );
  }
}

/// 用户拍卖骨架 sliver 列表
class UserAuctionSkeletonSliverList extends StatelessWidget {
  /// 创建用户拍卖骨架 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  const UserAuctionSkeletonSliverList({
    super.key,
    this.itemCount = 12,
  });

  /// 骨架条目数量
  final int itemCount;

  /// 构建用户拍卖骨架 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return const _UserAuctionSkeletonRow();
      },
      separatorBuilder: (context, index) {
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
      },
      itemCount: itemCount,
    );
  }
}

/// 用户拍卖骨架行
class _UserAuctionSkeletonRow extends StatelessWidget {
  /// 创建用户拍卖骨架行
  const _UserAuctionSkeletonRow();

  /// 构建用户拍卖骨架行
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
                              width: 52,
                              height: 18,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Bone.text(width: 170, fontSize: 11),
                            SizedBox(height: 3),
                            Bone.text(width: 118, fontSize: 11),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Bone(
                        width: 58,
                        height: 21,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                    ],
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
