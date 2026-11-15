import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/update/app_content_version.dart';
import 'package:magrail_app/core/update/app_patch_updater.dart';
import 'package:magrail_app/core/update/app_release_info.dart';
import 'package:magrail_app/core/update/app_update_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final _latestReleasePageUrl = Uri.parse(
  'https://github.com/koorinyaa/magrail_app/releases/latest',
);

// 更新提示记录保留 30 天，避免长期保留旧版本提示状态
const _promptRecordLifetime = Duration(days: 30);

// 并行检查最多等待 15 秒，超时后仍允许从 GitHub 获取整包
const _updateCheckTimeout = Duration(seconds: 15);

/// 应用更新检查结果
final class AppUpdateCheckResult {
  /// 创建应用更新检查结果
  ///
  /// [currentVersion] 当前应用版本
  /// [latestRelease] 最新 Release 信息
  /// [hasUpdate] 是否存在可更新版本
  /// [restartRequired] 是否有代码变更等待下次完整启动
  /// [checkFailed] 是否未能取得 GitHub 最新版本，不能确认已是最新版
  const AppUpdateCheckResult({
    required this.currentVersion,
    required this.latestRelease,
    required this.hasUpdate,
    required this.restartRequired,
    required this.checkFailed,
  });

  /// 当前应用版本
  final String currentVersion;

  /// 最新 Release 信息
  final AppReleaseInfo? latestRelease;

  /// 是否存在可更新版本
  final bool hasUpdate;

  /// 是否有更新或回滚等待下次完整启动
  final bool restartRequired;

  /// 是否未能确认 GitHub 最新版本
  final bool checkFailed;
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
  }) : _repository = repository,
       _preferences = preferences {
    _patchUpdater.addListener(_handlePatchChanged);
  }

  final AppUpdateRepository _repository;
  final AppPreferences _preferences;
  final _patchUpdater = AppPatchUpdater();
  Future<AppUpdateCheckResult>? _activeCheck;
  AppReleaseInfo? _latestRelease;
  String? _installedVersion;
  bool _isChecking = false;
  bool _disposed = false;

  /// 是否正在检查更新
  bool get isChecking => _isChecking;

  /// 当前运行代码的内容版本，用于与 GitHub 标签比较
  String get currentVersion => appContentVersion;

  /// 系统记录的基础包版本及构建号，补丁不会改变该值
  String? get installedVersion => _installedVersion;

  /// 当前进程实际运行的补丁号，空值表示基础包代码
  int? get currentPatch => _patchUpdater.currentPatch;

  /// 是否仍在后台准备补丁，整包检查超时不会取消引擎下载
  bool get isPreparingPatch => _patchUpdater.isChecking;

  /// 是否有更新或回滚需要下次完整启动生效
  bool get restartRequired => _patchUpdater.restartRequired;

  /// 是否需要重启以撤回当前补丁
  bool get rollbackPending => _patchUpdater.rollbackPending;

  /// 是否需要在设置入口显示更新标记
  bool get hasUpdateNotice => hasUpdate || restartRequired;

  /// 最新 Release 信息
  AppReleaseInfo? get latestRelease => _latestRelease;

  /// 是否需要提供整包更新，优先等待已下载的新补丁生效
  bool get hasUpdate => !_isChecking && _needsFullUpdate;

  /// 根据实际运行内容判断整包后备，不持久化已热更新标记
  bool get _needsFullUpdate {
    final release = _latestRelease;
    return release != null &&
        !_patchUpdater.updatePending &&
        (rollbackPending || _compareVersions(release.version, currentVersion) > 0);
  }

  /// 并行检查 GitHub 与补丁，优先热更新且为整包后备保留有限等待时间
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
    if (release == null || !hasUpdate) {
      return false;
    }
    if (rollbackPending) return true;

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
    if (release == null || !hasUpdate) {
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
      _latestRelease?.htmlUrl ?? _latestReleasePageUrl,
      mode: LaunchMode.externalApplication,
    );
  }

  /// 取得基础包版本供关于页面展示，读取失败不阻断网络检查
  Future<void> loadInstalledVersion() async {
    if (_installedVersion != null || _disposed) return;

    try {
      final info = await PackageInfo.fromPlatform();
      if (_disposed) return;
      _installedVersion = info.buildNumber.isEmpty
          ? info.version
          : '${info.version}+${info.buildNumber}';
      _notify();
    } catch (_) {
      // 内容版本独立于平台包信息，仍可判断是否需要更新
    }
  }

  /// 重新进入前台时核对引擎已经完成的下载，不额外发起网络请求
  Future<void> refreshPatchState() => _patchUpdater.refreshState();

  /// 执行有限等待的并行检查，补丁失败不影响 GitHub 结果
  Future<AppUpdateCheckResult> _runUpdateCheck() async {
    _isChecking = true;
    _notify();
    unawaited(loadInstalledVersion());
    var githubCheckFailed = false;

    try {
      final githubCheck = _repository.fetchLatestRelease()
          .timeout(_updateCheckTimeout)
          .then<void>((release) {
            if (!_disposed) _latestRelease = release;
          }).catchError((Object error) {
            githubCheckFailed = true;
            // 不沿用上次成功结果声称本次检查已完成
            if (!_disposed) _latestRelease = null;
          });
      final patchCheck = _patchUpdater.checkForUpdate().timeout(
        _updateCheckTimeout,
        onTimeout: () {
          // 引擎请求继续执行，晚到的下载结果仍可撤销整包后备状态
        },
      );
      await Future.wait<void>([githubCheck, patchCheck]);

      return AppUpdateCheckResult(
        currentVersion: currentVersion,
        latestRelease: _latestRelease,
        hasUpdate: _needsFullUpdate,
        restartRequired: restartRequired,
        checkFailed: githubCheckFailed,
      );
    } finally {
      _isChecking = false;
      _activeCheck = null;
      _notify();
    }
  }

  /// 将补丁的晚到状态同步到更新入口和已经打开的更新面板
  void _handlePatchChanged() {
    _notify();
  }

  /// 仅在控制器有效时通知页面
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// 释放更新通知，后台引擎请求仍由补丁更新器处理
  @override
  void dispose() {
    _disposed = true;
    _patchUpdater.removeListener(_handlePatchChanged);
    _patchUpdater.dispose();
    super.dispose();
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
