import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/core/widgets/secondary_page_sliver_app_bar.dart';

/// 二级页面固定标题刷新视图
class SecondaryPageRefreshView extends StatelessWidget {
  /// 创建二级页面固定标题刷新视图
  ///
  /// [key] Flutter 组件标识
  /// [title] 页面标题
  /// [onRefresh] 下拉刷新回调
  /// [slivers] 页面滚动内容
  /// [actions] 标题栏右侧操作组件
  /// [bottom] 标题栏下方的固定区域
  /// [scrollController] 页面滚动控制器
  const SecondaryPageRefreshView({
    super.key,
    required this.title,
    required this.onRefresh,
    required this.slivers,
    this.actions,
    this.bottom,
    this.scrollController,
  });

  /// 页面标题
  final String title;

  /// 下拉刷新回调
  final RefreshCallback onRefresh;

  /// 页面滚动内容
  final List<Widget> slivers;

  /// 标题栏右侧操作组件
  final List<Widget>? actions;

  /// 标题栏下方的固定区域
  final PreferredSizeWidget? bottom;

  /// 页面滚动控制器
  final ScrollController? scrollController;

  /// 构建二级页面固定标题刷新视图
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SecondaryPageHeader(
          title: title,
          actions: actions,
          bottom: bottom,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: CustomScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: slivers,
            ),
          ),
        ),
      ],
    );
  }
}

/// 二级页面固定标题区域
class _SecondaryPageHeader extends StatelessWidget {
  /// 创建二级页面固定标题区域
  ///
  /// [title] 页面标题
  /// [actions] 右侧操作组件
  /// [bottom] 标题栏下方的固定区域
  const _SecondaryPageHeader({
    required this.title,
    required this.actions,
    required this.bottom,
  });

  /// 页面标题
  final String title;

  /// 右侧操作组件
  final List<Widget>? actions;

  /// 标题栏下方的固定区域
  final PreferredSizeWidget? bottom;

  /// 构建二级页面固定标题区域
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final systemOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle,
      child: ClipRect(
        child: BackdropFilter(
          filter: AppBlurStyle.filter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppBlurStyle.surfaceColor(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top),
                SizedBox(
                  height: SecondaryPageSliverAppBar.defaultToolbarHeight +
                      (bottom?.preferredSize.height ?? 0),
                  child: AppBar(
                    primary: false,
                    toolbarHeight:
                        SecondaryPageSliverAppBar.defaultToolbarHeight,
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    foregroundColor: colorScheme.onSurface,
                    forceMaterialTransparency: true,
                    leading: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        size: 30,
                      ),
                    ),
                    title: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    scrolledUnderElevation: 0,
                    surfaceTintColor: Colors.transparent,
                    actions: actions ?? const [SizedBox(width: kToolbarHeight)],
                    bottom: bottom,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
