import 'dart:convert';

import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Tinygrail API 客户端
class ApiClient {
  /// 创建 API 客户端
  ///
  /// [_dio] Dio 实例
  const ApiClient(this._dio);

  final Dio _dio;

  /// GET JSON 请求
  ///
  /// [path] API 路径
  /// [queryParameters] URL 查询参数
  Future<T> getJson<T>(
    String path, {
    Map<String, Object?>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// POST JSON 请求
  ///
  /// [path] API 路径
  /// [data] 请求体数据，会在发送前序列化为 JSON
  /// [queryParameters] URL 查询参数
  Future<T> postJson<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data == null ? null : jsonEncode(data),
        options: Options(contentType: Headers.jsonContentType),
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
