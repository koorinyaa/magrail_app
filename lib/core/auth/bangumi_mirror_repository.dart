import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';

import 'bangumi_mirror_config.dart';

/// 镜像发布接口更新与默认域名缓存
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

  static const _configUrl = 'https://bangumi.wiki/api/v1/mirrors';
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

  /// 启动时读取镜像发布接口的有效缓存，来源不符或损坏时保持内置地址
  Future<void> loadCache() async {
    try {
      final data = jsonDecode(await _cacheFile.readAsString());
      // 只采用当前发布接口的缓存，避免其他来源的配置覆盖内置域名
      if (data is! Map<String, dynamic> || data['source'] != _configUrl) {
        return;
      }
      final host = _parseHost(data['defaultHost']);
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
      final host = _parseRemoteHost(response.data);
      if (host == null) {
        return;
      }
      await _cacheFile.parent.create(recursive: true);
      final pending = File('${_cacheFile.path}.pending');
      await pending.writeAsString(
        jsonEncode({'source': _configUrl, 'defaultHost': host}),
        flush: true,
      );
      // 写完后替换正式缓存，避免中断写入破坏上次可用地址
      await pending.rename(_cacheFile.path);
      _preferences.updateDefaultBangumiMirrorHost(host);
    } catch (_) {
      // 默认配置刷新失败静默保留缓存，不覆盖自定义选择或触发重试循环
    }
  }

  /// 优先选择推荐镜像，再按权重选择兼容当前服务域名的镜像
  ///
  /// [data] 镜像发布接口返回的 JSON
  String? _parseRemoteHost(dynamic data) {
    if (data is! Map<String, dynamic> || data['mirrors'] is! List) {
      return null;
    }

    String? selectedHost;
    var selectedRecommended = false;
    var selectedWeight = 0;
    for (final mirror in data['mirrors'] as List) {
      if (mirror is! Map<String, dynamic> ||
          mirror['recommended'] is! bool ||
          mirror['weight'] is! int ||
          mirror['services'] is! List) {
        continue;
      }
      final host = _parseHost(mirror['base']);
      if (host == null) {
        continue;
      }

      // 授权、Next API 和图片共用根域名替换，必须同时提供对应主机
      final requiredHosts = {
        'main': host,
        'next': 'next.$host',
        'lain': 'lain.$host',
      };
      final services = mirror['services'] as List;
      final supportsRequiredHosts = requiredHosts.entries.every(
        (entry) => services.any(
          (service) =>
              service is Map<String, dynamic> &&
              service['id'] == entry.key &&
              service['hosts'] is List &&
              (service['hosts'] as List).contains(entry.value),
        ),
      );
      if (!supportsRequiredHosts) {
        continue;
      }

      final recommended = mirror['recommended'] as bool;
      final weight = mirror['weight'] as int;
      // 推荐状态与权重相同时保留接口原有顺序
      if (selectedHost == null ||
          (recommended && !selectedRecommended) ||
          (recommended == selectedRecommended && weight > selectedWeight)) {
        selectedHost = host;
        selectedRecommended = recommended;
        selectedWeight = weight;
      }
    }
    return selectedHost;
  }

  /// 解析只含合法主机名的配置字段
  ///
  /// [value] 本地缓存或镜像发布接口中的域名字段
  String? _parseHost(dynamic value) {
    if (value is! String) {
      return null;
    }
    final normalized = value.trim().toLowerCase();
    final host = BangumiMirrorConfig.normalizeHost(normalized);
    return host == normalized ? host : null;
  }
}
