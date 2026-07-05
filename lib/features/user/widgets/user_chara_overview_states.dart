import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/page_section_sliver.dart';
import 'package:magrail_app/features/user/widgets/user_chara_asset_carousel.dart';
import 'package:magrail_app/features/user/widgets/user_link_temple_overview_carousel.dart';

/// 用户角色资产预览骨架区
class UserCharaOverviewSkeletonSection extends StatelessWidget {
  /// 创建用户角色资产预览骨架区
  ///
  /// [key] Flutter 组件标识
  const UserCharaOverviewSkeletonSection({super.key});

  /// 构建用户角色资产预览骨架区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const SliverMainAxisGroup(
      slivers: [
        PageSectionSliver(
          topSpacing: 12,
          title: '连接',
          child: UserLinkOverviewCarousel(
            links: null,
            isLoading: true,
          ),
        ),
        PageSectionSliver(
          topSpacing: 22,
          title: '圣殿',
          child: UserTempleOverviewCarousel(
            profile: null,
            temples: null,
            isLoading: true,
          ),
        ),
        PageSectionSliver(
          topSpacing: 22,
          title: '角色',
          child: UserCharacterAssetCarousel(
            characters: null,
            isLoading: true,
          ),
        ),
        PageSectionSliver(
          topSpacing: 22,
          title: 'ICO',
          child: UserIcoAssetCarousel(
            icos: null,
            isLoading: true,
          ),
        ),
      ],
    );
  }
}

/// 用户角色资产提示状态
class UserOverviewMessage extends StatelessWidget {
  /// 创建用户角色资产提示状态
  ///
  /// [key] Flutter 组件标识
  /// [message] 提示文案
  /// [onRetry] 重试回调
  const UserOverviewMessage({
    super.key,
    required this.message,
    this.onRetry,
  });

  /// 提示文案
  final String message;

  /// 重试回调
  final Future<void> Function()? onRetry;

  /// 构建用户角色资产提示状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final onRetry = this.onRetry;
    if (onRetry != null) {
      return AppLoadFailedState(
        message: message,
        onActionPressed: () {
          onRetry();
        },
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(
          alpha: colorScheme.brightness == Brightness.dark ? 0.72 : 0.82,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
