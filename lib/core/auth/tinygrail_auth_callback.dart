import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'bangumi_auth_config.dart';
import 'tinygrail_site_config.dart';

/// 在独立 CookieJar 中跟随同源授权跳转并读取 Cookie 与访问令牌
///
/// [callbackUri] Tinygrail OAuth 回调地址
Future<({List<Cookie> cookies, String? token})> consumeTinygrailAuthCallback(
  Uri callbackUri,
) async {
  if (!BangumiAuthConfig.isTinygrailCallback(callbackUri)) {
    throw StateError('无效的授权回调地址');
  }
  final cookieJar = CookieJar();
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 120),
      responseType: ResponseType.plain,
      followRedirects: false,
      validateStatus: (status) =>
          status != null && status >= 200 && status < 400,
    ),
  );
  dio.interceptors.add(CookieManager(cookieJar));
  var currentUri = callbackUri;
  String? token;
  try {
    // OAuth 重定向保留最多五次请求，避免异常回调无限循环
    for (var attempt = 0; attempt <= 5; attempt += 1) {
      if (currentUri.path == '/' &&
          currentUri.queryParameters['close'] == 'true') {
        final values = currentUri.queryParametersAll['token'];
        if (values != null) {
          if (values.length != 1 ||
              values.single.trim().isEmpty ||
              values.single.contains(RegExp(r'[\r\n]'))) {
            throw StateError('授权返回的访问令牌无效');
          }
          token = values.single.trim();
        }
        // 不请求带有令牌的最终页面，避免凭据进入请求地址和异常信息
        break;
      }
      if (currentUri.queryParameters.containsKey('token')) {
        throw StateError('授权回调返回了无效的令牌地址');
      }
      if (attempt == 5) {
        throw StateError('授权回调跳转次数过多');
      }
      final response = await dio.getUri<String>(currentUri);
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 300 || statusCode >= 400) {
        break;
      }
      final location = response.headers.value(HttpHeaders.locationHeader);
      if (location == null || location.isEmpty) {
        throw StateError('授权回调缺少跳转地址');
      }
      final nextUri = currentUri.resolve(location);
      if (nextUri.scheme != 'https' ||
          nextUri.host != TinygrailSiteConfig.siteUri.host ||
          nextUri.port != 443 ||
          nextUri.userInfo.isNotEmpty) {
        throw StateError('授权回调返回了无效的跳转地址');
      }
      currentUri = nextUri;
    }
    return (
      cookies: await cookieJar.loadForRequest(TinygrailSiteConfig.apiBaseUri),
      token: token,
    );
  } finally {
    dio.close(force: true);
  }
}
