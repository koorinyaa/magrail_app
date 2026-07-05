import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/core/widgets/temple_cover_image.dart';

/// 圣殿卡片
class TempleCard extends StatelessWidget {
  /// 创建圣殿卡片
  ///
  /// [width] 卡片宽度
  /// [borderRadius] 卡片圆角
  /// [coverUrl] 圣殿封面地址
  /// [avatarUrl] 用户头像地址
  /// [characterName] 角色名称
  /// [characterLevel] 角色等级
  /// [zeroCount] ST 等级
  /// [ownerLabel] 用户展示文案
  /// [templeLevel] 圣殿等级
  /// [refine] 精炼等级
  /// [starForces] 圣殿星之力
  /// [heroTag] 图片 Hero 标识
  /// [showCharacterInfo] 是否显示角色名称和等级
  /// [onTap] 卡片点击回调
  /// [onCharacterTap] 角色名称和等级点击回调
  /// [onUserTap] 用户昵称点击回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const TempleCard({
    super.key,
    required this.coverUrl,
    required this.avatarUrl,
    required this.characterName,
    required this.characterLevel,
    required this.zeroCount,
    required this.ownerLabel,
    required this.templeLevel,
    required this.refine,
    required this.starForces,
    this.width = 180,
    this.borderRadius = 24,
    this.heroTag,
    this.showCharacterInfo = true,
    this.onTap,
    this.onCharacterTap,
    this.onUserTap,
    this.onAssetTap,
  });

  /// 卡片宽度
  final double width;

  /// 卡片圆角
  final double borderRadius;

  /// 圣殿封面地址
  final String coverUrl;

  /// 用户头像地址
  final String avatarUrl;

  /// 角色名称
  final String characterName;

  /// 角色等级
  final int characterLevel;

  /// ST 等级
  final int zeroCount;

  /// 用户展示文案
  final String ownerLabel;

  /// 圣殿等级
  final int templeLevel;

  /// 精炼等级
  final int refine;

  /// 圣殿星之力
  final int starForces;

  /// 图片 Hero 标识
  final String? heroTag;

  /// 是否显示角色名称和等级
  final bool showCharacterInfo;

  /// 卡片点击回调
  final VoidCallback? onTap;

  /// 角色名称和等级点击回调
  final VoidCallback? onCharacterTap;

  /// 用户昵称点击回调
  final VoidCallback? onUserTap;

  /// 圣殿资产入口点击回调
  final VoidCallback? onAssetTap;

  /// 构建圣殿卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

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
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                _buildImageLayer(),
                _buildReadingOverlay(),
                Positioned(
                  left: 12,
                  top: 12,
                  child: _TempleCardLevelBadge(
                    levelText: _levelText,
                    color: _themeColor,
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      splashColor: Colors.white.withValues(alpha: 0.12),
                      highlightColor: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                if (onAssetTap != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _TempleCardAssetEntryButton(
                      onPressed: onAssetTap!,
                    ),
                  ),
                _buildRoleInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建图片层
  Widget _buildImageLayer() {
    final image = DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.40),
          width: 0.75,
        ),
      ),
      child: TempleCoverImage(
        coverUrl: coverUrl,
        avatarUrl: avatarUrl,
      ),
    );

    final tag = heroTag;
    return Positioned.fill(
      child: tag == null ? image : Hero(tag: tag, child: image),
    );
  }

  /// 构建底部阅读渐变
  Widget _buildReadingOverlay() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 114,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2F2830).withValues(alpha: 0),
              const Color(0xFF2F2830).withValues(alpha: 0.29),
              const Color(0xFF2F2830).withValues(alpha: 0.50),
            ],
            stops: const [0, 0.58, 1],
          ),
        ),
      ),
    );
  }

  /// 构建角色信息
  Widget _buildRoleInfo() {
    return Positioned(
      left: 14,
      right: 14,
      bottom: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCharacterInfo) ...[
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onCharacterTap,
                borderRadius: BorderRadius.circular(10),
                splashColor: Colors.white.withValues(alpha: 0.10),
                highlightColor: Colors.white.withValues(alpha: 0.05),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          characterName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      LevelBadge(level: characterLevel, zeroCount: zeroCount),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: onUserTap,
                    borderRadius: BorderRadius.circular(8),
                    splashColor: Colors.white.withValues(alpha: 0.10),
                    highlightColor: Colors.white.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 3,
                      ),
                      child: Text(
                        ownerLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.80),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _TempleCardStarBadge(highlighted: starForces >= 10000),
            ],
          ),
        ],
      ),
    );
  }

  /// 圣殿等级文本
  String get _levelText {
    if (refine > 0) {
      return '+$refine';
    }

    return '$templeLevel';
  }

  /// 圣殿主题色
  Color get _themeColor {
    return switch (templeLevel) {
      2 => const Color(0xFFEAB308),
      3 => const Color(0xFFA855F7),
      _ => const Color(0xFF9CA3AF),
    };
  }
}

/// 圣殿资产入口按钮
class _TempleCardAssetEntryButton extends StatelessWidget {
  /// 创建圣殿资产入口按钮
  ///
  /// [onPressed] 点击回调
  const _TempleCardAssetEntryButton({
    required this.onPressed,
  });

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建圣殿资产入口按钮
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
        child: const SizedBox.square(
          dimension: 28,
          child: Icon(
            LucideIcons.walletCards,
            size: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// 圣殿卡片等级徽标
class _TempleCardLevelBadge extends StatelessWidget {
  /// 创建圣殿卡片等级徽标
  ///
  /// [levelText] 等级文本
  /// [color] 徽标颜色
  const _TempleCardLevelBadge({
    required this.levelText,
    required this.color,
  });

  /// 等级文本
  final String levelText;

  /// 徽标颜色
  final Color color;

  /// 构建圣殿卡片等级徽标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      constraints: const BoxConstraints(minWidth: 30),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        levelText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

/// 圣殿卡片星之力徽标
class _TempleCardStarBadge extends StatelessWidget {
  /// 创建圣殿卡片星之力徽标
  ///
  /// [highlighted] 是否高亮
  const _TempleCardStarBadge({
    required this.highlighted,
  });

  /// 是否高亮
  final bool highlighted;

  /// 构建圣殿卡片星之力徽标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Icon(
      highlighted ? Icons.star_rounded : Icons.star_border_rounded,
      color: const Color(0xFFFFD25A),
      size: 20,
      shadows: [
        Shadow(
          color: Colors.black.withValues(alpha: 0.09),
          offset: const Offset(0, 1),
          blurRadius: 3,
        ),
      ],
    );
  }
}
