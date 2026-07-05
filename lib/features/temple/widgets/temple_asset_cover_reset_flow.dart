import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/features/temple/model/temple_asset_card_data.dart';

/// 重置圣殿图片
///
/// [context] 当前组件树上下文
/// [data] 圣殿资产卡片展示数据
Future<void> resetTempleAssetCover(
  BuildContext context, {
  required TempleAssetCardData data,
}) async {
  final actionContext = data.actionContext;
  if (actionContext == null) {
    AppToast.error(context, text: '缺少操作上下文');
    return;
  }

  if (data.userId <= 0) {
    AppToast.error(context, text: '缺少圣殿所属用户 ID');
    return;
  }

  var refreshFailed = false;
  final confirmed = await showAppConfirmDialog(
    context,
    title: '重置圣殿图片',
    message: '确定要重置圣殿图片吗？',
    confirmText: '重置',
    showCancelButton: false,
    icon: LucideIcons.rotateCcw,
    onConfirm: () async {
      try {
        await actionContext.templeRepository.resetTempleCover(
          characterId: data.characterId,
          userId: data.userId,
        );
        try {
          await actionContext.onActionCompleted?.call();
        } catch (_) {
          refreshFailed = true;
        }
        return true;
      } catch (error) {
        if (context.mounted) {
          AppToast.error(context, text: _messageForCoverResetError(error));
        }
        return false;
      }
    },
  );
  if (!confirmed || !context.mounted) {
    return;
  }

  if (refreshFailed) {
    AppToast.error(context, text: '圣殿图片已重置，刷新圣殿数据失败');
  } else {
    AppToast.info(context, text: '重置圣殿图片成功');
  }
}

/// 转换圣殿图片重置错误文案
///
/// [error] 圣殿图片重置异常
String _messageForCoverResetError(Object error) {
  return resolveUserErrorMessage(error, fallback: '重置圣殿图片失败');
}
