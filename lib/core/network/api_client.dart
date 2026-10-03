import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Tinygrail API 客户端
class ApiClient {
  /// 创建 API 客户端
  ///
  /// [_dio] Dio 实例
  /// [readSessionGeneration] 读取排队请求所属的当前会话代际
  ApiClient(this._dio, {required this._readSessionGeneration}) {
    // 在 Cookie 拦截器完成读取后再次校验，避免旧请求使用后来切换的账号
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _validateRequestSession),
    );
  }

  // 服务端最多允许 10 个并发，业务请求限制为 8 个，为授权等直连请求留出余量
  static const int _maxConcurrentRequests = 8;
  // 仅共享客户端请求携带会话标记，授权直连请求继续使用现有流程
  static const String _sessionGenerationKey = 'magrailSessionGeneration';

  final Dio _dio;
  final int? Function() _readSessionGeneration;
  // GET 与 POST 共用名额，释放时优先交给已排队的请求
  final Queue<Completer<void>> _waitingRequests = Queue<Completer<void>>();
  int _activeRequestCount = 0;

  /// 排队发送 GET JSON 请求
  ///
  /// [path] API 路径
  /// [queryParameters] URL 查询参数
  /// [cancelToken] 本次 GET 请求的取消令牌
  Future<T> getJson<T>(
    String path, {
    Map<String, Object?>? queryParameters,
    CancelToken? cancelToken,
  }) {
    return _sendJson<T>(
      (sessionGeneration) => _dio.get<T>(
        path,
        options: Options(extra: {_sessionGenerationKey: sessionGeneration}),
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      ),
      cancelToken: cancelToken,
    );
  }

  /// 排队发送 POST JSON 请求
  ///
  /// [path] API 路径
  /// [data] 请求体数据，会在发送前序列化为 JSON
  /// [queryParameters] URL 查询参数
  Future<T> postJson<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
  }) async {
    final encodedData = data == null ? null : jsonEncode(data);
    return _sendJson<T>(
      (sessionGeneration) => _dio.post<T>(
        path,
        data: encodedData,
        options: Options(
          contentType: Headers.jsonContentType,
          extra: {_sessionGenerationKey: sessionGeneration},
        ),
        queryParameters: queryParameters,
      ),
    );
  }

  /// 取得请求名额并校验发送前的会话边界
  ///
  /// [request] 取得名额后发送的 JSON 请求
  /// [cancelToken] 排队与发送期间使用的取消令牌
  Future<T> _sendJson<T>(
    Future<Response<T>> Function(int? sessionGeneration) request, {
    CancelToken? cancelToken,
  }) async {
    final sessionGeneration = _readSessionGeneration();
    try {
      await _acquireRequestSlot(cancelToken);
      try {
        final cancelError = cancelToken?.cancelError;
        if (cancelError != null) throw cancelError;
        // 排队期间退出或切换会话后，不再携带新会话 Cookie 发送旧请求
        if (sessionGeneration != _readSessionGeneration()) {
          throw const ApiException(message: '登录状态已变更，请重试');
        }
        final response = await request(sessionGeneration);
        return response.data as T;
      } finally {
        // 成功、异常、超时及发送期间取消均需释放名额
        _releaseRequestSlot();
      }
    } on DioException catch (error) {
      final sessionError = error.error;
      if (sessionError is ApiException) throw sessionError;
      throw ApiException.fromDio(error);
    }
  }

  /// 在 Cookie 加载完成后阻止会话已变更的请求发送
  ///
  /// [options] 包含共享客户端会话标记的请求配置
  /// [handler] Dio 请求拦截处理器
  void _validateRequestSession(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (options.extra.containsKey(_sessionGenerationKey) &&
        options.extra[_sessionGenerationKey] != _readSessionGeneration()) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: const ApiException(message: '登录状态已变更，请重试'),
        ),
      );
      return;
    }
    handler.next(options);
  }

  /// 等待可用请求名额，排队取消时立即移出队列
  ///
  /// [cancelToken] 本次请求的取消令牌
  Future<void> _acquireRequestSlot(CancelToken? cancelToken) async {
    final cancelError = cancelToken?.cancelError;
    if (cancelError != null) throw cancelError;
    if (_activeRequestCount < _maxConcurrentRequests) {
      _activeRequestCount += 1;
      return;
    }

    final waiter = Completer<void>();
    _waitingRequests.addLast(waiter);
    unawaited(
      cancelToken?.whenCancel.then((error) {
        if (_waitingRequests.remove(waiter)) waiter.completeError(error);
      }),
    );
    await waiter.future;
  }

  /// 按排队顺序移交名额，无等待请求时减少在途计数
  void _releaseRequestSlot() {
    if (_waitingRequests.isNotEmpty) {
      _waitingRequests.removeFirst().complete();
    } else {
      _activeRequestCount -= 1;
    }
  }
}
