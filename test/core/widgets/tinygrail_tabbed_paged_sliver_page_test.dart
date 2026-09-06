import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/widgets/tinygrail_tabbed_paged_sliver_page.dart';

/// 验证分页页面的默认头部与自定义悬浮头部
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _EmptyPagedController controller;

  setUp(() {
    controller = _EmptyPagedController();
  });

  tearDown(() {
    controller.dispose();
  });

  testWidgets('默认头部使用二级页面标题和返回按钮', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TinygrailTabbedPagedSliverPage<int, int>(
          title: '测试页面',
          tabs: [
            TinygrailPagedTab<int, int>(
              label: '测试标签',
              controller: controller,
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
    );
    await tester.pump();

    expect(find.text('测试页面'), findsOneWidget);
    expect(find.text('测试标签'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('自定义头部悬浮于列表并同步刷新布局', (tester) async {
    final preparedIndexes = <int>[];
    final selectedIndexes = <int>[];
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: TinygrailTabbedPagedSliverPage<int, int>(
          onTabPrepared: preparedIndexes.add,
          onTabSelected: selectedIndexes.add,
          tabs: [
            for (final label in ['甲榜', '乙榜'])
              TinygrailPagedTab<int, int>(
                label: label,
                controller: controller,
                loadingSliver: const SliverToBoxAdapter(),
                emptySliverBuilder: (context, controller) {
                  return SliverToBoxAdapter(
                    child: SizedBox(height: 120, child: Text('$label内容')),
                  );
                },
                contentSliversBuilder: (context, items, onItemBuilt) {
                  return const <Widget>[];
                },
                completedLabel: '没有更多了',
              ),
          ],
          headerBuilder: (context, labels, index, pageController, onSelected) {
            selectedIndex = index;
            return PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    for (var i = 0; i < labels.length; i += 1)
                      Expanded(
                        child: TextButton(
                          onPressed: () => onSelected(i),
                          child: Text(labels[i]),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(preparedIndexes, [0]);
    expect(tester.getTopLeft(find.byType(PageView)), Offset.zero);
    expect(tester.getTopLeft(find.text('甲榜内容')).dy, 64);
    final indicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator).first,
    );
    expect(indicator.edgeOffset, 64);

    await tester.tap(find.text('乙榜'));
    await tester.pumpAndSettle();
    expect(selectedIndex, 1);
    expect(preparedIndexes, [0, 1]);
    expect(selectedIndexes, [1]);
    expect(find.text('乙榜内容'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(650, 0));
    await tester.pumpAndSettle();
    expect(selectedIndex, 0);
    expect(selectedIndexes, [1, 0]);
    expect(preparedIndexes, [0, 1]);
    expect(tester.takeException(), isNull);
  });
}

/// 测试用空分页控制器
class _EmptyPagedController extends TinygrailPagedListController<int, int> {
  /// 创建测试用空分页控制器
  _EmptyPagedController() : super(pageSize: 1);

  /// 请求测试分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页条目数量
  @override
  Future<TinygrailPage<int>> requestPage({
    required int page,
    required int pageSize,
  }) async {
    return const TinygrailPage<int>(
      items: <int>[],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
      itemsPerPage: 1,
    );
  }

  /// 转换测试分页条目
  ///
  /// [items] 原始测试条目
  @override
  List<int> convertPageItems(List<int> items) {
    return items;
  }
}
