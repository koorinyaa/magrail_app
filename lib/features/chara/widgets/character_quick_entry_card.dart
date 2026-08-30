part of 'character_quick_entry_bar.dart';

/// 角色入口装饰图形
enum _PortalArtwork {
  /// 英灵殿 Logo 图标
  tinygrailLogo,

  /// 幻想乡图标
  torii,

  /// 即将退市预警图标
  delistingWarning,
}

/// 角色入口交互卡片
class _CharacterPortalCard extends StatefulWidget {
  /// 创建角色入口交互卡片
  ///
  /// [sequence] 入口序号
  /// [title] 中文入口标题
  /// [englishTitle] 英文装饰标题
  /// [accent] 入口强调色
  /// [artwork] 入口装饰图形
  /// [prominent] 是否为主入口
  /// [onTap] 入口点击回调
  const _CharacterPortalCard({
    required this.sequence,
    required this.title,
    required this.englishTitle,
    required this.accent,
    required this.artwork,
    this.prominent = false,
    required this.onTap,
  });

  final String sequence;
  final String title;
  final String englishTitle;
  final Color accent;
  final _PortalArtwork artwork;
  final bool prominent;
  final VoidCallback onTap;

  /// 创建角色入口交互卡片状态
  @override
  State<_CharacterPortalCard> createState() => _CharacterPortalCardState();
}

/// 角色入口交互卡片状态
class _CharacterPortalCardState extends State<_CharacterPortalCard>
    with SingleTickerProviderStateMixin {
  static const SpringDescription _pressSpring = SpringDescription(
    mass: 1,
    stiffness: 420,
    damping: 28,
  );

  late final AnimationController _pressController;
  bool _disableAnimations = false;

  /// 初始化角色入口交互卡片状态
  @override
  void initState() {
    super.initState();
    _pressController = AnimationController.unbounded(vsync: this);
  }

  /// 同步系统动态效果设置
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (_disableAnimations && _pressController.value != 0) {
      _pressController
        ..stop()
        ..value = 0;
    }
  }

  /// 释放角色入口交互卡片状态
  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  /// 处理卡片按压高亮变化
  ///
  /// [highlighted] 是否正在按压卡片
  void _handleHighlightChanged(bool highlighted) {
    if (_disableAnimations) {
      return;
    }
    _pressController.animateWith(
      SpringSimulation(
        _pressSpring,
        _pressController.value,
        highlighted ? 1 : 0,
        0,
      ),
    );
  }

  /// 构建角色入口交互卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pressController,
      child: RepaintBoundary(child: _buildSurface(context)),
      builder: (context, child) {
        final press = _pressController.value.clamp(-0.12, 1.06);
        return Transform.translate(
          offset: Offset(0, math.max(0, press) * 3),
          child: Transform.scale(
            scale: 1 - press * 0.025,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }

  /// 构建卡片主题表面
  ///
  /// [context] 当前组件树上下文
  Widget _buildSurface(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final baseColor = colorScheme.surfaceContainer;
    final foregroundColor = colorScheme.onSurface;
    final radius = BorderRadius.circular(12);
    final accentAlpha = widget.prominent ? 0.24 : 0.14;
    final startColor = Color.alphaBlend(
      widget.accent.withValues(alpha: accentAlpha),
      baseColor,
    );
    final endColor = Color.alphaBlend(
      widget.accent.withValues(alpha: 0.035),
      baseColor,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: widget.accent.withValues(alpha: isDark ? 0.07 : 0.1),
            blurRadius: 24,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: widget.accent.withValues(
                alpha: widget.prominent ? 0.32 : 0.22,
              ),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [startColor, baseColor, endColor],
              stops: const [0, 0.58, 1],
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: _handleHighlightChanged,
            splashColor: widget.accent.withValues(alpha: 0.14),
            highlightColor: widget.accent.withValues(alpha: 0.07),
            borderRadius: radius,
            child: _buildCardContent(foregroundColor: foregroundColor),
          ),
        ),
      ),
    );
  }

  /// 构建卡片前景内容
  ///
  /// [foregroundColor] 卡片前景颜色
  Widget _buildCardContent({required Color foregroundColor}) {
    final isProminent = widget.prominent;
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _PortalCardPainter(
                accent: widget.accent,
                prominent: isProminent,
              ),
            ),
          ),
        ),
        Positioned(
          left: isProminent ? 2 : 4,
          right: isProminent ? -60 : -34,
          bottom: isProminent ? 25 : 18,
          child: IgnorePointer(
            child: Text(
              widget.englishTitle,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: foregroundColor.withValues(alpha: 0.08),
                fontSize: isProminent ? 39 : 22,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: isProminent ? -1.5 : -0.85,
                height: 1,
              ),
            ),
          ),
        ),
        Positioned(
          left: isProminent ? 14 : 10,
          top: isProminent ? 13 : 9,
          child: Text(
            widget.sequence,
            style: TextStyle(
              color: widget.accent,
              fontSize: isProminent ? 11 : 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              height: 1,
            ),
          ),
        ),
        Positioned(
          right: isProminent ? 14 : 9,
          top: isProminent ? 13 : 9,
          child: _buildArtwork(size: isProminent ? 58 : 26),
        ),
        Positioned(
          left: isProminent ? 14 : 10,
          right: isProminent ? 14 : 9,
          bottom: isProminent ? 14 : 9,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: isProminent ? 24 : 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: isProminent ? -0.8 : -0.3,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                LucideIcons.arrowUpRight,
                size: isProminent ? 18 : 14,
                color: widget.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建入口装饰图形
  ///
  /// [size] 装饰图形尺寸
  Widget _buildArtwork({required double size}) {
    final logoGradient = Theme.of(context).brightness == Brightness.light
        ? const RadialGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0x00FFFFFF)],
            stops: [0, 0.7, 1],
          )
        : const RadialGradient(colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)]);
    return SizedBox.square(
      dimension: size,
      child: switch (widget.artwork) {
        _PortalArtwork.tinygrailLogo => ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => logoGradient.createShader(bounds),
          child: ClipOval(
            child: Image.asset(
              'assets/images/tinygrail/tinygrail_logo.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        _PortalArtwork.torii => SvgPicture.asset(
          'assets/icons/torii.svg',
          colorFilter: ColorFilter.mode(widget.accent, BlendMode.srcIn),
        ),
        _PortalArtwork.delistingWarning => Icon(
          LucideIcons.calendarClock,
          size: size,
          color: widget.accent,
        ),
      },
    );
  }
}
