import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

import 'tinygrail_site_config.dart';

/// Tinygrail 认证仓库
class TinygrailAuthRepository {
  /// 创建 Tinygrail 认证仓库
  ///
  /// [dio] Tinygrail API 客户端
  /// [cookieJar] Tinygrail CookieJar
  TinygrailAuthRepository({required Dio dio, required CookieJar cookieJar})
      : _dio = dio,
        _cookieJar = cookieJar;

  final Dio _dio;
  final CookieJar _cookieJar;

  /// 请求 Tinygrail callback
  ///
  /// [callbackUri] 授权回调地址
  Future<void> consumeCallback(Uri callbackUri) async {
    await _consumeCallback(callbackUri);
  }

  /// 检查 Tinygrail 会话 Cookie
  Future<bool> hasTinygrailCookie() async {
    final cookies = await _cookieJar.loadForRequest(
      TinygrailSiteConfig.siteUri,
    );
    return cookies.isNotEmpty;
  }

  /// 清除 Tinygrail 会话 Cookie
  Future<void> clearSession() async {
    await _cookieJar.delete(TinygrailSiteConfig.siteUri);
  }

  /// 请求 Tinygrail 远端退出登录
  Future<void> logoutRemote() async {
    await _dio.post<dynamic>('account/logout');
  }

  /// 处理 Tinygrail callback
  ///
  /// [callbackUri] 授权回调地址
  Future<void> _consumeCallback(Uri callbackUri) async {
    Uri currentUri = callbackUri;

    // 302 Set-Cookie 处理：显式读取跳转响应
    for (var attempt = 0; attempt < 5; attempt += 1) {
      final response = await _dio.getUri<dynamic>(
        currentUri,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode < 300 || statusCode >= 400) {
        return;
      }

      final location = response.headers.value('location');
      if (location == null || location.isEmpty) {
        return;
      }

      final nextUri = currentUri.resolve(location);
      if (nextUri.host != TinygrailSiteConfig.siteUri.host) {
        return;
      }

      currentUri = nextUri;
    }

    throw StateError('授权回调跳转次数过多');
  }
}
