import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 用户头像
class UserAvatar extends StatelessWidget {
  /// 创建用户头像
  ///
  /// [key] Flutter 组件标识
  /// [imageUrl] 用户头像地址
  /// [isBanned] 是否为小圣杯封禁状态
  /// [size] 头像边长
  const UserAvatar({
    super.key,
    required this.imageUrl,
    required this.isBanned,
    this.size = 68,
  });

  /// 用户头像地址
  final String imageUrl;

  /// 是否为小圣杯封禁状态
  final bool isBanned;

  /// 头像边长
  final double size;

  /// 构建用户头像
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final borderColor = isBanned
        ? const Color(0xFFEF4444)
        : isDark
            ? Colors.white.withValues(alpha: 0.14)
            : const Color(0xFFE1E4E8);
    final isSmall = size <= 40;
    final resolvedImageUrl =
        imageUrl.isEmpty ? '' : TinygrailAssetUrls.normalizeAvatar(imageUrl);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF27272A) : Colors.white,
        border: Border.all(
          color: borderColor,
          width: isBanned ? (isSmall ? 1.4 : 2) : (isSmall ? 0.5 : 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
            blurRadius: isSmall ? 4 : 8,
            offset: Offset(0, isSmall ? 1 : 2),
          ),
        ],
      ),
      child: ClipOval(
        child: resolvedImageUrl.isEmpty
            ? _UserAvatarFallback(size: size)
            : CachedNetworkImage(
                imageUrl: resolvedImageUrl,
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
                  return _UserAvatarFallback(size: size);
                },
              ),
      ),
    );
  }
}

/// 用户头像失败占位
class _UserAvatarFallback extends StatelessWidget {
  /// 创建用户头像失败占位
  ///
  /// [size] 头像边长
  const _UserAvatarFallback({required this.size});

  /// 头像边长
  final double size;

  /// 构建用户头像失败占位
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
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: size * 0.5,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
