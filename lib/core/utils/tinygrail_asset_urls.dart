import 'package:magrail_app/core/auth/bangumi_mirror_config.dart';

/// Tinygrail 资源地址工具
class TinygrailAssetUrls {
  /// 禁用实例化
  const TinygrailAssetUrls._();

  static const String _cdnBaseUrl = 'https://tinygrail.mange.cn/';
  static const String _ossBaseUrl =
      'https://tinygrail.oss-cn-hangzhou.aliyuncs.com/';
  static const String _defaultAvatarUrl =
      'https://lain.bgm.tv/pic/user/l/icon.jpg';
  static const Set<String> _bangumiHosts = {
    'bgm.tv',
    'bangumi.tv',
    'chii.in',
  };

  static bool _useBangumiMirror = false;
  static String _bangumiMirrorHost = BangumiMirrorConfig.defaultHost;

  /// 配置 Bangumi 镜像域名
  ///
  /// [useMirror] 是否将 Bangumi 相关域名替换为镜像
  /// [mirrorHost] Bangumi 镜像域名
  static void configureBangumiMirror({
    required bool useMirror,
    String? mirrorHost,
  }) {
    _useBangumiMirror = useMirror;
    _bangumiMirrorHost = BangumiMirrorConfig.resolveHost(mirrorHost);
  }

  /// 当前 Bangumi 镜像域名
  static String get bangumiMirrorHost => _bangumiMirrorHost;

  /// 获取圣殿封面地址
  ///
  /// [cover] 原始封面地址
  /// [size] 封面尺寸
  static String getCover(
    String cover, {
    TinygrailCoverSize size = TinygrailCoverSize.large,
  }) {
    if (cover.isEmpty) {
      return '';
    }

    final normalizedCover = _normalizeHttps(cover);
    final width = size == TinygrailCoverSize.small ? '150' : '480';

    if (normalizedCover.contains('/crt/')) {
      if (size == TinygrailCoverSize.large &&
          normalizedCover.contains('/crt/m/')) {
        return _applyBangumiMirror(
          normalizedCover.replaceFirst('/m/', '/l/'),
        );
      }

      if (size == TinygrailCoverSize.small &&
          normalizedCover.contains('/crt/g/')) {
        return _applyBangumiMirror(
          normalizedCover.replaceFirst('/g/', '/m/'),
        );
      }

      return _applyBangumiMirror(normalizedCover);
    }

    if (normalizedCover.startsWith(_ossBaseUrl)) {
      return '$_cdnBaseUrl${normalizedCover.substring(_ossBaseUrl.length)}!w$width';
    }

    if (normalizedCover.startsWith('/cover')) {
      return '$_cdnBaseUrl$normalizedCover!w$width';
    }

    return _applyBangumiMirror(normalizedCover);
  }

  /// 获取大尺寸圣殿封面地址
  ///
  /// [cover] 原始封面地址
  static String getLargeCover(String cover) {
    return getCover(cover, size: TinygrailCoverSize.large);
  }

  /// 获取小尺寸圣殿封面地址
  ///
  /// [cover] 原始封面地址
  static String getSmallCover(String cover) {
    return getCover(cover, size: TinygrailCoverSize.small);
  }

  /// 标准化头像地址
  ///
  /// [avatar] 原始头像地址
  static String normalizeAvatar(String avatar) {
    if (avatar.isEmpty) {
      return _applyBangumiMirror(_defaultAvatarUrl);
    }

    if (avatar.startsWith(_ossBaseUrl)) {
      return '$_cdnBaseUrl${avatar.substring(_ossBaseUrl.length)}!w120';
    }

    if (avatar.startsWith('/avatar')) {
      return '$_cdnBaseUrl$avatar!w120';
    }

    return _applyBangumiMirror(_normalizeHttps(avatar));
  }

  /// 标准化 HTTPS 地址
  ///
  /// [url] 原始资源地址
  static String _normalizeHttps(String url) {
    if (url.startsWith('//')) {
      return 'https:$url';
    }

    return url.replaceFirst('http://', 'https://');
  }

  /// 替换 Bangumi 资源域名
  ///
  /// [url] 标准化后的资源地址
  static String _applyBangumiMirror(String url) {
    if (!_useBangumiMirror) {
      return url;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) {
      return url;
    }

    final mirrorHost = _resolveBangumiMirrorHost(uri.host);
    if (mirrorHost == null) {
      return url;
    }

    return uri.replace(host: mirrorHost).toString();
  }

  /// 解析 Bangumi 镜像域名
  ///
  /// [host] 资源地址域名
  static String? _resolveBangumiMirrorHost(String host) {
    final normalizedHost = host.toLowerCase();
    for (final domain in _bangumiHosts) {
      if (normalizedHost == domain) {
        return _bangumiMirrorHost;
      }

      final suffix = '.$domain';
      if (normalizedHost.endsWith(suffix)) {
        final subdomain = normalizedHost.substring(
          0,
          normalizedHost.length - suffix.length,
        );
        return '$subdomain.$_bangumiMirrorHost';
      }
    }

    return null;
  }
}

/// Tinygrail 圣殿封面尺寸
enum TinygrailCoverSize {
  /// 小尺寸 150px
  small,

  /// 大尺寸 480px
  large,
}
