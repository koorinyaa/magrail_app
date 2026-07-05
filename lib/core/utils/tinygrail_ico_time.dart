import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';

/// ICO 剩余时间不足 24 小时时使用的警示色
const Color tinygrailIcoEndingSoonColor = Color(0xFFF5A524);

// 剩余时间警示阈值
const Duration _tinygrailIcoEndingSoonThreshold = Duration(hours: 24);

/// 解析 ICO 剩余结束时间展示
///
/// [value] 接口返回时间文本
({String text, Color? accentColor}) resolveTinygrailIcoRemainingTime(
  String value,
) {
  final text = value.trim();
  if (text.isEmpty) {
    return (text: '--', accentColor: null);
  }

  final endTime = TinygrailFormatters.parseServerFutureTime(text);
  if (endTime == null) {
    return (text: text, accentColor: null);
  }

  final difference = endTime.toLocal().difference(DateTime.now());
  if (difference.inSeconds <= 0) {
    return (text: '已结束', accentColor: null);
  }

  if (difference.inHours < 1) {
    return (text: '即将结束', accentColor: tinygrailIcoEndingSoonColor);
  }

  if (difference < _tinygrailIcoEndingSoonThreshold) {
    return (
      text: '剩余${difference.inHours}小时',
      accentColor: tinygrailIcoEndingSoonColor,
    );
  }

  if (difference.inDays < 30) {
    return (text: '剩余${difference.inDays}天', accentColor: null);
  }

  if (difference.inDays < 365) {
    final months = difference.inDays ~/ 30;
    return (text: '剩余$months个月', accentColor: null);
  }

  final years = difference.inDays ~/ 365;
  return (text: '剩余$years年', accentColor: null);
}
