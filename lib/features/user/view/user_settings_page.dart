import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/auth/bangumi_mirror_config.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/core/widgets/app_loading_dialog.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

const _appName = 'MaGrail';
const _appIconAsset = 'assets/icons/app_icon_foreground.png';

/// 用户设置二级页面
class UserSettingsPage extends StatefulWidget {
  /// 创建用户设置二级页面
  ///
  /// [key] Flutter 组件标识
  /// [authRepository] Tinygrail 授权仓库
  /// [preferences] 本地偏好设置
  /// [userRepository] 用户仓库
  /// [onSignedOut] 退出登录后的回调
  const UserSettingsPage({
    super.key,
    required this.authRepository,
    required this.preferences,
    required this.userRepository,
    this.onSignedOut,
  });

  /// Tinygrail 授权仓库
  final TinygrailAuthRepository authRepository;

  /// 本地偏好设置
  final AppPreferences preferences;

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
                      child: _SettingsActionTile(
                        icon: Icons.info_outline_rounded,
                        label: '关于',
                        onPressed: _openAboutPage,
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
        builder: (context) => const _AboutPage(),
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

/// 关于二级页面
class _AboutPage extends StatefulWidget {
  /// 创建关于二级页面
  const _AboutPage();

  /// 创建关于二级页面状态
  @override
  State<_AboutPage> createState() => _AboutPageState();
}

/// 关于二级页面状态
class _AboutPageState extends State<_AboutPage> {
  late final Future<PackageInfo> _packageInfoFuture;

  /// 初始化关于二级页面状态
  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  /// 构建关于二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          const SecondaryPageSliverAppBar(title: '关于'),
          SliverFillRemaining(
            hasScrollBody: false,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  56,
                  24,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      _appIconAsset,
                      width: 112,
                      height: 112,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<PackageInfo>(
                      future: _packageInfoFuture,
                      builder: (context, snapshot) {
                        final version = switch (snapshot) {
                          AsyncSnapshot(hasError: true) => '获取失败',
                          AsyncSnapshot(hasData: true, data: final data?) =>
                            _formatPackageVersion(data),
                          _ => '读取中',
                        };

                        return Text(
                          '版本 $version',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化平台包版本号
  ///
  /// [packageInfo] 平台包信息
  String _formatPackageVersion(PackageInfo packageInfo) {
    final buildNumber = packageInfo.buildNumber;

    if (buildNumber.isEmpty) {
      return packageInfo.version;
    }

    return '${packageInfo.version}+$buildNumber';
  }
}

/// 设置分组标题
class _SettingsSectionLabel extends StatelessWidget {
  /// 创建设置分组标题
  ///
  /// [label] 分组标题
  const _SettingsSectionLabel({required this.label});

  /// 分组标题
  final String label;

  /// 构建设置分组标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      label,
      style: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// 设置页表面分组
class _SettingsSurface extends StatelessWidget {
  /// 创建设置页表面分组
  ///
  /// [child] 分组内容
  const _SettingsSurface({required this.child});

  /// 分组内容
  final Widget child;

  /// 构建设置页表面分组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerLow : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 设置页普通跳转项
class _SettingsActionTile extends StatelessWidget {
  /// 创建设置页普通跳转项
  ///
  /// [icon] 左侧图标
  /// [label] 选项文字
  /// [onPressed] 点击回调
  const _SettingsActionTile({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  /// 左侧图标
  final IconData icon;

  /// 选项文字
  final String label;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建设置页普通跳转项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Icon(icon, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bangumi 镜像开关
class _BangumiMirrorSwitchTile extends StatelessWidget {
  /// 创建 Bangumi 镜像开关
  ///
  /// [value] 是否使用 Bangumi 镜像
  /// [mirrorHost] Bangumi 镜像域名
  /// [onChanged] 开关变化回调
  const _BangumiMirrorSwitchTile({
    required this.value,
    required this.mirrorHost,
    required this.onChanged,
  });

  /// 是否使用 Bangumi 镜像
  final bool value;

  /// Bangumi 镜像域名
  final String mirrorHost;

  /// 开关变化回调
  final ValueChanged<bool> onChanged;

  /// 构建 Bangumi 镜像开关
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
      child: Row(
        children: [
          const Icon(Icons.travel_explore_rounded, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '使用 $mirrorHost 镜像',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return null;
              }

              return colorScheme.onSurfaceVariant.withValues(
                alpha: isDark ? 0.92 : 0.78,
              );
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return null;
              }

              return colorScheme.onSurfaceVariant.withValues(
                alpha: isDark ? 0.24 : 0.16,
              );
            }),
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return null;
              }

              return colorScheme.outlineVariant.withValues(
                alpha: isDark ? 0.72 : 0.44,
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// 退出登录按钮
class _SignOutButton extends StatelessWidget {
  /// 创建退出登录按钮
  ///
  /// [isDisabled] 是否禁用点击
  /// [onPressed] 退出按钮点击回调
  const _SignOutButton({
    required this.isDisabled,
    required this.onPressed,
  });

  /// 是否禁用点击
  final bool isDisabled;

  /// 退出按钮点击回调
  final VoidCallback onPressed;

  /// 构建退出登录按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: 22,
                color: colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '退出登录',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
