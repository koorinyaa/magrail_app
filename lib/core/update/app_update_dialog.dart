import 'package:flutter/material.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/update/app_release_info.dart';
import 'package:magrail_app/core/update/app_update_controller.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';

/// 显示应用更新弹窗
///
/// [context] 当前组件树上下文
/// [controller] 应用更新控制器
/// [markPrompted] 是否记录为已自动提示
Future<bool> showAppUpdateDialog(
  BuildContext context, {
  required AppUpdateController controller,
  bool markPrompted = false,
}) async {
  final release = controller.latestRelease;
  if (release == null || !controller.hasUpdate) {
    return false;
  }

  if (!context.mounted) {
    return false;
  }

  if (markPrompted) {
    await controller.markLatestReleasePrompted();
  }
  if (!context.mounted || !controller.hasUpdate) {
    return false;
  }

  return showAppConfirmDialog(
    context,
    title: '发现新版本',
    message: '',
    content: _AppUpdateMessage(
      controller: controller,
      release: release,
    ),
    confirmText: '下载最新版本',
    cancelText: '稍后',
    icon: Icons.system_update_alt_rounded,
    onConfirm: () async {
      // 下载超时后补丁仍可能完成，不再打开已经失去必要性的整包页面
      if (!controller.hasUpdate) return true;
      final opened = await controller.openLatestReleasePage();
      if (!opened && context.mounted) {
        AppToast.error(context, text: '无法打开下载页面，请稍后重试');
      }

      return opened;
    },
  );
}

/// 在补丁晚到时关闭对应更新面板，避免继续提示下载整包
class _AppUpdateMessage extends StatefulWidget {
  /// 创建更新说明
  ///
  /// [controller] 统一更新控制器
  /// [release] 当前面板对应的 GitHub Release
  const _AppUpdateMessage({required this.controller, required this.release});

  /// 统一更新控制器
  final AppUpdateController controller;

  /// 当前面板对应的 GitHub Release
  final AppReleaseInfo release;

  /// 创建更新说明状态
  @override
  State<_AppUpdateMessage> createState() => _AppUpdateMessageState();
}

/// 更新说明与当前更新面板的状态协调
class _AppUpdateMessageState extends State<_AppUpdateMessage> {
  /// 监听晚到的补丁状态
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleUpdateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleUpdateChanged());
  }

  /// 只移除当前说明所属面板，不关闭用户后来打开的其他页面
  void _handleUpdateChanged() {
    if (!mounted ||
        widget.controller.hasUpdate ||
        widget.controller.isChecking) {
      return;
    }

    final route = ModalRoute.of(context);
    if (route != null && route.isActive) {
      Navigator.of(context).removeRoute(route, false);
    }
  }

  /// 释放面板更新监听
  @override
  void dispose() {
    widget.controller.removeListener(_handleUpdateChanged);
    super.dispose();
  }

  /// 构建更新说明
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Text(
      _updateMessage(
        currentVersion: widget.controller.currentVersion,
        release: widget.release,
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
    );
  }
}

/// 构建更新弹窗文案
///
/// [currentVersion] 当前应用版本
/// [release] 最新 Release 信息
String _updateMessage({
  required String currentVersion,
  required AppReleaseInfo release,
}) {
  final body = _compactReleaseBody(release.body);
  final baseMessage =
      '当前版本：$currentVersion\n'
      '最新版本：${release.version}';
  if (body.isEmpty) {
    return baseMessage;
  }

  return '$baseMessage\n\n$body';
}

/// 压缩 Release 说明文本
///
/// [body] Release 原始说明
String _compactReleaseBody(String body) {
  final compact = body
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .take(4)
      .join('\n');
  if (compact.length <= 180) {
    return compact;
  }

  return '${compact.substring(0, 180)}...';
}
