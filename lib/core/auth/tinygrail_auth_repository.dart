import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

import 'tinygrail_site_config.dart';

/// Tinygrail 认证仓库
class TinygrailAuthRepository {
  /// 创建 Tinygrail 认证仓库
  ///
  /// [dio] Tinygrail API 客户端
  /// [cookieJar] Tinygrail CookieJar 实例
  TinygrailAuthRepository({required Dio dio, required CookieJar cookieJar})
    : _dio = dio,
      _cookieJar = cookieJar;

  final Dio _dio;
  final CookieJar _cookieJar;

  // 冷启动首次检查 Cookie 前允许现有会话任务捕获代际
  int _sessionGeneration = 0;
  bool _isSessionGenerationActive = true;

  /// 请求 Tinygrail callback
  ///
  /// [callbackUri] 授权回调地址
  Future<void> consumeCallback(Uri callbackUri) async {
    await _consumeCallback(callbackUri);
  }

  /// 检查 Tinygrail 会话 Cookie
  Future<bool> hasTinygrailCookie() async {
    final checkGeneration = _sessionGeneration;
    final cookies = await _cookieJar.loadForRequest(
      TinygrailSiteConfig.siteUri,
    );
    if (checkGeneration != _sessionGeneration) {
      // 旧 Cookie 检查只读取当前状态，不能重新激活已变更的会话
      return _isSessionGenerationActive;
    }
    final hasCookie = cookies.isNotEmpty;
    if (hasCookie) {
      _activateSessionGeneration();
    } else {
      _invalidateSessionGeneration();
    }
    return hasCookie;
  }

  /// 捕获当前 Tinygrail 会话代际
  ///
  /// 无可用会话时返回空值
  int? captureSessionGeneration() {
    return _isSessionGenerationActive ? _sessionGeneration : null;
  }

  /// 判断会话代际是否仍属于当前授权
  ///
  /// [generation] 任务开始时捕获的会话代际
  bool isSessionGenerationCurrent(int generation) {
    return _isSessionGenerationActive && generation == _sessionGeneration;
  }

  /// 读取 fuyuake bot 授权 token
  Future<String> readFuyuakeBotToken() async {
    final cookies = [
      ...await _cookieJar.loadForRequest(TinygrailSiteConfig.siteUri),
      ...await _cookieJar.loadForRequest(TinygrailSiteConfig.apiBaseUri),
    ];
    for (final cookie in cookies) {
      // fuyuake bot 使用 Tinygrail 会话 Cookie 的 value 作为 token
      if (cookie.name == '.AspNetCore.Identity.Application' &&
          cookie.value.trim().isNotEmpty) {
        return cookie.value;
      }
    }

    throw StateError('请先授权');
  }

  /// 清除 Tinygrail 会话 Cookie
  Future<void> clearSession() async {
    // 先同步废弃旧代际，避免并发资产请求在 Cookie 删除后写回快照
    _invalidateSessionGeneration(advanceBoundary: true);
    try {
      await _cookieJar.delete(TinygrailSiteConfig.siteUri);
    } finally {
      // 再废弃删除期间启动的 Cookie 检查和资产任务
      _invalidateSessionGeneration(advanceBoundary: true);
    }
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

  /// 激活新授权对应的会话代际
  void _activateSessionGeneration() {
    if (_isSessionGenerationActive) {
      return;
    }
    _sessionGeneration += 1;
    _isSessionGenerationActive = true;
  }

  /// 废弃当前授权对应的会话代际
  ///
  /// [advanceBoundary] 是否在已废弃状态下继续推进代际
  void _invalidateSessionGeneration({bool advanceBoundary = false}) {
    if (!_isSessionGenerationActive && !advanceBoundary) {
      return;
    }
    _sessionGeneration += 1;
    _isSessionGenerationActive = false;
  }
}
