import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magrail_app/app/theme/app_material_theme.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/widgets/tinygrail_tabbed_paged_sliver_page.dart';
import 'package:magrail_app/features/main_navigation/widgets/chrome/main_navigation_search_header.dart';
import 'package:magrail_app/features/ranking/widgets/ranking_tab_bar.dart';

/// 验证排行榜文字标签、统一渐变头部与分页交互
void main() {
  for (final isDark in [false, true]) {
    for (final width in [320.0, 390.0, 430.0]) {
      testWidgets('文字标签在不同宽度与主题下保持尺寸 width=$width dark=$isDark', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(Size(width, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final pageController = PageController();
        addTearDown(pageController.dispose);
        var selectedIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            theme: isDark ? AppMaterialTheme.dark() : AppMaterialTheme.light(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: const TextScaler.linear(1.5)),
                    child: RankingTabBar(
                      labels: const ['精炼排行', '番市首富'],
                      selectedIndex: selectedIndex,
                      pageController: pageController,
                      onSelected: (index) {
                        setState(() => selectedIndex = index);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final controlFinder = find.byType(RankingTabBar);
        final firstLabelRect = tester.getRect(find.text('精炼排行'));
        final secondLabelRect = tester.getRect(find.text('番市首富'));
        expect(
          tester.getSize(controlFinder),
          Size(width, RankingTabBar.height),
        );
        expect(
          (firstLabelRect.left + secondLabelRect.right) / 2,
          closeTo(width / 2, 0.01),
        );
        expect(secondLabelRect.left - firstLabelRect.right, 24);
        expect(secondLabelRect.right, lessThan(width - 24));
        expect(
          tester.widget<Text>(find.text('精炼排行')).style?.fontWeight,
          FontWeight.w700,
        );
        expect(
          tester.widget<Text>(find.text('番市首富')).style?.fontWeight,
          FontWeight.w500,
        );
        expect(_indicatorFinder(), findsOneWidget);
        expect(tester.getSize(_indicatorFinder()), const Size(24, 2));
        expect(
          tester.getCenter(_indicatorFinder()).dx,
          closeTo(firstLabelRect.center.dx, 0.01),
        );
        expect(find.byType(BackdropFilter), findsNothing);

        await tester.tap(find.text('番市首富'));
        await tester.pumpAndSettle();
        expect(selectedIndex, 1);
        expect(
          tester.getCenter(_indicatorFinder()).dx,
          closeTo(secondLabelRect.center.dx, 0.01),
        );
        expect(
          tester.getSize(controlFinder),
          Size(width, RankingTabBar.height),
        );
        expect(tester.getRect(find.text('精炼排行')), firstLabelRect);
        expect(tester.getRect(find.text('番市首富')), secondLabelRect);
        expect(
          tester.widget<Text>(find.text('番市首富')).style?.fontWeight,
          FontWeight.w700,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('长按标签不绘制波纹或高亮且松手仍可点击', (tester) async {
    final sceneKey = GlobalKey();
    final pageController = PageController();
    addTearDown(pageController.dispose);
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppMaterialTheme.light().copyWith(
          highlightColor: Colors.red,
          splashColor: Colors.red,
        ),
        home: Scaffold(
          body: RepaintBoundary(
            key: sceneKey,
            child: ColoredBox(
              color: Colors.white,
              child: RankingTabBar(
                labels: const ['精炼排行', '番市首富'],
                selectedIndex: 0,
                pageController: pageController,
                onSelected: (_) => taps += 1,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tabInk = find
        .descendant(
          of: find.byType(RankingTabBar),
          matching: find.byType(InkWell),
        )
        .first;
    final ink = tester.widget<InkWell>(tabInk);
    expect(ink.splashFactory, NoSplash.splashFactory);
    expect(ink.highlightColor, Colors.transparent);
    final samplePoint = tester.getTopLeft(tabInk) + const Offset(4, 4);
    final before = await _readScenePixel(
      tester,
      find.byKey(sceneKey),
      samplePoint,
    );
    final gesture = await tester.startGesture(tester.getCenter(tabInk));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(
      await _readScenePixel(tester, find.byKey(sceneKey), samplePoint),
      before,
    );
    expect(taps, 0);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  for (final direction in TextDirection.values) {
    testWidgets('单条下划线随拖动、回拖和点击连续移动 direction=$direction', (tester) async {
      final controllers = [_RankingTestController(), _RankingTestController()];
      addTearDown(() {
        for (final controller in controllers) {
          controller.dispose();
        }
      });
      late PageController pageController;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppMaterialTheme.light(),
          home: Directionality(
            textDirection: direction,
            child: TinygrailTabbedPagedSliverPage<int, int>(
              headerBuilder:
                  (context, labels, selectedIndex, controller, onSelected) {
                    pageController = controller;
                    return RankingTabBar(
                      labels: labels,
                      selectedIndex: selectedIndex,
                      pageController: controller,
                      onSelected: onSelected,
                    );
                  },
              tabs: [
                for (var index = 0; index < 2; index += 1)
                  TinygrailPagedTab<int, int>(
                    label: index == 0 ? '精炼排行' : '番市首富',
                    controller: controllers[index],
                    loadingSliver: const SliverToBoxAdapter(),
                    emptySliverBuilder: (context, controller) {
                      return const SliverToBoxAdapter();
                    },
                    contentSliversBuilder: (context, items, onItemBuilt) {
                      return const <Widget>[];
                    },
                    completedLabel: '没有更多了',
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final firstLabelRect = tester.getRect(find.text('精炼排行'));
      final secondLabelRect = tester.getRect(find.text('番市首富'));
      final firstCenter = firstLabelRect.center.dx;
      final secondCenter = secondLabelRect.center.dx;
      final indicatorY = tester.getCenter(_indicatorFinder()).dy;

      /// 验证下划线与页面使用相同的连续进度
      void expectFollowingPage() {
        expect(_indicatorFinder(), findsOneWidget);
        expect(
          tester.getCenter(_indicatorFinder()).dx,
          closeTo(
            firstCenter + (secondCenter - firstCenter) * pageController.page!,
            0.01,
          ),
        );
        expect(tester.getCenter(_indicatorFinder()).dy, indicatorY);
        expect(tester.getRect(find.text('精炼排行')), firstLabelRect);
        expect(tester.getRect(find.text('番市首富')), secondLabelRect);
      }

      final nextDirection = direction == TextDirection.ltr ? -1.0 : 1.0;
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PageView)),
      );
      await gesture.moveBy(Offset(nextDirection * 20, 0));
      await tester.pump();
      await gesture.moveBy(Offset(nextDirection * 200, 0));
      await tester.pump();
      expect(pageController.page!, inExclusiveRange(0.1, 0.5));
      expectFollowingPage();

      await gesture.moveBy(Offset(nextDirection * 120, 0));
      await tester.pump();
      final fartherProgress = pageController.page!;
      expect(fartherProgress, inExclusiveRange(0.3, 0.5));
      expectFollowingPage();

      final pageWidth = tester.getSize(find.byType(PageView)).width;
      await gesture.moveBy(
        Offset(nextDirection * (0.5 - pageController.page!) * pageWidth, 0),
      );
      await tester.pump();
      expect(pageController.page, closeTo(0.5, 0.001));
      expectFollowingPage();

      await gesture.moveBy(Offset(-nextDirection * 100, 0));
      await tester.pump();
      expect(pageController.page!, lessThan(fartherProgress));
      expectFollowingPage();

      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(pageController.page, 0);
      expectFollowingPage();

      await tester.tap(find.text('番市首富'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(pageController.page!, inExclusiveRange(0, 1));
      expectFollowingPage();
      await tester.pumpAndSettle();
      expect(pageController.page, 1);
      expectFollowingPage();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('列表从统一头部后方滚过并保留切换分页与刷新', (tester) async {
    final controllers = [_RankingTestController(), _RankingTestController()];
    final sceneKey = GlobalKey();
    addTearDown(() {
      for (final controller in controllers) {
        controller.dispose();
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppMaterialTheme.dark(),
        home: Scaffold(
          backgroundColor: const Color(0xFF111318),
          body: RepaintBoundary(
            key: sceneKey,
            child: TinygrailTabbedPagedSliverPage<int, int>(
              onTabPrepared: (index) => controllers[index].initialize(),
              headerBuilder:
                  (context, labels, selectedIndex, pageController, onSelected) {
                    final tabBar = RankingTabBar(
                      labels: labels,
                      selectedIndex: selectedIndex,
                      pageController: pageController,
                      onSelected: onSelected,
                    );
                    return PreferredSize(
                      preferredSize: Size.fromHeight(
                        MainNavigationSearchHeader.occupiedHeight(
                          context,
                          bottom: tabBar,
                        ),
                      ),
                      child: MainNavigationSearchHeader(
                        backgroundColor: const Color(0xFF111318),
                        onSearchPressed: () {},
                        onProfilePressed: () {},
                        bottom: tabBar,
                      ),
                    );
                  },
              tabs: [
                for (var i = 0; i < 2; i += 1)
                  TinygrailPagedTab<int, int>(
                    label: i == 0 ? '精炼排行' : '番市首富',
                    controller: controllers[i],
                    loadingSliver: const SliverToBoxAdapter(),
                    emptySliverBuilder: (context, controller) {
                      return const SliverToBoxAdapter();
                    },
                    contentSliversBuilder: (context, items, onItemBuilt) {
                      return [
                        SliverFixedExtentList(
                          itemExtent: 60,
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            onItemBuilt(index);
                            return ColoredBox(
                              color: Colors.green,
                              child: Text('$i-${items[index]}'),
                            );
                          }, childCount: items.length),
                        ),
                      ];
                    },
                    completedLabel: '没有更多了',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final controlFinder = find.byType(RankingTabBar);
    final headerFinder = find.byType(MainNavigationSearchHeader);
    const contentTop = 60 + RankingTabBar.height;
    expect(tester.getTopLeft(controlFinder).dy, 60);
    expect(tester.getTopLeft(find.byType(PageView)), Offset.zero);
    expect(tester.getTopLeft(find.text('0-0')).dy, contentTop);
    expect(
      tester.getBottomLeft(headerFinder).dy,
      contentTop + MainNavigationSearchHeader.fadeContentOverlap,
    );
    expect(
      tester
          .widget<RefreshIndicator>(find.byType(RefreshIndicator).first)
          .edgeOffset,
      contentTop,
    );
    final gradientFinder = find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).gradient is LinearGradient,
    );
    expect(gradientFinder, findsOneWidget);
    final beforeScrollColor = await _readScenePixel(
      tester,
      find.byKey(sceneKey),
      const Offset(400, 94),
    );
    expect(controllers[0].requestedPages, [1]);
    expect(controllers[1].requestedPages, isEmpty);
    final controlRect = tester.getRect(controlFinder);
    final scrollFinder = find.byType(CustomScrollView).hitTestable();
    await tester.drag(scrollFinder, const Offset(0, -240));
    await tester.pumpAndSettle();
    final scrollOffset = tester
        .widget<CustomScrollView>(scrollFinder)
        .controller!
        .offset;
    expect(scrollOffset, greaterThan(0));
    expect(tester.getRect(controlFinder), controlRect);
    final afterScrollColor = await _readScenePixel(
      tester,
      find.byKey(sceneKey),
      const Offset(400, 94),
    );
    expect(afterScrollColor.g, greaterThan(beforeScrollColor.g + 0.05));
    expect(afterScrollColor.g, lessThan(Colors.green.g));
    expect(
      (await _readScenePixel(
        tester,
        find.byKey(sceneKey),
        const Offset(400, contentTop + 9),
      )).toARGB32(),
      Colors.green.toARGB32(),
    );

    await tester.tap(find.text('番市首富'));
    await tester.pumpAndSettle();
    expect(controllers[1].requestedPages, [1]);
    expect(tester.widget<RankingTabBar>(controlFinder).selectedIndex, 1);

    await tester.drag(scrollFinder, const Offset(0, 320));
    await tester.pumpAndSettle();
    expect(controllers[1].requestedPages, [1, 1]);

    await tester.drag(find.byType(PageView), const Offset(650, 0));
    await tester.pumpAndSettle();
    expect(tester.widget<RankingTabBar>(controlFinder).selectedIndex, 0);
    expect(
      tester.widget<CustomScrollView>(scrollFinder).controller!.offset,
      closeTo(scrollOffset, 1),
    );
    expect(controllers[0].requestedPages.where((page) => page == 1), [1]);

    await tester.drag(scrollFinder, const Offset(0, -2600));
    await tester.pumpAndSettle();
    expect(controllers[0].requestedPages, [1, 2]);
    expect(tester.takeException(), isNull);
  });
}

/// 定位排行榜唯一的下划线
Finder _indicatorFinder() {
  return find.descendant(
    of: find.byType(RankingTabBar),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Positioned && widget.width == 24 && widget.height == 2,
    ),
  );
}

/// 读取测试场景实际绘制的像素
///
/// [tester] 组件测试驱动器
/// [sceneFinder] 场景绘制边界
/// [position] 相对场景左上角的采样位置
Future<Color> _readScenePixel(
  WidgetTester tester,
  Finder sceneFinder,
  Offset position,
) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(sceneFinder);
  final color = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      final offset =
          (position.dy.toInt() * image.width + position.dx.toInt()) * 4;
      return Color.fromARGB(
        bytes.getUint8(offset + 3),
        bytes.getUint8(offset),
        bytes.getUint8(offset + 1),
        bytes.getUint8(offset + 2),
      );
    } finally {
      image.dispose();
    }
  });
  return color!;
}

/// 排行榜标签交互测试专用分页控制器
class _RankingTestController extends TinygrailPagedListController<int, int> {
  /// 创建排行榜测试分页控制器
  _RankingTestController() : super(pageSize: 30);

  /// 测试期间请求的页码
  final List<int> requestedPages = [];

  /// 返回用于验证滚动与分页的测试数据
  ///
  /// [page] 请求页码
  /// [pageSize] 每页条目数
  @override
  Future<TinygrailPage<int>> requestPage({
    required int page,
    required int pageSize,
  }) async {
    requestedPages.add(page);
    return TinygrailPage<int>(
      items: List.generate(pageSize, (index) => (page - 1) * pageSize + index),
      currentPage: page,
      totalPages: 2,
      totalItems: pageSize * 2,
      itemsPerPage: pageSize,
    );
  }

  /// 保留测试条目用于展示
  ///
  /// [items] 测试分页条目
  @override
  List<int> convertPageItems(List<int> items) => items;
}
