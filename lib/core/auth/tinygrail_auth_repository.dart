import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:magrail_app/core/network/api_exception.dart';
import 'package:magrail_app/core/storage/secure_storage.dart';

import 'tinygrail_auth_callback.dart';
import 'tinygrail_site_config.dart';

/// Tinygrail 会话凭据、授权回调与 Cookie 优先鉴权
class TinygrailAuthRepository {
  /// 创建 Tinygrail 认证仓库并接入共享客户端的鉴权处理
  ///
  /// [dio] Tinygrail API 客户端，凭据与 Cookie 处理由本仓库装配
  /// [cookieJar] Tinygrail CookieJar 实例
  /// [secureStorage] 访问令牌安全存储
  TinygrailAuthRepository({
    required this._dio,
    required this._cookieJar,
    required this._secureStorage,
  }) : _cookieManager = CookieManager(_cookieJar) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _attachCredentials,
        onResponse: _handleAuthResponse,
        onError: _handleAuthError,
      ),
    );
  }

  static const _accessTokenKey = 'tinygrail_access_token';
  static const _identityCookieName = '.AspNetCore.Identity.Application';
  static const _requestGenerationKey = 'tinygrailAuthGeneration';
  static const _requestModeKey = 'tinygrailAuthMode';
  static const _tokenRetryKey = 'tinygrailTokenRetried';
  final Dio _dio;
  final CookieJar _cookieJar;
  final CookieManager _cookieManager;
  final SecureStorage _secureStorage;

  // 同一授权内切换凭据不改变代际，退出或重新授权使旧任务失效
  int _sessionGeneration = 0;
  bool _isSessionGenerationActive = true;
  bool _isChangingCredentials = false;
  int _pendingSessionClears = 0;
  bool _cookieRejected = false;
  bool _tokenRejected = false;
  String? _accessToken;
  bool _isTokenLoaded = false;
  Future<void>? _tokenLoadTask;
  Future<void> _credentialWriteTask = Future<void>.value();
  int _authorizationRevision = 0;

  /// 凭据写入或退出清理期间暂停读取正式会话
  bool get _credentialsBlocked =>
      _isChangingCredentials || _pendingSessionClears > 0;

  /// 接收授权回调并串行提交新凭据，旧授权结果不覆盖退出后的会话
  ///
  /// [callbackUri] 授权回调地址
  Future<void> consumeCallback(Uri callbackUri) async {
    if (_credentialsBlocked) {
      throw StateError('登录状态正在变更，请重试');
    }
    final revision = ++_authorizationRevision;
    final generation = _sessionGeneration;
    final credentials = await consumeTinygrailAuthCallback(callbackUri);
    if (credentials.token == null &&
        !credentials.cookies.any(_isIdentityCookie)) {
      throw StateError('授权未返回可用的登录凭据');
    }
    await _enqueueCredentialWrite(() async {
      if (revision != _authorizationRevision ||
          generation != _sessionGeneration) {
        throw StateError('登录状态已变更，请重新授权');
      }
      _isChangingCredentials = true;
      _invalidateSessionGeneration(advanceBoundary: true);
      _accessToken = null;
      _isTokenLoaded = true;
      try {
        if (credentials.token case final token?) {
          await _secureStorage.write(_accessTokenKey, token);
        } else {
          // Cookie 授权不能沿用另一账号或另一授权的访问令牌
          await _secureStorage.delete(_accessTokenKey);
        }
        await _cookieJar.delete(TinygrailSiteConfig.siteUri, true);
        await _cookieJar.saveFromResponse(
          TinygrailSiteConfig.apiBaseUri,
          credentials.cookies,
        );
        if (revision != _authorizationRevision) {
          throw StateError('登录状态已变更，请重新授权');
        }
        _accessToken = credentials.token;
        _cookieRejected = false;
        _tokenRejected = false;
        _activateSessionGeneration();
      } catch (_) {
        // 提交不完整时关闭会话，避免混用新旧账号的凭据
        _accessToken = null;
        try {
          await _secureStorage.delete(_accessTokenKey);
        } finally {
          await _cookieJar.delete(TinygrailSiteConfig.siteUri, true);
        }
        rethrow;
      } finally {
        _isChangingCredentials = false;
      }
    });
  }

  /// 检查本地是否存在身份 Cookie 或尚未被服务端拒绝的访问令牌
  Future<bool> hasSession() async {
    if (_credentialsBlocked) return false;
    final checkGeneration = _sessionGeneration;
    final cookies = await _cookieJar.loadForRequest(
      TinygrailSiteConfig.apiBaseUri,
    );
    var available = !_cookieRejected && cookies.any(_isIdentityCookie);
    if (!available) {
      await _loadAccessToken();
      available = _accessToken != null && !_tokenRejected;
    }
    if (checkGeneration != _sessionGeneration || _credentialsBlocked) {
      // 旧检查只读取当前状态，不能重新激活已变更的会话
      return !_credentialsBlocked && _isSessionGenerationActive;
    }
    if (available) {
      _activateSessionGeneration();
    } else {
      _invalidateSessionGeneration();
    }
    return available;
  }

  /// 捕获当前 Tinygrail 会话代际，无可用会话时返回空值
  int? captureSessionGeneration() {
    return _isSessionGenerationActive ? _sessionGeneration : null;
  }

  /// 判断会话代际是否仍属于当前授权
  ///
  /// [generation] 任务开始时捕获的会话代际
  bool isSessionGenerationCurrent(int generation) {
    return _isSessionGenerationActive && generation == _sessionGeneration;
  }

  /// 读取 fuyuake bot 使用的身份 Cookie，不使用 Tinygrail API 访问令牌
  Future<String> readFuyuakeBotToken() async {
    if (_credentialsBlocked || _cookieRejected) {
      throw StateError('Bot 配置需要有效的 Cookie，请重新授权');
    }
    final generation = _sessionGeneration;
    final cookies = await _cookieJar.loadForRequest(
      TinygrailSiteConfig.apiBaseUri,
    );
    if (generation != _sessionGeneration || _credentialsBlocked) {
      throw StateError('登录状态已变更，请重试');
    }
    for (final cookie in cookies) {
      if (_isIdentityCookie(cookie)) return cookie.value;
    }
    throw StateError('Bot 配置需要有效的 Cookie，请重新授权');
  }

  /// 同时清除 Cookie 与安全存储中的访问令牌，并立即废弃旧任务
  Future<void> clearSession() async {
    ++_authorizationRevision;
    _pendingSessionClears += 1;
    _invalidateSessionGeneration(advanceBoundary: true);
    _accessToken = null;
    _isTokenLoaded = true;
    try {
      await _enqueueCredentialWrite(() async {
        try {
          await _secureStorage.delete(_accessTokenKey);
        } finally {
          await _cookieJar.delete(TinygrailSiteConfig.siteUri, true);
        }
      });
    } finally {
      _cookieRejected = false;
      _tokenRejected = false;
      _pendingSessionClears -= 1;
      _invalidateSessionGeneration(advanceBoundary: true);
    }
  }

  /// 使用当前优先凭据请求 Tinygrail 远端退出登录
  Future<void> logoutRemote() async {
    await _dio.post<dynamic>(
      'account/logout',
      options: Options(extra: {_requestGenerationKey: _sessionGeneration}),
    );
  }

  /// 串行修改凭据，避免安全存储写入与退出清理互相覆盖
  ///
  /// [action] 需要串行执行的凭据修改
  Future<void> _enqueueCredentialWrite(Future<void> Function() action) {
    final task = _credentialWriteTask.then((_) => action());
    // 当前任务的失败由调用方处理，后续退出或授权仍需继续清理凭据
    _credentialWriteTask = task.then<void>((_) {}, onError: (Object error) {});
    return task;
  }

  /// 合并安全存储读取，并阻止旧读取恢复已退出的访问令牌
  Future<void> _loadAccessToken() {
    if (_isTokenLoaded) return Future<void>.value();
    return _tokenLoadTask ??= _readAccessToken().whenComplete(
      () => _tokenLoadTask = null,
    );
  }

  /// 读取并校验持久化访问令牌，存储失败由调用方处理
  Future<void> _readAccessToken() async {
    final generation = _sessionGeneration;
    final value = await _secureStorage.read(_accessTokenKey);
    if (generation != _sessionGeneration || _credentialsBlocked) return;
    _accessToken =
        value != null &&
            value.trim().isNotEmpty &&
            !value.contains(RegExp(r'[\r\n]'))
        ? value.trim()
        : null;
    _isTokenLoaded = true;
  }

  /// 判断是否为有效的身份 Cookie
  ///
  /// [cookie] CookieJar 已过滤本地过期时间的 Cookie
  bool _isIdentityCookie(Cookie cookie) {
    return cookie.name == _identityCookieName && cookie.value.trim().isNotEmpty;
  }

  /// 判断当前请求是否属于固定 HTTPS Tinygrail API
  ///
  /// [uri] 当前请求地址
  bool _isTinygrailApi(Uri uri) {
    return uri.scheme == 'https' &&
        uri.host == TinygrailSiteConfig.siteUri.host &&
        uri.port == 443 &&
        uri.userInfo.isEmpty &&
        uri.path.startsWith('/api/') &&
        uri.path != '/api/account/callback' &&
        uri.path != '/api/account/callback/';
  }

  /// 读取 Cookie 后选择单一鉴权凭据，并检查请求所属会话
  ///
  /// [options] 当前请求配置
  /// [handler] Dio 请求拦截处理器
  void _attachCredentials(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.removeWhere(
      (key, _) => key.toLowerCase() == 'x-access-token',
    );
    if (!_isTinygrailApi(options.uri)) {
      handler.next(options);
      return;
    }
    final generation = options.extra.putIfAbsent(
      _requestGenerationKey,
      () => _sessionGeneration,
    );
    try {
      // 复用 CookieManager 的路径排序与加载，不预先在其他拦截器附加 Cookie
      options.headers[HttpHeaders.cookieHeader] = await _cookieManager
          .loadCookies(options);
      final cookieHeader = options.headers[HttpHeaders.cookieHeader] as String?;
      final hasIdentityCookie =
          cookieHeader
              ?.split(';')
              .any(
                (value) =>
                    value.trim().startsWith('$_identityCookieName=') &&
                    value.trim().length > _identityCookieName.length + 1,
              ) ??
          false;
      if (!_cookieRejected &&
          hasIdentityCookie &&
          options.extra[_tokenRetryKey] != true) {
        options.extra[_requestModeKey] = 'cookie';
      } else {
        // token 请求移除全部 Cookie，CookieManager 下次仍可读取正式 CookieJar
        options.headers.removeWhere(
          (key, _) => key.toLowerCase() == HttpHeaders.cookieHeader,
        );
        await _loadAccessToken();
        options.extra[_requestModeKey] = 'none';
        if (_accessToken != null && !_tokenRejected) {
          options.headers['x-access-token'] = _accessToken;
          options.extra[_requestModeKey] = 'token';
        }
      }
      if (generation != _sessionGeneration || _credentialsBlocked) {
        throw const ApiException(message: '登录状态已变更，请重试');
      }
      // API 重定向交由调用方视为异常，防止自定义凭据头被转交其他地址
      options.followRedirects = false;
      handler.next(options);
    } catch (error) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error is ApiException
              ? error
              : const ApiException(message: '读取登录凭据失败'),
        ),
      );
    }
  }

  /// 在当前会话的凭据队列内保存响应 Cookie，旧响应不能恢复已退出的会话
  ///
  /// [response] 可能携带 Set-Cookie 的 Tinygrail API 响应
  Future<void> _saveResponseCookies(Response<dynamic> response) async {
    final options = response.requestOptions;
    if (!_isTinygrailApi(options.uri)) return;
    await _enqueueCredentialWrite(() async {
      if (options.extra[_requestGenerationKey] != _sessionGeneration ||
          _credentialsBlocked) {
        throw const ApiException(message: '登录状态已变更，请重试');
      }
      await _cookieManager.saveCookies(response);
    });
  }

  /// 识别当前用户资产接口明确的未授权业务响应
  ///
  /// [response] 服务器响应，指定用户资料缺失不属于当前用户鉴权失败
  bool _isAuthFailure(Response<dynamic> response) {
    if (response.statusCode == 401) return true;
    final data = response.data;
    return response.requestOptions.uri.path == '/api/chara/user/assets' &&
        data is Map &&
        data['State'] == 1 &&
        data['Message'] == '此用户暂无资产信息。' &&
        data['Value'] == null;
  }

  /// 处理已确认的 Cookie 鉴权失败，并在同一请求名额内回退一次
  ///
  /// [options] 首次请求配置
  Future<Response<dynamic>?> _retryWithToken(RequestOptions options) async {
    if (options.extra[_requestGenerationKey] != _sessionGeneration ||
        _credentialsBlocked ||
        !_isTinygrailApi(options.uri)) {
      return null;
    }
    if (options.extra[_requestModeKey] == 'token') {
      _tokenRejected = true;
      return null;
    }
    if (options.extra[_requestModeKey] != 'cookie' ||
        options.extra[_tokenRetryKey] == true) {
      return null;
    }
    _cookieRejected = true;
    await _loadAccessToken();
    if (options.extra[_requestGenerationKey] != _sessionGeneration ||
        _credentialsBlocked ||
        _accessToken == null ||
        _tokenRejected) {
      return null;
    }
    final headers = Map<String, dynamic>.from(options.headers)
      ..removeWhere(
        (key, _) =>
            key.toLowerCase() == HttpHeaders.cookieHeader ||
            key.toLowerCase() == 'x-access-token',
      );
    // 复用请求体、取消令牌和会话标记，不重新占用共享客户端的并发名额
    return _dio.fetch<dynamic>(
      options.copyWith(
        headers: headers,
        extra: {...options.extra, _tokenRetryKey: true},
      ),
    );
  }

  /// 处理 HTTP 成功响应中的明确未授权状态，其他业务失败不重试
  ///
  /// [response] 当前响应
  /// [handler] Dio 响应拦截处理器
  void _handleAuthResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    try {
      await _saveResponseCookies(response);
      final retry = _isAuthFailure(response)
          ? await _retryWithToken(response.requestOptions)
          : null;
      handler.next(retry ?? response);
    } on DioException catch (error) {
      handler.reject(error);
    } catch (error) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          error: error is ApiException
              ? error
              : const ApiException(message: '保存登录状态失败'),
        ),
      );
    }
  }

  /// 只在 HTTP 401 时回退，403、超时、断网和其他错误不重试
  ///
  /// [error] 当前请求异常
  /// [handler] Dio 异常拦截处理器
  void _handleAuthError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      if (error.response case final response?) {
        await _saveResponseCookies(response);
      }
      if (error.response?.statusCode != 401) {
        handler.next(error);
        return;
      }
      final retry = await _retryWithToken(error.requestOptions);
      if (retry == null) {
        handler.next(error);
      } else {
        handler.resolve(retry);
      }
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (failure) {
      handler.next(
        DioException(
          requestOptions: error.requestOptions,
          error: failure is ApiException
              ? failure
              : const ApiException(message: '恢复登录状态失败'),
        ),
      );
    }
  }

  /// 激活新授权对应的会话代际
  void _activateSessionGeneration() {
    if (_isSessionGenerationActive) return;
    _sessionGeneration += 1;
    _isSessionGenerationActive = true;
  }

  /// 废弃当前授权对应的会话代际
  ///
  /// [advanceBoundary] 是否在已废弃状态下继续推进代际
  void _invalidateSessionGeneration({bool advanceBoundary = false}) {
    if (!_isSessionGenerationActive && !advanceBoundary) return;
    _sessionGeneration += 1;
    _isSessionGenerationActive = false;
  }
}
