import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/snapping_horizontal_list_view.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/model/latest_link_api_item.dart';
import 'package:magrail_app/features/temple/model/latest_link_pair.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/latest_link_card.dart';
import 'package:magrail_app/features/temple/widgets/latest_link_skeleton_card.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_dialog.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 最新连接横向轮播
class LatestLinkCarousel extends StatelessWidget {
  /// 创建最新连接横向轮播
  ///
  /// [pairs] 最新连接展示组
  /// [isLoading] 是否正在加载
  /// [isLoadFailed] 是否加载失败
  /// [onRetry] 重试回调
  /// [characterDetailRepository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  const LatestLinkCarousel({
    super.key,
    required this.pairs,
    required this.isLoading,
    required this.isLoadFailed,
    required this.onRetry,
    required this.characterDetailRepository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
  });

  /// 最新连接展示组
  final List<LatestLinkPair>? pairs;

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

  /// 构建最新连接横向轮播
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final showSkeleton = isLoading && (pairs == null || pairs!.isEmpty);

    if (isLoadFailed && !showSkeleton && (pairs == null || pairs!.isEmpty)) {
      return Padding(
        padding: AppSafeAreaInsets.symmetricHorizontal(
          context,
          horizontal: 24,
        ),
        child: _LatestLinkErrorState(onRetry: onRetry),
      );
    }

    if (!showSkeleton && pairs != null && pairs!.isEmpty) {
      return Padding(
        padding: AppSafeAreaInsets.symmetricHorizontal(
          context,
          horizontal: 24,
        ),
        child: const _LatestLinkEmptyState(),
      );
    }

    final itemCount = showSkeleton ? 6 : pairs!.length;

    return SnappingHorizontalListView(
      height: 268,
      itemCount: itemCount,
      itemExtent: LatestLinkCard.defaultWidth,
      separatorExtent: 14,
      padding: AppSafeAreaInsets.symmetricHorizontal(
        context,
        horizontal: 24,
        vertical: 6,
      ),
      clipBehavior: Clip.none,
      itemBuilder: (context, index) {
        if (showSkeleton) {
          return const LatestLinkSkeletonCard(
            width: LatestLinkCard.defaultWidth,
          );
        }

        return LatestLinkCard(
          pair: pairs![index],
          onCharacterTap: (item) => _openCharacterDetail(context, item),
          onUserTap: (pair) => _openUserDetail(context, pair),
          onAssetTap: (pair, item) {
            _openTempleAssetDialog(context, pair, item);
          },
        );
      },
    );
  }

  /// 打开圣殿资产弹窗
  ///
  /// [context] 当前组件树上下文
  /// [pair] 最新连接展示组
  /// [item] 被点击的连接侧圣殿条目
  void _openTempleAssetDialog(
    BuildContext context,
    LatestLinkPair pair,
    LatestLinkApiItem item,
  ) {
    unawaited(
      showTempleAssetCardDialogFromSource(
        context,
        source: TempleAssetDialogSource(
          ownerName: pair.ownerName,
          ownerNickname: pair.ownerNickname,
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

  /// 打开用户详情
  ///
  /// [context] 当前组件树上下文
  /// [pair] 最新连接展示组
  void _openUserDetail(BuildContext context, LatestLinkPair pair) {
    context.pushNamed(
      'userDetail',
      queryParameters: {'username': pair.ownerName},
    );
  }

  /// 打开角色详情
  ///
  /// [context] 当前组件树上下文
  /// [item] 最新连接接口条目
  void _openCharacterDetail(BuildContext context, LatestLinkApiItem item) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.characterName,
    );
  }
}

/// 首页最新连接加载失败状态
class _LatestLinkErrorState extends StatelessWidget {
  /// 创建首页最新连接加载失败状态
  ///
  /// [onRetry] 重试回调
  const _LatestLinkErrorState({
    required this.onRetry,
  });

  /// 重试回调
  final Future<void> Function() onRetry;

  /// 构建首页最新连接加载失败状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 268,
      child: Center(
        child: AppLoadFailedState(
          message: '请检查网络后重试',
          onActionPressed: onRetry,
        ),
      ),
    );
  }
}

/// 最新连接空状态
class _LatestLinkEmptyState extends StatelessWidget {
  /// 创建最新连接空状态
  const _LatestLinkEmptyState();

  /// 构建最新连接空状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 268,
      child: Center(
        child: Text(
          '暂无最新连接',
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
