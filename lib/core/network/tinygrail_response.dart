/// Tinygrail 通用响应
///
/// [state] 接口状态码
/// [message] 接口消息
/// [value] 接口数据
class TinygrailResponse<T> {
  /// 创建 Tinygrail 通用响应
  ///
  /// [state] 接口状态码
  /// [message] 接口消息
  /// [value] 接口数据
  const TinygrailResponse({
    required this.state,
    required this.message,
    required this.value,
  });

  final int state;
  final String? message;
  final T? value;

  /// 是否请求成功
  bool get isSuccess => state == 0;

  /// 从 JSON 创建 Tinygrail 通用响应
  ///
  /// [json] 原始响应 JSON
  /// [fromJson] Value 字段转换函数
  factory TinygrailResponse.fromJson(
    Map<String, Object?> json,
    T? Function(Object? value) fromJson,
  ) {
    return TinygrailResponse(
      state: TinygrailResponseParser.asInt(json['State']),
      message: TinygrailResponseParser.asNullableString(json['Message']),
      value: fromJson(json['Value']),
    );
  }
}

/// Tinygrail 响应字段解析工具
class TinygrailResponseParser {
  /// 禁止创建解析工具实例
  const TinygrailResponseParser._();

  /// 转换整数值
  ///
  /// [value] 原始值
  static int asInt(Object? value) {
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

  /// 转换浮点值
  ///
  /// [value] 原始值
  static double asDouble(Object? value) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }

  /// 转换字符串值
  ///
  /// [value] 原始值
  static String asString(Object? value) {
    if (value is String) {
      return value;
    }

    return value?.toString() ?? '';
  }

  /// 转换可空字符串值
  ///
  /// [value] 原始值
  static String? asNullableString(Object? value) {
    if (value == null) {
      return null;
    }

    final resolved = asString(value);
    return resolved.isEmpty ? null : resolved;
  }

  /// 转换字符串键的 Map
  ///
  /// [value] 原始值
  static Map<String, Object?>? asObjectMap(Object? value) {
    if (value is! Map) {
      return null;
    }

    return value.map(
      (key, itemValue) => MapEntry(key.toString(), itemValue),
    );
  }

  /// 转换对象数组
  ///
  /// [value] 原始值
  /// [fromJson] 条目转换函数
  static List<T>? asObjectList<T>(
    Object? value,
    T Function(Map<String, Object?> json) fromJson,
  ) {
    if (value is! List) {
      return null;
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
}
