import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/auth/tinygrail_site_config.dart';
import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/storage/secure_storage.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/rank/repository/character_rank_repository.dart';
import 'package:magrail_app/features/chara/trade_history/repository/character_trade_history_repository.dart';
import 'package:magrail_app/features/chara/tower/repository/tower_repository.dart';
import 'package:magrail_app/features/chara/top_week/repository/top_week_repository.dart';
import 'package:magrail_app/features/ico/repository/ico_character_repository.dart';
import 'package:magrail_app/features/ico/repository/st_character_repository.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/ranking/repository/ranking_repository.dart';
import 'package:magrail_app/features/scratch_ticket/repository/scratch_ticket_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用依赖集合
class AppDependencies {
  /// 创建应用依赖集合
  ///
  /// [apiClient] Tinygrail API 客户端
  /// [authRepository] Tinygrail 授权仓库
  /// [preferences] 本地偏好设置
  /// [secureStorage] 安全存储
  /// [repositories] 业务仓库集合
  AppDependencies({
    required this.apiClient,
    required this.authRepository,
    required this.preferences,
    required this.secureStorage,
    required this.repositories,
  });

  /// Tinygrail API 客户端
  final ApiClient apiClient;

  /// Tinygrail 授权仓库
  final TinygrailAuthRepository authRepository;

  /// 本地偏好设置
  final AppPreferences preferences;

  /// 安全存储
  final SecureStorage secureStorage;

  /// 业务仓库集合
  final AppRepositories repositories;
}

/// 应用业务仓库集合
class AppRepositories {
  /// 创建应用业务仓库集合
  ///
  /// [apiClient] Tinygrail API 客户端
  /// [dio] Dio 客户端
  /// [authRepository] Tinygrail 授权仓库
  /// [preferences] 本地偏好设置
  factory AppRepositories({
    required ApiClient apiClient,
    required Dio dio,
    required TinygrailAuthRepository authRepository,
    required AppPreferences preferences,
  }) {
    final auctionRepository = AuctionRepository(apiClient: apiClient);

    return AppRepositories._(
      topWeek: TopWeekRepository(apiClient: apiClient),
      ranking: RankingRepository(apiClient: apiClient),
      characterRank: CharacterRankRepository(apiClient: apiClient),
      characterDetail: CharacterDetailRepository(apiClient: apiClient),
      characterTradeHistory:
          CharacterTradeHistoryRepository(apiClient: apiClient),
      tower: TowerRepository(apiClient: apiClient),
      icoCharacter: IcoCharacterRepository(apiClient: apiClient),
      stCharacter: StCharacterRepository(apiClient: apiClient),
      temple: TempleRepository(apiClient: apiClient),
      templeAssetMagic: TempleAssetMagicRepository(apiClient: apiClient),
      oos: TinygrailOosRepository(apiClient: apiClient, dio: dio),
      auction: auctionRepository,
      scratchTicket: ScratchTicketRepository(apiClient: apiClient),
      user: UserRepository(
        apiClient: apiClient,
        authRepository: authRepository,
        preferences: preferences,
        auctionRepository: auctionRepository,
      ),
    );
  }

  /// 创建应用业务仓库集合实例
  ///
  /// [topWeek] 每周萌王仓库
  /// [characterDetail] 角色详情仓库
  /// [characterTradeHistory] 角色交易记录仓库
  /// [tower] 通天塔仓库
  /// [temple] 圣殿仓库
  /// [templeAssetMagic] 圣殿资产魔法道具仓库
  /// [oos] Tinygrail OOS 仓库
  /// [auction] 拍卖仓库
  /// [scratchTicket] 刮刮乐仓库
  /// [user] 用户仓库
  /// [ranking] 排行榜仓库
  /// [characterRank] 角色排序仓库
  /// [icoCharacter] ICO 角色仓库
  /// [stCharacter] ST 角色仓库
  const AppRepositories._({
    required this.topWeek,
    required this.ranking,
    required this.characterRank,
    required this.characterDetail,
    required this.characterTradeHistory,
    required this.tower,
    required this.icoCharacter,
    required this.stCharacter,
    required this.temple,
    required this.templeAssetMagic,
    required this.oos,
    required this.auction,
    required this.scratchTicket,
    required this.user,
  });

  /// 每周萌王仓库
  final TopWeekRepository topWeek;

  /// 排行榜仓库
  final RankingRepository ranking;

  /// 角色排序仓库
  final CharacterRankRepository characterRank;

  /// 角色详情仓库
  final CharacterDetailRepository characterDetail;

  /// 角色交易记录仓库
  final CharacterTradeHistoryRepository characterTradeHistory;

  /// 通天塔仓库
  final TowerRepository tower;

  /// ICO 角色仓库
  final IcoCharacterRepository icoCharacter;

  /// ST 角色仓库
  final StCharacterRepository stCharacter;

  /// 圣殿仓库
  final TempleRepository temple;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository templeAssetMagic;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oos;

  /// 拍卖仓库
  final AuctionRepository auction;

  /// 刮刮乐仓库
  final ScratchTicketRepository scratchTicket;

  /// 用户仓库
  final UserRepository user;
}

/// 初始化应用依赖
Future<AppDependencies> bootstrap() async {
  final supportDirectory = await getApplicationSupportDirectory();
  final cookieJar = PersistCookieJar(
    storage: FileStorage('${supportDirectory.path}/cookies'),
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: TinygrailSiteConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 120),
      responseType: ResponseType.json,
    ),
  );

  // Tinygrail 会话边界：保存 Set-Cookie，并在后续请求自动附带 Cookie
  dio.interceptors.add(CookieManager(cookieJar));

  final apiClient = ApiClient(dio);
  final secureStorage = const SecureStorage(FlutterSecureStorage());
  final preferences = AppPreferences(await SharedPreferences.getInstance());
  // 启动时同步 Bangumi 镜像偏好，供静态资源地址工具使用
  TinygrailAssetUrls.configureBangumiMirror(
    useMirror: preferences.useBangumiMirror,
    mirrorHost: preferences.bangumiMirrorHost,
  );

  final authRepository =
      TinygrailAuthRepository(dio: dio, cookieJar: cookieJar);

  return AppDependencies(
    apiClient: apiClient,
    authRepository: authRepository,
    preferences: preferences,
    secureStorage: secureStorage,
    repositories: AppRepositories(
      apiClient: apiClient,
      dio: dio,
      authRepository: authRepository,
      preferences: preferences,
    ),
  );
}
