import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 显示发送红包底部抽屉
///
/// [context] 当前组件树上下文
/// [repository] 用户仓库
/// [username] 目标用户名
/// [nickname] 目标用户昵称
/// [onSuccess] 发送成功回调
Future<void> showUserRedPacketSendSheet(
  BuildContext context, {
  required UserRepository repository,
  required String username,
  String? nickname,
  VoidCallback? onSuccess,
}) {
  final originContext = context;
  return showModalBottomSheet<void>(
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
        child: UserRedPacketSendSheet(
          repository: repository,
          username: username,
          nickname: nickname,
          onSuccess: (message) {
            onSuccess?.call();
            if (!originContext.mounted) {
              return;
            }

            AppToast.info(originContext, text: message);
          },
        ),
      );
    },
  );
}

/// 发送红包底部抽屉
class UserRedPacketSendSheet extends StatefulWidget {
  /// 创建发送红包底部抽屉
  ///
  /// [key] Flutter 组件标识
  /// [repository] 用户仓库
  /// [username] 目标用户名
  /// [nickname] 目标用户昵称
  /// [onSuccess] 发送成功回调
  const UserRedPacketSendSheet({
    super.key,
    required this.repository,
    required this.username,
    this.nickname,
    this.onSuccess,
  });

  /// 用户仓库
  final UserRepository repository;

  /// 目标用户名
  final String username;

  /// 目标用户昵称
  final String? nickname;

  /// 发送成功回调
  final ValueChanged<String>? onSuccess;

  /// 创建发送红包底部抽屉状态
  @override
  State<UserRedPacketSendSheet> createState() => _UserRedPacketSendSheetState();
}

/// 发送红包底部抽屉状态
class _UserRedPacketSendSheetState extends State<UserRedPacketSendSheet> {
  // 红包接口单次发送金额上限
  static const int _maxAmount = 1000000;

  late final TextEditingController _amountController;
  late final TextEditingController _messageController;
  bool _isSubmitting = false;

  /// 初始化发送红包底部抽屉状态
  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _maxAmount.toString());
    _messageController = TextEditingController();
  }

  /// 释放发送红包底部抽屉状态
  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// 构建发送红包底部抽屉
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
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
                  const SizedBox(height: 10),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '输入金额和祝福留言',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _SheetTextField(
                            controller: _amountController,
                            label: '红包金额',
                            hintText: '请输入红包金额',
                            prefixText: '₵',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 10),
                          _SheetTextField(
                            controller: _messageController,
                            label: '祝福留言',
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 16),
                          _SendButton(
                            isLoading: _isSubmitting,
                            onPressed: _submit,
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

  /// 弹层标题
  String get _title {
    final nickname = widget.nickname?.trim();
    if (nickname == null || nickname.isEmpty) {
      return '发送红包';
    }

    return '发送红包给「$nickname」';
  }

  /// 提交发送红包请求
  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final username = widget.username.trim();
    if (username.isEmpty) {
      AppToast.error(context, text: '缺少目标用户');
      return;
    }

    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      AppToast.error(context, text: '请输入有效的红包金额');
      return;
    }

    if (amount > _maxAmount) {
      AppToast.error(context, text: '红包金额不能超过 $_maxAmount');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await widget.repository.sendRedPacket(
        username: username,
        amount: amount,
        message: _messageController.text.trim(),
      );
      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      widget.onSuccess?.call(result);
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.error(
        context,
        text: _resolveErrorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 解析发送红包错误文案
  ///
  /// [error] 原始错误
  String _resolveErrorMessage(Object error) {
    return resolveUserErrorMessage(error, fallback: '发送红包失败');
  }
}

/// 发送红包输入框
class _SheetTextField extends StatelessWidget {
  /// 创建发送红包输入框
  ///
  /// [controller] 文本控制器
  /// [label] 标签文案
  /// [hintText] 占位文案
  /// [prefixText] 前缀文案
  /// [keyboardType] 键盘类型
  /// [inputFormatters] 输入格式化规则
  const _SheetTextField({
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixText,
    this.keyboardType,
    this.inputFormatters,
  });

  /// 文本控制器
  final TextEditingController controller;

  /// 标签文案
  final String label;

  /// 占位文案
  final String? hintText;

  /// 前缀文案
  final String? prefixText;

  /// 键盘类型
  final TextInputType? keyboardType;

  /// 输入格式化规则
  final List<TextInputFormatter>? inputFormatters;

  /// 构建发送红包输入框
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixText: prefixText,
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.035),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.72),
            width: 1.4,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
      ),
    );
  }
}

/// 发送红包确认按钮
class _SendButton extends StatelessWidget {
  /// 创建发送红包确认按钮
  ///
  /// [isLoading] 是否正在提交
  /// [onPressed] 点击回调
  const _SendButton({
    required this.isLoading,
    required this.onPressed,
  });

  /// 是否正在提交
  final bool isLoading;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建发送红包确认按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        child: SizedBox(
          height: 42,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    '发送',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
