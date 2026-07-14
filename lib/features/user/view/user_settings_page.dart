import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/auth/bangumi_mirror_config.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/update/app_update_controller.dart';
import 'package:magrail_app/core/update/app_update_dialog.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/viewer/fullscreen_image_viewer_page.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/core/widgets/app_loading_dialog.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

part 'user_settings_page_about.dart';
part 'user_settings_page_components.dart';
part 'user_settings_page_donate.dart';
part 'user_settings_page_theme.dart';

const _appName = 'MaGrail';
const _appIconAsset = 'assets/icons/app_icon_foreground.png';
const _githubIconAsset = 'assets/icons/github.svg';
const _donateAlipayAsset = 'assets/images/donate/alipay.jpg';
const _donateWechatPayAsset = 'assets/images/donate/wechatpay.jpg';
const _projectGithubLabel = '项目地址';
final _projectGithubUrl = Uri.parse('https://github.com/koorinyaa/magrail_app');

/// 用户设置页路由附加数据
class UserSettingsRouteExtra {
  /// 创建用户设置页路由附加数据
  ///
  /// [onSignedOut] 退出登录后的回调
  /// [onLiquidGlassChanged] 液态玻璃开关变化回调
  const UserSettingsRouteExtra({
    this.onSignedOut,
    this.onLiquidGlassChanged,
  });

  /// 退出登录后的回调
  final VoidCallback? onSignedOut;

  /// 液态玻璃开关变化回调
  final ValueChanged<bool>? onLiquidGlassChanged;
}

/// 用户设置二级页面
class UserSettingsPage extends StatefulWidget {
  /// 创建用户设置二级页面
  ///
  /// [key] Flutter 组件标识
  /// [authRepository] Tinygrail 授权仓库
  /// [preferences] 本地偏好设置
  /// [updateController] 应用更新控制器
  /// [userRepository] 用户仓库
  /// [onSignedOut] 退出登录后的回调
  /// [onLiquidGlassChanged] 液态玻璃开关变化回调
  /// [onThemeModeChanged] 应用主题模式变化回调
  const UserSettingsPage({
    super.key,
    required this.authRepository,
    required this.preferences,
    required this.updateController,
    required this.userRepository,
    this.onSignedOut,
    this.onLiquidGlassChanged,
    this.onThemeModeChanged,
  });

  /// Tinygrail 授权仓库
  final TinygrailAuthRepository authRepository;

  /// 本地偏好设置
  final AppPreferences preferences;

  /// 应用更新控制器
  final AppUpdateController updateController;

  /// 用户仓库
  final UserRepository userRepository;

  /// 退出登录后的回调
  final VoidCallback? onSignedOut;

  /// 液态玻璃开关变化回调
  final ValueChanged<bool>? onLiquidGlassChanged;

  /// 应用主题模式变化回调
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  /// 创建用户设置二级页面状态
  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

/// 用户设置二级页面状态
class _UserSettingsPageState extends State<UserSettingsPage> {
  bool _isSigningOut = false;
  late bool _useBangumiMirror;
  late String _bangumiMirrorHost;
  late bool _hiddenFeaturesEnabled;
  late bool _revealPrivateUserHoldingsEnabled;
  late bool _useLiquidGlass;
  late bool _showBotAction;
  late ThemeMode _themeMode;

  /// 初始化用户设置二级页面状态
  @override
  void initState() {
    super.initState();
    _useBangumiMirror = widget.preferences.useBangumiMirror;
    _bangumiMirrorHost = BangumiMirrorConfig.resolveHost(
      widget.preferences.bangumiMirrorHost,
    );
    _hiddenFeaturesEnabled = widget.preferences.hiddenFeaturesEnabled;
    _revealPrivateUserHoldingsEnabled =
        widget.preferences.revealPrivateUserHoldingsEnabled;
    _useLiquidGlass = widget.preferences.useLiquidGlass;
    _showBotAction = widget.preferences.showBotAction;
    _themeMode = widget.preferences.themeMode;
  }

  /// 构建用户设置二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          const SecondaryPageSliverAppBar(title: '设置'),
          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SettingsSurface(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SettingsValueActionTile(
                            icon: Icons.dark_mode_outlined,
                            label: '深色模式',
                            value: _themeMode.settingsLabel,
                            onPressed: _openThemeModePage,
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 50,
                            endIndent: 16,
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.72,
                            ),
                          ),
                          _SettingsSwitchTile(
                            icon: Icons.blur_on_rounded,
                            label: '液态玻璃',
                            value: _useLiquidGlass,
                            onChanged: _handleLiquidGlassChanged,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsSurface(
                      child: _BangumiMirrorSwitchTile(
                        value: _useBangumiMirror,
                        mirrorHost: _bangumiMirrorHost,
                        onChanged: _handleBangumiMirrorChanged,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsSurface(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SettingsSwitchTile(
                            icon: LucideIcons.bot,
                            label: '显示 Bot 入口',
                            value: _showBotAction,
                            onChanged: _handleShowBotActionChanged,
                          ),
                          if (_hiddenFeaturesEnabled) ...[
                            Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 50,
                              endIndent: 16,
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.72,
                              ),
                            ),
                            _SettingsSwitchTile(
                              icon: Icons.visibility_outlined,
                              label: '显示未公开用户持股',
                              value: _revealPrivateUserHoldingsEnabled,
                              onChanged:
                                  _handleRevealPrivateUserHoldingsChanged,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsSurface(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SettingsActionTile(
                            icon: Icons.favorite_border_rounded,
                            label: '打赏',
                            onPressed: _openDonatePage,
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 50,
                            endIndent: 16,
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.72,
                            ),
                          ),
                          AnimatedBuilder(
                            animation: widget.updateController,
                            builder: (context, child) {
                              return _SettingsActionTile(
                                icon: Icons.info_outline_rounded,
                                label: '关于',
                                showNewBadge: widget.updateController.hasUpdate,
                                onPressed: _openAboutPage,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsSurface(
                      child: _SignOutButton(
                        isDisabled: _isSigningOut,
                        onPressed: _handleSignOut,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 打开打赏页面
  void _openDonatePage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const _DonatePage(),
      ),
    );
  }

  /// 打开关于页面
  void _openAboutPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _AboutPage(
          preferences: widget.preferences,
          updateController: widget.updateController,
          onHiddenFeaturesChanged: _handleHiddenFeaturesChanged,
        ),
      ),
    );
  }

  /// 打开深色模式设置页面
  void _openThemeModePage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _ThemeModePage(
          preferences: widget.preferences,
          initialThemeMode: _themeMode,
          onChanged: _handleThemeModeChanged,
        ),
      ),
    );
  }

  /// 处理应用主题模式变化
  ///
  /// [themeMode] 新的应用主题模式
  void _handleThemeModeChanged(ThemeMode themeMode) {
    if (!mounted || _themeMode == themeMode) {
      return;
    }

    setState(() {
      _themeMode = themeMode;
    });
    widget.onThemeModeChanged?.call(themeMode);
  }

  /// 处理隐藏功能状态变化
  ///
  /// [enabled] 是否启用隐藏功能
  void _handleHiddenFeaturesChanged(bool enabled) {
    if (!mounted) {
      return;
    }

    setState(() {
      _hiddenFeaturesEnabled = enabled;
      if (!enabled) {
        _revealPrivateUserHoldingsEnabled = false;
      }
    });
  }

  /// 处理 Bangumi 镜像开关变化
  ///
  /// [value] 是否使用 Bangumi 镜像
  Future<void> _handleBangumiMirrorChanged(bool value) async {
    final previousValue = _useBangumiMirror;
    setState(() {
      _useBangumiMirror = value;
    });
    TinygrailAssetUrls.configureBangumiMirror(
      useMirror: value,
      mirrorHost: _bangumiMirrorHost,
    );

    try {
      await widget.preferences.setUseBangumiMirror(value);
      if (!mounted) {
        return;
      }

      AppToast.info(
        context,
        text:
            value ? '已启用 $_bangumiMirrorHost 镜像' : '已关闭 $_bangumiMirrorHost 镜像',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _useBangumiMirror = previousValue;
      });
      TinygrailAssetUrls.configureBangumiMirror(
        useMirror: previousValue,
        mirrorHost: _bangumiMirrorHost,
      );
      AppToast.error(
        context,
        text: '保存设置失败，请稍后重试',
      );
    }
  }

  /// 处理液态玻璃开关变化
  ///
  /// [value] 是否启用液态玻璃
  Future<void> _handleLiquidGlassChanged(bool value) async {
    final previousValue = _useLiquidGlass;
    setState(() {
      _useLiquidGlass = value;
    });
    widget.onLiquidGlassChanged?.call(value);

    try {
      await widget.preferences.setUseLiquidGlass(value);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _useLiquidGlass = previousValue;
      });
      widget.onLiquidGlassChanged?.call(previousValue);
      AppToast.error(
        context,
        text: '保存设置失败，请稍后重试',
      );
    }
  }

  /// 处理 Bot 入口显示开关变化
  ///
  /// [value] 是否显示 Bot 入口
  Future<void> _handleShowBotActionChanged(bool value) async {
    final previousValue = _showBotAction;
    setState(() {
      _showBotAction = value;
    });

    try {
      await widget.preferences.setShowBotAction(value);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _showBotAction = previousValue;
      });
      AppToast.error(
        context,
        text: '保存设置失败，请稍后重试',
      );
    }
  }

  /// 处理未公开用户持股查看开关变化
  ///
  /// [value] 是否允许点击未公开用户持股
  Future<void> _handleRevealPrivateUserHoldingsChanged(bool value) async {
    final previousValue = _revealPrivateUserHoldingsEnabled;
    setState(() {
      _revealPrivateUserHoldingsEnabled = value;
    });

    try {
      await widget.preferences.setRevealPrivateUserHoldingsEnabled(value);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _revealPrivateUserHoldingsEnabled = previousValue;
      });
      AppToast.error(
        context,
        text: '保存设置失败，请稍后重试',
      );
    }
  }

  /// 处理退出登录
  Future<void> _handleSignOut() async {
    if (_isSigningOut) {
      return;
    }

    final confirmed = await _confirmSignOut();
    if (!mounted || !confirmed) {
      return;
    }

    setState(() {
      _isSigningOut = true;
    });

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    unawaited(showAppLoadingDialog(context, message: '正在退出登录'));

    try {
      // 退出登录先清理本地会话和缓存，避免继续展示旧登录用户
      await widget.authRepository.clearSession();
      await widget.userRepository.clearCurrentUserDataOnSignOut();
    } catch (_) {
      if (rootNavigator.mounted) {
        rootNavigator.pop();
      }
      if (!mounted) {
        return;
      }

      setState(() {
        _isSigningOut = false;
      });
      AppToast.error(
        context,
        text: '退出登录失败，请稍后重试',
      );
      return;
    }

    try {
      // 远端退出只做补充清理，失败不阻断本地退出流程
      await widget.authRepository.logoutRemote();
    } catch (_) {
      // 远端退出失败时仍继续关闭当前登录态
    }

    try {
      // 远端退出响应可能重新写入失效 Cookie，离开设置页前再次清理
      await widget.authRepository.clearSession();
    } catch (_) {
      if (rootNavigator.mounted) {
        rootNavigator.pop();
      }
      if (!mounted) {
        return;
      }

      setState(() {
        _isSigningOut = false;
      });
      AppToast.error(
        context,
        text: '退出登录失败，请稍后重试',
      );
      return;
    }

    if (!mounted) {
      return;
    }

    if (rootNavigator.mounted) {
      rootNavigator.pop();
    }
    widget.onSignedOut?.call();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  /// 确认退出登录
  Future<bool> _confirmSignOut() async {
    final colorScheme = Theme.of(context).colorScheme;

    return showAppConfirmDialog(
      context,
      title: '退出登录？',
      message: '确定要退出登录吗？',
      confirmText: '退出',
      icon: Icons.logout_rounded,
      confirmColor: colorScheme.error,
    );
  }
}
