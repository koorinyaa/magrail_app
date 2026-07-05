import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/auth/bangumi_mirror_config.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/update/app_update_controller.dart';
import 'package:magrail_app/core/update/app_update_dialog.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/core/widgets/app_loading_dialog.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'user_settings_page_about.dart';
part 'user_settings_page_components.dart';

const _appName = 'MaGrail';
const _appIconAsset = 'assets/icons/app_icon_foreground.png';

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
  const UserSettingsPage({
    super.key,
    required this.authRepository,
    required this.preferences,
    required this.updateController,
    required this.userRepository,
    this.onSignedOut,
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

  /// 创建用户设置二级页面状态
  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

/// 用户设置二级页面状态
class _UserSettingsPageState extends State<UserSettingsPage> {
  bool _isSigningOut = false;
  late bool _useBangumiMirror;
  late String _bangumiMirrorHost;

  /// 初始化用户设置二级页面状态
  @override
  void initState() {
    super.initState();
    _useBangumiMirror = widget.preferences.useBangumiMirror;
    _bangumiMirrorHost = BangumiMirrorConfig.resolveHost(
      widget.preferences.bangumiMirrorHost,
    );
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
                    const _SettingsSectionLabel(label: '网络'),
                    const SizedBox(height: 8),
                    _SettingsSurface(
                      child: _BangumiMirrorSwitchTile(
                        value: _useBangumiMirror,
                        mirrorHost: _bangumiMirrorHost,
                        onChanged: _handleBangumiMirrorChanged,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsSurface(
                      child: AnimatedBuilder(
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

  /// 打开关于页面
  void _openAboutPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _AboutPage(
          updateController: widget.updateController,
        ),
      ),
    );
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
      await widget.userRepository.clearCurrentUserAssetsCache();
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
