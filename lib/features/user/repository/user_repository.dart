import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/analytics/app_activity_reporter.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/api_exception.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/user/analysis/repository/user_asset_analysis_database.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_database.dart';
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

part 'user_repository/user_repository_page_queries.dart';
part 'user_repository/user_repository_assets.dart';

/// 用户仓库及当前登录资料缓存状态
class UserRepository extends ChangeNotifier with _UserRepositoryPageQueries {
  /// 创建用户仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  /// [authRepository] Tinygrail 授权仓库
  /// [preferences] 本地偏好设置
  /// [auctionRepository] 拍卖仓库
  /// [activityReporter] 应用活跃状态上报器
  UserRepository({
    required ApiClient apiClient,
    required TinygrailAuthRepository authRepository,
    required AppPreferences preferences,
    required AuctionRepository auctionRepository,
    required AppActivityReporter activityReporter,
  }) : _apiClient = apiClient,
       _authRepository = authRepository,
       _preferences = preferences,
       _auctionRepository = auctionRepository,
       _activityReporter = activityReporter;

  @override
  final ApiClient _apiClient;
  final TinygrailAuthRepository _authRepository;
  final AppPreferences _preferences;
  final AppActivityReporter _activityReporter;
  @override
  final AuctionRepository _auctionRepository;

  /// 用户页面复用的拍卖仓库
  AuctionRepository get auctionRepository => _auctionRepository;

  // 当前用户缓存超过 7 天未更新后不再用于首屏展示
  static const Duration _currentUserCacheLifetime = Duration(days: 7);

  /// 检查当前 Tinygrail 会话是否存在本地 Cookie
  Future<bool> hasCurrentUserSessionCookie() {
    return _authRepository.hasTinygrailCookie();
  }

  /// 捕获当前登录用户会话代际
  int? captureCurrentUserSessionGeneration() {
    return _authRepository.captureSessionGeneration();
  }

  /// 判断任务捕获的当前用户会话代际是否仍然有效
  ///
  /// [generation] 任务开始时捕获的会话代际
  bool isCurrentUserSessionGenerationCurrent(int generation) {
    return _authRepository.isSessionGenerationCurrent(generation);
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
  /// 当前用户请求在会话变更后不写入缓存或发布旧结果
  Future<UserAssetsFetchResult> fetchUserAssets({String? username}) {
    return _fetchAssets(username: username);
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
    final response = TinygrailResponse<UserShareBonusForecast>.fromJson(json, (
      value,
    ) {
      final valueJson = TinygrailResponseParser.asObjectMap(value);
      if (valueJson == null) {
        return null;
      }

      return UserShareBonusForecast.fromJson(valueJson);
    });

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

  /// 持久化当前用户资料并通知监听者
  ///
  /// [profile] 用户资产资料
  Future<void> cacheCurrentUserAssets(UserDetailProfile profile) async {
    await _preferences.setCurrentUserAssetsCache(
      jsonEncode({
        'UpdatedAt': _cacheUpdatedAtMilliseconds(),
        'Profile': profile.toJson(),
      }),
    );
    notifyListeners();
  }

  /// 缓存当前登录用户角色资产预览
  ///
  /// [cache] 用户角色资产预览缓存
  Future<void> cacheCurrentUserCharaOverview(UserCharaOverviewCache cache) {
    final cacheJson = cache.toJson()
      ..['UpdatedAt'] = _cacheUpdatedAtMilliseconds();
    return _preferences.setCurrentUserCharaOverviewCache(jsonEncode(cacheJson));
  }

  /// 清除当前用户资料和预览缓存并通知监听者
  Future<void> clearCurrentUserAssetsCache() async {
    await Future.wait([
      _preferences.clearCurrentUserAssetsCache(),
      _preferences.clearCurrentUserCharaOverviewCache(),
    ]);
    notifyListeners();
  }

  /// 清除退出用户的资料缓存、完整资产快照和资产分析缓存
  Future<void> clearCurrentUserDataOnSignOut() async {
    final username = readCachedCurrentUserAssets()?.name.trim() ?? '';
    if (username.isNotEmpty) {
      final analysisDatabase = UserAssetAnalysisDatabase();
      try {
        await Future.wait([
          UserAssetSnapshotDatabase().deleteSnapshot(username),
          analysisDatabase.deleteEntry(username),
        ]);
      } finally {
        await analysisDatabase.close();
      }
    }

    await clearCurrentUserAssetsCache();
    // 本地退出完成后立即把设备最新登录状态更新为空
    unawaited(_activityReporter.report());
  }

  /// 获取当前用户委托订单分页数据
  ///
  /// [path] API 路径
  /// [fallbackMessage] 失败兜底文案
  @override
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

  /// 编码用户名路径段
  ///
  /// [username] 原始用户名
  @override
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
  @override
  TinygrailPage<T> _parsePageResponse<T>({
    required Map<String, Object?> json,
    required T Function(Map<String, Object?> json) itemFromJson,
    required String fallbackMessage,
  }) {
    final response = TinygrailResponse<TinygrailPage<T>>.fromJson(json, (
      value,
    ) {
      final valueJson = TinygrailResponseParser.asObjectMap(value);
      if (valueJson == null) {
        return null;
      }

      return TinygrailPage.fromJson(valueJson, itemFromJson);
    });

    final page = response.value;
    if (!response.isSuccess || page == null) {
      throw StateError(response.message ?? fallbackMessage);
    }

    return page;
  }
}
