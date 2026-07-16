import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';

const _characterDetailRouteName = 'characterDetail';

/// 打开角色详情页
///
/// [context] 当前组件树上下文
/// [characterId] 角色 ID
/// [name] 角色名称
/// [avatarUrl] 角色头像地址
/// [avatarHeroTag] 入口头像转场标识
void openCharacterDetail(
  BuildContext context, {
  required int characterId,
  String? name,
  String? avatarUrl,
  String? avatarHeroTag,
}) {
  final resolvedName =
      TinygrailFormatters.decodeHtmlEntities(name ?? '').trim();
  final trimmedAvatarUrl = avatarUrl?.trim();
  final resolvedAvatarUrl = trimmedAvatarUrl == null || trimmedAvatarUrl.isEmpty
      ? ''
      : TinygrailAssetUrls.normalizeAvatar(trimmedAvatarUrl);
  final resolvedAvatarHeroTag = avatarHeroTag?.trim() ?? '';
  final queryParameters = {
    'characterId': characterId.toString(),
    if (resolvedName.isNotEmpty) 'name': resolvedName,
    if (resolvedAvatarUrl.isNotEmpty) 'avatarUrl': resolvedAvatarUrl,
    if (resolvedAvatarUrl.isNotEmpty && resolvedAvatarHeroTag.isNotEmpty)
      'avatarHeroTag': resolvedAvatarHeroTag,
  };
  final router = GoRouter.of(context);
  final currentRouteName = _currentRouteName(router);

  // 当前已在角色详情页时复用页面 Key，由页面内部切换角色并避免新页面动画
  if (currentRouteName == _characterDetailRouteName) {
    if (_currentCharacterDetailId(router) == characterId &&
        resolvedName.isEmpty &&
        resolvedAvatarUrl.isEmpty) {
      return;
    }

    context.replaceNamed(
      _characterDetailRouteName,
      queryParameters: queryParameters,
    );
    return;
  }

  final baseConfiguration = _removeExistingCharacterDetail(
    router.routerDelegate.currentConfiguration,
  );
  if (baseConfiguration != null) {
    final location = router.namedLocation(
      _characterDetailRouteName,
      queryParameters: queryParameters,
    );
    router.routeInformationProvider.push<void>(
      location,
      base: baseConfiguration,
    );
    return;
  }

  context.pushNamed(
    _characterDetailRouteName,
    queryParameters: queryParameters,
  );
}

/// 移除当前路由栈中已有的角色详情页
///
/// [configuration] 当前 go_router 路由栈配置
RouteMatchList? _removeExistingCharacterDetail(RouteMatchList configuration) {
  final nextMatches = <RouteMatchBase>[
    for (final match in configuration.matches)
      if (!_isCharacterDetailMatch(match)) match,
  ];

  if (nextMatches.length == configuration.matches.length) {
    return null;
  }

  return RouteMatchList(
    matches: nextMatches,
    uri: configuration.uri,
    extra: configuration.extra,
    error: configuration.error,
    pathParameters: configuration.pathParameters,
  );
}

/// 判断路由匹配是否为角色详情页
///
/// [match] go_router 路由匹配项
bool _isCharacterDetailMatch(RouteMatchBase match) {
  return match is RouteMatch && match.route.name == _characterDetailRouteName;
}

/// 读取当前路由栈栈顶名称
///
/// [router] GoRouter 实例
String? _currentRouteName(GoRouter router) {
  final configuration = router.routerDelegate.currentConfiguration;
  if (configuration.matches.isEmpty) {
    return null;
  }

  final currentMatch = configuration.matches.last;
  if (currentMatch is RouteMatch) {
    return currentMatch.route.name;
  }

  return null;
}

/// 读取当前角色详情页角色 ID
///
/// [router] GoRouter 实例
int? _currentCharacterDetailId(GoRouter router) {
  final queryParameters =
      router.routerDelegate.currentConfiguration.uri.queryParameters;
  final value = queryParameters['characterId'];
  return int.tryParse(value ?? '');
}
