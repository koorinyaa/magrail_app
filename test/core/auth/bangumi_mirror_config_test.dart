import 'package:flutter_test/flutter_test.dart';
import 'package:magrail_app/core/auth/bangumi_auth_config.dart';
import 'package:magrail_app/core/auth/bangumi_mirror_config.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';

/// 验证 Bangumi 镜像默认值、授权主机、输入边界与子域替换
void main() {
  tearDown(() {
    TinygrailAssetUrls.configureBangumiMirror(
      useMirror: false,
      mirrorHost: BangumiMirrorConfig.defaultHost,
    );
  });

  test('默认镜像使用 bangumi.pro', () {
    expect(BangumiMirrorConfig.defaultHost, 'bangumi.pro');
    expect(BangumiMirrorConfig.resolveHost(null), 'bangumi.pro');
    expect(BangumiMirrorConfig.resolveHost(''), 'bangumi.pro');
  });

  test('OAuth 授权地址按镜像开关选择主机', () {
    final officialUri = BangumiAuthConfig.authorizeUri(useMirror: false);
    final defaultMirrorUri = BangumiAuthConfig.authorizeUri(useMirror: true);
    final customMirrorUri = BangumiAuthConfig.authorizeUri(
      useMirror: true,
      mirrorHost: 'mirror.example.com',
    );

    expect(officialUri.host, 'bgm.tv');
    expect(defaultMirrorUri.host, 'bangumi.pro');
    expect(customMirrorUri.host, 'mirror.example.com');
    expect(customMirrorUri.path, '/oauth/authorize');
  });

  test('镜像输入统一提取小写主机名', () {
    expect(BangumiMirrorConfig.normalizeHost('BANGUMI.PRO'), 'bangumi.pro');
    expect(
      BangumiMirrorConfig.normalizeHost(
        'https://Mirror.Example.com/oauth/authorize',
      ),
      'mirror.example.com',
    );
    expect(
      BangumiMirrorConfig.normalizeHost('//Mirror.Example.com/path'),
      'mirror.example.com',
    );
  });

  test('镜像输入拒绝非域名与不支持的地址形式', () {
    expect(BangumiMirrorConfig.normalizeHost('not a host'), isNull);
    expect(BangumiMirrorConfig.normalizeHost('localhost'), isNull);
    expect(
      BangumiMirrorConfig.normalizeHost('ftp://mirror.example.com'),
      isNull,
    );
    expect(
      BangumiMirrorConfig.normalizeHost('mirror.example.com:8443'),
      isNull,
    );
  });

  test('自定义镜像同步替换 Bangumi 主域名与子域名', () {
    TinygrailAssetUrls.configureBangumiMirror(
      useMirror: true,
      mirrorHost: 'mirror.example.com',
    );

    expect(
      TinygrailAssetUrls.normalizeBangumiUrl('https://bgm.tv/subject/1'),
      'https://mirror.example.com/subject/1',
    );
    expect(
      TinygrailAssetUrls.normalizeBangumiUrl('https://next.bgm.tv/p1'),
      'https://next.mirror.example.com/p1',
    );
    expect(
      TinygrailAssetUrls.normalizeBangumiUrl(
        'https://lain.bgm.tv/pic/user/l/icon.jpg',
      ),
      'https://lain.mirror.example.com/pic/user/l/icon.jpg',
    );
  });
}
