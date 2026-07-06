import 'package:dio/dio.dart';
import 'package:magrail_app/core/network/api_exception.dart';
import 'package:magrail_app/features/bot/model/bot_models.dart';

/// fuyuake bot 仓库
class BotRepository {
  /// 创建 fuyuake bot 仓库
  BotRepository()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            responseType: ResponseType.json,
          ),
        );

  static const _baseUrl = 'https://api.fuyuake.top/xsb/';

  final Dio _dio;

  /// 获取 bot 配置
  ///
  /// [token] fuyuake bot 授权 token
  Future<BotConfig> fetchConfig({required String token}) async {
    final data = await _postBotData(
      'bot/config',
      token: token,
      fallback: '获取 Bot 配置失败',
    );
    final map = _asStringKeyMap(data);
    if (map == null) {
      throw const ApiException(message: '获取 Bot 配置失败');
    }

    return BotConfig.fromJson(map);
  }

  /// 保存 bot 配置
  ///
  /// [token] fuyuake bot 授权 token
  /// [config] bot 配置数据
  Future<void> saveConfig({
    required String token,
    required BotConfig config,
  }) async {
    await _putBotData(
      'bot/config',
      token: token,
      data: _encodeFormFields(config.toFormFields()),
      fallback: '保存 Bot 配置失败',
    );
  }

  /// 取消 bot 授权
  ///
  /// [token] fuyuake bot 授权 token
  /// [userId] bot 归属用户 ID
  Future<void> revokeAuthorization({
    required String token,
    required String userId,
  }) async {
    await _postBotData(
      'bot/logout',
      token: token,
      data: _encodeFormFields([MapEntry('Name', userId)]),
      contentType: Headers.formUrlEncodedContentType,
      fallback: '取消 Bot 授权失败',
    );
  }

  /// 获取 bot 操作日志
  ///
  /// [token] fuyuake bot 授权 token
  /// [userId] bot 归属用户 ID
  Future<List<BotLogEntry>> fetchLogs({
    required String token,
    required String userId,
  }) async {
    final data = await _getBotData(
      'bot/$userId/log',
      token: token,
      fallback: '获取 Bot 日志失败',
    );

    return _asObjectList(data, BotLogEntry.fromJson);
  }

  /// 发送 bot GET 请求并解析 data
  ///
  /// [path] 接口路径
  /// [token] fuyuake bot 授权 token
  /// [queryParameters] 查询参数
  /// [fallback] 兜底错误文案
  Future<Object?> _getBotData(
    String path, {
    String? token,
    Map<String, Object?>? queryParameters,
    required String fallback,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: {
          if (queryParameters != null) ...queryParameters,
          if (token != null) 'token': token,
        },
      );
      return _parseBotResponse(response.data, fallback: fallback);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// 发送 bot POST 请求并解析 data
  ///
  /// [path] 接口路径
  /// [token] fuyuake bot 授权 token
  /// [data] 请求体
  /// [queryParameters] 查询参数
  /// [contentType] 请求体类型
  /// [fallback] 兜底错误文案
  Future<Object?> _postBotData(
    String path, {
    String? token,
    Object? data,
    Map<String, Object?>? queryParameters,
    String? contentType,
    required String fallback,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: {
          if (queryParameters != null) ...queryParameters,
          if (token != null) 'token': token,
        },
        options: contentType == null ? null : Options(contentType: contentType),
      );
      return _parseBotResponse(response.data, fallback: fallback);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// 发送 bot PUT 请求并解析 data
  ///
  /// [path] 接口路径
  /// [token] fuyuake bot 授权 token
  /// [data] 请求体
  /// [fallback] 兜底错误文案
  Future<Object?> _putBotData(
    String path, {
    required String token,
    required Object? data,
    required String fallback,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: {'token': token},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return _parseBotResponse(response.data, fallback: fallback);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// 解析 bot 通用响应
  ///
  /// [data] 原始响应
  /// [fallback] 兜底错误文案
  Object? _parseBotResponse(Object? data, {required String fallback}) {
    final map = _asStringKeyMap(data);
    if (map == null) {
      throw ApiException(message: fallback);
    }

    final code = _asInt(map['code']);
    if (code == 200) {
      return map['data'];
    }

    final message = _asString(map['msg']).trim();
    throw ApiException(message: message.isEmpty ? fallback : message);
  }
}

/// 编码重复 key 表单字段
///
/// [fields] 表单字段列表
String _encodeFormFields(List<MapEntry<String, String>> fields) {
  return fields
      .map(
        (entry) => '${Uri.encodeQueryComponent(entry.key)}='
            '${Uri.encodeQueryComponent(entry.value)}',
      )
      .join('&');
}

/// 转换字符串键 Map
///
/// [value] 原始值
Map<String, Object?>? _asStringKeyMap(Object? value) {
  if (value is! Map) {
    return null;
  }

  return value.map(
    (key, itemValue) => MapEntry(key.toString(), itemValue),
  );
}

/// 转换对象列表
///
/// [value] 原始值
/// [fromJson] 条目转换回调
List<T> _asObjectList<T>(
  Object? value,
  T Function(Map<String, Object?> json) fromJson,
) {
  if (value is! List) {
    return <T>[];
  }

  return value
      .whereType<Map<Object?, Object?>>()
      .map(
        (item) => fromJson(
          item.map(
            (key, itemValue) => MapEntry(key.toString(), itemValue),
          ),
        ),
      )
      .toList(growable: false);
}

/// 转换字符串值
///
/// [value] 原始值
String _asString(Object? value) {
  if (value is String) {
    return value;
  }

  return value?.toString() ?? '';
}

/// 转换整数值
///
/// [value] 原始值
int _asInt(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is double) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value) ?? 0;
  }

  return 0;
}
