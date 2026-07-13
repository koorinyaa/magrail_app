import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// 角色搜索悬浮输入栏
class CharacterSearchInputBar extends StatelessWidget {
  /// 输入栏高度
  static const double height = 44;

  /// 创建角色搜索悬浮输入栏
  ///
  /// [key] Flutter 组件标识
  /// [controller] 搜索输入控制器
  /// [placeholder] 输入框占位文案
  /// [autofocus] 是否自动聚焦输入框
  /// [onChanged] 搜索内容变化回调
  /// [onSubmitted] 搜索内容提交回调
  /// [onClose] 关闭按钮点击回调，未提供时不显示关闭按钮
  const CharacterSearchInputBar({
    super.key,
    required this.controller,
    required this.placeholder,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.onClose,
  });

  /// 搜索输入控制器
  final TextEditingController controller;

  /// 输入框占位文案
  final String placeholder;

  /// 是否自动聚焦输入框
  final bool autofocus;

  /// 搜索内容变化回调
  final ValueChanged<String>? onChanged;

  /// 搜索内容提交回调
  final ValueChanged<String>? onSubmitted;

  /// 关闭按钮点击回调
  final VoidCallback? onClose;

  /// 构建角色搜索悬浮输入栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final closeCallback = onClose;

    return Row(
      children: [
        Expanded(
          child: GlassTextField.search(
            controller: controller,
            autofocus: autofocus,
            placeholder: placeholder,
            prefixIcon: Icon(
              LucideIcons.search,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            height: CharacterSearchInputBar.height,
            useOwnLayer: true,
            quality: GlassQuality.minimal,
            interactionBehavior: GlassInteractionBehavior.glowOnly,
            textStyle: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            placeholderStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (closeCallback != null) ...[
          const SizedBox(width: 10),
          GlassIconButton(
            icon: Icon(
              LucideIcons.x,
              color: colorScheme.onSurfaceVariant,
            ),
            iconSize: 18,
            size: CharacterSearchInputBar.height,
            onPressed: closeCallback,
            interactionScale: 1.0,
            useOwnLayer: true,
            quality: GlassQuality.minimal,
          ),
        ],
      ],
    );
  }
}
