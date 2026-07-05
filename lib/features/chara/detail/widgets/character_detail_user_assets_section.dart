import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_user_assets.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_user_character.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/model/temple_asset_card_data.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_card.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

part 'character_detail_user_assets_content.dart';

/// 角色详情当前用户资产展示区
class CharacterDetailUserAssetsSection extends StatelessWidget {
  /// 创建角色详情当前用户资产展示区
  ///
  /// [key] Flutter 组件标识
  /// [header] 已上市角色头部资料
  /// [assets] 当前用户资产状态
  /// [currentUserDisplayName] 当前登录用户显示名称
  /// [currentUserName] 当前登录用户名
  /// [repository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  /// [onRetry] 资产加载失败后的重试回调
  /// [onAuthorize] 打开 Tinygrail 授权页回调
  const CharacterDetailUserAssetsSection({
    super.key,
    required this.header,
    required this.assets,
    required this.currentUserDisplayName,
    required this.currentUserName,
    required this.repository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
    required this.onRetry,
    required this.onAuthorize,
  });

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 当前用户资产状态
  final CharacterDetailUserAssets assets;

  /// 当前登录用户显示名称
  final String currentUserDisplayName;

  /// 当前登录用户名
  final String currentUserName;

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// 圣殿仓库
  final TempleRepository templeRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository magicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 资产加载失败后的重试回调
  final Future<void> Function() onRetry;

  /// 打开 Tinygrail 授权页回调
  final VoidCallback onAuthorize;

  /// 构建角色详情当前用户资产展示区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final duration =
        disableAnimations ? Duration.zero : const Duration(milliseconds: 180);

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      child: switch (assets.status) {
        CharacterDetailUserAssetsStatus.signedOut => _UserAssetsMessage(
            key: const ValueKey<String>('assets-signed-out'),
            icon: Icons.login_rounded,
            title: '未授权',
            message: '部分功能需要授权才能使用',
            actionLabel: '点击授权',
            onActionPressed: onAuthorize,
          ),
        CharacterDetailUserAssetsStatus.loading =>
          const TempleAssetCardSkeleton(
            key: ValueKey<String>('assets-loading'),
          ),
        CharacterDetailUserAssetsStatus.failure => _UserAssetsMessage(
            key: const ValueKey<String>('assets-failure'),
            icon: Icons.wifi_off_rounded,
            message: assets.errorMessage ?? '获取当前用户资产失败',
            actionLabel: '重试',
            onActionPressed: () => unawaited(onRetry()),
          ),
        CharacterDetailUserAssetsStatus.ready => _UserAssetsListContent(
            key: ValueKey<int?>(
              assets.temple?.id,
            ),
            header: header,
            character:
                assets.character ?? const CharacterDetailUserCharacter.empty(),
            temple: assets.temple,
            currentUserDisplayName: currentUserDisplayName,
            currentUserName: currentUserName,
            repository: repository,
            templeRepository: templeRepository,
            magicRepository: magicRepository,
            oosRepository: oosRepository,
            userRepository: userRepository,
            onActionCompleted: onRetry,
          ),
      },
    );
  }
}

/// 角色详情当前用户资产加载骨架
class CharacterDetailUserAssetsSkeleton extends StatelessWidget {
  /// 创建角色详情当前用户资产加载骨架
  ///
  /// [key] Flutter 组件标识
  const CharacterDetailUserAssetsSkeleton({super.key});

  /// 构建角色详情当前用户资产加载骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const TempleAssetCardSkeleton();
  }
}

/// 当前用户资产状态文案
class _UserAssetsMessage extends StatelessWidget {
  /// 创建当前用户资产状态文案
  ///
  /// [key] Flutter 组件标识
  /// [icon] 状态图标
  /// [title] 状态标题
  /// [message] 状态文案
  /// [actionLabel] 操作按钮文案
  /// [onActionPressed] 操作按钮点击回调
  const _UserAssetsMessage({
    super.key,
    required this.icon,
    this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  /// 状态图标
  final IconData icon;

  /// 状态标题
  final String? title;

  /// 状态文案
  final String message;

  /// 操作按钮文案
  final String? actionLabel;

  /// 操作按钮点击回调
  final VoidCallback? onActionPressed;

  /// 构建当前用户资产状态文案
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final actionLabel = this.actionLabel;

    if (actionLabel != null) {
      return AppLoadFailedState(
        title: title ?? '加载失败',
        message: message,
        icon: icon,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
