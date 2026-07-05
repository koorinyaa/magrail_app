/// GitHub Release 更新信息
final class AppReleaseInfo {
  /// 创建 GitHub Release 更新信息
  ///
  /// [tagName] Release 标签名
  /// [version] 用于版本比较和展示的版本号
  /// [name] Release 标题
  /// [body] Release 说明
  /// [htmlUrl] Release 页面地址
  /// [publishedAt] Release 发布时间
  const AppReleaseInfo({
    required this.tagName,
    required this.version,
    required this.name,
    required this.body,
    required this.htmlUrl,
    required this.publishedAt,
  });

  /// Release 标签名
  final String tagName;

  /// 用于版本比较和展示的版本号
  final String version;

  /// Release 标题
  final String name;

  /// Release 说明
  final String body;

  /// Release 页面地址
  final Uri htmlUrl;

  /// Release 发布时间
  final DateTime? publishedAt;
}
