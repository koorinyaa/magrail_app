import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/app/bootstrap.dart';
import 'package:magrail_app/features/temple/view/latest_link_page.dart';
import 'package:magrail_app/features/temple/view/latest_temple_page.dart';

/// 构建圣殿业务路由
///
/// [dependencies] 应用依赖集合
List<RouteBase> buildTempleRoutes(AppDependencies dependencies) {
  return [
    GoRoute(
      name: 'latestTemples',
      path: '/latest-temples',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: LatestTemplePage(
          repository: dependencies.repositories.temple,
          characterDetailRepository: dependencies.repositories.characterDetail,
          oosRepository: dependencies.repositories.oos,
          magicRepository: dependencies.repositories.templeAssetMagic,
          userRepository: dependencies.repositories.user,
        ),
      ),
    ),
    GoRoute(
      name: 'latestLinks',
      path: '/latest-links',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: LatestLinkPage(
          repository: dependencies.repositories.temple,
          characterDetailRepository: dependencies.repositories.characterDetail,
          oosRepository: dependencies.repositories.oos,
          magicRepository: dependencies.repositories.templeAssetMagic,
          userRepository: dependencies.repositories.user,
        ),
      ),
    ),
  ];
}
