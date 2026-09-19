import 'package:flutter/material.dart';
import 'package:magrail_app/core/auth/bangumi_mirror_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地偏好设置
class AppPreferences extends ChangeNotifier {
  /// 创建本地偏好设置
  ///
  /// [_preferences] SharedPreferences 实例
  AppPreferences(this._preferences)
    : _useBangumiMirror = _preferences.getBool(_useBangumiMirrorKey) ?? false,
      _customBangumiMirrorHost = _preferences.getString(_bangumiMirrorHostKey);

  final SharedPreferences _preferences;

  /// 读取角色实际流通缓存
  ///
  /// [characterId] 角色 ID
  String? readCharacterCirculation(int characterId) {
    return _preferences.getString('character_circulation_$characterId');
  }

  /// 保存角色实际流通缓存并检查持久化结果
  ///
  /// [characterId] 角色 ID
  /// [value] 完整计算结果的 JSON，空值表示删除
  Future<void> saveCharacterCirculation(int characterId, String? value) async {
    final key = 'character_circulation_$characterId';
    final saved = value == null
        ? await _preferences.remove(key)
        : await _preferences.setString(key, value);
    if (!saved) throw StateError('实际流通缓存保存失败');
  }

  static const _prefersDarkModeKey = 'prefers_dark_mode';
  static const _themeModeKey = 'theme_mode';
  static const _useBangumiMirrorKey = 'use_bangumi_mirror';
  static const _bangumiMirrorHostKey = 'bangumi_custom_mirror_host';
  // 镜像设置写入成功后才用于请求，避免保存失败时提前切换域名
  bool _useBangumiMirror;
  String? _customBangumiMirrorHost;
  bool _isSavingMirror = false;
  String _defaultBangumiMirrorHost = BangumiMirrorConfig.defaultHost;
  static const _currentUserAssetsCacheKey = 'tinygrail_current_user_assets';
  static const _currentUserCharaOverviewCacheKey =
      'tinygrail_current_user_chara_overview';
  static const _characterDetailHistoryCacheKey =
      'tinygrail_character_detail_history';
  static const _hiddenFeaturesEnabledKey = 'hidden_features_enabled';
  static const _revealPrivateUserHoldingsEnabledKey =
      'reveal_private_user_holdings_enabled';
  static const _useLiquidGlassKey = 'use_liquid_glass';
  static const _showBotActionKey = 'show_bot_action';
  static const _botRiskAcknowledgedKey = 'bot_risk_acknowledged';
  static const _lastPromptedReleaseTagKey = 'last_prompted_release_tag';
  static const _lastPromptedReleaseTagSavedAtKey =
      'last_prompted_release_tag_saved_at';
  static const _lastActivityReportKey = 'last_activity_report_key';

  /// 读取应用主题模式
  ThemeMode get themeMode {
    final value = _preferences.getString(_themeModeKey);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => _legacyThemeMode,
    };
  }

  /// 保存应用主题模式
  ///
  /// [value] 应用主题模式
  Future<void> setThemeMode(ThemeMode value) {
    return _preferences.setString(_themeModeKey, value.name);
  }

  /// 读取旧版深色模式偏好
  ThemeMode get _legacyThemeMode {
    final prefersDarkMode = _preferences.getBool(_prefersDarkModeKey);
    if (prefersDarkMode == null) {
      return ThemeMode.system;
    }

    return prefersDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  /// 是否启用镜像，关闭时使用官方域名
  bool get useBangumiMirror => _useBangumiMirror;

  /// 最近有效配置中的默认镜像域名
  String get defaultBangumiMirrorHost => _defaultBangumiMirrorHost;

  /// 自定义地址优先，未设置时使用最近有效的默认地址
  String get effectiveBangumiMirrorHost =>
      BangumiMirrorConfig.normalizeHost(bangumiMirrorHost) ??
      defaultBangumiMirrorHost;

  /// 更新已通过校验的默认配置，不覆盖自定义域名
  ///
  /// [host] 从本地缓存或远端配置读取的域名
  void updateDefaultBangumiMirrorHost(String host) {
    final normalized = BangumiMirrorConfig.normalizeHost(host);
    if (normalized == null || normalized == _defaultBangumiMirrorHost) {
      return;
    }
    _defaultBangumiMirrorHost = normalized;
    notifyListeners();
  }

  /// 保存镜像总开关，不改变已保存的自定义地址
  ///
  /// [value] 是否启用镜像
  Future<void> setUseBangumiMirror(bool value) async {
    if (_isSavingMirror) {
      throw StateError('镜像设置正在保存');
    }
    _isSavingMirror = true;
    final previousValue = _useBangumiMirror;
    try {
      final saved = await _preferences.setBool(_useBangumiMirrorKey, value);
      if (!saved) {
        throw StateError('保存镜像开关失败');
      }
      _useBangumiMirror = value;
    } catch (_) {
      await _preferences.setBool(_useBangumiMirrorKey, previousValue);
      rethrow;
    } finally {
      _isSavingMirror = false;
      notifyListeners();
    }
  }

  /// 读取用户保存的自定义域名，未设置时为空
  String? get bangumiMirrorHost {
    return _customBangumiMirrorHost;
  }

  /// 保存自定义镜像域名，空字符串清除覆盖并恢复默认地址
  ///
  /// [value] 自定义域名，空字符串表示使用默认配置
  Future<void> setBangumiMirrorHost(String value) async {
    final host = BangumiMirrorConfig.normalizeHost(value);
    if (value.trim().isNotEmpty && host == null) {
      throw ArgumentError('无效的镜像地址');
    }
    if (_isSavingMirror) {
      throw StateError('镜像设置正在保存');
    }
    _isSavingMirror = true;
    final previousHost = bangumiMirrorHost;
    try {
      final saved = host == null
          ? await _preferences.remove(_bangumiMirrorHostKey)
          : await _preferences.setString(_bangumiMirrorHostKey, host);
      if (!saved) {
        throw StateError('保存镜像地址失败');
      }
      _customBangumiMirrorHost = host;
    } catch (_) {
      if (previousHost == null) {
        await _preferences.remove(_bangumiMirrorHostKey);
      } else {
        await _preferences.setString(_bangumiMirrorHostKey, previousHost);
      }
      rethrow;
    } finally {
      _isSavingMirror = false;
      notifyListeners();
    }
  }

  /// 读取当前登录用户资产缓存
  String? get currentUserAssetsCache {
    return _preferences.getString(_currentUserAssetsCacheKey);
  }

  /// 保存当前登录用户资产缓存
  ///
  /// [value] 序列化后的用户资产数据
  Future<void> setCurrentUserAssetsCache(String value) {
    return _preferences.setString(_currentUserAssetsCacheKey, value);
  }

  /// 清除当前登录用户资产缓存
  Future<void> clearCurrentUserAssetsCache() {
    return _preferences.remove(_currentUserAssetsCacheKey);
  }

  /// 读取当前登录用户角色资产预览缓存
  String? get currentUserCharaOverviewCache {
    return _preferences.getString(_currentUserCharaOverviewCacheKey);
  }

  /// 保存当前登录用户角色资产预览缓存
  ///
  /// [value] 序列化后的角色资产预览数据
  Future<void> setCurrentUserCharaOverviewCache(String value) {
    return _preferences.setString(_currentUserCharaOverviewCacheKey, value);
  }

  /// 清除当前登录用户角色资产预览缓存
  Future<void> clearCurrentUserCharaOverviewCache() {
    return _preferences.remove(_currentUserCharaOverviewCacheKey);
  }

  /// 读取角色详情打开历史缓存
  String? get characterDetailHistoryCache {
    return _preferences.getString(_characterDetailHistoryCacheKey);
  }

  /// 保存角色详情打开历史缓存
  ///
  /// [value] 序列化后的角色详情打开历史
  Future<void> setCharacterDetailHistoryCache(String value) {
    return _preferences.setString(_characterDetailHistoryCacheKey, value);
  }

  /// 清除角色详情打开历史缓存
  Future<void> clearCharacterDetailHistoryCache() {
    return _preferences.remove(_characterDetailHistoryCacheKey);
  }

  /// 读取隐藏功能开关状态
  bool get hiddenFeaturesEnabled {
    return _preferences.getBool(_hiddenFeaturesEnabledKey) ?? false;
  }

  /// 保存隐藏功能开关状态
  ///
  /// [value] 是否启用隐藏功能
  Future<void> setHiddenFeaturesEnabled(bool value) {
    return _preferences.setBool(_hiddenFeaturesEnabledKey, value);
  }

  /// 读取未公开用户持股查看开关状态
  bool get revealPrivateUserHoldingsEnabled {
    return _preferences.getBool(_revealPrivateUserHoldingsEnabledKey) ?? false;
  }

  /// 保存未公开用户持股查看开关状态
  ///
  /// [value] 是否允许点击未公开用户持股
  Future<void> setRevealPrivateUserHoldingsEnabled(bool value) {
    return _preferences.setBool(_revealPrivateUserHoldingsEnabledKey, value);
  }

  /// 读取液态玻璃开关状态
  bool get useLiquidGlass {
    return _preferences.getBool(_useLiquidGlassKey) ?? true;
  }

  /// 保存液态玻璃开关状态
  ///
  /// [value] 是否启用液态玻璃
  Future<void> setUseLiquidGlass(bool value) {
    return _preferences.setBool(_useLiquidGlassKey, value);
  }

  /// 读取 Bot 入口显示状态
  bool get showBotAction {
    return _preferences.getBool(_showBotActionKey) ?? false;
  }

  /// 保存 Bot 入口显示状态
  ///
  /// [value] 是否在当前用户页显示 Bot 入口
  Future<void> setShowBotAction(bool value) {
    return _preferences.setBool(_showBotActionKey, value);
  }

  /// 读取 Bot 托管风险确认状态
  bool get botRiskAcknowledged {
    return _preferences.getBool(_botRiskAcknowledgedKey) ?? false;
  }

  /// 保存 Bot 托管风险确认状态
  ///
  /// [value] 是否已确认 Bot 第三方托管风险
  Future<void> setBotRiskAcknowledged(bool value) {
    return _preferences.setBool(_botRiskAcknowledgedKey, value);
  }

  /// 清除 Bot 托管风险确认状态
  Future<void> clearBotRiskAcknowledged() {
    return _preferences.remove(_botRiskAcknowledgedKey);
  }

  /// 读取上次自动提示的新版本标签
  String? get lastPromptedReleaseTag {
    return _preferences.getString(_lastPromptedReleaseTagKey);
  }

  /// 读取上次自动提示新版本的保存时间
  int? get lastPromptedReleaseTagSavedAtMilliseconds {
    return _preferences.getInt(_lastPromptedReleaseTagSavedAtKey);
  }

  /// 保存上次自动提示的新版本标签
  ///
  /// [tagName] Release 标签名
  /// [savedAt] 保存时间
  Future<void> setLastPromptedReleaseTag({
    required String tagName,
    required DateTime savedAt,
  }) async {
    await _preferences.setString(_lastPromptedReleaseTagKey, tagName);
    await _preferences.setInt(
      _lastPromptedReleaseTagSavedAtKey,
      savedAt.millisecondsSinceEpoch,
    );
  }

  /// 清除上次自动提示的新版本标签
  Future<void> clearLastPromptedReleaseTag() async {
    await _preferences.remove(_lastPromptedReleaseTagKey);
    await _preferences.remove(_lastPromptedReleaseTagSavedAtKey);
  }

  /// 读取上次成功活跃上报的去重键
  String? get lastActivityReportKey {
    return _preferences.getString(_lastActivityReportKey);
  }

  /// 保存成功活跃上报的去重键
  ///
  /// [value] UTC+8 日期、账号、平台和版本组成的去重键
  Future<void> setLastActivityReportKey(String value) {
    return _preferences.setString(_lastActivityReportKey, value);
  }
}
