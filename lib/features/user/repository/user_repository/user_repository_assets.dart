part of '../user_repository.dart';

// 旧会话结果只结束对应任务，不清除或覆盖当前会话的数据
const _changedUserSessionResult = UserAssetsFetchResult.failure('登录状态已变更，请重试');

/// 用户资产请求与当前会话边界
extension _UserRepositoryAssets on UserRepository {
  /// 请求用户资产并校验当前用户会话
  ///
  /// [username] 用户名，空值表示当前用户
  Future<UserAssetsFetchResult> _fetchAssets({String? username}) async {
    final isCurrentUserRequest = isCachedCurrentUser(username);
    var sessionGeneration = isCurrentUserRequest
        ? _authRepository.captureSessionGeneration()
        : null;
    if (isCurrentUserRequest) {
      try {
        final hasCookie = await _authRepository.hasTinygrailCookie();
        if (!hasCookie) {
          return _handleCurrentUserAuthExpired('请先授权', generation: null);
        }
        final activeGeneration = _authRepository.captureSessionGeneration();
        if (activeGeneration == null ||
            (sessionGeneration != null &&
                sessionGeneration != activeGeneration)) {
          return _changedUserSessionResult;
        }
        sessionGeneration = activeGeneration;
      } catch (_) {
        return _handleCurrentUserAuthExpired(
          '请先授权',
          generation: sessionGeneration,
        );
      }
    }

    final path = username == null || username.isEmpty
        ? 'chara/user/assets'
        : 'chara/user/assets/${_encodeUsername(username)}';

    try {
      final json = await _apiClient.getJson<Map<String, Object?>>(path);
      // 请求完成时先确认归属，旧成功结果和旧鉴权失败都不能修改新会话
      if (isCurrentUserRequest && !_isAssetsSessionCurrent(sessionGeneration)) {
        return _changedUserSessionResult;
      }
      final response = TinygrailResponse<UserDetailProfile>.fromJson(json, (
        value,
      ) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        return valueJson == null ? null : UserDetailProfile.fromJson(valueJson);
      });

      final profile = response.value;
      if (!response.isSuccess || profile == null) {
        final message = response.message ?? '获取用户资产失败';
        return isCurrentUserRequest
            ? _handleCurrentUserAuthExpired(
                message,
                generation: sessionGeneration,
              )
            : UserAssetsFetchResult.failure(message);
      }

      if (isCurrentUserRequest) {
        try {
          await cacheCurrentUserAssets(profile);
        } catch (_) {
          // 缓存写入失败不影响本次接口结果返回
        }
        if (!_isAssetsSessionCurrent(sessionGeneration)) {
          return _changedUserSessionResult;
        }
        // 仅上报仍属于当前会话的接口结果
        unawaited(
          _activityReporter.report(
            userId: profile.userId,
            username: profile.name,
          ),
        );
      }
      return UserAssetsFetchResult.success(profile);
    } on ApiException catch (error) {
      if (isCurrentUserRequest && !_isAssetsSessionCurrent(sessionGeneration)) {
        return _changedUserSessionResult;
      }
      if (isCurrentUserRequest &&
          (error.statusCode == 401 || error.statusCode == 403)) {
        return _handleCurrentUserAuthExpired(
          error.message,
          generation: sessionGeneration,
        );
      }
      return UserAssetsFetchResult.failure(error.message);
    } catch (_) {
      return const UserAssetsFetchResult.failure('获取用户资产失败');
    }
  }

  /// 判断资产请求是否仍属于当前有效会话
  ///
  /// [generation] 请求捕获的会话代际
  bool _isAssetsSessionCurrent(int? generation) {
    return generation != null &&
        _authRepository.isSessionGenerationCurrent(generation);
  }

  /// 清理当前失效会话的缓存
  ///
  /// [message] 会话失效提示
  /// [generation] 产生失败结果的会话代际，空值表示无本地 Cookie
  Future<UserAssetsFetchResult> _handleCurrentUserAuthExpired(
    String message, {
    required int? generation,
  }) async {
    if (_authRepository.captureSessionGeneration() != generation) {
      return _changedUserSessionResult;
    }
    await clearCurrentUserAssetsCache();
    if (_authRepository.captureSessionGeneration() != generation) {
      return _changedUserSessionResult;
    }
    unawaited(_activityReporter.report());
    return UserAssetsFetchResult.authExpired(message);
  }
}
