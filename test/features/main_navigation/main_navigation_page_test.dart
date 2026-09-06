import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magrail_app/app/bootstrap.dart';
import 'package:magrail_app/app/theme/app_material_theme.dart';
import 'package:magrail_app/core/analytics/app_activity_reporter.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/auth/tinygrail_site_config.dart';
import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/features/main_navigation/model/main_tab.dart';
import 'package:magrail_app/features/main_navigation/view/main_navigation_page.dart';
import 'package:magrail_app/features/main_navigation/widgets/chrome/main_navigation_search_header.dart';
import 'package:magrail_app/features/main_navigation/widgets/navigation/main_mobile_navigation_dock.dart';
import 'package:magrail_app/features/user/assets/controller/user_asset_snapshot_coordinator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 验证头像入口异步等待期间的主导航状态
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final failCookieCheck in [false, true]) {
    testWidgets(
      failCookieCheck ? '头像入口处理 Cookie 异常并保留当前页面' : '用户切换标签后不执行迟到的头像跳转',
      (tester) async {
        SharedPreferences.setMockInitialValues({'use_liquid_glass': false});
        final preferences = AppPreferences(
          await SharedPreferences.getInstance(),
        );
        final dio = Dio();
        final cookieJar = CookieJar();
        final auth = _NavigationTestAuthRepository(
          dio: dio,
          cookieJar: cookieJar,
        );
        await cookieJar.saveFromResponse(TinygrailSiteConfig.siteUri, [
          Cookie('.AspNetCore.Identity.Application', 'test-session'),
        ]);
        final client = _NavigationTestClient(dio);
        final repositories = AppRepositories(
          apiClient: client,
          dio: dio,
          authRepository: auth,
          preferences: preferences,
          activityReporter: _NoopActivityReporter(),
        );
        addTearDown(() {
          repositories.user.dispose();
          dio.close(force: true);
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppMaterialTheme.light(),
            home: MainNavigationPage(
              authRepository: auth,
              preferences: preferences,
              topWeekRepository: repositories.topWeek,
              rankingRepository: repositories.ranking,
              auctionRepository: repositories.auction,
              characterDetailRepository: repositories.characterDetail,
              towerRepository: repositories.tower,
              icoCharacterRepository: repositories.icoCharacter,
              characterRankRepository: repositories.characterRank,
              templeRepository: repositories.temple,
              templeAssetMagicRepository: repositories.templeAssetMagic,
              oosRepository: repositories.oos,
              userRepository: repositories.user,
              userAssetSnapshotCoordinator: _NoopSnapshotCoordinator(),
              scratchTicketRepository: repositories.scratchTicket,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final header = tester.widget<MainNavigationSearchHeader>(
          find.byType(MainNavigationSearchHeader),
        );
        final dockFinder = find.byType(MainMobileNavigationDock);
        auth.failCookieCheck = failCookieCheck;
        final opening = (header.onProfilePressed as Future<void> Function())();
        if (failCookieCheck) {
          await tester.runAsync(() => opening);
          await tester.pump();
          expect(find.text('用户资产加载失败，请稍后重试'), findsOneWidget);
          expect(
            tester.widget<MainMobileNavigationDock>(dockFinder).currentTab,
            MainTab.home,
          );
          await tester.pump(const Duration(seconds: 4));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          return;
        }
        await tester.runAsync(() => client.assetsRequested.future);
        tester
            .widget<MainMobileNavigationDock>(dockFinder)
            .onTabSelected(MainTab.character);
        await tester.pumpAndSettle();
        client.assetsResponse.complete({
          'State': 0,
          'Value': {'Id': 1, 'Name': 'test-user', 'Nickname': '测试用户'},
        });
        await tester.runAsync(() => opening);
        await tester.pumpAndSettle();
        expect(
          tester.widget<MainMobileNavigationDock>(dockFinder).currentTab,
          MainTab.character,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

/// 可模拟 Cookie 读取失败的测试认证仓库
class _NavigationTestAuthRepository extends TinygrailAuthRepository {
  /// 创建测试认证仓库
  ///
  /// [dio] 测试客户端
  /// [cookieJar] 内存 Cookie 存储
  _NavigationTestAuthRepository({required super.dio, required super.cookieJar});

  /// 是否模拟 Cookie 读取异常
  bool failCookieCheck = false;

  /// 读取测试会话或返回预设异常
  @override
  Future<bool> hasTinygrailCookie() async {
    if (failCookieCheck) {
      throw StateError('测试 Cookie 读取失败');
    }
    return super.hasTinygrailCookie();
  }
}

/// 延迟当前用户响应，其他区块直接返回失败的导航测试客户端
class _NavigationTestClient extends ApiClient {
  /// 创建测试客户端
  ///
  /// [dio] 未使用的底层客户端
  _NavigationTestClient(super.dio);

  /// 当前用户请求进入客户端
  final assetsRequested = Completer<void>();

  /// 测试控制的用户资料响应
  final assetsResponse = Completer<Map<String, Object?>>();

  /// 返回测试请求结果，不访问网络
  ///
  /// [path] 请求路径
  /// [queryParameters] 查询参数
  @override
  Future<T> getJson<T>(
    String path, {
    Map<String, Object?>? queryParameters,
  }) async {
    if (path == 'chara/user/assets') {
      if (!assetsRequested.isCompleted) {
        assetsRequested.complete();
      }
      return await assetsResponse.future as T;
    }
    throw StateError('导航测试不加载其他区块');
  }
}

/// 导航测试不启动活跃上报
class _NoopActivityReporter extends Fake implements AppActivityReporter {
  /// 忽略测试上报
  ///
  /// [userId] 用户 ID
  /// [username] 用户名
  @override
  Future<void> report({int? userId, String? username}) async {}
}

/// 导航测试不访问资产快照
class _NoopSnapshotCoordinator extends Fake
    implements UserAssetSnapshotCoordinator {
  /// 接收测试监听注册
  ///
  /// [listener] 控制器回调
  @override
  void addListener(VoidCallback listener) {}

  /// 接收测试监听释放
  ///
  /// [listener] 控制器回调
  @override
  void removeListener(VoidCallback listener) {}
}
