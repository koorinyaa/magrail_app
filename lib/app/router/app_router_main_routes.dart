import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/app/bootstrap.dart';
import 'package:magrail_app/features/main_navigation/view/main_navigation_page.dart';

/// 构建应用主导航路由
///
/// [dependencies] 应用依赖集合
List<RouteBase> buildMainRoutes(AppDependencies dependencies) {
  return [
    GoRoute(
      name: 'mainNavigation',
      path: '/',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: MainNavigationPage(
          authRepository: dependencies.authRepository,
          preferences: dependencies.preferences,
          topWeekRepository: dependencies.repositories.topWeek,
          rankingRepository: dependencies.repositories.ranking,
          auctionRepository: dependencies.repositories.auction,
          characterDetailRepository:
              dependencies.repositories.characterDetail,
          towerRepository: dependencies.repositories.tower,
          icoCharacterRepository: dependencies.repositories.icoCharacter,
          stCharacterRepository: dependencies.repositories.stCharacter,
          characterRankRepository: dependencies.repositories.characterRank,
          templeRepository: dependencies.repositories.temple,
          templeAssetMagicRepository:
              dependencies.repositories.templeAssetMagic,
          oosRepository: dependencies.repositories.oos,
          userRepository: dependencies.repositories.user,
          scratchTicketRepository: dependencies.repositories.scratchTicket,
        ),
      ),
    ),
  ];
}
