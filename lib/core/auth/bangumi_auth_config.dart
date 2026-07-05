import 'bangumi_mirror_config.dart';
import 'tinygrail_site_config.dart';

/// Bangumi OAuth 配置
class BangumiAuthConfig {
  /// 禁用实例化
  const BangumiAuthConfig._();

  static const String _defaultAuthorizeHost = 'bgm.tv';

  // Tinygrail OAuth client：授权后由 Tinygrail callback 下发会话 Cookie
  static const String _clientId = 'bgm2525b0e4c7d93fec';

  /// 创建 Bangumi OAuth 授权地址
  ///
  /// [useMirror] 是否使用 Bangumi 镜像域名
  /// [mirrorHost] Bangumi 镜像域名
  static Uri authorizeUri({
    required bool useMirror,
    String? mirrorHost,
  }) {
    return Uri.https(
      useMirror
          ? BangumiMirrorConfig.resolveHost(mirrorHost)
          : _defaultAuthorizeHost,
      '/oauth/authorize',
      {
        'response_type': 'code',
        'client_id': _clientId,
        'redirect_uri': TinygrailSiteConfig.authCallbackUri.toString(),
      },
    );
  }

  /// 匹配 Tinygrail callback
  ///
  /// [uri] WebView 目标地址
  static bool isTinygrailCallback(Uri uri) {
    final callbackUri = TinygrailSiteConfig.authCallbackUri;
    final callbackPath = callbackUri.path;
    return uri.scheme == callbackUri.scheme &&
        uri.host.toLowerCase() == callbackUri.host &&
        (uri.path == callbackPath || uri.path == '$callbackPath/');
  }
}
