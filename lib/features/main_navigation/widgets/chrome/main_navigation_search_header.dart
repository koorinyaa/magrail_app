import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
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
    final searchGlassSettings = isDark
        ? const LiquidGlassSettings(
            glassColor: Color(0x1AFFFFFF),
            thickness: 0,
            blur: 0,
            glowIntensity: 0,
            shadowElevation: 0,
          )
        : const LiquidGlassSettings(
            visibility: 0,
            glassColor: Colors.transparent,
            thickness: 0,
            blur: 0,
            glowIntensity: 0,
            shadowElevation: 0,
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
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: gradientStops,
                      colors: [
                        backgroundColor,
                        backgroundColor,
                        backgroundColor.withValues(alpha: 0.99),
                        backgroundColor.withValues(alpha: 0.96),
                        backgroundColor.withValues(alpha: 0.9),
                        backgroundColor.withValues(alpha: 0.8),
                        backgroundColor.withValues(alpha: 0.65),
                        backgroundColor.withValues(alpha: 0.45),
                        backgroundColor.withValues(alpha: 0.2),
                        backgroundColor.withValues(alpha: 0),
                      ],
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
                      left: 24,
                      top: _searchRowPadding,
                      right: 24,
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
                                      size: CharacterSearchInputBar.height * 0.5,
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
