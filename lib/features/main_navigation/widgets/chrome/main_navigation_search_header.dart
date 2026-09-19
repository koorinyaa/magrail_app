import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/theme/glass_theme_helpers.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/features/chara/search/widgets/character_search_input_bar.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';
import 'package:magrail_app/features/user/widgets/user_avatar.dart';

/// 主导航顶部搜索栏
class MainNavigationSearchHeader extends StatelessWidget {
  /// 独立搜索行高度，不含系统状态栏
  static const double contentHeight = 72;

  // 保持搜索框原有顶部位置，有标签栏时仅收紧搜索行底部留白
  static const double _searchRowPadding =
      (contentHeight - CharacterSearchInputBar.height) / 2;

  // 标签文字自带顶部留白
  static const double _searchTabSpacing = 2;

  /// 渐变向页面内容延伸的高度
  static const double fadeContentOverlap = 8;

  // 渐变前段缓慢衰减，后段逐步加速变为透明，避免末端出现分层
  static const List<double> _backgroundGradientStops = [
    0,
    0.14,
    0.28,
    0.42,
    0.56,
    0.68,
    0.78,
    0.88,
    0.95,
    1,
  ];

  /// 计算固定头部占位高度，不包含渐变尾部
  ///
  /// [context] 当前组件树上下文
  /// [bottom] 附加标签栏，存在时收紧搜索行下方留白
  static double occupiedHeight(
    BuildContext context, {
    PreferredSizeWidget? bottom,
  }) {
    return MediaQuery.paddingOf(context).top +
        _searchRowPadding +
        CharacterSearchInputBar.height +
        (bottom == null
            ? _searchRowPadding
            : _searchTabSpacing + bottom.preferredSize.height);
  }

  /// 创建主导航顶部搜索栏
  ///
  /// [key] Flutter 组件标识
  /// [backgroundColor] 页面背景色
  /// [profile] 当前登录用户资料，为空时显示头像占位
  /// [onSearchPressed] 搜索栏点击回调
  /// [onProfilePressed] 用户头像点击回调
  /// [bottom] 与搜索行共用渐变背景的底部标签栏
  const MainNavigationSearchHeader({
    super.key,
    required this.backgroundColor,
    required this.onSearchPressed,
    required this.onProfilePressed,
    this.profile,
    this.bottom,
  });

  /// 页面背景色
  final Color backgroundColor;

  /// 当前登录用户资料
  final UserDetailProfile? profile;

  /// 搜索栏点击回调
  final VoidCallback onSearchPressed;

  /// 用户头像点击回调
  final VoidCallback onProfilePressed;

  /// 与搜索行共用渐变背景的底部标签栏
  final PreferredSizeWidget? bottom;

  /// 构建主导航顶部搜索栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    // 搜索入口与头像占位共享磨砂配置，其余效果继承组件当前主题
    final searchGlassSettings = GlassThemeHelpers.resolveSettings(context)
        .copyWith(
          blur: AppBlurStyle.sigma,
          glassColor: isDark
              ? const Color(0xFF52525B).withValues(alpha: 0.35)
              : const Color(0xFFD4D4D8).withValues(alpha: 0.45),
        );
    final avatarFeedbackColor = isDark ? Colors.white : Colors.black;
    final systemOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );
    final topPadding = MediaQuery.paddingOf(context).top;
    final profile = this.profile;
    final bottom = this.bottom;
    final fullHeight = occupiedHeight(context, bottom: bottom);
    // 附加标签栏时从搜索框中部开始背景过渡，前景控件始终保持清晰
    final gradientStart = bottom == null
        ? 0.0
        : (topPadding + contentHeight / 2) / (fullHeight + fadeContentOverlap);
    final gradientStops = bottom == null
        ? _backgroundGradientStops
        : [
            for (final stop in _backgroundGradientStops)
              gradientStart + (1 - gradientStart) * stop,
          ];
    final surfaceColor =
        Color.alphaBlend(
          colorScheme.surfaceContainer.withValues(alpha: 0.8),
          backgroundColor,
        ).withValues(
          alpha: isDark
              ? AppBlurStyle.darkSurfaceAlpha
              : AppBlurStyle.lightSurfaceAlpha,
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle,
      child: SizedBox(
        width: double.infinity,
        height: fullHeight + fadeContentOverlap,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                // 先采样后方内容，再在同一模糊图层内淡出结果，避免外层离屏遮罩隔断采样
                child: ClipRect(
                  child: BackdropFilter(
                    filter: AppBlurStyle.filter,
                    child: CustomPaint(
                      foregroundPainter: _SearchHeaderFadePainter(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: gradientStops,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.white.withValues(alpha: 0.99),
                            Colors.white.withValues(alpha: 0.96),
                            Colors.white.withValues(alpha: 0.9),
                            Colors.white.withValues(alpha: 0.8),
                            Colors.white.withValues(alpha: 0.65),
                            Colors.white.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: ColoredBox(color: surfaceColor),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: fullHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: topPadding),
                  Padding(
                    padding: AppSafeAreaInsets.fromLTRB(
                      context,
                      left: AppSafeAreaInsets.primaryPageHorizontal,
                      top: _searchRowPadding,
                      right: AppSafeAreaInsets.primaryPageHorizontal,
                      bottom: bottom == null
                          ? _searchRowPadding
                          : _searchTabSpacing,
                    ),
                    child: SizedBox(
                      height: CharacterSearchInputBar.height,
                      child: Row(
                        children: [
                          Expanded(
                            child: CharacterSearchInputBar(
                              placeholder: '搜索角色',
                              readOnly: true,
                              glassSettings: searchGlassSettings,
                              onTap: onSearchPressed,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox.square(
                            dimension: CharacterSearchInputBar.height,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (profile == null)
                                  GlassContainer(
                                    width: CharacterSearchInputBar.height,
                                    height: CharacterSearchInputBar.height,
                                    alignment: Alignment.center,
                                    shape: const LiquidOval(),
                                    settings: searchGlassSettings,
                                    useOwnLayer: true,
                                    quality: GlassQuality.minimal,
                                    child: Icon(
                                      Icons.person_rounded,
                                      size:
                                          CharacterSearchInputBar.height * 0.5,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                else
                                  UserAvatar(
                                    imageUrl: profile.avatar,
                                    isBanned: profile.isBanned,
                                    size: CharacterSearchInputBar.height,
                                  ),
                                // 头像内容会遮住底层墨水反馈，透明材质必须绘制在最上层
                                Material(
                                  type: MaterialType.transparency,
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: onProfilePressed,
                                    customBorder: const CircleBorder(),
                                    splashColor: avatarFeedbackColor.withValues(
                                      alpha: 0.12,
                                    ),
                                    highlightColor: avatarFeedbackColor
                                        .withValues(
                                          alpha: isDark ? 0.10 : 0.08,
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
                  ?bottom,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 在搜索头部模糊图层内淡出完整磨砂画面
class _SearchHeaderFadePainter extends CustomPainter {
  /// 创建磨砂结果渐隐绘制器
  ///
  /// [gradient] 磨砂画面从可见到透明的纵向遮罩
  const _SearchHeaderFadePainter({required this.gradient});

  /// 磨砂结果的透明度遮罩
  final LinearGradient gradient;

  /// 对已绘制的模糊背景和灰色表面应用渐隐
  ///
  /// [canvas] 所属 BackdropFilter 图层的画布
  /// [size] 搜索头部背景尺寸
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    // 混合当前模糊图层
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = gradient.createShader(bounds),
    );
  }

  /// 在渐隐范围变化时更新遮罩
  ///
  /// [oldDelegate] 上一次的渐隐绘制配置
  @override
  bool shouldRepaint(_SearchHeaderFadePainter oldDelegate) {
    return gradient != oldDelegate.gradient;
  }
}
