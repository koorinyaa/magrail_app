import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/auth/tinygrail_site_config.dart';

/// 验证 Tinygrail 会话代际的退出与重新授权边界
void main() {
  test('退出后旧会话代际失效且重新授权不会恢复', () async {
    final cookieJar = CookieJar();
    final repository = TinygrailAuthRepository(
      dio: Dio(),
      cookieJar: cookieJar,
    );
    final oldCookie = Cookie(
      '.AspNetCore.Identity.Application',
      'old-session',
    )
      ..domain = TinygrailSiteConfig.siteUri.host
      ..path = '/';
    await cookieJar.saveFromResponse(
      TinygrailSiteConfig.siteUri,
      [oldCookie],
    );
    expect(await repository.hasTinygrailCookie(), isTrue);

    final oldGeneration = repository.captureSessionGeneration();
    expect(oldGeneration, isNotNull);

    final clearOperation = repository.clearSession();
    expect(
      repository.isSessionGenerationCurrent(oldGeneration!),
      isFalse,
    );
    await clearOperation;
    expect(repository.captureSessionGeneration(), isNull);

    final newCookie = Cookie(
      '.AspNetCore.Identity.Application',
      'new-session',
    )
      ..domain = TinygrailSiteConfig.siteUri.host
      ..path = '/';
    await cookieJar.saveFromResponse(
      TinygrailSiteConfig.siteUri,
      [newCookie],
    );
    final concurrentChecks = await Future.wait([
      repository.hasTinygrailCookie(),
      repository.hasTinygrailCookie(),
    ]);
    expect(concurrentChecks, everyElement(isTrue));

    final newGeneration = repository.captureSessionGeneration();
    expect(newGeneration, isNotNull);
    expect(newGeneration, isNot(oldGeneration));
    expect(repository.isSessionGenerationCurrent(oldGeneration), isFalse);
    expect(
      repository.isSessionGenerationCurrent(newGeneration!),
      isTrue,
    );
  });
}
