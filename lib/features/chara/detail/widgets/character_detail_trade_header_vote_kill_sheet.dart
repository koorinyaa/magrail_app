part of 'character_detail_trade_header_card.dart';

/// 显示已上市头部投票删除底部抽屉
///
/// [context] 当前组件树上下文
Future<String?> _showTradeHeaderVoteKillSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: BoxConstraints.tightFor(
      width: MediaQuery.sizeOf(context).width,
    ),
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      const topGap = 32.0;
      final availableHeight =
          mediaQuery.size.height - mediaQuery.padding.top - topGap;
      final maxHeight =
          availableHeight.clamp(0.0, mediaQuery.size.height).toDouble();

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: const _TradeHeaderVoteKillSheet(),
      );
    },
  );
}

/// 已上市头部投票删除底部抽屉
class _TradeHeaderVoteKillSheet extends StatefulWidget {
  /// 创建已上市头部投票删除底部抽屉
  const _TradeHeaderVoteKillSheet();

  /// 创建已上市头部投票删除底部抽屉状态
  @override
  State<_TradeHeaderVoteKillSheet> createState() =>
      _TradeHeaderVoteKillSheetState();
}

/// 已上市头部投票删除底部抽屉状态
class _TradeHeaderVoteKillSheetState extends State<_TradeHeaderVoteKillSheet> {
  late final TextEditingController _reasonController;

  /// 初始化已上市头部投票删除底部抽屉状态
  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  /// 释放已上市头部投票删除底部抽屉状态
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  /// 构建已上市头部投票删除底部抽屉
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerLowest;

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.32 : 0.58,
                ),
              ),
            ),
          ),
          child: SafeArea(
            left: false,
            right: false,
            top: false,
            child: Padding(
              padding: AppSafeAreaInsets.fromLTRB(
                context,
                left: 20,
                top: 10,
                right: 20,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppBottomSheetDragHandle(),
                  const SizedBox(height: 14),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _VoteKillSheetHeader(),
                          const SizedBox(height: 18),
                          const _VoteKillSheetNotice(),
                          const SizedBox(height: 14),
                          _VoteKillReasonField(
                            controller: _reasonController,
                          ),
                          const SizedBox(height: 18),
                          _VoteKillSheetActions(
                            onConfirm: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 提交投票删除理由
  void _submit() {
    Navigator.of(context).pop(_reasonController.text.trim());
  }
}

/// 投票删除抽屉标题区
class _VoteKillSheetHeader extends StatelessWidget {
  /// 创建投票删除抽屉标题区
  const _VoteKillSheetHeader();

  /// 构建投票删除抽屉标题区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBottomSheetHeader(
      icon: LucideIcons.trash2,
      title: '投票删除',
      subtitle: '满三票删除角色，且无法再次上市',
      iconColor: colorScheme.error,
    );
  }
}

/// 投票删除抽屉提示区
class _VoteKillSheetNotice extends StatelessWidget {
  /// 创建投票删除抽屉提示区
  const _VoteKillSheetNotice();

  /// 构建投票删除抽屉提示区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    const warningColor = Color(0xFFF5A524);
    final foregroundColor = isDark ? const Color(0xFFFFD58A) : warningColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: foregroundColor.withValues(alpha: isDark ? 0.14 : 0.11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: foregroundColor.withValues(alpha: isDark ? 0.24 : 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              LucideIcons.triangleAlert,
              size: 16,
              color: foregroundColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '请确认角色状态后再提交，删除理由可留空',
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 投票删除理由输入框
class _VoteKillReasonField extends StatelessWidget {
  /// 创建投票删除理由输入框
  ///
  /// [controller] 删除理由输入控制器
  const _VoteKillReasonField({
    required this.controller,
  });

  /// 删除理由输入控制器
  final TextEditingController controller;

  /// 构建投票删除理由输入框
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
      controller: controller,
      minLines: 4,
      maxLines: 5,
      maxLength: 120,
      textInputAction: TextInputAction.newline,
      cursorColor: colorScheme.primary,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      decoration: InputDecoration(
        labelText: '删除理由',
        hintText: '可选',
        filled: true,
        fillColor: fillColor,
        counterStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
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

/// 投票删除抽屉操作区
class _VoteKillSheetActions extends StatelessWidget {
  /// 创建投票删除抽屉操作区
  ///
  /// [onConfirm] 确认回调
  const _VoteKillSheetActions({
    required this.onConfirm,
  });

  /// 确认回调
  final VoidCallback onConfirm;

  /// 构建投票删除抽屉操作区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton(
      style: FilledButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
      onPressed: onConfirm,
      child: const Text('确认投票'),
    );
  }
}
