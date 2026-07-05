part of 'tinygrail_tabbed_paged_sliver_page.dart';

/// Tinygrail 标签分页页面固定头部
class _TinygrailTabbedPageHeader extends StatelessWidget {
  /// 创建 Tinygrail 标签分页页面固定头部
  ///
  /// [title] 页面标题
  /// [labels] 标签文案列表
  /// [selectedIndex] 当前选中的标签索引
  /// [pageController] 页面控制器
  /// [onSelected] 标签点击回调
  /// [showBackButton] 是否显示返回按钮
  /// [onSearchPressed] 搜索按钮点击回调
  /// [useBlurHeader] 是否使用模糊顶部栏
  /// [useSecondaryTitleStyle] 是否使用二级页面标题样式
  const _TinygrailTabbedPageHeader({
    required this.title,
    required this.labels,
    required this.selectedIndex,
    required this.pageController,
    required this.onSelected,
    required this.showBackButton,
    required this.onSearchPressed,
    required this.useBlurHeader,
    required this.useSecondaryTitleStyle,
  });

  static const double _secondaryTitleHeight =
      SecondaryPageSliverAppBar.defaultToolbarHeight;

  /// 页面标题
  final String title;

  /// 标签文案列表
  final List<String> labels;

  /// 当前选中的标签索引
  final int selectedIndex;

  /// 页面控制器
  final PageController pageController;

  /// 标签点击回调
  final ValueChanged<int> onSelected;

  /// 是否显示返回按钮
  final bool showBackButton;

  /// 搜索按钮点击回调
  final VoidCallback? onSearchPressed;

  /// 是否使用模糊顶部栏
  final bool useBlurHeader;

  /// 是否使用二级页面标题样式
  final bool useSecondaryTitleStyle;

  /// 解析固定头部在页面中的可见高度
  ///
  /// [context] 当前组件树上下文
  /// [useSecondaryTitleStyle] 是否使用二级页面标题样式
  static double visibleHeight(
    BuildContext context, {
    required bool useSecondaryTitleStyle,
  }) {
    final titleHeight =
        useSecondaryTitleStyle ? _secondaryTitleHeight : AppPageTitleBar.height;

    return MediaQuery.paddingOf(context).top +
        titleHeight +
        _TinygrailPagedTabHeader.height;
  }

  /// 构建 Tinygrail 标签分页页面固定头部
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
    final topPadding = MediaQuery.paddingOf(context).top;
    final content = Column(
      children: [
        SizedBox(height: topPadding),
        if (useSecondaryTitleStyle)
          _TinygrailSecondaryTitleBar(
            title: title,
            showBackButton: showBackButton,
            onSearchPressed: onSearchPressed,
          )
        else
          AppPageTitleBar(
            title: title,
            showBackButton: showBackButton,
            onSearchPressed: onSearchPressed,
          ),
        _TinygrailPagedTabHeader(
          labels: labels,
          selectedIndex: selectedIndex,
          pageController: pageController,
          onSelected: onSelected,
          showDivider: useBlurHeader,
        ),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle,
      child: SizedBox(
        height: visibleHeight(
          context,
          useSecondaryTitleStyle: useSecondaryTitleStyle,
        ),
        child: useBlurHeader
            ? ClipRect(
                child: BackdropFilter(
                  filter: AppBlurStyle.filter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppBlurStyle.surfaceColor(context),
                    ),
                    child: content,
                  ),
                ),
              )
            : content,
      ),
    );
  }
}

/// Tinygrail 标签分页二级页面标题栏
class _TinygrailSecondaryTitleBar extends StatelessWidget {
  /// 创建 Tinygrail 标签分页二级页面标题栏
  ///
  /// [title] 页面标题
  /// [showBackButton] 是否显示返回按钮
  /// [onSearchPressed] 搜索按钮点击回调
  const _TinygrailSecondaryTitleBar({
    required this.title,
    required this.showBackButton,
    required this.onSearchPressed,
  });

  /// 页面标题
  final String title;

  /// 是否显示返回按钮
  final bool showBackButton;

  /// 搜索按钮点击回调
  final VoidCallback? onSearchPressed;

  /// 构建 Tinygrail 标签分页二级页面标题栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      primary: false,
      toolbarHeight: _TinygrailTabbedPageHeader._secondaryTitleHeight,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      forceMaterialTransparency: true,
      leading: showBackButton
          ? IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.chevron_left_rounded,
                size: 30,
              ),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      actions: onSearchPressed == null
          ? const [SizedBox(width: kToolbarHeight)]
          : [
              IconButton(
                onPressed: onSearchPressed,
                icon: const Icon(Icons.search_rounded, size: 22),
              ),
            ],
    );
  }
}

/// Tinygrail 分页标签页头部
class _TinygrailPagedTabHeader extends StatelessWidget
    implements PreferredSizeWidget {
  /// 创建 Tinygrail 分页标签页头部
  ///
  /// [labels] 标签文案列表
  /// [selectedIndex] 当前选中的标签索引
  /// [pageController] 页面控制器
  /// [onSelected] 标签点击回调
  /// [showDivider] 是否显示底部分割线
  const _TinygrailPagedTabHeader({
    required this.labels,
    required this.selectedIndex,
    required this.pageController,
    required this.onSelected,
    required this.showDivider,
  });

  /// 标签栏高度
  static const double height = 48;

  /// 标签文案列表
  final List<String> labels;

  /// 当前选中的标签索引
  final int selectedIndex;

  /// 页面控制器
  final PageController pageController;

  /// 标签点击回调
  final ValueChanged<int> onSelected;

  /// 是否显示底部分割线
  final bool showDivider;

  /// 固定区域尺寸
  @override
  Size get preferredSize => const Size.fromHeight(height);

  /// 构建 Tinygrail 分页标签页头部
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final dividerColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.24 : 0.30,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom:
              showDivider ? BorderSide(color: dividerColor) : BorderSide.none,
        ),
      ),
      child: SizedBox(
        height: preferredSize.height,
        child: Padding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: 16,
            top: 6,
            right: 16,
            bottom: 8,
          ),
          child: _TinygrailPagedTabTrack(
            labels: labels,
            selectedIndex: selectedIndex,
            pageController: pageController,
            onSelected: onSelected,
          ),
        ),
      ),
    );
  }
}

/// Tinygrail 分页标签轨道
class _TinygrailPagedTabTrack extends StatelessWidget {
  /// 创建 Tinygrail 分页标签轨道
  ///
  /// [labels] 标签文案列表
  /// [selectedIndex] 当前选中的标签索引
  /// [pageController] 页面控制器
  /// [onSelected] 标签点击回调
  const _TinygrailPagedTabTrack({
    required this.labels,
    required this.selectedIndex,
    required this.pageController,
    required this.onSelected,
  });

  /// 标签文案列表
  final List<String> labels;

  /// 当前选中的标签索引
  final int selectedIndex;

  /// 页面控制器
  final PageController pageController;

  /// 标签点击回调
  final ValueChanged<int> onSelected;

  /// 构建 Tinygrail 分页标签轨道
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final trackColor = isDark
        ? colorScheme.surfaceContainerLow.withValues(alpha: 0.82)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.72);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedBuilder(
              animation: pageController,
              builder: (context, child) {
                final progress = _resolvePageProgress();
                final tabWidth = constraints.maxWidth / labels.length;

                return Stack(
                  children: [
                    Positioned(
                      left: tabWidth * progress,
                      top: 0,
                      bottom: 0,
                      width: tabWidth,
                      child: _TinygrailPagedTabIndicator(isDark: isDark),
                    ),
                    Row(
                      children: [
                        for (var index = 0; index < labels.length; index += 1)
                          Expanded(
                            child: _TinygrailPagedTabButton(
                              label: labels[index],
                              isSelected: (progress - index).abs() < 0.5,
                              onPressed: () => onSelected(index),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// 解析页面滚动进度
  double _resolvePageProgress() {
    final rawProgress =
        pageController.hasClients ? pageController.page : selectedIndex;
    final progress = rawProgress ?? selectedIndex.toDouble();
    return progress.clamp(0, labels.length - 1).toDouble();
  }
}

/// Tinygrail 分页标签选中指示器
class _TinygrailPagedTabIndicator extends StatelessWidget {
  /// 创建 Tinygrail 分页标签选中指示器
  ///
  /// [isDark] 是否为深色模式
  const _TinygrailPagedTabIndicator({
    required this.isDark,
  });

  /// 是否为深色模式
  final bool isDark;

  /// 构建 Tinygrail 分页标签选中指示器
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor =
        isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface;
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.26 : 0.10);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

/// Tinygrail 分页标签按钮
class _TinygrailPagedTabButton extends StatelessWidget {
  /// 创建 Tinygrail 分页标签按钮
  ///
  /// [label] 标签文案
  /// [isSelected] 是否选中
  /// [onPressed] 点击回调
  const _TinygrailPagedTabButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  /// 标签文案
  final String label;

  /// 是否选中
  final bool isSelected;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建 Tinygrail 分页标签按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 30,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
