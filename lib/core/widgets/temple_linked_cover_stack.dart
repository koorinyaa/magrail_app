import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/temple_cover_image.dart';

/// 圣殿 LINK 静态封面堆叠
class TempleLinkedCoverStack extends StatelessWidget {
  // 错位比例
  static const double _horizontalOffsetRatio = 8 / 112;
  static const double _verticalOffsetRatio = 10 / 150;

  /// 创建圣殿 LINK 静态封面堆叠
  ///
  /// [width] 堆叠区域宽度
  /// [frontCover] 前层圣殿封面
  /// [linkedCover] 后层 LINK 封面
  const TempleLinkedCoverStack({
    super.key,
    required this.width,
    required this.frontCover,
    required this.linkedCover,
  });

  /// 堆叠区域宽度
  final double width;

  /// 前层圣殿封面
  final Widget frontCover;

  /// 后层 LINK 封面
  final Widget linkedCover;

  /// 根据堆叠区域宽度计算单张封面宽度
  ///
  /// [width] 堆叠区域宽度
  static double coverWidthFor(double width) {
    return width * (1 - _horizontalOffsetRatio);
  }

  /// 构建圣殿 LINK 静态封面堆叠
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final height = width / 3 * 4;
    final horizontalOffset = width * _horizontalOffsetRatio;
    final verticalOffset = height * _verticalOffsetRatio;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: horizontalOffset,
            top: 0,
            child: linkedCover,
          ),
          Positioned(
            left: 0,
            top: verticalOffset,
            child: frontCover,
          ),
        ],
      ),
    );
  }
}

/// 圣殿 LINK 后层封面
class TempleLinkedCover extends StatelessWidget {
  /// 创建圣殿 LINK 后层封面
  ///
  /// [width] 封面宽度
  /// [coverUrl] 圣殿封面地址
  /// [avatarUrl] 封面缺失时使用的头像地址
  /// [heroTag] 封面 Hero 标识
  const TempleLinkedCover({
    super.key,
    required this.width,
    required this.coverUrl,
    required this.avatarUrl,
    this.heroTag,
  });

  /// 封面宽度
  final double width;

  /// 圣殿封面地址
  final String coverUrl;

  /// 封面缺失时使用的头像地址
  final String avatarUrl;

  /// 封面 Hero 标识
  final String? heroTag;

  /// 构建圣殿 LINK 后层封面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);
    final image = TempleCoverImage(
      coverUrl: coverUrl,
      avatarUrl: avatarUrl,
    );
    final tag = heroTag;

    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 6,
                offset: const Offset(4, 3),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.40),
                  width: 0.75,
                ),
              ),
              child: tag == null ? image : Hero(tag: tag, child: image),
            ),
          ),
        ),
      ),
    );
  }
}
