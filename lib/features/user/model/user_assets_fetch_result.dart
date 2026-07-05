import 'package:magrail_app/features/user/model/user_detail_profile.dart';

/// 用户资产请求状态
enum UserAssetsFetchStatus {
  /// 请求成功
  success,

  /// 当前会话失效
  authExpired,

  /// 请求失败
  failure,
}

/// 用户资产请求结果
final class UserAssetsFetchResult {
  /// 创建用户资产请求结果
  ///
  /// [status] 请求状态
  /// [profile] 用户资产资料
  /// [message] 结果消息
  const UserAssetsFetchResult({
    required this.status,
    this.profile,
    this.message,
  });

  /// 创建成功结果
  ///
  /// [profile] 用户资产资料
  const UserAssetsFetchResult.success(UserDetailProfile profile)
      : this(
          status: UserAssetsFetchStatus.success,
          profile: profile,
        );

  /// 创建会话失效结果
  ///
  /// [message] 结果消息
  const UserAssetsFetchResult.authExpired(String message)
      : this(
          status: UserAssetsFetchStatus.authExpired,
          message: message,
        );

  /// 创建失败结果
  ///
  /// [message] 结果消息
  const UserAssetsFetchResult.failure(String message)
      : this(
          status: UserAssetsFetchStatus.failure,
          message: message,
        );

  /// 请求状态
  final UserAssetsFetchStatus status;

  /// 用户资产资料
  final UserDetailProfile? profile;

  /// 结果消息
  final String? message;
}
