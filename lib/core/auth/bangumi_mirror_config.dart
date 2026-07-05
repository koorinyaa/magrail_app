/// Bangumi 镜像域名配置
class BangumiMirrorConfig {
  /// 禁用实例化
  const BangumiMirrorConfig._();

  /// 默认 Bangumi 镜像域名
  static const String defaultHost = 'bangumi.lol';

  /// 解析可用的 Bangumi 镜像域名
  ///
  /// [host] 用户配置或默认配置中的镜像域名
  static String resolveHost(String? host) {
    final normalizedHost = normalizeHost(host);
    if (normalizedHost == null) {
      return defaultHost;
    }

    return normalizedHost;
  }

  /// 标准化 Bangumi 镜像域名
  ///
  /// [host] 用户输入或本地缓存中的镜像域名
  static String? normalizeHost(String? host) {
    final value = host?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    final uriText = value.startsWith('//') ? 'https:$value' : value;
    final uri = Uri.tryParse(uriText);
    if (uri != null && uri.host.trim().isNotEmpty) {
      return uri.host.trim().toLowerCase();
    }

    final withoutScheme = uriText.replaceFirst(RegExp(r'^https?://'), '');
    final resolvedHost = withoutScheme.split('/').first.trim();
    if (resolvedHost.isEmpty) {
      return null;
    }

    return resolvedHost.toLowerCase();
  }
}
