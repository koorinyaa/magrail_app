import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/snapping_horizontal_list_view.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/model/temple_api_item.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/latest_temple_card.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_dialog.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 最新圣殿横向轮播
class LatestTempleCarousel extends StatelessWidget {
  /// 创建最新圣殿横向轮播
  ///
  /// [items] 最新圣殿条目
  /// [isLoading] 是否正在加载
  /// [isLoadFailed] 是否加载失败
  /// [onRetry] 重试回调
  /// [characterDetailRepository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  const LatestTempleCarousel({
    super.key,
    required this.items,
    required this.isLoading,
    required this.isLoadFailed,
    required this.onRetry,
    required this.characterDetailRepository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
  });

  static const double _cardWidth = 180;
  static const double _cardHeight = _cardWidth / 3 * 4;

  /// 最新圣殿条目
  final List<TempleApiItem>? items;

  /// 是否正在加载
  final bool isLoading;

  /// 是否加载失败
  final bool isLoadFailed;

  /// 重试回调
  final Future<void> Function() onRetry;

  /// 角色详情仓库
  final CharacterDetailRepository characterDetailRepository;

  /// 圣殿仓库
  final TempleRepository templeRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository magicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 构建最新圣殿横向轮播
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final showSkeleton = isLoading && (items == null || items!.isEmpty);

    if (isLoadFailed && !showSkeleton && (items == null || items!.isEmpty)) {
      return Padding(
        padding: AppSafeAreaInsets.symmetricHorizontal(
          context,
          horizontal: 24,
        ),
        child: _LatestTempleErrorState(onRetry: onRetry),
      );
    }

    if (!showSkeleton && items != null && items!.isEmpty) {
      return Padding(
        padding: AppSafeAreaInsets.symmetricHorizontal(
          context,
          horizontal: 24,
        ),
        child: const _LatestTempleEmptyState(),
      );
    }

    final itemCount = showSkeleton ? 4 : items!.length;

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
          return const _LatestTempleSkeletonCard(width: _cardWidth);
        }

        final item = items![index];
        return LatestTempleCard(
          width: _cardWidth,
          item: item,
          onCharacterTap: (item) {
            openCharacterDetail(
              context,
              characterId: item.characterId,
              name: item.characterName,
            );
          },
          onUserTap: (item) {
            context.pushNamed(
              'userDetail',
              queryParameters: {'username': item.name},
            );
          },
          onAssetTap: (item) => _openTempleAssetDialog(context, item),
        );
      },
    );
  }

  /// 打开圣殿资产弹窗
  ///
  /// [context] 当前组件树上下文
  /// [item] 最新圣殿条目
  void _openTempleAssetDialog(BuildContext context, TempleApiItem item) {
    unawaited(
      showTempleAssetCardDialogFromSource(
        context,
        source: TempleAssetDialogSource(
          ownerName: item.name,
          ownerNickname: item.nickname,
          characterId: item.characterId,
        ),
        characterRepository: characterDetailRepository,
        templeRepository: templeRepository,
        magicRepository: magicRepository,
        oosRepository: oosRepository,
        userRepository: userRepository,
        currentUserName: _currentUserName,
      ),
    );
  }

  /// 当前登录用户名
  String get _currentUserName {
    return userRepository.readCachedCurrentUserAssets()?.name ?? '';
  }
}

/// 最新圣殿加载骨架卡片
class _LatestTempleSkeletonCard extends StatelessWidget {
  /// 创建最新圣殿加载骨架卡片
  ///
  /// [width] 卡片宽度
  const _LatestTempleSkeletonCard({
    required this.width,
  });

  /// 卡片宽度
  final double width;

  /// 构建最新圣殿加载骨架卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: Bone(
        width: width,
        height: width / 3 * 4,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

/// 首页最新圣殿加载失败状态
class _LatestTempleErrorState extends StatelessWidget {
  /// 创建首页最新圣殿加载失败状态
  ///
  /// [onRetry] 重试回调
  const _LatestTempleErrorState({
    required this.onRetry,
  });

  /// 重试回调
  final Future<void> Function() onRetry;

  /// 构建首页最新圣殿加载失败状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: LatestTempleCarousel._cardHeight + 12,
      child: Center(
        child: AppLoadFailedState(
          message: '请检查网络后重试',
          onActionPressed: onRetry,
        ),
      ),
    );
  }
}

/// 最新圣殿空状态
class _LatestTempleEmptyState extends StatelessWidget {
  /// 创建最新圣殿空状态
  const _LatestTempleEmptyState();

  /// 构建最新圣殿空状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: LatestTempleCarousel._cardHeight + 12,
      child: Center(
        child: Text(
          '暂无最新圣殿',
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
