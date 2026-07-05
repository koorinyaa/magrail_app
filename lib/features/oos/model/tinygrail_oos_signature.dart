import 'package:magrail_app/core/network/tinygrail_response.dart';

/// Tinygrail OOS 上传签名
final class TinygrailOosSignature {
  /// 创建 Tinygrail OOS 上传签名
  ///
  /// [key] OOS 授权 Key
  /// [sign] OOS 授权签名
  /// [date] OOS 请求时间
  const TinygrailOosSignature({
    required this.key,
    required this.sign,
    required this.date,
  });

  /// OOS 授权 Key
  final String key;

  /// OOS 授权签名
  final String sign;

  /// OOS 请求时间
  final String date;

  /// 从 JSON 创建 Tinygrail OOS 上传签名
  ///
  /// [json] 原始响应 JSON
  factory TinygrailOosSignature.fromJson(Map<String, Object?> json) {
    return TinygrailOosSignature(
      key: TinygrailResponseParser.asString(json['Key']),
      sign: TinygrailResponseParser.asString(json['Sign']),
      date: TinygrailResponseParser.asString(json['Date']),
    );
  }
}
