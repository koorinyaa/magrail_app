import 'package:dio/dio.dart';
import 'package:magrail_app/core/network/api_exception.dart';

/// 将异常转换为适合用户阅读的中文提示
///
/// [error] 捕获到的异常
/// [fallback] 默认提示
String resolveUserErrorMessage(Object? error, {required String fallback}) {
  if (error == null) {
    return fallback;
  }

  if (error is ApiException) {
    return _cleanMessage(error.message, fallback: fallback);
  }

  if (error is DioException) {
    return _messageForDioException(error, fallback: fallback);
  }

  if (error is StateError) {
    return _cleanMessage(error.message, fallback: fallback);
  }

  if (error is FormatException) {
    return fallback;
  }

  return _cleanMessage(error.toString(), fallback: fallback);
}

/// 转换 Dio 异常文案
///
/// [error] Dio 异常
/// [fallback] 默认提示
String _messageForDioException(
  DioException error, {
  required String fallback,
}) {
  return switch (error.type) {
    DioExceptionType.connectionTimeout => '连接服务器超时，请稍后重试',
    DioExceptionType.sendTimeout => '请求发送超时，请稍后重试',
    DioExceptionType.receiveTimeout => '服务器响应超时，请稍后重试',
    DioExceptionType.badCertificate => '服务器证书校验失败',
    DioExceptionType.badResponse => _messageForStatusCode(
        error.response?.statusCode,
        fallback: fallback,
      ),
    DioExceptionType.cancel => '请求已取消',
    DioExceptionType.connectionError => '网络连接失败，请检查网络后重试',
    DioExceptionType.unknown => fallback,
  };
}

/// 转换 HTTP 状态码文案
///
/// [statusCode] HTTP 状态码
/// [fallback] 默认提示
String _messageForStatusCode(int? statusCode, {required String fallback}) {
  if (statusCode == null) {
    return fallback;
  }

  return switch (statusCode) {
    401 || 403 => '登录已过期，请重新授权',
    404 => '请求的内容不存在',
    429 => '请求过于频繁，请稍后重试',
    >= 500 => '服务器暂时不可用，请稍后重试',
    _ => fallback,
  };
}

/// 清理异常文本
///
/// [message] 原始异常文本
/// [fallback] 默认提示
String _cleanMessage(String message, {required String fallback}) {
  var text = message.trim();
  if (text.isEmpty) {
    return fallback;
  }

  for (final prefix in _exceptionPrefixes) {
    if (text.startsWith(prefix)) {
      text = text.substring(prefix.length).trim();
      break;
    }
  }

  if (text.isEmpty) {
    return fallback;
  }

  final lowerText = text.toLowerCase();
  if (_looksLikeNetworkError(lowerText)) {
    return '网络连接失败，请检查网络后重试';
  }

  if (_looksLikeTechnicalError(text, lowerText)) {
    return fallback;
  }

  return text;
}

const List<String> _exceptionPrefixes = [
  'Exception: ',
  'Bad state: ',
  'StateError: ',
  'FormatException: ',
];

/// 判断是否为常见网络异常文本
///
/// [lowerText] 小写异常文本
bool _looksLikeNetworkError(String lowerText) {
  return lowerText.contains('socketexception') ||
      lowerText.contains('handshakeexception') ||
      lowerText.contains('httpexception') ||
      lowerText.contains('clientexception') ||
      lowerText.contains('failed host lookup') ||
      lowerText.contains('connection refused') ||
      lowerText.contains('connection reset') ||
      lowerText.contains('connection timed out') ||
      lowerText.contains('network is unreachable') ||
      lowerText.contains('xmlhttprequest error');
}

/// 判断是否为不适合直接展示的技术异常文本
///
/// [text] 原始异常文本
/// [lowerText] 小写异常文本
bool _looksLikeTechnicalError(String text, String lowerText) {
  return text.contains('\n') ||
      text.contains('package:') ||
      text.contains('Instance of') ||
      lowerText.contains('dioexception') ||
      lowerText.contains('apiexception') ||
      lowerText.contains('stack trace') ||
      lowerText.contains('null check operator') ||
      lowerText.contains('nosuchmethoderror') ||
      lowerText.contains('typeerror');
}
