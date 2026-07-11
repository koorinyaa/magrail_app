part of 'user_asset_analysis_character_packing_section.dart';

/// 用户资产分析资产占比角色气泡
class _PackedCharacterBubble extends StatelessWidget {
  /// 创建用户资产分析资产占比角色气泡
  ///
  /// [item] 圆图布局项
  /// [mode] 资产占比统计模式
  /// [disableAnimations] 是否禁用动画
  /// [onTap] 气泡点击回调，为空时禁用点击
  const _PackedCharacterBubble({
    required this.item,
    required this.mode,
    required this.disableAnimations,
    required this.onTap,
  });

  /// 圆图布局项
  final _PackedBubbleLayoutItem item;

  /// 资产占比统计模式
  final UserAssetAnalysisAssetProportionMode mode;

  /// 是否禁用动画
  final bool disableAnimations;

  /// 气泡点击回调
  final VoidCallback? onTap;

  /// 构建用户资产分析资产占比角色气泡
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final bubble = item.bubble;
    final diameter = item.radius * 2;
    final templeDominant = switch (mode) {
      UserAssetAnalysisAssetProportionMode.dividend =>
        bubble.templeDividend > bubble.characterDividend,
      UserAssetAnalysisAssetProportionMode.assets =>
        bubble.templeAssets > bubble.characterShares,
    };
    final sourceColor =
        templeDominant ? _templeDividendColor : _characterDividendColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCore = item.rank == 0;
    final isFeatured = item.rank < _featuredBubbleCount;
    final ringWidth = isCore ? 4.2 : (isFeatured ? 3.2 : 2.0);
    final avatarSize = math.max(0.0, diameter - ringWidth * 2 - 2);
    final shadowAlpha = item.ratio.clamp(0.16, 0.32).toDouble();
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(bubble.avatarUrl);

    Widget energyRing = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: isCore
              ? const [
                  _coreCyan,
                  _coreMint,
                  _coreGold,
                  _coreCoral,
                  _coreCyan,
                ]
              : [
                  sourceColor.withValues(alpha: 0.60),
                  sourceColor,
                  isFeatured ? _coreMint : sourceColor,
                  sourceColor.withValues(alpha: 0.60),
                ],
        ),
        boxShadow: [
          if (isCore) ...[
            BoxShadow(
              color: _coreCyan.withValues(alpha: 0.34),
              blurRadius: 24,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: _coreMint.withValues(alpha: 0.22),
              blurRadius: 34,
              spreadRadius: 4,
            ),
          ] else
            BoxShadow(
              color: sourceColor.withValues(alpha: shadowAlpha),
              blurRadius: isFeatured ? 18 : 11,
              spreadRadius: isFeatured ? 1 : 0,
              offset: const Offset(0, 5),
            ),
        ],
      ),
    );
    if (isCore && !disableAnimations) {
      energyRing = energyRing
          .animate(onPlay: (controller) => controller.repeat())
          .rotate(duration: 9.seconds);
    }

    Widget avatar = CharacterAvatar(
      imageUrl: avatarUrl,
      size: avatarSize,
      borderRadius: diameter,
    );
    final heroTag = onTap == null
        ? null
        : createCharacterDetailAvatarHeroTag(
            characterId: bubble.characterId,
            avatarUrl: bubble.avatarUrl,
            source: bubble,
          );
    if (heroTag != null) {
      avatar = Hero(
        tag: heroTag,
        transitionOnUserGestures: true,
        child: avatar,
      );
    }

    Widget orb = Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        if (isCore)
          Positioned.fill(
            child: _CoreHalo(disableAnimations: disableAnimations),
          ),
        Positioned.fill(child: energyRing),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(ringWidth),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF080B10) : Colors.white,
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.78),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: avatar,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(ringWidth + 1),
            child: IgnorePointer(
              child: ClipOval(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.22 : 0.34),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.10),
                      ],
                      stops: const [0, 0.42, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (onTap != null)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: sourceColor.withValues(alpha: 0.22),
                highlightColor: Colors.white.withValues(alpha: 0.08),
                onTap: onTap,
              ),
            ),
          ),
      ],
    );
    if (!disableAnimations) {
      orb = orb
          .animate(delay: (math.min(item.rank, 16) * 24).ms)
          .fadeIn(duration: 240.ms)
          .scaleXY(
            begin: 0.72,
            end: 1,
            duration: 420.ms,
            curve: Curves.easeOutBack,
          );
    }

    return Positioned(
      left: item.center.dx - item.radius,
      top: item.center.dy - item.radius,
      width: diameter,
      height: diameter,
      child: orb,
    );
  }
}

/// 用户资产分析核心角色光晕
class _CoreHalo extends StatelessWidget {
  /// 创建用户资产分析核心角色光晕
  ///
  /// [disableAnimations] 是否禁用动画
  const _CoreHalo({required this.disableAnimations});

  final bool disableAnimations;

  /// 构建用户资产分析核心角色光晕
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    Widget halo = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _coreCyan.withValues(alpha: 0.30),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _coreCyan.withValues(alpha: 0.24),
            blurRadius: 28,
            spreadRadius: 5,
          ),
        ],
      ),
    );
    if (!disableAnimations) {
      halo = halo
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .fade(begin: 0.34, end: 0.88, duration: 1800.ms)
          .scaleXY(
            begin: 0.94,
            end: 1.10,
            duration: 1800.ms,
            curve: Curves.easeInOut,
          );
    }
    return halo;
  }
}
