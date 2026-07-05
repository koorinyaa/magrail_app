import 'package:dio/dio.dart';
import 'package:magrail_app/core/update/app_release_info.dart';

const _latestReleaseApiUrl =
    'https://api.github.com/repos/koorinyaa/magrail_app/releases/latest';

/// GitHub 应用更新仓库
class AppUpdateRepository {
  /// 创建 GitHub 应用更新仓库
  ///
  /// [dio] 用于访问 GitHub Releases API 的 Dio 客户端
  const AppUpdateRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// 获取 GitHub 最新正式 Release
  Future<AppReleaseInfo?> fetchLatestRelease() async {
    final response = await _dio.get<Object?>(
      _latestReleaseApiUrl,
      options: Options(
        headers: const {
          'Accept': 'application/vnd.github+json',
        },
      ),
    );
    final data = response.data;
    if (data is! Map<String, Object?>) {
      throw StateError('检查更新失败');
    }

    final isDraft = data['draft'] == true;
    final isPrerelease = data['prerelease'] == true;
    if (isDraft || isPrerelease) {
      return null;
    }

    final tagName = (data['tag_name'] as String? ?? '').trim();
    final releaseUrl = Uri.tryParse(
      (data['html_url'] as String? ?? '').trim(),
    );
    if (tagName.isEmpty || releaseUrl == null) {
      throw StateError('检查更新失败');
    }

    return AppReleaseInfo(
      tagName: tagName,
      version: _versionFromTag(tagName),
      name: (data['name'] as String? ?? '').trim(),
      body: (data['body'] as String? ?? '').trim(),
      htmlUrl: releaseUrl,
      publishedAt: DateTime.tryParse(
        (data['published_at'] as String? ?? '').trim(),
      ),
    );
  }
}

/// 从 Release 标签中提取版本号
///
/// [tagName] Release 标签名
String _versionFromTag(String tagName) {
  final normalized = tagName.trim();
  if (normalized.startsWith('v') || normalized.startsWith('V')) {
    return normalized.substring(1);
  }

  return normalized;
}
