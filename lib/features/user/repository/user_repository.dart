import 'dart:async';
import 'dart:convert';

import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/api_exception.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/user/model/user_auction_api_item.dart';
import 'package:magrail_app/features/user/model/user_assets_fetch_result.dart';
import 'package:magrail_app/features/user/model/user_balance_log_api_item.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_chara_overview_cache.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';
import 'package:magrail_app/features/user/model/user_ico_api_item.dart';
import 'package:magrail_app/features/user/model/user_item_api_item.dart';
import 'package:magrail_app/features/user/model/user_link_api_item.dart';
import 'package:magrail_app/features/user/model/user_market_order_api_item.dart';
import 'package:magrail_app/features/user/model/user_red_packet_log_api_item.dart';
import 'package:magrail_app/features/user/model/user_share_bonus_forecast.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/model/user_trade_log_api_item.dart';

/// 用户仓库
class UserRepository {
  /// 创建用户仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  /// [authRepository] Tinygrail 授权仓库
  /// [preferences] 本地偏好设置
  /// [auctionRepository] 拍卖仓库
  const UserRepository({
    required ApiClient apiClient,
    required TinygrailAuthRepository authRepository,
    required AppPreferences preferences,
    required AuctionRepository auctionRepository,
  })  : _apiClient = apiClient,
        _authRepository = authRepository,
        _preferences = preferences,
        _auctionRepository = auctionRepository;

  final ApiClient _apiClient;
  final TinygrailAuthRepository _authRepository;
  final AppPreferences _preferences;
  final AuctionRepository _auctionRepository;

  /// 用户页面复用的拍卖仓库
  AuctionRepository get auctionRepository => _auctionRepository;

  // 当前用户缓存超过 7 天未更新后不再用于首屏展示
  static const Duration _currentUserCacheLifetime = Duration(days: 7);

  /// 检查当前 Tinygrail 会话是否存在本地 Cookie
  Future<bool> hasCurrentUserSessionCookie() {
    return _authRepository.hasTinygrailCookie();
  }

  /// 读取当前登录用户资产缓存
  UserDetailProfile? readCachedCurrentUserAssets() {
    final rawCache = _preferences.currentUserAssetsCache;
    if (rawCache == null || rawCache.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawCache);
      final cacheJson = TinygrailResponseParser.asObjectMap(decoded);
      if (cacheJson == null) {
        unawaited(clearCurrentUserAssetsCache());
        return null;
      }

      final updatedAt = TinygrailResponseParser.asInt(cacheJson['UpdatedAt']);
      final profileJson = TinygrailResponseParser.asObjectMap(
        cacheJson['Profile'],
      );
      if (profileJson == null || _isCacheExpired(updatedAt)) {
        unawaited(clearCurrentUserAssetsCache());
        return null;
      }

      return UserDetailProfile.fromJson(profileJson);
    } catch (_) {
      // 缓存内容损坏时清理本地资料和预览缓存
      unawaited(clearCurrentUserAssetsCache());
      return null;
    }
  }

  /// 判断用户名是否指向当前登录用户
  ///
  /// [username] 用户名，空值表示当前用户入口
  bool isCachedCurrentUser(String? username) {
    if (username == null || username.isEmpty) {
      return true;
    }

    final cached = readCachedCurrentUserAssets();
    return cached?.name == username;
  }

  /// 读取当前登录用户角色资产预览缓存
  ///
  /// [username] 用户名
  UserCharaOverviewCache? readCachedCurrentUserCharaOverview(String username) {
    final rawCache = _preferences.currentUserCharaOverviewCache;
    if (rawCache == null || rawCache.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawCache);
      final cacheJson = TinygrailResponseParser.asObjectMap(decoded);
      if (cacheJson == null) {
        unawaited(_preferences.clearCurrentUserCharaOverviewCache());
        return null;
      }

      final cache = UserCharaOverviewCache.fromJson(cacheJson);
      if (cache.username != username ||
          _isCacheExpired(cache.updatedAtMilliseconds)) {
        unawaited(_preferences.clearCurrentUserCharaOverviewCache());
        return null;
      }

      return cache;
    } catch (_) {
      // 预览缓存内容损坏时清理本地预览缓存
      unawaited(_preferences.clearCurrentUserCharaOverviewCache());
      return null;
    }
  }

  /// 获取用户资产
  ///
  /// [username] 用户名，不传时获取当前登录用户
  Future<UserAssetsFetchResult> fetchUserAssets({String? username}) async {
    final isCurrentUserRequest = _isCurrentUserRequest(username);
    if (isCurrentUserRequest) {
      try {
        final hasCookie = await _authRepository.hasTinygrailCookie();
        if (!hasCookie) {
          await clearCurrentUserAssetsCache();
          return const UserAssetsFetchResult.authExpired('请先授权');
        }
      } catch (_) {
        await clearCurrentUserAssetsCache();
        return const UserAssetsFetchResult.authExpired('请先授权');
      }
    }

    final path = username == null || username.isEmpty
        ? 'chara/user/assets'
        : 'chara/user/assets/${_encodeUsername(username)}';

    try {
      final json = await _apiClient.getJson<Map<String, Object?>>(path);
      final response = TinygrailResponse<UserDetailProfile>.fromJson(
        json,
        (value) {
          final valueJson = TinygrailResponseParser.asObjectMap(value);
          if (valueJson == null) {
            return null;
          }

          return UserDetailProfile.fromJson(valueJson);
        },
      );

      final profile = response.value;
      if (!response.isSuccess || profile == null) {
        final message = response.message ?? '获取用户资产失败';
        if (isCurrentUserRequest) {
          // 会话失效不是普通网络失败，需要丢弃当前用户缓存避免下次展示旧资料
          unawaited(clearCurrentUserAssetsCache());
          return UserAssetsFetchResult.authExpired(message);
        }

        return UserAssetsFetchResult.failure(message);
      }

      if (_shouldCacheCurrentUserAssets(username)) {
        try {
          await cacheCurrentUserAssets(profile);
        } catch (_) {
          // 缓存写入失败不影响本次接口结果返回
        }
      }

      return UserAssetsFetchResult.success(profile);
    } on ApiException catch (error) {
      return UserAssetsFetchResult.failure(error.message);
    } catch (_) {
      return const UserAssetsFetchResult.failure('获取用户资产失败');
    }
  }

  /// 获取当前用户资金日志分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页日志数量
  Future<TinygrailPage<UserBalanceLogApiItem>> fetchUserBalanceLogPage({
    int page = 1,
    int pageSize = 50,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/user/balance/$page/$pageSize',
    );

    return _parsePageResponse(
      json: json,
      itemFromJson: UserBalanceLogApiItem.fromJson,
      fallbackMessage: '获取资金日志失败',
    );
  }

  /// 获取当前用户拍卖分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页拍卖数量
  Future<TinygrailPage<UserAuctionApiItem>> fetchUserAuctionPage({
    int page = 1,
    int pageSize = 50,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/user/auction/$page/$pageSize',
    );
    final pageData = _parsePageResponse(
      json: json,
      itemFromJson: UserAuctionApiItem.fromJson,
      fallbackMessage: '获取拍卖列表失败',
    );

    if (pageData.items.isEmpty) {
      return pageData;
    }

    try {
      final details = await _auctionRepository.fetchAuctionMap(
        pageData.items.map((item) => item.characterId).toList(growable: false),
      );
      return TinygrailPage(
        items: pageData.items
            .map(
              (item) => item.copyWith(
                auctionDetail: details[item.characterId],
              ),
            )
            .toList(growable: false),
        currentPage: pageData.currentPage,
        totalPages: pageData.totalPages,
        totalItems: pageData.totalItems,
        itemsPerPage: pageData.itemsPerPage,
      );
    } catch (_) {
      // 拍卖详情仅用于补充竞拍人数和数量，失败时保留基础拍卖列表
      return pageData;
    }
  }

  /// 获取当前用户买单分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页买单数量
  Future<TinygrailPage<UserMarketOrderApiItem>> fetchUserBidPage({
    int page = 1,
    int pageSize = 50,
  }) {
    return _fetchUserMarketOrderPage(
      path: 'chara/bids/0/$page/$pageSize',
      fallbackMessage: '获取买单列表失败',
    );
  }

  /// 获取当前用户卖单分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页卖单数量
  Future<TinygrailPage<UserMarketOrderApiItem>> fetchUserAskPage({
    int page = 1,
    int pageSize = 50,
  }) {
    return _fetchUserMarketOrderPage(
      path: 'chara/asks/0/$page/$pageSize',
      fallbackMessage: '获取卖单列表失败',
    );
  }

  /// 获取当前用户道具列表
  ///
  /// [pageSize] 单次请求道具数量
  Future<List<UserItemApiItem>> fetchUserItems({
    int pageSize = 50,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/user/item/0/1/$pageSize',
    );

    final page = _parsePageResponse(
      json: json,
      itemFromJson: UserItemApiItem.fromJson,
      fallbackMessage: '获取道具列表失败',
    );
    return page.items;
  }

  /// 获取用户红包记录分页数据
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页记录数量
  Future<TinygrailPage<UserRedPacketLogApiItem>> fetchUserRedPacketLogPage({
    required String username,
    int page = 1,
    int pageSize = 20,
  }) async {
    final encodedUsername = _encodeUsername(username);
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/user/send/log/$encodedUsername/$page/$pageSize',
    );

    return _parsePageResponse(
      json: json,
      itemFromJson: UserRedPacketLogApiItem.fromJson,
      fallbackMessage: '获取红包记录失败',
    );
  }

  /// 向用户发送红包
  ///
  /// [username] 收款用户名
  /// [amount] 红包金额
  /// [message] 祝福留言
  Future<String> sendRedPacket({
    required String username,
    required int amount,
    required String message,
  }) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      throw StateError('缺少目标用户');
    }

    if (amount <= 0) {
      throw StateError('请输入有效的红包金额');
    }

    final encodedUsername = _encodeUsername(resolvedUsername);
    final encodedMessage = Uri.encodeComponent(message);
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'event/send/$encodedUsername/$amount/$encodedMessage',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '发送红包失败');
    }

    return response.value ?? response.message ?? '发送红包成功';
  }

  /// 获取用户交易记录分页数据
  ///
  /// [userId] 用户 ID
  /// [page] 页码
  /// [pageSize] 每页记录数量
  Future<TinygrailPage<UserTradeLogApiItem>> fetchUserTradeLogPage({
    required int userId,
    int page = 1,
    int pageSize = 48,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/user/history/$userId/$page/$pageSize',
    );

    return _parsePageResponse(
      json: json,
      itemFromJson: UserTradeLogApiItem.fromJson,
      fallbackMessage: '获取交易记录失败',
    );
  }

  /// 取消当前用户拍卖
  ///
  /// [auctionId] 拍卖记录 ID
  Future<String> cancelUserAuction(int auctionId) {
    return _auctionRepository.cancelAuction(auctionId);
  }

  /// 封禁 Tinygrail 用户
  ///
  /// [username] 用户名
  Future<String> banUser(String username) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      throw StateError('缺少目标用户');
    }

    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/user/ban/${_encodeUsername(resolvedUsername)}',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '封禁用户失败');
    }

    return '封禁用户成功';
  }

  /// 解除 Tinygrail 用户封禁
  ///
  /// [username] 用户名
  Future<String> unbanUser(String username) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      throw StateError('缺少目标用户');
    }

    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/user/unban/${_encodeUsername(resolvedUsername)}',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '解除封禁失败');
    }

    return '解除封禁成功';
  }

  /// 领取当前用户每周分红
  Future<String> claimWeeklyBonus() async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'event/share/bonus',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '领取每周分红失败');
    }

    return response.value ?? response.message ?? '领取每周分红成功';
  }

  /// 获取用户股息预测
  ///
  /// [username] 用户名，当前用户请求会使用默认预测接口
  Future<UserShareBonusForecast> fetchShareBonusForecast({
    required String username,
  }) async {
    final resolvedUsername = username.trim();
    if (resolvedUsername.isEmpty) {
      throw StateError('缺少目标用户');
    }

    final path = isCachedCurrentUser(resolvedUsername)
        ? 'event/share/bonus/test'
        : 'event/share/bonus/test/${_encodeUsername(resolvedUsername)}';
    final json = await _apiClient.getJson<Map<String, Object?>>(path);
    final response = TinygrailResponse<UserShareBonusForecast>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }

        return UserShareBonusForecast.fromJson(valueJson);
      },
    );

    final forecast = response.value;
    if (!response.isSuccess || forecast == null) {
      throw StateError(response.message ?? '获取股息预测失败');
    }

    return forecast;
  }

  /// 领取当前用户签到奖励
  Future<String> claimDailyBonus() async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'event/bangumi/bonus/daily',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '领取签到奖励失败');
    }

    return response.value ?? response.message ?? '领取签到奖励成功';
  }

  /// 领取当前用户节日福利
  Future<String> claimHolidayBonus() async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'event/holiday/bonus',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '领取节日福利失败');
    }

    return response.value ?? response.message ?? '领取节日福利成功';
  }

  /// 获取节日福利名称
  Future<String?> fetchHolidayName() async {
    try {
      final json = await _apiClient.getJson<Map<String, Object?>>(
        'event/holiday/bonus/check',
      );
      final response = TinygrailResponse<String>.fromJson(
        json,
        TinygrailResponseParser.asNullableString,
      );

      if (!response.isSuccess) {
        return null;
      }

      return response.value;
    } catch (_) {
      return null;
    }
  }

  /// 获取用户连接分页数据
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页条目数量
  Future<TinygrailPage<UserLinkApiItem>> fetchUserLinkPage({
    required String username,
    int page = 1,
    int pageSize = 12,
  }) async {
    final encodedUsername = _encodeUsername(username);
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/user/link/$encodedUsername/$page/$pageSize',
    );

    return _parsePageResponse(
      json: json,
      itemFromJson: UserLinkApiItem.fromJson,
      fallbackMessage: '获取连接列表失败',
    );
  }

  /// 获取用户圣殿分页数据
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页条目数量
  /// [keyword] 搜索关键字
  /// [characterIds] 限定角色 ID 列表
  Future<TinygrailPage<UserTempleApiItem>> fetchUserTemplePage({
    required String username,
    int page = 1,
    int pageSize = 24,
    String keyword = '',
    List<int> characterIds = const [],
  }) async {
    final encodedUsername = _encodeUsername(username);
    final queryParameters = <String, Object?>{
      if (keyword.isNotEmpty) 'keyword': keyword,
      if (characterIds.isNotEmpty) 'characterIds': characterIds.join(','),
    };
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/user/temple/$encodedUsername/$page/$pageSize',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    return _parsePageResponse(
      json: json,
      itemFromJson: UserTempleApiItem.fromJson,
      fallbackMessage: '获取圣殿列表失败',
    );
  }

  /// 获取用户角色分页数据
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页条目数量
  /// [sort] 排序方式
  /// [characterIds] 限定角色 ID 列表
  Future<TinygrailPage<UserCharacterApiItem>> fetchUserCharacterPage({
    required String username,
    int page = 1,
    int pageSize = 24,
    String sort = '',
    List<int> characterIds = const [],
  }) async {
    final encodedUsername = _encodeUsername(username);
    final queryParameters = <String, Object?>{
      if (sort.isNotEmpty) 'sort': sort,
      if (characterIds.isNotEmpty) 'characterIds': characterIds.join(','),
    };
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/user/chara/$encodedUsername/$page/$pageSize',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    return _parsePageResponse(
      json: json,
      itemFromJson: UserCharacterApiItem.fromJson,
      fallbackMessage: '获取角色列表失败',
    );
  }

  /// 获取用户 ICO 分页数据
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页条目数量
  Future<TinygrailPage<UserIcoApiItem>> fetchUserIcoPage({
    required String username,
    int page = 1,
    int pageSize = 24,
  }) async {
    final encodedUsername = _encodeUsername(username);
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/user/initial/$encodedUsername/$page/$pageSize',
    );

    return _parsePageResponse(
      json: json,
      itemFromJson: UserIcoApiItem.fromJson,
      fallbackMessage: '获取 ICO 列表失败',
    );
  }

  /// 缓存当前登录用户资产
  ///
  /// [profile] 用户资产资料
  Future<void> cacheCurrentUserAssets(UserDetailProfile profile) {
    return _preferences.setCurrentUserAssetsCache(
      jsonEncode({
        'UpdatedAt': _cacheUpdatedAtMilliseconds(),
        'Profile': profile.toJson(),
      }),
    );
  }

  /// 缓存当前登录用户角色资产预览
  ///
  /// [cache] 用户角色资产预览缓存
  Future<void> cacheCurrentUserCharaOverview(
    UserCharaOverviewCache cache,
  ) {
    final cacheJson = cache.toJson()
      ..['UpdatedAt'] = _cacheUpdatedAtMilliseconds();
    return _preferences.setCurrentUserCharaOverviewCache(
      jsonEncode(cacheJson),
    );
  }

  /// 清除当前登录用户资料和角色资产预览缓存
  Future<void> clearCurrentUserAssetsCache() async {
    await Future.wait([
      _preferences.clearCurrentUserAssetsCache(),
      _preferences.clearCurrentUserCharaOverviewCache(),
    ]);
  }

  /// 获取当前用户委托订单分页数据
  ///
  /// [path] API 路径
  /// [fallbackMessage] 失败兜底文案
  Future<TinygrailPage<UserMarketOrderApiItem>> _fetchUserMarketOrderPage({
    required String path,
    required String fallbackMessage,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(path);

    return _parsePageResponse(
      json: json,
      itemFromJson: UserMarketOrderApiItem.fromJson,
      fallbackMessage: fallbackMessage,
    );
  }

  /// 判断是否为当前登录用户资产请求
  ///
  /// [username] 用户名
  bool _isCurrentUserRequest(String? username) {
    return _shouldCacheCurrentUserAssets(username);
  }

  /// 判断本次资产结果是否应写入当前用户缓存
  ///
  /// [username] 用户名，空值表示当前用户入口
  bool _shouldCacheCurrentUserAssets(String? username) {
    return isCachedCurrentUser(username);
  }

  /// 编码用户名路径段
  ///
  /// [username] 原始用户名
  String _encodeUsername(String username) {
    return Uri.encodeComponent(username);
  }

  /// 读取当前缓存更新时间戳
  int _cacheUpdatedAtMilliseconds() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// 判断缓存是否已过期
  ///
  /// [updatedAtMilliseconds] 缓存更新时间戳
  bool _isCacheExpired(int updatedAtMilliseconds) {
    if (updatedAtMilliseconds <= 0) {
      return true;
    }

    final elapsedMilliseconds =
        DateTime.now().millisecondsSinceEpoch - updatedAtMilliseconds;
    return elapsedMilliseconds > _currentUserCacheLifetime.inMilliseconds;
  }

  /// 解析用户分页响应
  ///
  /// [json] 原始响应 JSON
  /// [itemFromJson] 分页条目转换函数
  /// [fallbackMessage] 失败兜底文案
  TinygrailPage<T> _parsePageResponse<T>({
    required Map<String, Object?> json,
    required T Function(Map<String, Object?> json) itemFromJson,
    required String fallbackMessage,
  }) {
    final response = TinygrailResponse<TinygrailPage<T>>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }

        return TinygrailPage.fromJson(valueJson, itemFromJson);
      },
    );

    final page = response.value;
    if (!response.isSuccess || page == null) {
      throw StateError(response.message ?? fallbackMessage);
    }

    return page;
  }
}
