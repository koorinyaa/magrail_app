import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/app/bootstrap.dart';
import 'package:magrail_app/features/bangumi/next/next_bangumi_subject_navigation.dart';
import 'package:magrail_app/features/bangumi/next/view/next_bangumi_subject_page.dart';
import 'package:magrail_app/features/bot/view/bot_config_page.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_collections_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_collections_route_extra.dart';
import 'package:magrail_app/features/chara/detail/view/character_detail_board_page.dart';
import 'package:magrail_app/features/chara/detail/view/character_detail_links_page.dart';
import 'package:magrail_app/features/chara/detail/view/character_detail_page.dart';
import 'package:magrail_app/features/chara/detail/view/character_detail_temples_page.dart';
import 'package:magrail_app/features/chara/trade_history/view/character_gm_trade_history_page.dart';
import 'package:magrail_app/features/chara/rank/view/all_character_rank_page.dart';
import 'package:magrail_app/features/chara/top_week/view/top_week_history_page.dart';
import 'package:magrail_app/features/chara/tower/view/tower_log_page.dart';
import 'package:magrail_app/features/chara/tower/view/tower_ranking_page.dart';
import 'package:magrail_app/features/chara/pool/controller/character_pool_controller.dart';
import 'package:magrail_app/features/chara/pool/view/character_pool_page.dart';
import 'package:magrail_app/features/chara/pool/widgets/character_pool_assets.dart';
import 'package:magrail_app/features/ico/view/st_character_page.dart';
import 'package:magrail_app/features/main_navigation/view/main_navigation_page.dart';
import 'package:magrail_app/features/temple/view/latest_link_page.dart';
import 'package:magrail_app/features/temple/view/latest_temple_page.dart';
import 'package:magrail_app/features/user/analysis/view/user_asset_analysis_page.dart';
import 'package:magrail_app/features/user/model/user_detail_entry_mode.dart';
import 'package:magrail_app/features/user/view/user_auction_page.dart';
import 'package:magrail_app/features/user/view/user_balance_log_page.dart';
import 'package:magrail_app/features/user/view/user_character_page.dart';
import 'package:magrail_app/features/user/view/user_detail_page.dart';
import 'package:magrail_app/features/user/view/user_ico_page.dart';
import 'package:magrail_app/features/user/view/user_item_page.dart';
import 'package:magrail_app/features/user/view/user_link_page.dart';
import 'package:magrail_app/features/user/view/user_market_order_page.dart';
import 'package:magrail_app/features/user/view/user_red_packet_log_page.dart';
import 'package:magrail_app/features/user/view/user_settings_page.dart';
import 'package:magrail_app/features/user/view/user_temple_page.dart';
import 'package:magrail_app/features/user/view/user_trade_log_page.dart';

part 'app_router_character_detail_extra.dart';

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
      GoRoute(
        name: 'characterBoard',
        path: '/character-board',
        pageBuilder: (context, state) {
          final queryParameters = state.uri.queryParameters;
          final routeExtra =
              _characterDetailCollectionsRouteExtraFromExtra(state.extra);
          final collectionsController =
              _characterDetailCollectionsControllerFromExtra(state.extra);

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
          final routeExtra =
              _characterDetailCollectionsRouteExtraFromExtra(state.extra);
          final collectionsController =
              _characterDetailCollectionsControllerFromExtra(state.extra);

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
          final routeExtra =
              _characterDetailCollectionsRouteExtraFromExtra(state.extra);
          final collectionsController =
              _characterDetailCollectionsControllerFromExtra(state.extra);

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
      GoRoute(
        name: 'latestTemples',
        path: '/latest-temples',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: LatestTemplePage(
            repository: dependencies.repositories.temple,
            characterDetailRepository:
                dependencies.repositories.characterDetail,
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
            characterDetailRepository:
                dependencies.repositories.characterDetail,
            oosRepository: dependencies.repositories.oos,
            magicRepository: dependencies.repositories.templeAssetMagic,
            userRepository: dependencies.repositories.user,
          ),
        ),
      ),
      GoRoute(
        name: 'userDetail',
        path: '/user-detail',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: UserDetailPage(
            entryMode: UserDetailEntryMode.secondary,
            authRepository: dependencies.authRepository,
            preferences: dependencies.preferences,
            repository: dependencies.repositories.user,
            characterDetailRepository:
                dependencies.repositories.characterDetail,
            templeRepository: dependencies.repositories.temple,
            templeAssetMagicRepository:
                dependencies.repositories.templeAssetMagic,
            oosRepository: dependencies.repositories.oos,
            scratchTicketRepository: dependencies.repositories.scratchTicket,
            username: state.uri.queryParameters['username'],
          ),
        ),
      ),
      GoRoute(
        name: 'userLinks',
        path: '/user-links',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: UserLinkPage(
            repository: dependencies.repositories.user,
            characterDetailRepository:
                dependencies.repositories.characterDetail,
            templeRepository: dependencies.repositories.temple,
            templeAssetMagicRepository:
                dependencies.repositories.templeAssetMagic,
            oosRepository: dependencies.repositories.oos,
            username: state.uri.queryParameters['username'] ?? '',
            nickname: state.uri.queryParameters['nickname'],
            currentUserName: state.uri.queryParameters['currentUserName'] ?? '',
          ),
        ),
      ),
      GoRoute(
        name: 'userAssetAnalysis',
        path: '/user-asset-analysis',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: UserAssetAnalysisPage(
            repository: dependencies.repositories.user,
            characterDetailRepository:
                dependencies.repositories.characterDetail,
            username: state.uri.queryParameters['username'] ?? '',
            nickname: state.uri.queryParameters['nickname'],
          ),
        ),
      ),
      GoRoute(
        name: 'userBalanceLogs',
        path: '/user-balance-logs',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: UserBalanceLogPage(
            repository: dependencies.repositories.user,
          ),
        ),
      ),
      GoRoute(
        name: 'userAuctions',
        path: '/user-auctions',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: UserAuctionPage(
            repository: dependencies.repositories.user,
          ),
        ),
      ),
      GoRoute(
        name: 'userMarketOrders',
        path: '/user-market-orders',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: UserMarketOrderPage(
            repository: dependencies.repositories.user,
          ),
        ),
      ),
      GoRoute(
        name: 'userItems',
        path: '/user-items',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: UserItemPage(
            repository: dependencies.repositories.user,
          ),
        ),
      ),
      GoRoute(
        name: 'userRedPacketLogs',
        path: '/user-red-packet-logs',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: UserRedPacketLogPage(
            repository: dependencies.repositories.user,
            username: state.uri.queryParameters['username'] ?? '',
            nickname: state.uri.queryParameters['nickname'],
          ),
        ),
      ),
      GoRoute(
        name: 'userTradeLogs',
        path: '/user-trade-logs',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: UserTradeLogPage(
            repository: dependencies.repositories.user,
            userId: int.tryParse(
                  state.uri.queryParameters['userId'] ?? '',
                ) ??
                0,
            username: state.uri.queryParameters['username'] ?? '',
            nickname: state.uri.queryParameters['nickname'],
          ),
        ),
      ),
      GoRoute(
        name: 'userTemples',
        path: '/user-temples',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: UserTemplePage(
            repository: dependencies.repositories.user,
            characterDetailRepository:
                dependencies.repositories.characterDetail,
            templeRepository: dependencies.repositories.temple,
            templeAssetMagicRepository:
                dependencies.repositories.templeAssetMagic,
            oosRepository: dependencies.repositories.oos,
            username: state.uri.queryParameters['username'] ?? '',
            nickname: state.uri.queryParameters['nickname'],
            currentUserName: state.uri.queryParameters['currentUserName'] ?? '',
          ),
        ),
      ),
      GoRoute(
        name: 'userCharacters',
        path: '/user-characters',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: UserCharacterPage(
            repository: dependencies.repositories.user,
            username: state.uri.queryParameters['username'] ?? '',
            nickname: state.uri.queryParameters['nickname'],
          ),
        ),
      ),
      GoRoute(
        name: 'userIcos',
        path: '/user-icos',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: UserIcoPage(
            repository: dependencies.repositories.user,
            username: state.uri.queryParameters['username'] ?? '',
            nickname: state.uri.queryParameters['nickname'],
          ),
        ),
      ),
      GoRoute(
        name: 'userBotConfig',
        path: '/user-bot-config',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: BotConfigPage(
            authRepository: dependencies.authRepository,
            preferences: dependencies.preferences,
            repository: dependencies.repositories.bot,
            characterRepository: dependencies.repositories.characterDetail,
            userRepository: dependencies.repositories.user,
          ),
        ),
      ),
      GoRoute(
        name: 'userSettings',
        path: '/user-settings',
        pageBuilder: (context, state) {
          final routeExtra = state.extra is UserSettingsRouteExtra
              ? state.extra as UserSettingsRouteExtra
              : null;
          final onSignedOut = routeExtra?.onSignedOut ??
              (state.extra is VoidCallback
                  ? state.extra as VoidCallback
                  : null);

          return MaterialPage(
            key: state.pageKey,
            child: UserSettingsPage(
              authRepository: dependencies.authRepository,
              preferences: dependencies.preferences,
              updateController: dependencies.updateController,
              userRepository: dependencies.repositories.user,
              onSignedOut: onSignedOut,
              onLiquidGlassChanged: routeExtra?.onLiquidGlassChanged,
              onThemeModeChanged: onThemeModeChanged,
            ),
          );
        },
      ),
    ],
  );
}
