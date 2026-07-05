/// Tinygrail 站点配置
class TinygrailSiteConfig {
  /// 禁用实例化
  const TinygrailSiteConfig._();

  /// Tinygrail 站点根地址
  static final Uri siteUri = Uri.parse('https://tinygrail.com/');

  /// Tinygrail API 根地址
  static final Uri apiBaseUri = Uri.parse('https://tinygrail.com/api/');

  /// Tinygrail API 根地址字符串
  static String get apiBaseUrl => apiBaseUri.toString();

  /// Tinygrail 授权回调地址
  static final Uri authCallbackUri = Uri.parse(
    'https://tinygrail.com/api/account/callback',
  );
}
