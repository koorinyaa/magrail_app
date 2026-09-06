import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// 主导航标签
enum MainTab {
  /// 首页
  home(
    label: '首页',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    showInMobileDock: true,
  ),

  /// 角色
  character(
    label: '角色',
    icon: Symbols.cards_stack,
    activeIcon: Symbols.cards_stack_rounded,
    showInMobileDock: true,
  ),

  /// 排行榜
  ranking(
    label: '排行榜',
    icon: Icons.leaderboard_outlined,
    activeIcon: Icons.leaderboard_rounded,
    showInMobileDock: true,
  ),

  /// 我的
  profile(
    label: '我的',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    showInMobileDock: false,
  );

  /// 创建主导航标签
  ///
  /// [label] 导航文案
  /// [icon] 未选中图标
  /// [activeIcon] 选中图标
  /// [showInMobileDock] 是否显示在移动端底部胶囊导航中
  const MainTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.showInMobileDock,
  });

  /// 导航文案
  final String label;

  /// 未选中图标
  final IconData icon;

  /// 选中图标
  final IconData activeIcon;

  /// 是否显示在移动端底部胶囊导航中
  final bool showInMobileDock;
}
