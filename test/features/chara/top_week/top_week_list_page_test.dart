import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/chara/top_week/controller/top_week_controller.dart';
import 'package:magrail_app/features/chara/top_week/model/top_week_entry.dart';
import 'package:magrail_app/features/chara/top_week/repository/top_week_repository.dart';
import 'package:magrail_app/features/chara/top_week/view/top_week_list_page.dart';
import 'package:magrail_app/features/chara/top_week/widgets/top_week_list.dart';

/// 验证每周萌王二级页面复用共享数据并支持下拉刷新
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeTopWeekController controller;

  setUp(() {
    controller = _FakeTopWeekController(<TopWeekEntry>[_entry]);
  });

  tearDown(() {
    controller.dispose();
  });

  testWidgets('显示共享条目和图标指标并调用下拉刷新', (tester) async {
    var characterPressed = false;
    var auctionPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TopWeekListPage(
          controller: controller,
          onCharacterPressed: (entry, heroTag) {
            characterPressed = true;
          },
          onAuctionPressed: (entry) {
            auctionPressed = true;
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.text('角色一'), findsOneWidget);
    expect(tester.getSize(find.byType(TopWeekListRow)).height, 88);
    expect(find.textContaining('12 / 均价'), findsOneWidget);
    expect(find.textContaining('(刚刚更新)'), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsNothing);
    expect(find.byIcon(Icons.insights_rounded), findsOneWidget);
    expect(find.byIcon(Icons.group_rounded), findsOneWidget);
    expect(find.byIcon(Icons.gavel_rounded), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_rounded), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(controller.refreshCount, 1);

    await tester.tap(find.text('竞拍'));
    expect(auctionPressed, isTrue);

    await tester.tap(find.text('角色一'));
    expect(characterPressed, isTrue);
  });
}

final _entry = const TopWeekEntry(
  rank: 1,
  characterId: 1,
  name: '角色一',
  level: 3,
  coverUrl: '',
  avatarUrl: '',
  surplus: '+100',
  score: '80',
  bidders: '2',
  bidAmount: '30股',
  valhallaAmount: '10股',
  averagePrice: '12',
  basePrice: 10,
  maxAuctionAmount: 20,
  rankColor: Colors.amber,
);

/// 测试用每周萌王控制器
class _FakeTopWeekController extends TopWeekController {
  /// 创建测试用每周萌王控制器
  ///
  /// [entries] 测试条目
  _FakeTopWeekController(this._testEntries)
    : super(
        repository: TopWeekRepository(apiClient: ApiClient(Dio())),
        auctionRepository: AuctionRepository(apiClient: ApiClient(Dio())),
      );

  final List<TopWeekEntry> _testEntries;

  /// 刷新调用次数
  int refreshCount = 0;

  /// 测试用当前条目
  @override
  List<TopWeekEntry> get entries => _testEntries;

  /// 测试用首次加载状态
  @override
  bool get isLoading => false;

  /// 测试用刷新状态
  @override
  bool get isRefreshing => false;

  /// 测试用失败状态
  @override
  bool get isLoadFailed => false;

  /// 测试用刷新文案
  @override
  String get refreshLabel => '刚刚更新';

  /// 记录测试刷新调用
  @override
  Future<void> refresh() async {
    refreshCount++;
  }
}
