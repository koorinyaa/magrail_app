import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/app/bootstrap.dart';
import 'package:magrail_app/features/bot/view/bot_config_page.dart';
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
import 'package:magrail_app/features/user/view/user_starlight_temple_page.dart';
import 'package:magrail_app/features/user/view/user_temple_page.dart';
import 'package:magrail_app/features/user/view/user_trade_log_page.dart';

/// 构建用户业务路由
///
/// [dependencies] 应用依赖集合
/// [onThemeModeChanged] 应用主题模式变化回调
List<RouteBase> buildUserRoutes(
  AppDependencies dependencies,
  ValueChanged<ThemeMode>? onThemeModeChanged,
) {
  return [
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
          characterDetailRepository: dependencies.repositories.characterDetail,
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
          characterDetailRepository: dependencies.repositories.characterDetail,
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
          characterDetailRepository: dependencies.repositories.characterDetail,
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
          characterDetailRepository: dependencies.repositories.characterDetail,
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
      name: 'userStarlightTemples',
      path: '/user-starlight-temples',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: UserStarlightTemplePage(
          userRepository: dependencies.repositories.user,
          characterDetailRepository: dependencies.repositories.characterDetail,
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
            (state.extra is VoidCallback ? state.extra as VoidCallback : null);

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
  ];
}
