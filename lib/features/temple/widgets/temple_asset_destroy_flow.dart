import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/features/temple/model/temple_asset_card_data.dart';

/// 拆除圣殿
///
/// [context] 当前组件树上下文
/// [data] 圣殿资产卡片展示数据
Future<void> destroyTempleAsset(
  BuildContext context, {
  required TempleAssetCardData data,
}) async {
  final actionContext = data.actionContext;
  if (actionContext == null) {
    AppToast.error(context, text: '缺少操作上下文');
    return;
  }

  var refreshFailed = false;
  var resultMessage = '';
  final colorScheme = Theme.of(context).colorScheme;
  final confirmed = await showAppConfirmDialog(
    context,
    title: '拆除圣殿',
    message: '拆除操作不可逆，请谨慎确认，确定要拆除圣殿？',
    icon: LucideIcons.trash2,
    confirmText: '拆除',
    confirmColor: colorScheme.error,
    onConfirm: () async {
      try {
        resultMessage = await actionContext.templeRepository.destroyTemple(
          characterId: data.characterId,
        );
        try {
          await actionContext.onActionCompleted?.call();
        } catch (_) {
          refreshFailed = true;
        }
        return true;
      } catch (error) {
        if (context.mounted) {
          AppToast.error(context, text: _messageForTempleDestroyError(error));
        }
        return false;
      }
    },
  );

  if (!confirmed || !context.mounted) {
    return;
  }

  if (refreshFailed) {
    AppToast.error(context, text: '圣殿已拆除，刷新圣殿数据失败');
  } else {
    AppToast.info(
      context,
      text: resultMessage.isEmpty ? '圣殿拆除成功' : resultMessage,
    );
  }
}

/// 转换圣殿拆除错误文案
///
/// [error] 圣殿拆除异常
String _messageForTempleDestroyError(Object error) {
  return resolveUserErrorMessage(error, fallback: '拆除圣殿失败');
}
