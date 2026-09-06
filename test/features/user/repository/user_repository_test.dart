import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magrail_app/core/analytics/app_activity_reporter.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/auth/tinygrail_site_config.dart';
import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/api_exception.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/storage/secure_storage.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/user/assets/controller/user_asset_snapshot_coordinator.dart';
import 'package:magrail_app/features/user/controller/user_detail_controller.dart';
import 'package:magrail_app/features/user/model/user_assets_fetch_result.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 验证用户资料通知与延迟请求的会话边界
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio dio;
  late CookieJar cookieJar;
  late TinygrailAuthRepository auth;
  late _PendingAssetsClient client;
  late _RecordingActivityReporter reporter;
  late UserRepository repository;
  late List<String?> notifications;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    dio = Dio();
    cookieJar = CookieJar();
    auth = TinygrailAuthRepository(dio: dio, cookieJar: cookieJar);
    client = _PendingAssetsClient(dio);
    reporter = _RecordingActivityReporter(dio, preferences);
    repository = UserRepository(
      apiClient: client,
      authRepository: auth,
      preferences: preferences,
      auctionRepository: AuctionRepository(apiClient: client),
      activityReporter: reporter,
    );
    notifications = [];
    repository.addListener(() {
      notifications.add(repository.readCachedCurrentUserAssets()?.name);
    });
    await _activateSession(cookieJar, auth, 'old-session');
  });

  tearDown(() {
    repository.dispose();
    dio.close(force: true);
  });

  test('当前会话成功结果通知头像更新并可清除', () async {
    final request = repository.fetchUserAssets();
    await client.requested.future;
    client.response.complete({
      'State': 0,
      'Value': _profile('old-user').toJson(),
    });
    final result = await request;

    expect(result.status, UserAssetsFetchStatus.success);
    expect(notifications, ['old-user']);
    expect(reporter.usernames, ['old-user']);
    await repository.clearCurrentUserAssetsCache();
    expect(notifications, ['old-user', null]);
  });

  test('退出后迟到的成功结果不能恢复用户缓存或通知旧头像', () async {
    final request = repository.fetchUserAssets();
    await client.requested.future;
    await auth.clearSession();
    await repository.clearCurrentUserAssetsCache();
    notifications.clear();

    client.response.complete({
      'State': 0,
      'Value': _profile('old-user').toJson(),
    });
    final result = await request;
    expect(repository.readCachedCurrentUserAssets(), isNull);
    expect(notifications, isEmpty);
    expect(reporter.usernames, isEmpty);
    expect(result.status, UserAssetsFetchStatus.failure);
  });

  test('当前会话的鉴权失败仍清除缓存并返回过期状态', () async {
    await repository.cacheCurrentUserAssets(_profile('old-user'));
    notifications.clear();
    final request = repository.fetchUserAssets();
    await client.requested.future;
    client.response.completeError(
      const ApiException(message: '登录已过期', statusCode: 401),
    );
    expect((await request).status, UserAssetsFetchStatus.authExpired);
    expect(repository.readCachedCurrentUserAssets(), isNull);
    expect(notifications, [null]);
    expect(reporter.usernames, [null]);
  });

  test('没有本地 Cookie 时仍清除资料且不请求资产接口', () async {
    await repository.cacheCurrentUserAssets(_profile('old-user'));
    await auth.clearSession();
    expect(
      await cookieJar.loadForRequest(TinygrailSiteConfig.siteUri),
      isEmpty,
    );
    notifications.clear();
    expect(
      (await repository.fetchUserAssets()).status,
      UserAssetsFetchStatus.authExpired,
    );
    expect(repository.readCachedCurrentUserAssets(), isNull);
    expect(client.requested.isCompleted, isFalse);
    expect(notifications, [null]);
  });

  for (final responseKind in ['success', 'business-error', 'unauthorized']) {
    test('重新授权后忽略旧会话的迟到结果 $responseKind', () async {
      final request = repository.fetchUserAssets();
      await client.requested.future;
      await auth.clearSession();
      await repository.clearCurrentUserAssetsCache();
      await _activateSession(cookieJar, auth, 'new-session');
      await repository.cacheCurrentUserAssets(_profile('new-user'));
      notifications.clear();

      if (responseKind == 'success') {
        client.response.complete({
          'State': 0,
          'Value': _profile('old-user').toJson(),
        });
      } else if (responseKind == 'business-error') {
        client.response.complete({'State': -1, 'Message': '旧请求失败'});
      } else {
        client.response.completeError(
          const ApiException(message: '旧会话失效', statusCode: 401),
        );
      }

      final result = await request;
      expect(repository.readCachedCurrentUserAssets()?.name, 'new-user');
      expect(notifications, isEmpty);
      expect(reporter.usernames, isEmpty);
      expect(result.status, UserAssetsFetchStatus.failure);
    });
  }

  test('节日请求期间切换会话不写回旧用户资料', () async {
    final controller = UserDetailController(
      repository: repository,
      snapshotCoordinator: _UnusedSnapshotCoordinator(),
    );
    addTearDown(controller.dispose);
    final refresh = controller.refresh();
    await client.requested.future;
    client.response.complete({
      'State': 0,
      'Value': _profile('old-user').toJson(),
    });
    await client.holidayRequested.future;

    await auth.clearSession();
    await repository.clearCurrentUserAssetsCache();
    await _activateSession(cookieJar, auth, 'new-session');
    await repository.cacheCurrentUserAssets(_profile('new-user'));
    notifications.clear();
    client.holidayResponse.complete({'State': 0, 'Value': '测试节日'});
    await refresh;

    expect(repository.readCachedCurrentUserAssets()?.name, 'new-user');
    expect(notifications, isEmpty);
    expect(controller.profile, isNull);
    expect(controller.isLoading, isFalse);
    expect(controller.isRefreshing, isFalse);
  });
}

/// 使用主机 Cookie 激活测试会话，不访问网络
///
/// [cookieJar] 内存 Cookie 存储
/// [auth] 正式认证仓库
/// [value] 测试 Cookie 标识
Future<void> _activateSession(
  CookieJar cookieJar,
  TinygrailAuthRepository auth,
  String value,
) async {
  final cookie = Cookie('.AspNetCore.Identity.Application', value)..path = '/';
  await cookieJar.saveFromResponse(TinygrailSiteConfig.siteUri, [cookie]);
  expect(await auth.hasTinygrailCookie(), isTrue);
}

/// 创建会话边界测试资料
///
/// [name] 测试用户名
UserDetailProfile _profile(String name) {
  return UserDetailProfile.fromJson({'Id': 1, 'Name': name, 'Nickname': name});
}

/// 手动完成用户资产请求的测试客户端
class _PendingAssetsClient extends ApiClient {
  /// 创建延迟响应测试客户端
  ///
  /// [dio] 仅用于满足客户端构造约定，不发送请求
  _PendingAssetsClient(super.dio);

  /// 请求已经进入客户端
  final requested = Completer<void>();

  /// 测试控制的响应结果
  final response = Completer<Map<String, Object?>>();

  /// 节日请求已经进入客户端
  final holidayRequested = Completer<void>();

  /// 测试控制的节日响应
  final holidayResponse = Completer<Map<String, Object?>>();

  /// 等待测试完成响应
  ///
  /// [path] 请求路径
  /// [queryParameters] 查询参数
  @override
  Future<T> getJson<T>(
    String path, {
    Map<String, Object?>? queryParameters,
  }) async {
    if (path == 'event/holiday/bonus/check') {
      holidayRequested.complete();
      return await holidayResponse.future as T;
    }
    if (!path.startsWith('chara/user/assets')) {
      throw StateError('测试不访问资产预览接口');
    }
    requested.complete();
    return await response.future as T;
  }
}

/// 本测试不启动资产快照任务，仅接收控制器的监听注册
class _UnusedSnapshotCoordinator extends Fake
    implements UserAssetSnapshotCoordinator {
  /// 接收测试监听注册
  ///
  /// [listener] 控制器监听回调
  @override
  void addListener(VoidCallback listener) {}

  /// 接收测试监听释放
  ///
  /// [listener] 控制器监听回调
  @override
  void removeListener(VoidCallback listener) {}
}

/// 记录活跃上报的测试替身，不调用平台或网络
class _RecordingActivityReporter extends AppActivityReporter {
  /// 创建测试上报器
  ///
  /// [dio] 未使用的客户端
  /// [preferences] 测试偏好存储
  _RecordingActivityReporter(Dio dio, AppPreferences preferences)
    : super(
        dio: dio,
        preferences: preferences,
        secureStorage: const SecureStorage(FlutterSecureStorage()),
      );

  /// 上报的测试用户名
  final List<String?> usernames = [];

  /// 记录上报参数
  ///
  /// [userId] 用户 ID
  /// [username] 用户名
  @override
  Future<void> report({int? userId, String? username}) async {
    usernames.add(username);
  }
}
