import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/app/bootstrap.dart';

import 'app_router_bangumi_routes.dart';
import 'app_router_chara_routes.dart';
import 'app_router_main_routes.dart';
import 'app_router_temple_routes.dart';
import 'app_router_user_routes.dart';

/// 创建应用路由表
///
/// [dependencies] 应用依赖集合
/// [rootNavigatorKey] 根导航器标识
/// [onThemeModeChanged] 应用主题模式变化回调
GoRouter createAppRouter({
  required AppDependencies dependencies,
  GlobalKey<NavigatorState>? rootNavigatorKey,
  ValueChanged<ThemeMode>? onThemeModeChanged,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ...buildMainRoutes(dependencies),
      ...buildCharaRoutes(dependencies),
      ...buildBangumiRoutes(dependencies),
      ...buildTempleRoutes(dependencies),
      ...buildUserRoutes(dependencies, onThemeModeChanged),
    ],
  );
}
