import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/oos/model/tinygrail_oos_signature.dart';

/// Tinygrail OOS 仓库
final class TinygrailOosRepository {
  /// 创建 Tinygrail OOS 仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  /// [dio] Dio 客户端
  const TinygrailOosRepository({
    required ApiClient apiClient,
    required Dio dio,
  })  : _apiClient = apiClient,
        _dio = dio;

  static const String _baseUrl =
      'https://tinygrail.oss-cn-hangzhou.aliyuncs.com';

  final ApiClient _apiClient;
  final Dio _dio;

  /// 构建 OOS 文件地址
  ///
  /// [path] OOS 目录
  /// [hash] 文件哈希
  /// [extension] 文件扩展名
  String buildUrl({
    required String path,
    required String hash,
    String extension = 'jpg',
  }) {
    return '$_baseUrl/$path/$hash.$extension';
  }

  /// 计算原始 data URL 哈希
  ///
  /// [bytes] 文件字节
  /// [contentType] 文件 MIME 类型
  String hashDataUrl({
    required Uint8List bytes,
    required String contentType,
  }) {
    final dataUrl = 'data:$contentType;base64,${base64Encode(bytes)}';
    return md5.convert(utf8.encode(dataUrl)).toString();
  }

  /// 获取 OOS 上传签名
  ///
  /// [path] OOS 目录
  /// [hash] 文件哈希
  /// [contentType] 文件 MIME 类型
  Future<TinygrailOosSignature> fetchSignature({
    required String path,
    required String hash,
    required String contentType,
  }) async {
    final encodedType = Uri.encodeComponent(contentType);
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/oss/sign/$path/$hash/$encodedType',
    );
    final response = TinygrailResponse<TinygrailOosSignature>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }

        return TinygrailOosSignature.fromJson(valueJson);
      },
    );

    if (!response.isSuccess || response.value == null) {
      throw StateError(response.message ?? '获取 OOS 签名失败');
    }

    return response.value!;
  }

  /// 上传文件字节到 OOS
  ///
  /// [url] OOS 文件地址
  /// [bytes] 文件字节
  /// [contentType] 文件 MIME 类型
  /// [signature] OOS 上传签名
  Future<void> uploadBytes({
    required String url,
    required Uint8List bytes,
    required String contentType,
    required TinygrailOosSignature signature,
  }) async {
    try {
      await _dio.putUri<void>(
        Uri.parse(url),
        data: bytes,
        options: Options(
          contentType: contentType,
          responseType: ResponseType.plain,
          headers: {
            'Authorization': 'OSS ${signature.key}:${signature.sign}',
            'x-oss-date': signature.date,
          },
        ),
      );
    } on DioException {
      throw StateError('上传文件失败');
    }
  }
}
