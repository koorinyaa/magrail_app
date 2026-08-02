import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/storage/secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_activity_config.dart';

/// 应用活跃状态上报器
class AppActivityReporter {
  /// 创建应用活跃状态上报器
  ///
  /// [dio] 不携带业务 Cookie 的统计客户端
  /// [secureStorage] 安装标识安全存储
  /// [preferences] 活跃上报去重状态
  AppActivityReporter({
    required Dio dio,
    required SecureStorage secureStorage,
    required AppPreferences preferences,
  })  : _dio = dio,
        _secureStorage = secureStorage,
        _preferences = preferences;

  final Dio _dio;
  final SecureStorage _secureStorage;
  final AppPreferences _preferences;
  Future<void> _reportQueue = Future<void>.value();

  static const _projectKey = 'magrail_app';

  // 安装标识与业务会话隔离，退出登录时保持不变
  static const _installationIdStorageKey = 'activity_installation_id';
  static final _installationIdPattern = RegExp(r'^[a-f0-9]{32}$');

  /// 上报当前安装实例和登录账号的活跃状态
  ///
  /// [userId] 当前 Tinygrail 用户 ID，未登录时为空
  /// [username] 当前 Tinygrail 用户名，未登录时为空
  Future<void> report({int? userId, String? username}) {
    _reportQueue = _reportQueue.then(
      (_) => _report(userId: userId, username: username),
    );
    return _reportQueue;
  }

  /// 执行单次活跃状态上报
  ///
  /// [userId] 当前 Tinygrail 用户 ID，未登录时为空
  /// [username] 当前 Tinygrail 用户名，未登录时为空
  Future<void> _report({int? userId, String? username}) async {
    final endpoint = AppActivityConfig.endpoint;
    if (endpoint == null) {
      return;
    }

    try {
      final platform = _resolvePlatform();
      if (platform == null) {
        return;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = _resolveAppVersion(packageInfo);
      final resolvedUsername = username?.trim() ?? '';
      final hasUser =
          userId != null && userId > 0 && resolvedUsername.isNotEmpty;
      final reportUserId = hasUser ? userId : null;
      final reportUsername = hasUser ? resolvedUsername : null;
      final reportKey = _buildReportKey(
        userId: reportUserId,
        username: reportUsername,
        platform: platform,
        appVersion: appVersion,
      );
      if (_preferences.lastActivityReportKey == reportKey) {
        return;
      }

      final installationId = await _readOrCreateInstallationId();
      final response = await _dio.postUri<Object?>(
        endpoint,
        data: <String, Object?>{
          'projectKey': _projectKey,
          'installationId': installationId,
          'userId': reportUserId,
          'username': reportUsername,
          'platform': platform,
          'appVersion': appVersion,
        },
      );
      final statusCode = response.statusCode;
      if (statusCode == null || statusCode < 200 || statusCode >= 300) {
        return;
      }

      await _preferences.setLastActivityReportKey(reportKey);
    } catch (_) {
      // 活跃统计失败不影响启动、登录和退出流程
    }
  }

  /// 读取或生成当前安装实例标识
  Future<String> _readOrCreateInstallationId() async {
    final stored = await _secureStorage.read(_installationIdStorageKey);
    if (stored != null && _installationIdPattern.hasMatch(stored)) {
      return stored;
    }

    final installationId = _generateInstallationId();
    await _secureStorage.write(_installationIdStorageKey, installationId);
    return installationId;
  }

  /// 生成 128 位随机安装标识
  String _generateInstallationId() {
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var index = 0; index < 16; index += 1) {
      buffer.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  /// 构建本地每日上报去重键
  ///
  /// [userId] 当前 Tinygrail 用户 ID
  /// [username] 当前 Tinygrail 用户名
  /// [platform] 客户端平台
  /// [appVersion] 应用版本
  String _buildReportKey({
    required int? userId,
    required String? username,
    required String platform,
    required String appVersion,
  }) {
    final utc8Now = DateTime.now().toUtc().add(const Duration(hours: 8));
    final day = '${utc8Now.year.toString().padLeft(4, '0')}-'
        '${utc8Now.month.toString().padLeft(2, '0')}-'
        '${utc8Now.day.toString().padLeft(2, '0')}';
    final account = userId == null ? 'guest' : '$userId:$username';
    return '$day|$account|$platform|$appVersion';
  }

  /// 解析当前运行平台
  String? _resolvePlatform() {
    if (Platform.isAndroid) {
      return 'android';
    }
    if (Platform.isIOS) {
      return 'ios';
    }
    return null;
  }

  /// 解析包含构建号的应用版本
  ///
  /// [packageInfo] 当前安装包信息
  String _resolveAppVersion(PackageInfo packageInfo) {
    final version = packageInfo.version.trim();
    final buildNumber = packageInfo.buildNumber.trim();
    return buildNumber.isEmpty ? version : '$version+$buildNumber';
  }
}
