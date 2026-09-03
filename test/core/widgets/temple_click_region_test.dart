import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/core/widgets/temple_card.dart';
import 'package:magrail_app/core/widgets/temple_link_card.dart';

/// 验证圣殿卡片角色行的底部点击区域优先级
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('圣殿角色行空白区域触发角色回调', (tester) async {
    var imagePressed = false;
    var characterPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TempleCard(
            coverUrl: '',
            avatarUrl: '',
            characterName: '角色一',
            characterLevel: 3,
            zeroCount: 1,
            ownerLabel: '@用户一',
            templeLevel: 2,
            refine: 0,
            starForces: 0,
            onTap: () {
              imagePressed = true;
            },
            onCharacterTap: () {
              characterPressed = true;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final cardRect = tester.getRect(find.byType(TempleCard));
    final levelBadgeRect = tester.getRect(find.byType(LevelBadge));
    await tester.tapAt(
      Offset(cardRect.right - 20, levelBadgeRect.center.dy),
    );

    expect(characterPressed, isTrue);
    expect(imagePressed, isFalse);
  });

  testWidgets('圣殿卡片底部空白区域不会触发查看大图', (tester) async {
    var imagePressed = false;
    var userPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TempleCard(
            coverUrl: '',
            avatarUrl: '',
            characterName: '角色一',
            characterLevel: 3,
            zeroCount: 1,
            ownerLabel: '@用户一',
            templeLevel: 2,
            refine: 0,
            starForces: 0,
            onTap: () {
              imagePressed = true;
            },
            onUserTap: () {
              userPressed = true;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final cardRect = tester.getRect(find.byType(TempleCard));
    await tester.tapAt(Offset(cardRect.center.dx, cardRect.bottom - 25));
    await tester.tapAt(Offset(cardRect.center.dx, cardRect.bottom - 6));

    expect(userPressed, isTrue);
    expect(imagePressed, isFalse);
  });

  testWidgets('圣殿连接卡片底部空白区域不会触发封面查看', (tester) async {
    var leftCoverPressed = false;
    var rightCoverPressed = false;
    var leftCharacterPressed = false;
    var rightCharacterPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TempleLinkCard(
            leftCoverUrl: '',
            leftAvatarUrl: '',
            leftCharacterName: '左侧角色',
            rightCoverUrl: '',
            rightAvatarUrl: '',
            rightCharacterName: '右侧角色',
            onLeftCoverTap: () {
              leftCoverPressed = true;
            },
            onRightCoverTap: () {
              rightCoverPressed = true;
            },
            onLeftCharacterTap: () {
              leftCharacterPressed = true;
            },
            onRightCharacterTap: () {
              rightCharacterPressed = true;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final cardRect = tester.getRect(find.byType(TempleLinkCard));
    await tester.tapAt(Offset(cardRect.left + 40, cardRect.bottom - 6));
    await tester.tapAt(Offset(cardRect.right - 40, cardRect.bottom - 6));
    await tester.tapAt(Offset(cardRect.left + 40, cardRect.bottom - 28));
    await tester.tapAt(Offset(cardRect.right - 40, cardRect.bottom - 28));

    expect(leftCoverPressed, isFalse);
    expect(rightCoverPressed, isFalse);
    expect(leftCharacterPressed, isTrue);
    expect(rightCharacterPressed, isTrue);
  });

  testWidgets('圣殿连接卡片主体仍可触发左右封面查看', (tester) async {
    var leftCoverPressed = false;
    var rightCoverPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TempleLinkCard(
            leftCoverUrl: '',
            leftAvatarUrl: '',
            leftCharacterName: '左侧角色',
            rightCoverUrl: '',
            rightAvatarUrl: '',
            rightCharacterName: '右侧角色',
            onLeftCoverTap: () {
              leftCoverPressed = true;
            },
            onRightCoverTap: () {
              rightCoverPressed = true;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final cardRect = tester.getRect(find.byType(TempleLinkCard));
    await tester.tapAt(Offset(cardRect.left + 40, cardRect.top + 40));
    await tester.tapAt(Offset(cardRect.right - 40, cardRect.top + 40));

    expect(leftCoverPressed, isTrue);
    expect(rightCoverPressed, isTrue);
  });
}
