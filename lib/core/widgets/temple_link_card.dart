import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/widgets/temple_cover_image.dart';

/// 圣殿连接卡片
class TempleLinkCard extends StatelessWidget {
  /// 创建圣殿连接卡片
  ///
  /// [leftCoverUrl] 左侧封面地址
  /// [leftAvatarUrl] 左侧头像回退地址
  /// [leftCharacterName] 左侧角色名称
  /// [rightCoverUrl] 右侧封面地址
  /// [rightAvatarUrl] 右侧头像回退地址
  /// [rightCharacterName] 右侧角色名称
  /// [width] 组件宽度
  /// [leftHeroTag] 左侧图片 Hero 标识
  /// [rightHeroTag] 右侧图片 Hero 标识
  /// [onLeftCoverTap] 左侧图片点击回调
  /// [onRightCoverTap] 右侧图片点击回调
  /// [onLeftCharacterTap] 左侧角色名称点击回调
  /// [onRightCharacterTap] 右侧角色名称点击回调
  /// [onLeftAssetTap] 左侧圣殿资产入口点击回调
  /// [onRightAssetTap] 右侧圣殿资产入口点击回调
  const TempleLinkCard({
    super.key,
    required this.leftCoverUrl,
    required this.leftAvatarUrl,
    required this.leftCharacterName,
    required this.rightCoverUrl,
    required this.rightAvatarUrl,
    required this.rightCharacterName,
    this.width = 288,
    this.leftHeroTag,
    this.rightHeroTag,
    this.onLeftCoverTap,
    this.onRightCoverTap,
    this.onLeftCharacterTap,
    this.onRightCharacterTap,
    this.onLeftAssetTap,
    this.onRightAssetTap,
  });

  static const double _baseWidth = 288;
  static const double _baseHeight = 222;
  static const double _baseBorderRadius = 24;
  static const double _baseShapeWidth = 161.5;
  static const double _baseSplitGap = 4;
  static const double _baseDiagonalInset = 35;
  static const double _baseNameHorizontalPadding = 18;
  static const double _baseNameSplitPadding = 8;
  static const double _baseNameBottomPadding = 17;
  static const double _baseGradientHeight = 91;
  static const double _baseNameFontSize = 14.5;

  /// 左侧封面地址
  final String leftCoverUrl;

  /// 左侧头像回退地址
  final String leftAvatarUrl;

  /// 左侧角色名称
  final String leftCharacterName;

  /// 右侧封面地址
  final String rightCoverUrl;

  /// 右侧头像回退地址
  final String rightAvatarUrl;

  /// 右侧角色名称
  final String rightCharacterName;

  /// 组件宽度
  final double width;

  /// 左侧图片 Hero 标识
  final String? leftHeroTag;

  /// 右侧图片 Hero 标识
  final String? rightHeroTag;

  /// 左侧图片点击回调
  final VoidCallback? onLeftCoverTap;

  /// 右侧图片点击回调
  final VoidCallback? onRightCoverTap;

  /// 左侧角色名称点击回调
  final VoidCallback? onLeftCharacterTap;

  /// 右侧角色名称点击回调
  final VoidCallback? onRightCharacterTap;

  /// 左侧圣殿资产入口点击回调
  final VoidCallback? onLeftAssetTap;

  /// 右侧圣殿资产入口点击回调
  final VoidCallback? onRightAssetTap;

  /// 构建圣殿连接卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final scale = width / _baseWidth;
    final height = _baseHeight * scale;
    final radius = BorderRadius.circular(_baseBorderRadius * scale);
    final shapeWidth = _baseShapeWidth * scale;
    final rightShapeOffset = width - shapeWidth;
    final splitGap = _baseSplitGap * scale;
    final diagonalInset = _baseDiagonalInset * scale;

    return DecoratedBox(
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
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: shapeWidth,
                height: height,
                child: ClipPath(
                  clipper: _TempleLinkDiagonalClipper(
                    clipLeftSide: true,
                    diagonalInset: diagonalInset,
                    splitGap: splitGap,
                  ),
                  child: _TempleLinkCoverButton(
                    coverUrl: leftCoverUrl,
                    avatarUrl: leftAvatarUrl,
                    heroTag: leftHeroTag,
                    onTap: onLeftCoverTap,
                  ),
                ),
              ),
              Positioned(
                left: rightShapeOffset,
                top: 0,
                width: shapeWidth,
                height: height,
                child: ClipPath(
                  clipper: _TempleLinkDiagonalClipper(
                    clipLeftSide: false,
                    diagonalInset: diagonalInset,
                    splitGap: splitGap,
                  ),
                  child: _TempleLinkCoverButton(
                    coverUrl: rightCoverUrl,
                    avatarUrl: rightAvatarUrl,
                    heroTag: rightHeroTag,
                    onTap: onRightCoverTap,
                  ),
                ),
              ),
              _buildBottomGradient(scale),
              _buildCharacterNames(
                rightShapeOffset: rightShapeOffset,
                splitGap: splitGap,
                scale: scale,
              ),
              ..._buildAssetEntryButtons(scale),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.40),
                        width: 0.75,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建左右圣殿资产入口按钮
  ///
  /// [scale] 尺寸缩放比例
  List<Widget> _buildAssetEntryButtons(double scale) {
    final dimension = (28 * scale).clamp(24.0, 30.0).toDouble();
    final iconSize = (14 * scale).clamp(12.0, 15.0).toDouble();
    final top = 8 * scale;
    final side = 8 * scale;

    return [
      if (onLeftAssetTap != null)
        Positioned(
          top: top,
          left: side,
          child: _TempleLinkAssetEntryButton(
            dimension: dimension,
            iconSize: iconSize,
            onPressed: onLeftAssetTap!,
          ),
        ),
      if (onRightAssetTap != null)
        Positioned(
          top: top,
          right: side,
          child: _TempleLinkAssetEntryButton(
            dimension: dimension,
            iconSize: iconSize,
            onPressed: onRightAssetTap!,
          ),
        ),
    ];
  }

  /// 构建左右角色名称
  ///
  /// [rightShapeOffset] 右侧图片偏移
  /// [splitGap] 中间斜切间距
  /// [scale] 尺寸缩放比例
  Widget _buildCharacterNames({
    required double rightShapeOffset,
    required double splitGap,
    required double scale,
  }) {
    final style = TextStyle(
      color: const Color(0xD6FFFFFF),
      fontSize: (_baseNameFontSize * scale).clamp(11.0, 16.0),
      fontWeight: FontWeight.w800,
      height: 1,
      shadows: const [
        Shadow(
          color: Color(0x66000000),
          offset: Offset(0, 1),
          blurRadius: 4,
        ),
      ],
    );

    final nameHorizontalPadding = _baseNameHorizontalPadding * scale;
    final nameSplitPadding = _baseNameSplitPadding * scale;
    final nameBottomPadding = _baseNameBottomPadding * scale;
    final splitLeft = rightShapeOffset - splitGap / 2;
    final splitRight = rightShapeOffset + splitGap / 2;
    final leftNameWidth = math.max(
      0.0,
      splitLeft - nameHorizontalPadding - nameSplitPadding,
    );

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            left: nameHorizontalPadding,
            bottom: nameBottomPadding,
            width: leftNameWidth,
            child: _TempleLinkNameButton(
              onTap: onLeftCharacterTap,
              text: leftCharacterName,
              style: style,
            ),
          ),
          Positioned(
            left: splitRight + nameSplitPadding,
            right: nameHorizontalPadding,
            bottom: nameBottomPadding,
            child: _TempleLinkNameButton(
              onTap: onRightCharacterTap,
              text: rightCharacterName,
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部渐变层
  ///
  /// [scale] 尺寸缩放比例
  Widget _buildBottomGradient(double scale) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: _baseGradientHeight * scale,
      child: const IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x002F2830),
                Color(0x522F2830),
                Color(0x8A2F2830),
              ],
              stops: [0, 0.42, 1],
            ),
          ),
        ),
      ),
    );
  }
}

/// 圣殿连接资产入口按钮
class _TempleLinkAssetEntryButton extends StatelessWidget {
  /// 创建圣殿连接资产入口按钮
  ///
  /// [dimension] 按钮宽高
  /// [iconSize] 图标尺寸
  /// [onPressed] 点击回调
  const _TempleLinkAssetEntryButton({
    required this.dimension,
    required this.iconSize,
    required this.onPressed,
  });

  /// 按钮宽高
  final double dimension;

  /// 图标尺寸
  final double iconSize;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建圣殿连接资产入口按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.28),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        splashColor: Colors.white.withValues(alpha: 0.12),
        highlightColor: Colors.white.withValues(alpha: 0.06),
        child: SizedBox.square(
          dimension: dimension,
          child: Icon(
            LucideIcons.walletCards,
            size: iconSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// 圣殿连接角色名称按钮
class _TempleLinkNameButton extends StatelessWidget {
  /// 创建圣殿连接角色名称按钮
  ///
  /// [text] 角色名称文本
  /// [style] 文本样式
  /// [textAlign] 文本对齐方式
  /// [onTap] 点击回调
  const _TempleLinkNameButton({
    required this.text,
    required this.style,
    this.textAlign,
    this.onTap,
  });

  /// 角色名称文本
  final String text;

  /// 文本样式
  final TextStyle style;

  /// 文本对齐方式
  final TextAlign? textAlign;

  /// 点击回调
  final VoidCallback? onTap;

  /// 构建圣殿连接角色名称按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        splashColor: Colors.white.withValues(alpha: 0.10),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
            style: style,
          ),
        ),
      ),
    );
  }
}

/// 圣殿连接封面按钮
class _TempleLinkCoverButton extends StatelessWidget {
  /// 创建圣殿连接封面按钮
  ///
  /// [coverUrl] 封面地址
  /// [avatarUrl] 头像回退地址
  /// [heroTag] 图片 Hero 标识
  /// [onTap] 点击回调
  const _TempleLinkCoverButton({
    required this.coverUrl,
    required this.avatarUrl,
    this.heroTag,
    this.onTap,
  });

  /// 封面地址
  final String coverUrl;

  /// 头像回退地址
  final String avatarUrl;

  /// 图片 Hero 标识
  final String? heroTag;

  /// 点击回调
  final VoidCallback? onTap;

  /// 构建圣殿连接封面按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final cover = TempleCoverImage(
      coverUrl: coverUrl,
      avatarUrl: avatarUrl,
      alignment: Alignment.topCenter,
      fallbackAvatarAlignment: Alignment.center,
    );
    final tag = heroTag;

    return Stack(
      fit: StackFit.expand,
      children: [
        tag == null ? cover : Hero(tag: tag, child: cover),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withValues(alpha: 0.12),
            highlightColor: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ],
    );
  }
}

/// 圣殿连接斜切裁剪
class _TempleLinkDiagonalClipper extends CustomClipper<Path> {
  /// 创建圣殿连接斜切裁剪
  ///
  /// [clipLeftSide] 是否裁剪左侧图片区域
  /// [diagonalInset] 斜切横向偏移
  /// [splitGap] 中间斜切间距
  const _TempleLinkDiagonalClipper({
    required this.clipLeftSide,
    required this.diagonalInset,
    required this.splitGap,
  });

  /// 是否裁剪左侧图片区域
  final bool clipLeftSide;

  /// 斜切横向偏移
  final double diagonalInset;

  /// 中间斜切间距
  final double splitGap;

  /// 生成斜切路径
  ///
  /// [size] 裁剪区域尺寸
  @override
  Path getClip(Size size) {
    final gapOffset = splitGap / 2;

    if (clipLeftSide) {
      return Path()
        ..moveTo(0, 0)
        ..lineTo(size.width - gapOffset, 0)
        ..lineTo(size.width - diagonalInset - gapOffset, size.height)
        ..lineTo(0, size.height)
        ..close();
    }

    return Path()
      ..moveTo(diagonalInset + gapOffset, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(gapOffset, size.height)
      ..close();
  }

  /// 判断是否需要重新裁剪
  ///
  /// [oldClipper] 旧裁剪器
  @override
  bool shouldReclip(_TempleLinkDiagonalClipper oldClipper) {
    return oldClipper.clipLeftSide != clipLeftSide ||
        oldClipper.diagonalInset != diagonalInset ||
        oldClipper.splitGap != splitGap;
  }
}
