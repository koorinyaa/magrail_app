import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用内部复制与剪切板内容摘要
abstract final class AppClipboard {
  static final _internalCopies = StreamController<String>.broadcast(sync: true);

  /// 应用内部复制成功后的内容摘要，用于使旧查询和待展示结果失效
  static Stream<String> get internalCopies => _internalCopies.stream;

  /// 计算与读取规则一致的内容摘要，不保留剪切板原文
  ///
  /// [text] 复制或读取的文本
  static String fingerprint(String text) {
    return sha256.convert(utf8.encode(text.trim())).toString();
  }

  /// 复制文本并持久化已处理状态，记录失败不影响复制成功
  ///
  /// [text] 写入系统剪切板的文本
  static Future<void> copyText(String text) async {
    AppPreferences? preferences;
    try {
      preferences = AppPreferences(await SharedPreferences.getInstance());
    } catch (_) {
      // 存储不可用时仍允许复制，当前运行期间通过复制通知避免重复提示
    }
    try {
      await Clipboard.setData(ClipboardData(text: text));
      final digest = fingerprint(text);
      final saving = preferences?.saveClipboardDetailState(
        fingerprint: digest,
        isHandled: true,
      );
      _internalCopies.add(digest);
      try {
        await saving;
      } catch (_) {
        // 系统剪切板已写入，记录失败不将复制结果改为失败
      }
    } finally {
      preferences?.dispose();
    }
  }
}
