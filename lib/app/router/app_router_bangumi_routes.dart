import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/app/bootstrap.dart';
import 'package:magrail_app/features/bangumi/next/next_bangumi_subject_navigation.dart';
import 'package:magrail_app/features/bangumi/next/view/next_bangumi_subject_page.dart';

/// 构建 Bangumi 业务路由
///
/// [dependencies] 应用依赖集合
List<RouteBase> buildBangumiRoutes(AppDependencies dependencies) {
  return [
    GoRoute(
      name: nextBangumiSubjectRouteName,
      path: '/next-bangumi-subject',
      pageBuilder: (context, state) {
        final queryParameters = state.uri.queryParameters;

        return MaterialPage(
          key: state.pageKey,
          child: NextBangumiSubjectPage(
            subjectId: int.tryParse(
                  queryParameters['subjectId'] ?? '',
                ) ??
                0,
            characterRepository: dependencies.repositories.characterDetail,
            templeRepository: dependencies.repositories.temple,
            magicRepository: dependencies.repositories.templeAssetMagic,
            oosRepository: dependencies.repositories.oos,
            userRepository: dependencies.repositories.user,
          ),
        );
      },
    ),
  ];
}
