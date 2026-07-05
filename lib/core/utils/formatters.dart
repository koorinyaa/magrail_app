import 'package:intl/intl.dart';

/// 格式化工具
class Formatters {
  /// 禁用实例化
  const Formatters._();

  static const int _tenThousand = 10000;
  static const int _hundredMillion = 100000000;

  static final NumberFormat currency = NumberFormat('#,##0.##');
  static final NumberFormat compact = NumberFormat.compact();
  static final NumberFormat _compactNumber = NumberFormat('0.##');
  static final NumberFormat _groupedNumber = NumberFormat('#,##0.##');

  /// 格式化 Tinygrail 货币
  ///
  /// [value] 货币数值
  static String tinygrailCurrency(num value) {
    return '₵${_formatTruncatedDecimal(value, currency)}';
  }

  /// 格式化数字千分组
  ///
  /// [value] 原始数值
  static String groupedNumber(num value) {
    return _formatTruncatedDecimal(value, _groupedNumber);
  }

  /// 格式化纯数字小数并移除末尾零
  ///
  /// [value] 原始数值
  /// [fractionDigits] 最大小数位数
  static String plainDecimal(
    num value, {
    int fractionDigits = 2,
  }) {
    return value
        .toStringAsFixed(fractionDigits)
        .replaceFirst(RegExp(r'\.?0+$'), '');
  }

  /// 格式化 Tinygrail 数值缩略
  ///
  /// [value] 原始数值
  /// [prefix] 前缀文本
  static String tinygrailCompactValue(
    num value, {
    String prefix = '',
  }) {
    if (value.abs() < _tenThousand) {
      return '$prefix${_formatTruncatedDecimal(value, _compactNumber)}';
    }

    if (value.abs() >= _hundredMillion) {
      return '$prefix${_formatTruncatedUnit(value, _hundredMillion)}e';
    }

    return '$prefix${_formatTruncatedUnit(value, _tenThousand)}w';
  }

  /// 按单位截断并保留两位小数
  ///
  /// [value] 原始数值
  /// [unit] 缩略单位
  static String _formatTruncatedUnit(num value, int unit) {
    return _formatTruncatedDecimal(value / unit, _compactNumber);
  }

  /// 截断小数后按指定格式输出
  ///
  /// [value] 原始数值
  /// [format] 数字格式
  static String _formatTruncatedDecimal(num value, NumberFormat format) {
    return format.format(_truncateFraction(value, 2));
  }

  /// 按指定小数位截断数值
  ///
  /// [value] 原始数值
  /// [fractionDigits] 保留小数位数
  static num _truncateFraction(num value, int fractionDigits) {
    num scale = 1;
    for (var index = 0; index < fractionDigits; index += 1) {
      scale *= 10;
    }

    final truncatedValue = (value * scale).truncate() / scale;
    return truncatedValue == 0 ? 0 : truncatedValue;
  }
}
