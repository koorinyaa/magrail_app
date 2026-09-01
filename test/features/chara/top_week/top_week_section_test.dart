import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magrail_app/core/widgets/temple_cover_image.dart';
import 'package:magrail_app/features/chara/top_week/model/top_week_entry.dart';
import 'package:magrail_app/features/chara/top_week/widgets/top_week_section.dart';

/// 验证每周萌王卡片的指标和竞拍区域点击边界
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('指标区域可查看大图且竞拍区域不会触发查看', (tester) async {
    var auctionPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TopWeekCarousel(
            entries: const <TopWeekEntry>[_entry],
            isLoading: false,
            onCharacterPressed: (_) {},
            onAuctionPressed: (_) {
              auctionPressed = true;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final image = find.byType(TempleCoverImage);
    final imageOrigin = tester.getTopLeft(image);
    final imageSize = tester.getSize(image);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    await tester.tapAt(imageOrigin + const Offset(40, 254));
    await tester.pump();
    expect(navigator.canPop(), isTrue);

    navigator.pop();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tapAt(imageOrigin + const Offset(40, 279));
    await tester.pump(const Duration(milliseconds: 350));
    expect(navigator.canPop(), isTrue);

    navigator.pop();
    await tester.pump();

    await tester.tapAt(
      imageOrigin + Offset(185, imageSize.height - 32),
    );
    await tester.pump();

    expect(navigator.canPop(), isFalse);

    await tester.tap(find.text('竞拍'));
    await tester.pump();
    expect(navigator.canPop(), isFalse);
    expect(auctionPressed, isTrue);
  });
}

const _entry = TopWeekEntry(
  rank: 1,
  characterId: 1,
  name: '角色一',
  level: 3,
  coverUrl: 'https://example.com/top-week-cover.png',
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
