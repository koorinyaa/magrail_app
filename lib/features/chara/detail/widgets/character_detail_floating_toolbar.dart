import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_history_item.dart';

/// 角色详情页固定顶部浮层
class CharacterDetailFloatingToolbar extends StatelessWidget {
  /// 创建角色详情页固定顶部浮层
  ///
  /// [key] Flutter 组件标识
  /// [toolbarHeight] 顶部操作区高度
  /// [progress] 顶部背景从透明到模糊浮层的滚动进度
  /// [identityProgress] 顶部紧凑角色标识显示进度
  /// [current] 当前角色历史条目
  /// [onSearchPressed] 搜索按钮点击回调
  const CharacterDetailFloatingToolbar({
    super.key,
    required this.toolbarHeight,
    required this.progress,
    required this.identityProgress,
    required this.current,
    required this.onSearchPressed,
  });

  /// 顶部操作区高度
  final double toolbarHeight;

  /// 顶部背景从透明到模糊浮层的滚动进度
  final double progress;

  /// 顶部紧凑角色标识显示进度
  final double identityProgress;

  /// 当前角色历史条目
  final CharacterDetailHistoryItem? current;

  /// 搜索按钮点击回调
  final VoidCallback onSearchPressed;

  /// 构建角色详情页固定顶部浮层
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
              child: _CharacterDetailTopActions(
                toolbarHeight: toolbarHeight,
                current: current,
                identityProgress: identityProgress,
                onSearchPressed: onSearchPressed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 角色详情页顶部操作区
class _CharacterDetailTopActions extends StatelessWidget {
  /// 创建角色详情页顶部操作区
  ///
  /// [toolbarHeight] 顶部操作区高度
  /// [current] 当前角色历史条目
  /// [identityProgress] 顶部紧凑角色标识显示进度
  /// [onSearchPressed] 搜索按钮点击回调
  const _CharacterDetailTopActions({
    required this.toolbarHeight,
    required this.current,
    required this.identityProgress,
    required this.onSearchPressed,
  });

  /// 顶部操作区高度
  final double toolbarHeight;

  /// 当前角色历史条目
  final CharacterDetailHistoryItem? current;

  /// 顶部紧凑角色标识显示进度
  final double identityProgress;

  /// 搜索按钮点击回调
  final VoidCallback onSearchPressed;

  /// 构建角色详情页顶部操作区
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

    return IconButtonTheme(
      data: IconButtonThemeData(style: iconButtonStyle),
      child: IconTheme(
        data: IconThemeData(color: colorScheme.onSurface),
        child: SizedBox(
          width: double.infinity,
          height: toolbarHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
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
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: kToolbarHeight,
                  child: Center(
                    child: IconButton(
                      onPressed: onSearchPressed,
                      icon: const Icon(
                        Icons.search_rounded,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              _CharacterDetailTopIdentity(
                current: current,
                progress: identityProgress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 角色详情页顶部紧凑角色标识
class _CharacterDetailTopIdentity extends StatelessWidget {
  /// 创建角色详情页顶部紧凑角色标识
  ///
  /// [current] 当前角色历史条目
  /// [progress] 顶部紧凑角色标识显示进度
  const _CharacterDetailTopIdentity({
    required this.current,
    required this.progress,
  });

  /// 当前角色历史条目
  final CharacterDetailHistoryItem? current;

  /// 顶部紧凑角色标识显示进度
  final double progress;

  /// 构建角色详情页顶部紧凑角色标识
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final item = current;
    if (item == null || progress <= 0) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final visibleProgress = Curves.easeOutCubic.transform(
      progress.clamp(0.0, 1.0).toDouble(),
    );

    return Opacity(
      opacity: visibleProgress,
      child: Transform.translate(
        offset: Offset(0, 6 * (1 - visibleProgress)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CharacterAvatar(
                imageUrl: item.avatarUrl,
                size: 30,
                borderRadius: 15,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  item.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
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
