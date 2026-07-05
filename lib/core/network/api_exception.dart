import 'package:dio/dio.dart';

/// API 异常
class ApiException implements Exception {
  /// 创建 API 异常
  ///
  /// [message] 错误信息
  /// [statusCode] HTTP 状态码
  const ApiException({required this.message, this.statusCode});

  /// 适合展示或记录的错误文案
  final String message;

  /// HTTP 状态码
  final int? statusCode;

  /// 转换 Dio 异常
  ///
  /// [error] Dio 异常
  factory ApiException.fromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = switch (error.type) {
      DioExceptionType.connectionTimeout => '连接服务器超时，请稍后重试',
      DioExceptionType.sendTimeout => '请求发送超时，请稍后重试',
      DioExceptionType.receiveTimeout => '服务器响应超时，请稍后重试',
      DioExceptionType.badCertificate => '服务器证书校验失败',
      DioExceptionType.badResponse => _badResponseMessage(statusCode),
      DioExceptionType.cancel => '请求已取消',
      DioExceptionType.connectionError => '网络连接失败，请检查网络后重试',
      DioExceptionType.unknown => '网络请求失败，请稍后重试',
    };

    return ApiException(message: message, statusCode: statusCode);
  }

  /// 返回调试文本
  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// 转换 HTTP 失败状态文案
///
/// [statusCode] HTTP 状态码
String _badResponseMessage(int? statusCode) {
  if (statusCode == null) {
    return '服务器响应异常，请稍后重试';
  }

  return switch (statusCode) {
    401 || 403 => '登录已过期，请重新授权',
    404 => '请求的内容不存在',
    429 => '请求过于频繁，请稍后重试',
    >= 500 => '服务器暂时不可用，请稍后重试',
    _ => '服务器响应异常，请稍后重试',
  };
}
