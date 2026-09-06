import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:magrail_app/app/theme/app_material_theme.dart';
import 'package:magrail_app/features/chara/search/widgets/character_search_input_bar.dart';
import 'package:magrail_app/features/main_navigation/widgets/chrome/main_navigation_search_header.dart';
import 'package:magrail_app/features/ranking/widgets/ranking_tab_bar.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';
import 'package:magrail_app/features/user/widgets/user_avatar.dart';

/// 验证主导航搜索头部的布局与点击入口
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('搜索栏和头像分别触发对应回调', (tester) async {
    var searchPressed = false;
    var profilePressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MainNavigationSearchHeader(
            backgroundColor: Colors.white,
            onSearchPressed: () {
              searchPressed = true;
            },
            onProfilePressed: () {
              profilePressed = true;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CharacterSearchInputBar), findsOneWidget);
    expect(find.text('搜索角色'), findsOneWidget);
    expect(find.byType(UserAvatar), findsNothing);
    expect(find.byType(GlassContainer), findsOneWidget);
    final searchRect = tester.getRect(find.byType(CharacterSearchInputBar));
    final avatarRect = tester.getRect(find.byType(GlassContainer));
    final searchBar = tester.widget<CharacterSearchInputBar>(
      find.byType(CharacterSearchInputBar),
    );
    final emptyAvatar = tester.widget<GlassContainer>(
      find.byType(GlassContainer),
    );
    expect(emptyAvatar.settings, searchBar.glassSettings);
    expect(emptyAvatar.quality, GlassQuality.minimal);
    expect(searchRect.top, 14);
    expect(searchRect.height, 44);
    expect(avatarRect.size, const Size(44, 44));
    expect(avatarRect.top, searchRect.top);
    expect(avatarRect.bottom, searchRect.bottom);
    expect(tester.getSize(find.byType(MainNavigationSearchHeader)).height, 80);

    await tester.tap(find.byType(CharacterSearchInputBar));
    await tester.pump();
    expect(searchPressed, isTrue);

    await tester.tapAt(avatarRect.center);
    await tester.pump();
    expect(profilePressed, isTrue);
  });

  testWidgets('登录后继续使用原用户头像', (tester) async {
    const profile = UserDetailProfile(
      userId: 1,
      name: 'tester',
      nickname: '测试用户',
      rank: 1,
      avatar: '',
      balance: 0,
      assets: 0,
      type: 0,
      state: 0,
      showDaily: false,
      showWeekly: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MainNavigationSearchHeader(
            backgroundColor: Colors.white,
            profile: profile,
            onSearchPressed: () {},
            onProfilePressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(UserAvatar), findsOneWidget);
    expect(find.byType(GlassContainer), findsNothing);
    final avatar = tester.widget<UserAvatar>(find.byType(UserAvatar));
    expect(avatar.imageUrl, profile.avatar);
    expect(avatar.size, CharacterSearchInputBar.height);
  });

  testWidgets('顶部栏自身包含状态栏安全区', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            padding: EdgeInsets.only(top: 24),
          ),
          child: Scaffold(
            body: MainNavigationSearchHeader(
              backgroundColor: Colors.white,
              onSearchPressed: () {},
              onProfilePressed: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.getSize(find.byType(MainNavigationSearchHeader)).height, 104);
  });

  for (final isDark in [false, true]) {
    testWidgets('附加标签栏时收紧间距且头像与搜索框对齐 dark=$isDark', (tester) async {
      final pageController = PageController();
      addTearDown(pageController.dispose);
      var occupiedHeight = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: isDark ? AppMaterialTheme.dark() : AppMaterialTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              padding: EdgeInsets.only(top: 24),
            ),
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  final tabBar = RankingTabBar(
                    labels: const ['精炼排行', '番市首富'],
                    selectedIndex: 0,
                    pageController: pageController,
                    onSelected: (_) {},
                  );
                  occupiedHeight = MainNavigationSearchHeader.occupiedHeight(
                    context,
                    bottom: tabBar,
                  );
                  return MainNavigationSearchHeader(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    onSearchPressed: () {},
                    onProfilePressed: () {},
                    bottom: tabBar,
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final searchRect = tester.getRect(find.byType(CharacterSearchInputBar));
      final avatarRect = tester.getRect(find.byType(GlassContainer));
      expect(searchRect.top, 38);
      expect(searchRect.height, 44);
      expect(avatarRect.size, const Size(44, 44));
      expect(avatarRect.top, searchRect.top);
      expect(avatarRect.bottom, searchRect.bottom);
      expect(
        tester.getTopLeft(find.byType(RankingTabBar)).dy,
        searchRect.bottom + 2,
      );
      expect(
        tester.getTopLeft(find.text('精炼排行')).dy - searchRect.bottom,
        inInclusiveRange(11, 13),
      );
      expect(occupiedHeight, 128);
      expect(
        tester.getSize(find.byType(MainNavigationSearchHeader)).height,
        136,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('头像按住反馈绘制在上层且取消或松开后恢复 dark=$isDark', (tester) async {
      final sceneKey = GlobalKey();
      var profileTaps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: isDark ? AppMaterialTheme.dark() : AppMaterialTheme.light(),
          home: Scaffold(
            body: RepaintBoundary(
              key: sceneKey,
              child: MainNavigationSearchHeader(
                backgroundColor: isDark
                    ? const Color(0xFF111318)
                    : const Color(0xFFF5F7FB),
                onSearchPressed: () {},
                onProfilePressed: () => profileTaps += 1,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final avatarRect = tester.getRect(find.byType(GlassContainer));
      final before = await _readAvatarPixels(tester, sceneKey, avatarRect);
      final cancelledPress = await tester.startGesture(avatarRect.center);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      final held = await _readAvatarPixels(tester, sceneKey, avatarRect);
      expect(
        held.first.g,
        isDark
            ? greaterThan(before.first.g + 0.03)
            : lessThan(before.first.g - 0.03),
      );
      expect(held.last, before.last);
      expect(tester.getRect(find.byType(GlassContainer)), avatarRect);
      expect(profileTaps, 0);

      await cancelledPress.cancel();
      await tester.pumpAndSettle();
      expect(await _readAvatarPixels(tester, sceneKey, avatarRect), before);
      expect(profileTaps, 0);

      final completedPress = await tester.startGesture(avatarRect.center);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      expect(profileTaps, 0);
      await completedPress.up();
      await tester.pumpAndSettle();
      expect(profileTaps, 1);
      expect(await _readAvatarPixels(tester, sceneKey, avatarRect), before);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('搜索区域底部使用透明渐变衔接页面内容', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MainNavigationSearchHeader(
            backgroundColor: Colors.white,
            onSearchPressed: () {},
            onProfilePressed: () {},
          ),
        ),
      ),
    );

    final gradientFinder = find.byWidgetPredicate((widget) {
      if (widget case DecoratedBox(:final decoration)) {
        return decoration is BoxDecoration &&
            decoration.gradient is LinearGradient;
      }
      return false;
    });
    final gradientBox = tester.widget<DecoratedBox>(gradientFinder);
    final gradient =
        (gradientBox.decoration as BoxDecoration).gradient! as LinearGradient;

    expect(gradient.begin, Alignment.topCenter);
    expect(gradient.end, Alignment.bottomCenter);
    expect(gradient.colors.last.a, 0);
    expect(gradient.stops, [
      0,
      0.14,
      0.28,
      0.42,
      0.56,
      0.68,
      0.78,
      0.88,
      0.95,
      1,
    ]);
    expect(gradient.colors.map((color) => color.a), [
      1,
      1,
      0.99,
      0.96,
      0.9,
      0.8,
      0.65,
      0.45,
      0.2,
      0,
    ]);
    expect(tester.getSize(gradientFinder).height, 80);
    expect(tester.getTopLeft(gradientFinder).dy, 0);

    final searchBar = tester.widget<CharacterSearchInputBar>(
      find.byType(CharacterSearchInputBar),
    );
    expect(searchBar.glassSettings?.visibility, 0);
    expect(searchBar.glassSettings?.blur, 0);
    expect(searchBar.glassSettings?.thickness, 0);
  });

  testWidgets('夜间模式为搜索栏保留最低限度的浅色底', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
          body: MainNavigationSearchHeader(
            backgroundColor: const Color(0xFF111318),
            onSearchPressed: () {},
            onProfilePressed: () {},
          ),
        ),
      ),
    );

    final searchBar = tester.widget<CharacterSearchInputBar>(
      find.byType(CharacterSearchInputBar),
    );
    expect(searchBar.glassSettings?.glassColor, const Color(0x1AFFFFFF));
    expect(searchBar.glassSettings?.visibility, 1);
    expect(searchBar.glassSettings?.blur, 0);
    expect(searchBar.glassSettings?.thickness, 0);
  });
}

/// 读取头像圆内与圆外角落的实际像素
///
/// [tester] 组件测试驱动器
/// [sceneKey] 搜索头部绘制边界
/// [avatarRect] 头像在屏幕中的边界
Future<List<Color>> _readAvatarPixels(
  WidgetTester tester,
  GlobalKey sceneKey,
  Rect avatarRect,
) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(sceneKey),
  );
  final points = [
    boundary.globalToLocal(avatarRect.topLeft + const Offset(12, 12)),
    boundary.globalToLocal(avatarRect.topLeft + const Offset(1, 1)),
  ];
  final colors = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      return points
          .map((point) {
            final offset =
                (point.dy.toInt() * image.width + point.dx.toInt()) * 4;
            return Color.fromARGB(
              bytes.getUint8(offset + 3),
              bytes.getUint8(offset),
              bytes.getUint8(offset + 1),
              bytes.getUint8(offset + 2),
            );
          })
          .toList(growable: false);
    } finally {
      image.dispose();
    }
  });
  return colors!;
}
