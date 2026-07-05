import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/widgets/snapping_horizontal_list_view.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';
import 'package:magrail_app/features/user/model/user_link_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_link_card.dart';
import 'package:magrail_app/features/user/widgets/user_temple_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 用户连接预览横向栏
class UserLinkOverviewCarousel extends StatelessWidget {
  /// 创建用户连接预览横向栏
  ///
  /// [key] Flutter 组件标识
  /// [links] 用户连接预览
  /// [isLoading] 是否正在加载
  /// [onCharacterTap] 角色名称点击回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const UserLinkOverviewCarousel({
    super.key,
    required this.links,
    required this.isLoading,
    this.onCharacterTap,
    this.onAssetTap,
  });

  /// 用户连接预览
  final List<UserLinkApiItem>? links;

  /// 是否正在加载
  final bool isLoading;

  /// 角色名称点击回调
  final ValueChanged<UserTempleApiItem>? onCharacterTap;

  /// 圣殿资产入口点击回调
  final ValueChanged<UserTempleApiItem>? onAssetTap;

  /// 构建用户连接预览横向栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final resolvedLinks = links ?? const <UserLinkApiItem>[];
    final showSkeleton = isLoading && resolvedLinks.isEmpty;
    final itemCount = showSkeleton ? 6 : resolvedLinks.length;

    if (!showSkeleton && resolvedLinks.isEmpty) {
      return Padding(
        padding: AppSafeAreaInsets.symmetricHorizontal(
          context,
          horizontal: 24,
        ),
        child: const _UserOverviewInlineEmpty(message: '暂无连接'),
      );
    }

    return SnappingHorizontalListView(
      height: 268,
      itemCount: itemCount,
      itemExtent: UserLinkCard.defaultWidth,
      separatorExtent: 14,
      padding: AppSafeAreaInsets.symmetricHorizontal(
        context,
        horizontal: 24,
        vertical: 6,
      ),
      clipBehavior: Clip.none,
      itemBuilder: (context, index) {
        if (showSkeleton) {
          return const _UserLinkSkeletonCard(
            width: UserLinkCard.defaultWidth,
          );
        }

        return UserLinkCard(
          item: resolvedLinks[index],
          heroTagPrefix: 'user-link-preview-cover-$index',
          onCharacterTap: onCharacterTap,
          onAssetTap: onAssetTap,
        );
      },
    );
  }
}

/// 用户圣殿预览横向栏
class UserTempleOverviewCarousel extends StatelessWidget {
  /// 创建用户圣殿预览横向栏
  ///
  /// [key] Flutter 组件标识
  /// [profile] 用户资料
  /// [temples] 用户圣殿预览
  /// [isLoading] 是否正在加载
  /// [onCharacterTap] 角色区域点击回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const UserTempleOverviewCarousel({
    super.key,
    required this.profile,
    required this.temples,
    required this.isLoading,
    this.onCharacterTap,
    this.onAssetTap,
  });

  static const double _cardWidth = 180;
  static final double _cardHeight = UserTempleCard.heightForWidth(_cardWidth);

  /// 用户资料，骨架状态下可为空
  final UserDetailProfile? profile;

  /// 用户圣殿预览
  final List<UserTempleApiItem>? temples;

  /// 是否正在加载
  final bool isLoading;

  /// 角色区域点击回调
  final ValueChanged<UserTempleApiItem>? onCharacterTap;

  /// 圣殿资产入口点击回调
  final ValueChanged<UserTempleApiItem>? onAssetTap;

  /// 构建用户圣殿预览横向栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final resolvedTemples = temples ?? const <UserTempleApiItem>[];
    final showSkeleton = isLoading && resolvedTemples.isEmpty;
    final itemCount = showSkeleton ? 4 : resolvedTemples.length;

    if (!showSkeleton && resolvedTemples.isEmpty) {
      return Padding(
        padding: AppSafeAreaInsets.symmetricHorizontal(
          context,
          horizontal: 24,
        ),
        child: const _UserOverviewInlineEmpty(message: '暂无圣殿'),
      );
    }

    return SnappingHorizontalListView(
      height: _cardHeight + 12,
      itemCount: itemCount,
      itemExtent: _cardWidth,
      separatorExtent: 10,
      padding: AppSafeAreaInsets.symmetricHorizontal(
        context,
        horizontal: 24,
        vertical: 6,
      ),
      clipBehavior: Clip.none,
      itemBuilder: (context, index) {
        if (showSkeleton) {
          return _UserTempleSkeletonCard(
            width: _cardWidth,
            height: _cardHeight,
          );
        }

        return UserTempleCard(
          width: _cardWidth,
          item: resolvedTemples[index],
          ownerLabel: _ownerLabel(profile),
          heroTagPrefix: 'user-temple-preview-cover-$index',
          onCharacterTap: onCharacterTap,
          onAssetTap: onAssetTap,
        );
      },
    );
  }

  /// 解析用户展示文案
  ///
  /// [profile] 用户资料
  String _ownerLabel(UserDetailProfile? profile) {
    if (profile == null) {
      return '';
    }

    final nickname = profile.nickname.trim();
    if (nickname.isNotEmpty) {
      return '@$nickname';
    }

    return '@${profile.name}';
  }
}

/// 用户角色资产行内空状态
class _UserOverviewInlineEmpty extends StatelessWidget {
  /// 创建用户角色资产行内空状态
  ///
  /// [message] 空状态文案
  const _UserOverviewInlineEmpty({
    required this.message,
  });

  /// 空状态文案
  final String message;

  /// 构建用户角色资产行内空状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 88,
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// 用户连接加载骨架卡片
class _UserLinkSkeletonCard extends StatelessWidget {
  /// 创建用户连接加载骨架卡片
  ///
  /// [width] 卡片宽度
  const _UserLinkSkeletonCard({
    required this.width,
  });

  /// 卡片宽度
  final double width;

  /// 构建用户连接加载骨架卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone(
            width: width,
            height:
                UserLinkCard.imageHeight * width / UserLinkCard.defaultWidth,
            borderRadius: BorderRadius.circular(24),
          ),
          const SizedBox(height: 8),
          Bone(
            width: 66,
            height: 22,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}

/// 用户圣殿加载骨架卡片
class _UserTempleSkeletonCard extends StatelessWidget {
  /// 创建用户圣殿加载骨架卡片
  ///
  /// [width] 卡片宽度
  /// [height] 卡片高度
  const _UserTempleSkeletonCard({
    required this.width,
    required this.height,
  });

  /// 卡片宽度
  final double width;

  /// 卡片高度
  final double height;

  /// 构建用户圣殿加载骨架卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Bone(
              width: width,
              height: width / 3 * 4,
              borderRadius: BorderRadius.circular(24),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone(
                    width: width * 0.56,
                    height: 11,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 6),
                  Bone(
                    width: width - 8,
                    height: 4,
                    borderRadius: BorderRadius.circular(999),
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
