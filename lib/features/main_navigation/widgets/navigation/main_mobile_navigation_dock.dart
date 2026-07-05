import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:magrail_app/features/main_navigation/model/main_tab.dart';

/// 移动端液态玻璃导航
class MainMobileNavigationDock extends StatelessWidget {
  /// 创建移动端液态玻璃导航
  ///
  /// [key] Flutter 组件标识
  /// [currentTab] 当前选中的导航标签
  /// [useLiquidGlass] 是否启用液态玻璃
  /// [onTabSelected] 导航标签点击回调
  const MainMobileNavigationDock({
    super.key,
    required this.currentTab,
    required this.useLiquidGlass,
    required this.onTabSelected,
  });

  /// 当前选中的导航标签
  final MainTab currentTab;

  /// 是否启用液态玻璃
  final bool useLiquidGlass;

  /// 导航标签点击回调
  final ValueChanged<MainTab> onTabSelected;

  /// 构建移动端液态玻璃导航
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final dockTabs = MainTab.values
        .where((tab) => tab.showInMobileDock || tab == MainTab.profile)
        .toList(growable: false);
    final selectedIndex = dockTabs.indexOf(currentTab);

    return SafeArea(
      top: false,
      child: GlassTabBar.bottom(
        tabs: [
          for (final tab in dockTabs) _buildGlassTab(tab),
        ],
        quality:
            useLiquidGlass ? GlassQuality.premium : GlassQuality.minimal,
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        onTabSelected: (index) => onTabSelected(dockTabs[index]),
      ),
    );
  }

  /// 创建液态玻璃导航标签
  ///
  /// [tab] 导航标签
  GlassTab _buildGlassTab(MainTab tab) {
    return GlassTab(
      icon: _buildTabIcon(tab, selected: false),
      activeIcon: _buildTabIcon(tab, selected: true),
      label: tab.label,
    );
  }

  /// 创建导航标签图标
  ///
  /// [tab] 导航标签
  /// [selected] 是否选中
  Widget _buildTabIcon(
    MainTab tab, {
    required bool selected,
  }) {
    return Icon(
      selected ? tab.activeIcon : tab.icon,
      fill: tab == MainTab.character && selected ? 1 : 0,
      weight: tab == MainTab.character ? 600 : null,
    );
  }
}
