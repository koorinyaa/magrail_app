import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/app/bootstrap.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_collections_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_collections_route_extra.dart';
import 'package:magrail_app/features/chara/detail/view/character_detail_board_page.dart';
import 'package:magrail_app/features/chara/detail/view/character_detail_links_page.dart';
import 'package:magrail_app/features/chara/detail/view/character_detail_page.dart';
import 'package:magrail_app/features/chara/detail/view/character_detail_temples_page.dart';
import 'package:magrail_app/features/chara/pool/controller/character_pool_controller.dart';
import 'package:magrail_app/features/chara/pool/view/character_pool_page.dart';
import 'package:magrail_app/features/chara/pool/widgets/character_pool_assets.dart';
import 'package:magrail_app/features/chara/rank/view/all_character_rank_page.dart';
import 'package:magrail_app/features/chara/top_week/view/top_week_history_page.dart';
import 'package:magrail_app/features/chara/tower/view/tower_log_page.dart';
import 'package:magrail_app/features/chara/tower/view/tower_ranking_page.dart';
import 'package:magrail_app/features/chara/trade_history/view/character_gm_trade_history_page.dart';
import 'package:magrail_app/features/ico/view/st_character_page.dart';

/// 构建角色业务路由
///
/// [dependencies] 应用依赖集合
List<RouteBase> buildCharaRoutes(AppDependencies dependencies) {
  return [
    GoRoute(
      name: 'characterDetail',
      path: '/character-detail',
      pageBuilder: (context, state) {
        final queryParameters = state.uri.queryParameters;

        return MaterialPage(
          key: state.pageKey,
          child: CharacterDetailPage(
            preferences: dependencies.preferences,
            authRepository: dependencies.authRepository,
            repository: dependencies.repositories.characterDetail,
            userRepository: dependencies.repositories.user,
            templeRepository: dependencies.repositories.temple,
            magicRepository: dependencies.repositories.templeAssetMagic,
            oosRepository: dependencies.repositories.oos,
            auctionRepository: dependencies.repositories.auction,
            tradeHistoryRepository:
                dependencies.repositories.characterTradeHistory,
            characterId: int.tryParse(
              queryParameters['characterId'] ?? '',
            ),
            initialName: queryParameters['name'],
            initialAvatarUrl: queryParameters['avatarUrl'],
            initialAvatarHeroTag: queryParameters['avatarHeroTag'],
          ),
        );
      },
    ),
    GoRoute(
      name: 'characterGmTradeHistory',
      path: '/character-gm-trade-history',
      pageBuilder: (context, state) {
        final queryParameters = state.uri.queryParameters;

        return MaterialPage(
          key: state.pageKey,
          child: CharacterGmTradeHistoryPage(
            repository: dependencies.repositories.characterTradeHistory,
            characterId: int.tryParse(
                  queryParameters['characterId'] ?? '',
                ) ??
                0,
            characterName: queryParameters['name'],
          ),
        );
      },
    ),
    GoRoute(
      name: 'characterBoard',
      path: '/character-board',
      pageBuilder: (context, state) {
        final queryParameters = state.uri.queryParameters;
        final routeExtra = _characterCollectionsRouteExtra(state.extra);
        final collectionsController =
            _characterCollectionsController(state.extra);

        return MaterialPage(
          key: state.pageKey,
          child: CharacterDetailBoardPage(
            repository: dependencies.repositories.characterDetail,
            templeRepository: routeExtra?.templeRepository ??
                dependencies.repositories.temple,
            magicRepository: routeExtra?.magicRepository ??
                dependencies.repositories.templeAssetMagic,
            oosRepository:
                routeExtra?.oosRepository ?? dependencies.repositories.oos,
            userRepository:
                routeExtra?.userRepository ?? dependencies.repositories.user,
            characterId: int.tryParse(
                  queryParameters['characterId'] ?? '',
                ) ??
                0,
            characterName: queryParameters['name'] ?? '',
            totalShares: int.tryParse(queryParameters['total'] ?? '') ?? 0,
            currentUserName: routeExtra?.currentUserName ?? '',
            revealPrivateUserHoldings:
                dependencies.preferences.hiddenFeaturesEnabled &&
                    dependencies.preferences.revealPrivateUserHoldingsEnabled,
            collectionsController: collectionsController,
          ),
        );
      },
    ),
    GoRoute(
      name: 'characterLinks',
      path: '/character-links',
      pageBuilder: (context, state) {
        final queryParameters = state.uri.queryParameters;
        final routeExtra = _characterCollectionsRouteExtra(state.extra);
        final collectionsController =
            _characterCollectionsController(state.extra);

        return MaterialPage(
          key: state.pageKey,
          child: CharacterDetailLinksPage(
            characterId: int.tryParse(
                  queryParameters['characterId'] ?? '',
                ) ??
                0,
            characterName: queryParameters['name'] ?? '',
            avatarUrl: queryParameters['avatarUrl'] ?? '',
            repository: dependencies.repositories.characterDetail,
            templeRepository: routeExtra?.templeRepository ??
                dependencies.repositories.temple,
            magicRepository: routeExtra?.magicRepository ??
                dependencies.repositories.templeAssetMagic,
            oosRepository:
                routeExtra?.oosRepository ?? dependencies.repositories.oos,
            userRepository:
                routeExtra?.userRepository ?? dependencies.repositories.user,
            collectionsController: collectionsController,
            currentUserName: routeExtra?.currentUserName ?? '',
          ),
        );
      },
    ),
    GoRoute(
      name: 'characterTemples',
      path: '/character-temples',
      pageBuilder: (context, state) {
        final queryParameters = state.uri.queryParameters;
        final routeExtra = _characterCollectionsRouteExtra(state.extra);
        final collectionsController =
            _characterCollectionsController(state.extra);

        return MaterialPage(
          key: state.pageKey,
          child: CharacterDetailTemplesPage(
            characterId: int.tryParse(
                  queryParameters['characterId'] ?? '',
                ) ??
                0,
            characterName: queryParameters['name'] ?? '',
            avatarUrl: queryParameters['avatarUrl'] ?? '',
            repository: dependencies.repositories.characterDetail,
            templeRepository: routeExtra?.templeRepository ??
                dependencies.repositories.temple,
            magicRepository: routeExtra?.magicRepository ??
                dependencies.repositories.templeAssetMagic,
            oosRepository:
                routeExtra?.oosRepository ?? dependencies.repositories.oos,
            userRepository:
                routeExtra?.userRepository ?? dependencies.repositories.user,
            collectionsController: collectionsController,
            currentUserName: routeExtra?.currentUserName ?? '',
          ),
        );
      },
    ),
    GoRoute(
      name: 'topWeekHistory',
      path: '/top-week-history',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: TopWeekHistoryPage(
          repository: dependencies.repositories.topWeek,
        ),
      ),
    ),
    GoRoute(
      name: 'valhallaCharacters',
      path: '/valhalla-characters',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: CharacterPoolPage(
          title: '英灵殿',
          username: characterPoolValhallaUsername,
          rowType: CharacterPoolRowType.valhalla,
          authRepository: dependencies.authRepository,
          repository: dependencies.repositories.user,
          auctionRepository: dependencies.repositories.auction,
          emptyTitle: '暂无英灵殿角色',
          emptyMessage: '当前没有可展示的英灵殿角色',
          emptyIcon: LucideIcons.inbox,
          completedLabel: '没有更多英灵殿角色了',
        ),
      ),
    ),
    GoRoute(
      name: 'gensokyoCharacters',
      path: '/gensokyo-characters',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: CharacterPoolPage(
          title: '幻想乡',
          username: characterPoolGensokyoUsername,
          rowType: CharacterPoolRowType.gensokyo,
          authRepository: dependencies.authRepository,
          repository: dependencies.repositories.user,
          auctionRepository: dependencies.repositories.auction,
          emptyTitle: '暂无幻想乡角色',
          emptyMessage: '当前没有可展示的幻想乡角色',
          emptyIcon: LucideIcons.inbox,
          completedLabel: '没有更多幻想乡角色了',
        ),
      ),
    ),
    GoRoute(
      name: 'allCharacters',
      path: '/all-characters',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: AllCharacterRankPage(
          repository: dependencies.repositories.characterRank,
        ),
      ),
    ),
    GoRoute(
      name: 'stCharacters',
      path: '/st-characters',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: StCharacterPage(
          repository: dependencies.repositories.stCharacter,
        ),
      ),
    ),
    GoRoute(
      name: 'towerRanking',
      path: '/tower-ranking',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: TowerRankingPage(
          repository: dependencies.repositories.tower,
        ),
      ),
    ),
    GoRoute(
      name: 'towerLog',
      path: '/tower-log',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: TowerLogPage(
          repository: dependencies.repositories.tower,
        ),
      ),
    ),
  ];
}

/// 从路由附加数据读取角色详情公开展示区控制器
///
/// [extra] 路由附加数据
CharacterDetailCollectionsController? _characterCollectionsController(
  Object? extra,
) {
  if (extra is CharacterDetailCollectionsRouteExtra) {
    return extra.controller;
  }
  if (extra is CharacterDetailCollectionsController) {
    return extra;
  }

  return null;
}

/// 从路由附加数据读取角色详情公开展示区上下文
///
/// [extra] 路由附加数据
CharacterDetailCollectionsRouteExtra? _characterCollectionsRouteExtra(
  Object? extra,
) {
  return extra is CharacterDetailCollectionsRouteExtra ? extra : null;
}
