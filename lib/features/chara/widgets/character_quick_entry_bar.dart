import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';

part 'character_quick_entry_card.dart';
part 'character_quick_entry_painters.dart';
part 'character_quick_entry_layout.dart';

// 三个入口的强调色
const Color _valhallaAccent = Color(0xFFF5A524);
const Color _gensokyoAccent = Color(0xFFF31260);
const Color _stAccent = Color(0xFF9353D3);

/// 角色页快捷入口栏
class CharacterQuickEntryBar extends StatelessWidget {
  // 最小内容宽度
  static const double _minimumContentWidth = 288;

  /// 平板入口布局最大宽度，避免卡片过度横向拉伸
  static const double _maximumContentWidth = 760;

  /// 平板布局起始宽度
  static const double _tabletBreakpoint = 600;

  /// 平板入口横向边距
  static const double _tabletHorizontalPadding = 24;

  static const double _contentHeight = 162;

  /// 创建角色页快捷入口栏
  ///
  /// [key] Flutter 组件标识
  /// [onValhallaTap] 英灵殿入口点击回调
  /// [onGensokyoTap] 幻想乡入口点击回调
  /// [onStTap] ST 入口点击回调
  const CharacterQuickEntryBar({
    super.key,
    required this.onValhallaTap,
    required this.onGensokyoTap,
    required this.onStTap,
  });

  /// 英灵殿入口点击回调
  final VoidCallback onValhallaTap;

  /// 幻想乡入口点击回调
  final VoidCallback onGensokyoTap;

  /// ST 入口点击回调
  final VoidCallback onStTap;

  /// 构建角色页快捷入口栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final horizontalPadding =
        MediaQuery.sizeOf(context).width >= _tabletBreakpoint
            ? _tabletHorizontalPadding
            : 16.0;
    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: horizontalPadding,
        top: 0,
        right: horizontalPadding,
        bottom: 0,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = math
              .max(
                _minimumContentWidth,
                math.min(_maximumContentWidth, constraints.maxWidth),
              )
              .toDouble();
          final viewportWidth =
              math.min(contentWidth, constraints.maxWidth).toDouble();
          final canFit = contentWidth <= viewportWidth;
          return SizedBox(
            height: _contentHeight,
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: viewportWidth,
                height: _contentHeight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: canFit
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: contentWidth,
                    height: _contentHeight,
                    child: _CharacterPortalLayout(
                      onValhallaTap: onValhallaTap,
                      onGensokyoTap: onGensokyoTap,
                      onStTap: onStTap,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
