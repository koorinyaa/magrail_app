import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';
import 'package:magrail_app/features/user/widgets/user_avatar.dart';

/// 用户详情页固定顶部操作浮层
class UserDetailFloatingTopActions extends StatelessWidget {
  /// 创建用户详情页固定顶部操作浮层
  ///
  /// [key] Flutter 组件标识
  /// [toolbarHeight] 顶部操作区高度
  /// [progress] 顶部背景从透明到模糊浮层的滚动进度
  /// [profile] 用户资料
  /// [identityProgress] 顶部紧凑用户标识显示进度
  /// [showBackButton] 是否显示返回按钮
  /// [showSettingsButton] 是否显示设置按钮
  /// [hideBalanceAndAssets] 是否隐藏余额和资产
  /// [onBalanceAndAssetsVisibilityPressed] 余额和资产显示按钮点击回调
  /// [onSettingsPressed] 设置按钮点击回调
  const UserDetailFloatingTopActions({
    super.key,
    required this.toolbarHeight,
    required this.progress,
    required this.profile,
    required this.identityProgress,
    required this.showBackButton,
    required this.showSettingsButton,
    required this.hideBalanceAndAssets,
    required this.onBalanceAndAssetsVisibilityPressed,
    required this.onSettingsPressed,
  });

  /// 顶部操作区高度
  final double toolbarHeight;

  /// 顶部背景从透明到模糊浮层的滚动进度
  final double progress;

  /// 用户资料
  final UserDetailProfile? profile;

  /// 顶部紧凑用户标识显示进度
  final double identityProgress;

  /// 是否显示返回按钮
  final bool showBackButton;

  /// 是否显示设置按钮
  final bool showSettingsButton;

  /// 是否隐藏余额和资产
  final bool hideBalanceAndAssets;

  /// 余额和资产显示按钮点击回调
  final VoidCallback onBalanceAndAssetsVisibilityPressed;

  /// 设置按钮点击回调
  final VoidCallback onSettingsPressed;

  /// 构建用户详情页固定顶部操作浮层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.paddingOf(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundAlpha = progress *
        (isDark
            ? AppBlurStyle.darkSurfaceAlpha
            : AppBlurStyle.lightSurfaceAlpha);
    final backgroundColor = colorScheme.surface.withValues(
      alpha: backgroundAlpha,
    );
    final blurSigma = AppBlurStyle.sigma * progress;

    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(color: backgroundColor),
            child: Padding(
              padding: EdgeInsets.only(
                left: safePadding.left,
                top: safePadding.top,
                right: safePadding.right + 12,
              ),
              child: _UserDetailTopActions(
                toolbarHeight: toolbarHeight,
                profile: profile,
                identityProgress: identityProgress,
                showBackButton: showBackButton,
                showSettingsButton: showSettingsButton,
                hideBalanceAndAssets: hideBalanceAndAssets,
                onBalanceAndAssetsVisibilityPressed:
                    onBalanceAndAssetsVisibilityPressed,
                onSettingsPressed: onSettingsPressed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 用户详情页顶部紧凑用户标识
class _UserDetailTopIdentity extends StatelessWidget {
  /// 创建用户详情页顶部紧凑用户标识
  ///
  /// [profile] 用户资料
  /// [progress] 顶部紧凑用户标识显示进度
  const _UserDetailTopIdentity({
    required this.profile,
    required this.progress,
  });

  /// 用户资料
  final UserDetailProfile? profile;

  /// 顶部紧凑用户标识显示进度
  final double progress;

  /// 构建用户详情页顶部紧凑用户标识
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    if (profile == null || progress <= 0) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final visibleProgress = Curves.easeOutCubic.transform(
      progress.clamp(0.0, 1.0).toDouble(),
    );
    final nickname = profile.nickname.trim();
    final displayName = nickname.isEmpty ? profile.name : nickname;

    return Opacity(
      opacity: visibleProgress,
      child: Transform.translate(
        offset: Offset(0, 6 * (1 - visibleProgress)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(
                imageUrl: profile.avatar,
                isBanned: profile.isBanned,
                size: 30,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: profile.isBanned
                        ? const Color(0xFFEF4444)
                        : colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 用户详情页顶部操作区
class _UserDetailTopActions extends StatelessWidget {
  // 右侧隐私和设置按钮略小，避免两个按钮占满顶部操作区
  static const double _trailingButtonExtent = 40;
  static const double _trailingIconSize = 22;

  /// 创建用户详情页顶部操作区
  ///
  /// [toolbarHeight] 顶部操作区高度
  /// [profile] 用户资料
  /// [identityProgress] 顶部紧凑用户标识显示进度
  /// [showBackButton] 是否显示返回按钮
  /// [showSettingsButton] 是否显示设置按钮
  /// [hideBalanceAndAssets] 是否隐藏余额和资产
  /// [onBalanceAndAssetsVisibilityPressed] 余额和资产显示按钮点击回调
  /// [onSettingsPressed] 设置按钮点击回调
  const _UserDetailTopActions({
    required this.toolbarHeight,
    required this.profile,
    required this.identityProgress,
    required this.showBackButton,
    required this.showSettingsButton,
    required this.hideBalanceAndAssets,
    required this.onBalanceAndAssetsVisibilityPressed,
    required this.onSettingsPressed,
  });

  /// 顶部操作区高度
  final double toolbarHeight;

  /// 用户资料
  final UserDetailProfile? profile;

  /// 顶部紧凑用户标识显示进度
  final double identityProgress;

  /// 是否显示返回按钮
  final bool showBackButton;

  /// 是否显示设置按钮
  final bool showSettingsButton;

  /// 是否隐藏余额和资产
  final bool hideBalanceAndAssets;

  /// 余额和资产显示按钮点击回调
  final VoidCallback onBalanceAndAssetsVisibilityPressed;

  /// 设置按钮点击回调
  final VoidCallback onSettingsPressed;

  /// 构建用户详情页顶部操作区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconButtonStyle =
        (IconButtonTheme.of(context).style ?? const ButtonStyle()).copyWith(
      foregroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
      fixedSize: WidgetStatePropertyAll(
        Size.square(toolbarHeight),
      ),
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
    );
    final trailingIconButtonStyle = iconButtonStyle.copyWith(
      fixedSize: const WidgetStatePropertyAll(
        Size.square(_trailingButtonExtent),
      ),
    );

    return IconButtonTheme(
      data: IconButtonThemeData(
        style: iconButtonStyle,
      ),
      child: IconTheme(
        data: IconThemeData(color: colorScheme.onSurface),
        child: SizedBox(
          width: double.infinity,
          height: toolbarHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showBackButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: kToolbarHeight,
                    child: Center(
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              _UserDetailTopIdentity(
                profile: profile,
                progress: identityProgress,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: _trailingButtonExtent,
                      child: Center(
                        child: IconButton(
                          style: trailingIconButtonStyle,
                          onPressed: onBalanceAndAssetsVisibilityPressed,
                          icon: Icon(
                            hideBalanceAndAssets
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: _trailingIconSize,
                          ),
                        ),
                      ),
                    ),
                    if (showSettingsButton)
                      SizedBox(
                        width: _trailingButtonExtent,
                        child: Center(
                          child: IconButton(
                            style: trailingIconButtonStyle,
                            onPressed: onSettingsPressed,
                            icon: const Icon(
                              Icons.settings_outlined,
                              size: _trailingIconSize,
                            ),
                          ),
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
}
