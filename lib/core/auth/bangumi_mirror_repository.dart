import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';

import 'bangumi_mirror_config.dart';

/// 默认镜像配置下载与本地缓存
class BangumiMirrorRepository {
  /// 创建默认镜像配置仓库
  ///
  /// [preferences] 镜像选择与当前默认域名
  /// [cacheFile] 应用支持目录中的配置缓存
  BangumiMirrorRepository({
    required AppPreferences preferences,
    required File cacheFile,
  }) : _preferences = preferences,
       _cacheFile = cacheFile;

  static const _configUrl =
      'https://cdn.jsdelivr.net/gh/koorinyaa/magrail_app@main/config/bangumi_mirror.json';
  final AppPreferences _preferences;
  final File _cacheFile;
  // 独立客户端不携带业务 Cookie，启动配置请求最多等待短超时
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      responseType: ResponseType.json,
    ),
  );
  Future<void>? _refreshTask;

  /// 启动时读取有效缓存，缺失或损坏时保持内置地址
  Future<void> loadCache() async {
    try {
      final host = _parseHost(jsonDecode(await _cacheFile.readAsString()));
      if (host != null) {
        _preferences.updateDefaultBangumiMirrorHost(host);
      }
    } catch (_) {
      // 缓存不可用不阻断应用启动
    }
  }

  /// 异步刷新默认配置，并合并冷启动与前台恢复的并发请求
  Future<void> refresh() {
    return _refreshTask ??= _download().whenComplete(() => _refreshTask = null);
  }

  /// 下载并原子替换有效缓存，失败时保留最近有效配置
  Future<void> _download() async {
    try {
      final response = await _dio.get<dynamic>(_configUrl);
      final host = _parseHost(response.data);
      if (host == null) {
        return;
      }
      await _cacheFile.parent.create(recursive: true);
      final pending = File('${_cacheFile.path}.pending');
      await pending.writeAsString(
        jsonEncode({'defaultHost': host}),
        flush: true,
      );
      // 写完后替换正式缓存，避免中断写入破坏上次可用地址
      await pending.rename(_cacheFile.path);
      _preferences.updateDefaultBangumiMirrorHost(host);
    } catch (_) {
      // 默认配置刷新失败静默保留缓存，不覆盖自定义选择或触发重试循环
    }
  }

  /// 解析只含合法主机名的配置字段
  ///
  /// [data] 本地或远端 JSON 配置
  String? _parseHost(dynamic data) {
    if (data is! Map<String, dynamic> || data['defaultHost'] is! String) {
      return null;
    }
    final value = (data['defaultHost'] as String).trim().toLowerCase();
    final host = BangumiMirrorConfig.normalizeHost(value);
    return host == value ? host : null;
  }
}
