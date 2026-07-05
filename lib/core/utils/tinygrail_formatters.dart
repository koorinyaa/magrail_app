import 'package:intl/intl.dart';

/// Tinygrail 文本与时间格式化工具
final class TinygrailFormatters {
  /// 禁止创建 Tinygrail 格式化工具实例
  const TinygrailFormatters._();

  // Tinygrail 接口中无时区时间按服务器 UTC+8 本地时间处理
  static const int _serverOffsetMinutes = -8 * 60;

  // 超过 30 天后显示完整日期，近期记录继续使用相对天数
  static const int _absoluteDateThresholdDays = 30;

  /// 解码 Tinygrail 文本中的常见 HTML 实体
  ///
  /// [value] 原始文本
  static String decodeHtmlEntities(String value) {
    return value
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  /// 格式化 Tinygrail 服务端时间为相对时间文案
  ///
  /// [value] 服务端时间文本
  static String relativeTime(String value) {
    final parsed = parseServerTime(value);
    if (parsed == null) {
      return value;
    }

    final now = DateTime.now();
    final localTime = parsed.toLocal();
    final difference = now.difference(localTime);

    if (difference.inMinutes < -1) {
      return DateFormat('MM/dd HH:mm').format(localTime);
    }

    if (difference.inSeconds < 60) {
      return '刚刚';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    }

    if (difference.inDays < _absoluteDateThresholdDays) {
      return '${difference.inDays}天前';
    }

    return DateFormat('yyyy/MM/dd').format(localTime);
  }

  /// 格式化 Tinygrail 服务端时间为短相对时间
  ///
  /// [value] 服务端时间文本
  static String shortRelativeTime(String value) {
    final parsed = parseServerTime(value);
    if (parsed == null) {
      return value;
    }

    final difference = DateTime.now().difference(parsed.toLocal());

    if (difference.inDays > 365) {
      return '1年前';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    }

    if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    }

    if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    }

    return '${difference.inSeconds}秒前';
  }

  /// 格式化 Tinygrail 服务端时间为完整本地时间
  ///
  /// [value] 服务端时间文本
  static String dateTime(String value) {
    final parsed = parseServerTime(value);
    if (parsed == null) {
      return value;
    }

    return DateFormat('yyyy-MM-dd HH:mm:ss').format(parsed.toLocal());
  }

  /// 解析 Tinygrail 服务端时间
  ///
  /// [value] 服务端时间文本
  static DateTime? parseServerTime(String value) {
    return _parseServerTime(
      value,
      fallbackWhenCorrectedFuture: true,
    );
  }

  /// 解析 Tinygrail 服务端未来业务时间
  ///
  /// [value] 服务端时间文本
  static DateTime? parseServerFutureTime(String value) {
    return _parseServerTime(
      value,
      fallbackWhenCorrectedFuture: false,
    );
  }

  /// 解析 Tinygrail 服务端时间原始值
  ///
  /// [value] 服务端时间文本
  /// [fallbackWhenCorrectedFuture] 修正结果在未来时是否回退到设备本地解析
  static DateTime? _parseServerTime(
    String value, {
    required bool fallbackWhenCorrectedFuture,
  }) {
    final text = value.trim();
    if (text.isEmpty) {
      return null;
    }

    final timestamp = RegExp(r'/Date\((\d+)').firstMatch(text);
    if (timestamp != null) {
      final milliseconds = int.tryParse(timestamp.group(1)!);
      if (milliseconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(milliseconds);
      }
    }

    final parsed = DateTime.tryParse(text);
    if (parsed == null) {
      return null;
    }

    if (RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(text)) {
      // SignalR 日志带有明确时区，不能再按服务器本地时间二次修正
      return parsed;
    }

    final localOffsetMinutes = -DateTime.now().timeZoneOffset.inMinutes;
    final corrected = parsed.subtract(
      Duration(minutes: localOffsetMinutes - _serverOffsetMinutes),
    );

    if (!fallbackWhenCorrectedFuture ||
        !corrected
            .toLocal()
            .isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      return corrected;
    }

    final serverLocalText = text.replaceFirst(
      RegExp(r'(Z|[+-]\d{2}:?\d{2})$'),
      '',
    );
    return DateTime.tryParse(serverLocalText) ?? corrected;
  }
}
