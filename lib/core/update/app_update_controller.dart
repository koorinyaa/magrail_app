import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/update/app_release_info.dart';
import 'package:magrail_app/core/update/app_update_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final _latestReleasePageUrl = Uri.parse(
  'https://github.com/koorinyaa/magrail_app/releases/latest',
);

// 更新提示记录保留 30 天，避免长期保留旧版本提示状态
const _promptRecordLifetime = Duration(days: 30);

/// 应用更新检查结果
final class AppUpdateCheckResult {
  /// 创建应用更新检查结果
  ///
  /// [currentVersion] 当前应用版本
  /// [latestRelease] 最新 Release 信息
  /// [hasUpdate] 是否存在可更新版本
  const AppUpdateCheckResult({
    required this.currentVersion,
    required this.latestRelease,
    required this.hasUpdate,
  });

  /// 当前应用版本
  final String currentVersion;

  /// 最新 Release 信息
  final AppReleaseInfo? latestRelease;

  /// 是否存在可更新版本
  final bool hasUpdate;
}

/// 应用更新控制器
class AppUpdateController extends ChangeNotifier {
  /// 创建应用更新控制器
  ///
  /// [repository] GitHub 应用更新仓库
  /// [preferences] 本地偏好设置
  AppUpdateController({
    required AppUpdateRepository repository,
    required AppPreferences preferences,
  })  : _repository = repository,
        _preferences = preferences;

  final AppUpdateRepository _repository;
  final AppPreferences _preferences;
  Future<AppUpdateCheckResult>? _activeCheck;
  AppReleaseInfo? _latestRelease;
  String? _currentVersion;
  bool _isChecking = false;

  /// 是否正在检查更新
  bool get isChecking => _isChecking;

  /// 当前应用版本
  String? get currentVersion => _currentVersion;

  /// 最新 Release 信息
  AppReleaseInfo? get latestRelease => _latestRelease;

  /// 是否存在可更新版本
  bool get hasUpdate => _latestRelease != null;

  /// 检查 GitHub Release 是否有新版本
  Future<AppUpdateCheckResult> checkForUpdate() {
    final activeCheck = _activeCheck;
    if (activeCheck != null) {
      return activeCheck;
    }

    final check = _runUpdateCheck();
    _activeCheck = check;
    return check;
  }

  /// 判断当前新版本是否需要自动提示
  Future<bool> shouldShowAutomaticPrompt() async {
    final release = _latestRelease;
    if (release == null) {
      return false;
    }

    final promptedTag = _preferences.lastPromptedReleaseTag;
    final promptedAtMilliseconds =
        _preferences.lastPromptedReleaseTagSavedAtMilliseconds;
    if (promptedTag != release.tagName || promptedAtMilliseconds == null) {
      return true;
    }

    final promptedAt = DateTime.fromMillisecondsSinceEpoch(
      promptedAtMilliseconds,
    );
    final isExpired =
        DateTime.now().difference(promptedAt) > _promptRecordLifetime;
    if (isExpired) {
      await _preferences.clearLastPromptedReleaseTag();
      return true;
    }

    return false;
  }

  /// 记录当前最新版本已自动提示
  Future<void> markLatestReleasePrompted() {
    final release = _latestRelease;
    if (release == null) {
      return Future<void>.value();
    }

    return _preferences.setLastPromptedReleaseTag(
      tagName: release.tagName,
      savedAt: DateTime.now(),
    );
  }

  /// 打开 GitHub 最新 Release 页面
  Future<bool> openLatestReleasePage() {
    return launchUrl(
      _latestReleasePageUrl,
      mode: LaunchMode.externalApplication,
    );
  }

  /// 执行更新检查
  Future<AppUpdateCheckResult> _runUpdateCheck() async {
    _isChecking = true;
    notifyListeners();

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version.trim();
      final release = await _repository.fetchLatestRelease();
      final hasUpdate = release != null &&
          _compareVersions(release.version, currentVersion) > 0;

      _currentVersion = currentVersion;
      _latestRelease = hasUpdate ? release : null;
      return AppUpdateCheckResult(
        currentVersion: currentVersion,
        latestRelease: _latestRelease,
        hasUpdate: hasUpdate,
      );
    } finally {
      _isChecking = false;
      _activeCheck = null;
      notifyListeners();
    }
  }
}

/// 比较两个版本号大小
///
/// [left] 左侧版本号
/// [right] 右侧版本号
int _compareVersions(String left, String right) {
  final leftParts = _versionParts(left);
  final rightParts = _versionParts(right);
  final maxLength = leftParts.length > rightParts.length
      ? leftParts.length
      : rightParts.length;

  for (var index = 0; index < maxLength; index += 1) {
    final leftPart = index < leftParts.length ? leftParts[index] : 0;
    final rightPart = index < rightParts.length ? rightParts[index] : 0;
    if (leftPart != rightPart) {
      return leftPart.compareTo(rightPart);
    }
  }

  return 0;
}

/// 解析版本号数字段
///
/// [version] 版本号文本
List<int> _versionParts(String version) {
  final normalized = version.trim().split('+').first;
  final withoutPrefix = normalized.startsWith('v') || normalized.startsWith('V')
      ? normalized.substring(1)
      : normalized;
  return withoutPrefix.split('.').map(_leadingNumber).toList(growable: false);
}

/// 读取版本号分段开头的数字
///
/// [value] 版本号分段文本
int _leadingNumber(String value) {
  final match = RegExp(r'^\d+').firstMatch(value.trim());
  return int.tryParse(match?.group(0) ?? '') ?? 0;
}
