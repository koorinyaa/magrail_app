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
  if (release == null) {
    return false;
  }

  if (!context.mounted) {
    return false;
  }

  if (markPrompted) {
    await controller.markLatestReleasePrompted();
  }
  if (!context.mounted) {
    return false;
  }

  return showAppConfirmDialog(
    context,
    title: '发现新版本',
    message: _updateMessage(
      currentVersion: controller.currentVersion ?? '未知',
      release: release,
    ),
    confirmText: '下载最新版本',
    cancelText: '稍后',
    icon: Icons.system_update_alt_rounded,
    onConfirm: () async {
      final opened = await controller.openLatestReleasePage();
      if (!opened && context.mounted) {
        AppToast.error(context, text: '无法打开下载页面，请稍后重试');
      }

      return opened;
    },
  );
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
  final baseMessage = '当前版本：$currentVersion\n'
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
