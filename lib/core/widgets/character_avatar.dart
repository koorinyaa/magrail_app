import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 角色头像
class CharacterAvatar extends StatelessWidget {
  /// 创建角色头像
  ///
  /// [imageUrl] 头像地址
  /// [size] 头像边长
  /// [borderRadius] 头像圆角
  const CharacterAvatar({
    super.key,
    required this.imageUrl,
    this.size = 48,
    this.borderRadius = 16,
  });

  /// 头像地址
  final String imageUrl;

  /// 头像边长
  final double size;

  /// 头像圆角
  final double borderRadius;

  /// 构建角色头像
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl.isEmpty
            ? _CharacterAvatarFallback(
                size: size,
                borderRadius: borderRadius,
              )
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                placeholder: (context, url) {
                  return Skeletonizer.zone(
                    child: Bone(
                      width: size,
                      height: size,
                      borderRadius: BorderRadius.zero,
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return _CharacterAvatarFallback(
                    size: size,
                    borderRadius: borderRadius,
                  );
                },
              ),
      ),
    );
  }
}

/// 角色头像失败占位
class _CharacterAvatarFallback extends StatelessWidget {
  /// 创建角色头像失败占位
  ///
  /// [size] 头像边长
  /// [borderRadius] 头像圆角
  const _CharacterAvatarFallback({
    required this.size,
    required this.borderRadius,
  });

  /// 头像边长
  final double size;

  /// 头像圆角
  final double borderRadius;

  /// 构建角色头像失败占位
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Center(
        child: Icon(
          LucideIcons.ghost,
          size: size * 0.45,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
