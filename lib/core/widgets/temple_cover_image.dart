import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 圣殿封面图片
class TempleCoverImage extends StatelessWidget {
  /// 创建圣殿封面图片
  ///
  /// [coverUrl] 封面图片地址
  /// [avatarUrl] 头像图片地址
  /// [fit] 图片填充方式
  /// [alignment] 图片裁剪对齐方式
  /// [fallbackAvatarAlignment] 头像回退前景头像位置
  /// [placeholderIconSize] 占位图标尺寸
  const TempleCoverImage({
    super.key,
    required this.coverUrl,
    required this.avatarUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.topCenter,
    this.fallbackAvatarAlignment = const Alignment(0, -0.28),
    this.placeholderIconSize = 44,
  });

  /// 封面图片地址
  final String coverUrl;

  /// 头像图片地址
  final String avatarUrl;

  /// 图片填充方式
  final BoxFit fit;

  /// 图片裁剪对齐方式
  final Alignment alignment;

  /// 头像回退前景头像位置
  final Alignment fallbackAvatarAlignment;

  /// 占位图标尺寸
  final double placeholderIconSize;

  /// 构建圣殿封面图片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (coverUrl.isEmpty) {
      return _buildFallbackImage();
    }

    return CachedNetworkImage(
      imageUrl: coverUrl,
      fit: fit,
      alignment: alignment,
      placeholder: (context, url) {
        return const _TempleCoverSkeleton();
      },
      errorWidget: (context, url, error) {
        return _buildFallbackImage();
      },
    );
  }

  /// 构建封面缺失时的回退图片
  Widget _buildFallbackImage() {
    if (avatarUrl.isEmpty) {
      return _TempleCoverPlaceholder(iconSize: placeholderIconSize);
    }

    return _TempleAvatarCoverFallback(
      avatarUrl: avatarUrl,
      fit: fit,
      foregroundAlignment: fallbackAvatarAlignment,
      placeholderIconSize: placeholderIconSize,
    );
  }
}

/// 圣殿封面加载骨架
class _TempleCoverSkeleton extends StatelessWidget {
  /// 创建圣殿封面加载骨架
  const _TempleCoverSkeleton();

  /// 构建圣殿封面加载骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Skeletonizer.zone(
      child: Bone(
        width: double.infinity,
        height: double.infinity,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}

/// 圣殿封面占位图
class _TempleCoverPlaceholder extends StatelessWidget {
  /// 创建圣殿封面占位图
  ///
  /// [iconSize] 图标尺寸
  const _TempleCoverPlaceholder({
    required this.iconSize,
  });

  /// 图标尺寸
  final double iconSize;

  /// 构建圣殿封面占位图
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? const [
            Color(0xFF27272A),
            Color(0xFF18181B),
          ]
        : const [
            Color(0xFFF4F4F5),
            Color(0xFFE4E4E7),
          ];
    final iconColor = isDark
        ? const Color(0xFFA1A1AA).withValues(alpha: 0.86)
        : const Color(0xFFA1A1AA).withValues(alpha: 0.92);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}

/// 圣殿头像回退封面
class _TempleAvatarCoverFallback extends StatelessWidget {
  /// 创建圣殿头像回退封面
  ///
  /// [avatarUrl] 头像图片地址
  /// [fit] 图片填充方式
  /// [foregroundAlignment] 前景头像位置
  /// [placeholderIconSize] 占位图标尺寸
  const _TempleAvatarCoverFallback({
    required this.avatarUrl,
    required this.fit,
    required this.foregroundAlignment,
    required this.placeholderIconSize,
  });

  /// 头像图片地址
  final String avatarUrl;

  /// 图片填充方式
  final BoxFit fit;

  /// 前景头像位置
  final Alignment foregroundAlignment;

  /// 占位图标尺寸
  final double placeholderIconSize;

  /// 构建圣殿头像回退封面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: AppBlurStyle.filter,
            child: CachedNetworkImage(
              imageUrl: avatarUrl,
              fit: fit,
              alignment: Alignment.center,
              placeholder: (context, url) {
                return const _TempleCoverSkeleton();
              },
              errorWidget: (context, url, error) {
                return _TempleCoverPlaceholder(
                  iconSize: placeholderIconSize,
                );
              },
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.10),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x00000000),
                Color(0x1F000000),
              ],
            ),
          ),
        ),
        Align(
          alignment: foregroundAlignment,
          child: FractionallySizedBox(
            widthFactor: 0.5,
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: avatarUrl,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  placeholder: (context, url) {
                    return const _TempleCoverSkeleton();
                  },
                  errorWidget: (context, url, error) {
                    return _TempleCoverPlaceholder(
                      iconSize: placeholderIconSize,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
