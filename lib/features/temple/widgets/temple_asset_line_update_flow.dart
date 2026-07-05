import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/features/temple/model/temple_asset_card_data.dart';

/// 修改圣殿台词
///
/// [context] 当前组件树上下文
/// [data] 圣殿资产卡片展示数据
Future<void> updateTempleAssetLine(
  BuildContext context, {
  required TempleAssetCardData data,
}) async {
  final actionContext = data.actionContext;
  if (actionContext == null) {
    AppToast.error(context, text: '缺少操作上下文');
    return;
  }

  var lineValue = TinygrailFormatters.decodeHtmlEntities(data.line).trim();
  var refreshFailed = false;
  var resultMessage = '';
  final confirmed = await showAppConfirmDialog(
    context,
    title: '修改台词',
    message: '',
    icon: LucideIcons.messageSquareQuote,
    content: _TempleAssetLineEditor(
      initialLine: lineValue,
      onChanged: (value) {
        lineValue = value;
      },
    ),
    confirmText: '修改',
    showCancelButton: false,
    onConfirm: () async {
      final line = lineValue.trim();
      try {
        resultMessage = await actionContext.templeRepository.changeTempleLine(
          characterId: data.characterId,
          line: line,
        );
        try {
          await actionContext.onActionCompleted?.call();
        } catch (_) {
          refreshFailed = true;
        }
        return true;
      } catch (error) {
        if (context.mounted) {
          AppToast.error(context, text: _messageForLineUpdateError(error));
        }
        return false;
      }
    },
  );

  if (!confirmed || !context.mounted) {
    return;
  }

  if (refreshFailed) {
    AppToast.error(context, text: '台词已修改，刷新圣殿数据失败');
  } else {
    AppToast.info(
      context,
      text: resultMessage.isEmpty ? '修改台词成功' : resultMessage,
    );
  }
}

/// 圣殿台词编辑输入框
class _TempleAssetLineEditor extends StatefulWidget {
  /// 创建圣殿台词编辑输入框
  ///
  /// [initialLine] 初始台词
  /// [onChanged] 台词变更回调
  const _TempleAssetLineEditor({
    required this.initialLine,
    required this.onChanged,
  });

  /// 初始台词
  final String initialLine;

  /// 台词变更回调
  final ValueChanged<String> onChanged;

  /// 创建圣殿台词编辑输入框状态
  @override
  State<_TempleAssetLineEditor> createState() => _TempleAssetLineEditorState();
}

/// 圣殿台词编辑输入框状态
class _TempleAssetLineEditorState extends State<_TempleAssetLineEditor> {
  late final TextEditingController _controller;

  /// 初始化圣殿台词编辑输入框状态
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialLine);
  }

  /// 释放圣殿台词编辑输入控制器
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建圣殿台词编辑输入框
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final fillColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: isDark ? 0.42 : 0.58,
    );
    final borderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.36 : 0.68,
    );

    return TextField(
      controller: _controller,
      autofocus: true,
      minLines: 4,
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      cursorColor: colorScheme.primary,
      onChanged: widget.onChanged,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      decoration: InputDecoration(
        labelText: '台词',
        hintText: '请输入台词',
        filled: true,
        fillColor: fillColor,
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.62),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
    );
  }
}

/// 转换圣殿台词修改错误文案
///
/// [error] 圣殿台词修改异常
String _messageForLineUpdateError(Object error) {
  return resolveUserErrorMessage(error, fallback: '修改台词失败');
}
