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
  /// [controller] 搜索输入控制器，为空时仅使用占位文案
  /// [placeholder] 输入框占位文案
  /// [autofocus] 是否自动聚焦输入框
  /// [readOnly] 是否仅作为不可编辑的搜索入口
  /// [onTap] 搜索栏点击回调
  /// [onChanged] 搜索内容变化回调
  /// [onSubmitted] 搜索内容提交回调
  /// [onClose] 关闭按钮点击回调，未提供时不显示关闭按钮
  /// [glassSettings] 液态玻璃配置，为空时使用组件默认配置
  const CharacterSearchInputBar({
    super.key,
    this.controller,
    required this.placeholder,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onClose,
    this.glassSettings,
  });

  /// 搜索输入控制器
  final TextEditingController? controller;

  /// 输入框占位文案
  final String placeholder;

  /// 是否自动聚焦输入框
  final bool autofocus;

  /// 是否仅作为不可编辑的搜索入口
  final bool readOnly;

  /// 搜索栏点击回调
  final VoidCallback? onTap;

  /// 搜索内容变化回调
  final ValueChanged<String>? onChanged;

  /// 搜索内容提交回调
  final ValueChanged<String>? onSubmitted;

  /// 关闭按钮点击回调
  final VoidCallback? onClose;

  /// 液态玻璃配置
  final LiquidGlassSettings? glassSettings;

  /// 构建角色搜索悬浮输入栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final closeCallback = onClose;

    final searchField = GlassTextField.search(
      controller: controller,
      autofocus: autofocus,
      readOnly: readOnly,
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
      settings: glassSettings,
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
    );
    final searchContent = onTap == null
        ? searchField
        : _SearchEntryTapTarget(onTap: onTap!, child: searchField);

    return Row(
      children: [
        Expanded(child: searchContent),
        if (closeCallback != null) ...[
          const SizedBox(width: 10),
          GlassIconButton(
            icon: Icon(LucideIcons.x, color: colorScheme.onSurfaceVariant),
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

/// 只读搜索入口按压反馈
class _SearchEntryTapTarget extends StatefulWidget {
  /// 创建只读搜索入口按压反馈
  ///
  /// [onTap] 搜索入口点击回调
  /// [child] 搜索栏内容
  const _SearchEntryTapTarget({required this.onTap, required this.child});

  /// 搜索入口点击回调
  final VoidCallback onTap;

  /// 搜索栏内容
  final Widget child;

  /// 创建只读搜索入口按压反馈状态
  @override
  State<_SearchEntryTapTarget> createState() => _SearchEntryTapTargetState();
}

/// 只读搜索入口按压反馈状态
class _SearchEntryTapTargetState extends State<_SearchEntryTapTarget> {
  var _isPressed = false;

  /// 构建只读搜索入口按压反馈
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: IgnorePointer(child: widget.child),
      ),
    );
  }
}
