import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/auth/bangumi_auth_config.dart';
import 'package:magrail_app/core/auth/bangumi_mirror_config.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Tinygrail 授权页面
class TinygrailAuthPage extends StatefulWidget {
  /// 创建 Tinygrail 授权页面
  ///
  /// [key] Flutter 组件标识
  /// [authRepository] Tinygrail 授权仓库
  /// [preferences] 本地偏好设置
  /// [onAuthenticated] 授权成功并写入 Cookie 后关闭页面前执行的回调
  const TinygrailAuthPage({
    super.key,
    required this.authRepository,
    required this.preferences,
    this.onAuthenticated,
  });

  /// Tinygrail 授权仓库
  final TinygrailAuthRepository authRepository;

  /// 本地偏好设置
  final AppPreferences preferences;

  /// 授权成功并写入 Cookie 后关闭页面前执行的回调
  final Future<void> Function()? onAuthenticated;

  /// 创建 Tinygrail 授权页面状态
  @override
  State<TinygrailAuthPage> createState() => _TinygrailAuthPageState();
}

/// Tinygrail 授权页面状态
class _TinygrailAuthPageState extends State<TinygrailAuthPage> {
  late final WebViewController _controller;
  late bool _useBangumiMirror;
  late String _bangumiMirrorHost;
  bool _isConsumingCallback = false;
  bool _isUpdatingMirror = false;

  /// 初始化 Tinygrail 授权页面状态
  @override
  void initState() {
    super.initState();
    _useBangumiMirror = widget.preferences.useBangumiMirror;
    _bangumiMirrorHost = BangumiMirrorConfig.resolveHost(
      widget.preferences.bangumiMirrorHost,
    );
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _handleNavigationRequest,
          onPageStarted: _handlePageStarted,
          onUrlChange: _handleUrlChange,
        ),
      )
      ..loadRequest(_authorizeUri);
  }

  /// 构建 Tinygrail 授权页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          const SecondaryPageSliverAppBar(title: '登录授权'),
          SliverFillRemaining(
            hasScrollBody: false,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  _AuthMirrorSwitchTile(
                    value: _useBangumiMirror,
                    mirrorHost: _bangumiMirrorHost,
                    isUpdating: _isUpdatingMirror,
                    onChanged: _handleBangumiMirrorChanged,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        WebViewWidget(controller: _controller),
                        if (_isConsumingCallback)
                          const Positioned.fill(
                            child: ColoredBox(
                              color: Color(0x66000000),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 当前授权地址
  Uri get _authorizeUri {
    return BangumiAuthConfig.authorizeUri(
      useMirror: _useBangumiMirror,
      mirrorHost: _bangumiMirrorHost,
    );
  }

  /// 处理 Bangumi 镜像开关变化
  ///
  /// [value] 是否使用 Bangumi 镜像
  Future<void> _handleBangumiMirrorChanged(bool value) async {
    if (_isUpdatingMirror) {
      return;
    }

    final previousValue = _useBangumiMirror;
    setState(() {
      _useBangumiMirror = value;
      _isUpdatingMirror = true;
    });
    TinygrailAssetUrls.configureBangumiMirror(
      useMirror: value,
      mirrorHost: _bangumiMirrorHost,
    );

    try {
      await widget.preferences.setUseBangumiMirror(value);
      await _controller.loadRequest(_authorizeUri);
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
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingMirror = false;
        });
      }
    }
  }

  /// 处理 WebView 导航
  ///
  /// [request] WebView 导航请求
  FutureOr<NavigationDecision> _handleNavigationRequest(
    NavigationRequest request,
  ) {
    if (_handleCallbackUrl(request.url)) {
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  /// 处理页面开始加载
  ///
  /// [url] WebView 页面地址
  void _handlePageStarted(String url) {
    _handleCallbackUrl(url);
  }

  /// 处理 WebView 地址变化
  ///
  /// [change] WebView 地址变化
  void _handleUrlChange(UrlChange change) {
    final url = change.url;
    if (url == null || url.isEmpty) {
      return;
    }

    _handleCallbackUrl(url);
  }

  /// 处理 Tinygrail callback 地址
  ///
  /// [url] WebView 页面地址
  bool _handleCallbackUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !BangumiAuthConfig.isTinygrailCallback(uri)) {
      return false;
    }

    _consumeCallback(uri);
    return true;
  }

  /// 消费 Tinygrail callback
  ///
  /// [callbackUri] 授权回调地址
  Future<void> _consumeCallback(Uri callbackUri) async {
    if (_isConsumingCallback || !mounted) {
      return;
    }

    setState(() {
      _isConsumingCallback = true;
    });

    try {
      await widget.authRepository.consumeCallback(callbackUri);
      if (!mounted) {
        return;
      }

      // callback 结束后必须先确认 Cookie，避免无会话时继续加载用户资产
      final hasCookie = await widget.authRepository.hasTinygrailCookie();
      if (!mounted) {
        return;
      }

      if (!hasCookie) {
        await _showErrorDialog('');
        return;
      }

      await widget.onAuthenticated?.call();
      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      await _showErrorDialog(
        resolveUserErrorMessage(error, fallback: '授权失败'),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isConsumingCallback = false;
        });
      }
    }
  }

  /// 展示授权错误弹窗
  ///
  /// [message] 错误信息
  Future<void> _showErrorDialog(String message) async {
    await showAppConfirmDialog(
      context,
      title: '授权失败',
      message: message,
      confirmText: '关闭',
      showCancelButton: false,
      icon: Icons.error_outline_rounded,
    );
  }
}

/// 授权页 Bangumi 镜像开关
class _AuthMirrorSwitchTile extends StatelessWidget {
  /// 创建授权页 Bangumi 镜像开关
  ///
  /// [value] 是否使用 Bangumi 镜像
  /// [mirrorHost] Bangumi 镜像域名
  /// [isUpdating] 是否正在保存设置
  /// [onChanged] 开关变化回调
  const _AuthMirrorSwitchTile({
    required this.value,
    required this.mirrorHost,
    required this.isUpdating,
    required this.onChanged,
  });

  /// 是否使用 Bangumi 镜像
  final bool value;

  /// Bangumi 镜像域名
  final String mirrorHost;

  /// 是否正在保存设置
  final bool isUpdating;

  /// 开关变化回调
  final ValueChanged<bool> onChanged;

  /// 构建授权页 Bangumi 镜像开关
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Row(
          children: [
            Icon(
              Icons.travel_explore_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '使用 $mirrorHost 镜像',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '非官方镜像，请确认风险后使用',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: isUpdating ? null : onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
