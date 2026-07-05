import 'package:shared_preferences/shared_preferences.dart';

/// 本地偏好设置
class AppPreferences {
  /// 创建本地偏好设置
  ///
  /// [_preferences] SharedPreferences 实例
  AppPreferences(this._preferences);

  final SharedPreferences _preferences;

  static const _prefersDarkModeKey = 'prefers_dark_mode';
  static const _useBangumiMirrorKey = 'use_bangumi_mirror';
  static const _bangumiMirrorHostKey = 'bangumi_mirror_host';
  static const _currentUserAssetsCacheKey = 'tinygrail_current_user_assets';
  static const _currentUserCharaOverviewCacheKey =
      'tinygrail_current_user_chara_overview';
  static const _characterDetailHistoryCacheKey =
      'tinygrail_character_detail_history';
  static const _lastPromptedReleaseTagKey = 'last_prompted_release_tag';
  static const _lastPromptedReleaseTagSavedAtKey =
      'last_prompted_release_tag_saved_at';

  /// 读取深色模式偏好
  bool get prefersDarkMode =>
      _preferences.getBool(_prefersDarkModeKey) ?? false;

  /// 保存深色模式偏好
  ///
  /// [value] 深色模式偏好值
  Future<void> setPrefersDarkMode(bool value) {
    return _preferences.setBool(_prefersDarkModeKey, value);
  }

  /// 读取 Bangumi 镜像偏好
  bool get useBangumiMirror =>
      _preferences.getBool(_useBangumiMirrorKey) ?? false;

  /// 保存 Bangumi 镜像偏好
  ///
  /// [value] 是否使用 Bangumi 镜像
  Future<void> setUseBangumiMirror(bool value) {
    return _preferences.setBool(_useBangumiMirrorKey, value);
  }

  /// 读取 Bangumi 镜像域名
  String? get bangumiMirrorHost {
    return _preferences.getString(_bangumiMirrorHostKey);
  }

  /// 保存 Bangumi 镜像域名
  ///
  /// [value] Bangumi 镜像域名
  Future<void> setBangumiMirrorHost(String value) {
    return _preferences.setString(_bangumiMirrorHostKey, value);
  }

  /// 清除 Bangumi 镜像域名
  Future<void> clearBangumiMirrorHost() {
    return _preferences.remove(_bangumiMirrorHostKey);
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
}
