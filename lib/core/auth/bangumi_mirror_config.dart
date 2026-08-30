/// Bangumi 镜像域名配置
class BangumiMirrorConfig {
  /// 禁用实例化
  const BangumiMirrorConfig._();

  /// 默认 Bangumi 镜像域名
  static const String defaultHost = 'bangumi.pro';

  // 仅接受含顶级域名且每段长度符合 DNS 限制的主机名
  static final RegExp _hostPattern = RegExp(
    r'^(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+'
    r'[a-z](?:[a-z0-9-]{0,61}[a-z0-9])?$',
    caseSensitive: false,
  );

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

    final uriText = value.startsWith('//')
        ? 'https:$value'
        : value.contains('://')
        ? value
        : 'https://$value';
    final uri = Uri.tryParse(uriText);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort) {
      return null;
    }

    final normalizedHost = uri.host.trim().toLowerCase();
    if (!_hostPattern.hasMatch(normalizedHost)) {
      return null;
    }

    return normalizedHost;
  }
}
