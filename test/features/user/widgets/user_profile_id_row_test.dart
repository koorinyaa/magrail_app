import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magrail_app/features/user/widgets/user_detail_states.dart';
import 'package:magrail_app/features/user/widgets/user_profile_card_components.dart';

/// 验证用户资料卡 ID 区域
void main() {
  testWidgets('显示两个来源图标并分别响应复制点击', (tester) async {
    var tinygrailCopyCount = 0;
    var bangumiCopyCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserProfileIdRow(
            tinygrailId: 123456,
            bangumiId: 'bgm-user',
            onTinygrailCopyPressed: () => tinygrailCopyCount += 1,
            onBangumiCopyPressed: () => bangumiCopyCount += 1,
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(ShaderMask), findsOneWidget);
    expect(
      tester.widget<ShaderMask>(find.byType(ShaderMask)).blendMode,
      BlendMode.dstIn,
    );
    expect(find.text('123456'), findsOneWidget);
    expect(find.text('bgm-user'), findsOneWidget);
    expect(find.text('@123456'), findsNothing);
    expect(find.text('@bgm-user'), findsNothing);

    await tester.tap(find.text('123456'));
    await tester.tap(find.text('bgm-user'));

    expect(tinygrailCopyCount, 1);
    expect(bangumiCopyCount, 1);
  });

  testWidgets('窄屏下过长 BGM ID 使用单行省略', (tester) async {
    const bangumiId = 'very-long-bangumi-user-id-for-narrow-layout';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 220,
              child: UserProfileIdRow(
                tinygrailId: 123456,
                bangumiId: bangumiId,
                onTinygrailCopyPressed: () {},
                onBangumiCopyPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final bangumiIdText = tester.widget<Text>(find.text(bangumiId));
    expect(bangumiIdText.maxLines, 1);
    expect(bangumiIdText.overflow, TextOverflow.ellipsis);
  });

  testWidgets('双 ID 骨架适配窄屏夜间模式', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 220, child: UserDetailSkeleton()),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
