import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/features/user/model/user_sync_rate.dart';

/// 显示用户资产同步率弹窗
///
/// [context] 当前组件树上下文
/// [syncRate] 当前查看用户与登录用户的资产同步率
Future<void> showUserSyncRateDialog(
  BuildContext context, {
  required UserSyncRate syncRate,
}) async {
  await showAppConfirmDialog(
    context,
    title: '同步率',
    message: '',
    content: _UserSyncRateDialogContent(syncRate: syncRate),
    confirmText: '知道了',
    showCancelButton: false,
    icon: Icons.sync_rounded,
  );
}

/// 用户资产同步率弹窗内容
class _UserSyncRateDialogContent extends StatelessWidget {
  /// 创建用户资产同步率弹窗内容
  ///
  /// [syncRate] 当前查看用户与登录用户的资产同步率
  const _UserSyncRateDialogContent({required this.syncRate});

  /// 当前查看用户与登录用户的资产同步率
  final UserSyncRate syncRate;

  /// 构建用户资产同步率弹窗内容
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = TextStyle(
      color: colorScheme.onSurfaceVariant,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 1.3,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '共同角色 ${Formatters.groupedNumber(syncRate.commonCharacterCount)}'
                ' · 共同圣殿 ${Formatters.groupedNumber(syncRate.commonTempleCount)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${syncRate.percentage.toStringAsFixed(2)}%',
              maxLines: 1,
              style: labelStyle.copyWith(color: colorScheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: syncRate.progress,
          minHeight: 5,
          borderRadius: BorderRadius.circular(999),
          backgroundColor: colorScheme.surfaceContainerHighest,
          color: colorScheme.primary,
        ),
      ],
    );
  }
}
