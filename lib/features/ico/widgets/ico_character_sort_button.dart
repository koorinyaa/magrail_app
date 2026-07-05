import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/features/ico/repository/ico_character_repository.dart';

/// ICO 角色排序按钮
class IcoCharacterSortButton extends StatefulWidget {
  /// 创建 ICO 角色排序按钮
  ///
  /// [key] Flutter 组件标识
  /// [selectedType] 当前排序类型
  /// [onSelected] 排序选择回调
  const IcoCharacterSortButton({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  /// 当前排序类型
  final IcoCharacterSortType selectedType;

  /// 排序选择回调
  final ValueChanged<IcoCharacterSortType> onSelected;

  /// 创建 ICO 角色排序按钮状态
  @override
  State<IcoCharacterSortButton> createState() => _IcoCharacterSortButtonState();
}

/// ICO 角色排序按钮状态
class _IcoCharacterSortButtonState extends State<IcoCharacterSortButton>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  late final AnimationController _animationController;
  late final Animation<double> _menuAnimation;
  OverlayEntry? _overlayEntry;

  /// 初始化 ICO 角色排序按钮状态
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 110),
    );
    _menuAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  /// 释放 ICO 角色排序按钮状态
  @override
  void dispose() {
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  /// 构建 ICO 角色排序按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton(
        onPressed: _toggleMenu,
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          backgroundColor: Colors.transparent,
          minimumSize: const Size.square(34),
          fixedSize: const Size.square(34),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        icon: const Icon(Icons.sort_rounded, size: 20),
      ),
    );
  }

  /// 切换排序菜单显示状态
  void _toggleMenu() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      unawaited(_hideOverlay());
    }
  }

  /// 显示排序菜单弹层
  void _showOverlay() {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _IcoCharacterSortMenuOverlay(
          layerLink: _layerLink,
          animation: _menuAnimation,
          selectedType: widget.selectedType,
          onDismiss: () => unawaited(_hideOverlay()),
          onSelected: _handleSelected,
        );
      },
    );
    overlay.insert(_overlayEntry!);
    _animationController.forward(from: 0);
  }

  /// 隐藏排序菜单弹层
  Future<void> _hideOverlay() async {
    if (_overlayEntry == null) {
      return;
    }

    await _animationController.reverse();
    _removeOverlay();
  }

  /// 移除排序菜单弹层
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// 处理排序选择
  ///
  /// [type] 目标排序类型
  void _handleSelected(IcoCharacterSortType type) {
    widget.onSelected(type);
    unawaited(_hideOverlay());
  }
}

/// ICO 角色排序菜单弹层
class _IcoCharacterSortMenuOverlay extends StatelessWidget {
  /// 创建 ICO 角色排序菜单弹层
  ///
  /// [layerLink] 按钮与弹层的锚定链接
  /// [animation] 开合动画
  /// [selectedType] 当前排序类型
  /// [onDismiss] 关闭回调
  /// [onSelected] 排序选择回调
  const _IcoCharacterSortMenuOverlay({
    required this.layerLink,
    required this.animation,
    required this.selectedType,
    required this.onDismiss,
    required this.onSelected,
  });

  /// 按钮与弹层的锚定链接
  final LayerLink layerLink;

  /// 开合动画
  final Animation<double> animation;

  /// 当前排序类型
  final IcoCharacterSortType selectedType;

  /// 关闭回调
  final VoidCallback onDismiss;

  /// 排序选择回调
  final ValueChanged<IcoCharacterSortType> onSelected;

  /// 构建 ICO 角色排序菜单弹层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 6),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final value = animation.value;
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, -4 * (1 - value)),
                  child: Transform.scale(
                    alignment: Alignment.topRight,
                    scale: 0.96 + value * 0.04,
                    child: child,
                  ),
                ),
              );
            },
            child: _IcoCharacterSortMenuPanel(
              selectedType: selectedType,
              onSelected: onSelected,
            ),
          ),
        ),
      ],
    );
  }
}

/// ICO 角色排序菜单面板
class _IcoCharacterSortMenuPanel extends StatelessWidget {
  /// 创建 ICO 角色排序菜单面板
  ///
  /// [selectedType] 当前排序类型
  /// [onSelected] 排序选择回调
  const _IcoCharacterSortMenuPanel({
    required this.selectedType,
    required this.onSelected,
  });

  /// 当前排序类型
  final IcoCharacterSortType selectedType;

  /// 排序选择回调
  final ValueChanged<IcoCharacterSortType> onSelected;

  /// 构建 ICO 角色排序菜单面板
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(14);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: _IcoCharacterSortMenuMetrics.width,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: AppBlurStyle.filter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppBlurStyle.surfaceColor(context),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final type in IcoCharacterSortType.values) ...[
                    if (type != IcoCharacterSortType.values.first)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    _IcoCharacterSortMenuItem(
                      type: type,
                      selected: selectedType == type,
                      onSelected: onSelected,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ICO 角色排序菜单项
class _IcoCharacterSortMenuItem extends StatelessWidget {
  /// 创建 ICO 角色排序菜单项
  ///
  /// [type] 菜单项排序类型
  /// [selected] 是否为当前排序
  /// [onSelected] 排序选择回调
  const _IcoCharacterSortMenuItem({
    required this.type,
    required this.selected,
    required this.onSelected,
  });

  /// 菜单项排序类型
  final IcoCharacterSortType type;

  /// 是否为当前排序
  final bool selected;

  /// 排序选择回调
  final ValueChanged<IcoCharacterSortType> onSelected;

  /// 构建 ICO 角色排序菜单项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = colorScheme.onSurfaceVariant;

    return MenuItemButton(
      onPressed: () => onSelected(type),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)) {
            return colorScheme.onSurfaceVariant.withValues(alpha: 0.08);
          }

          return Colors.transparent;
        }),
        foregroundColor: WidgetStatePropertyAll(foreground),
        iconColor: WidgetStatePropertyAll(foreground),
        minimumSize: const WidgetStatePropertyAll(
          Size.fromHeight(_IcoCharacterSortMenuMetrics.itemHeight),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 10),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      leadingIcon: SizedBox(
        width: 18,
        height: 18,
        child: selected ? const Icon(Icons.check_rounded, size: 18) : null,
      ),
      child: Text(type.label),
    );
  }
}

/// ICO 角色排序菜单尺寸
final class _IcoCharacterSortMenuMetrics {
  /// 禁止创建 ICO 角色排序菜单尺寸实例
  const _IcoCharacterSortMenuMetrics._();

  /// 菜单宽度
  static const double width = 136;

  /// 菜单项高度
  static const double itemHeight = 34;
}
