import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';

/// Tinygrail 授权状态
enum AuthStatus {
  /// 正在检查本地 Cookie 会话
  checking,

  /// 当前没有可用 Tinygrail 会话
  unauthenticated,

  /// 正在用 Dio 消费 Tinygrail callback
  authenticating,

  /// 已存在可用 Tinygrail 会话
  authenticated,

  /// 授权或会话检查失败
  failure,
}

/// Tinygrail 授权状态数据
class AuthState {
  /// 创建授权状态
  ///
  /// [status] 授权状态
  /// [errorMessage] 错误说明
  const AuthState._({
    required this.status,
    this.errorMessage,
  });

  /// 创建“检查中”状态
  const AuthState.checking() : this._(status: AuthStatus.checking);

  /// 创建“未授权”状态
  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  /// 创建“授权中”状态
  const AuthState.authenticating() : this._(status: AuthStatus.authenticating);

  /// 创建“已授权”状态
  const AuthState.authenticated() : this._(status: AuthStatus.authenticated);

  /// 创建失败状态
  ///
  /// [errorMessage] 失败原因
  const AuthState.failure(String errorMessage)
      : this._(status: AuthStatus.failure, errorMessage: errorMessage);

  final AuthStatus status;
  final String? errorMessage;

  /// 判断是否忙碌
  bool get isBusy =>
      status == AuthStatus.checking || status == AuthStatus.authenticating;

  /// 比较授权状态
  ///
  /// [other] 对比对象
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AuthState &&
            other.status == status &&
            other.errorMessage == errorMessage;
  }

  /// 生成哈希值
  @override
  int get hashCode => Object.hash(status, errorMessage);

  /// 返回调试文本
  @override
  String toString() {
    return 'AuthState(status: $status, errorMessage: $errorMessage)';
  }
}

/// Tinygrail 授权 Cubit
class AuthCubit extends Cubit<AuthState> {
  /// 创建授权 Cubit
  ///
  /// [_authRepository] 授权仓库
  AuthCubit(this._authRepository) : super(const AuthState.checking());

  final TinygrailAuthRepository _authRepository;

  /// 检查 Tinygrail 会话
  Future<void> checkSession() async {
    if (isClosed) {
      return;
    }

    _emitIfActive(const AuthState.checking());

    try {
      final hasCookie = await _authRepository.hasTinygrailCookie();
      _emitIfActive(
        hasCookie
            ? const AuthState.authenticated()
            : const AuthState.unauthenticated(),
      );
    } catch (error) {
      _emitIfActive(
        AuthState.failure(resolveUserErrorMessage(error, fallback: '检查登录状态失败')),
      );
    }
  }

  /// 完成 Tinygrail 登录
  ///
  /// [callbackUri] 授权回调地址
  Future<void> completeLogin(Uri callbackUri) async {
    if (isClosed) {
      return;
    }

    if (state.status == AuthStatus.authenticating) {
      return;
    }

    _emitIfActive(const AuthState.authenticating());

    try {
      await _authRepository.consumeCallback(callbackUri);

      // CookieJar 登录状态确认：callback 完成后重新读取 Cookie
      final hasCookie = await _authRepository.hasTinygrailCookie();
      if (!hasCookie) {
        _emitIfActive(const AuthState.failure('授权失败'));
        return;
      }

      _emitIfActive(const AuthState.authenticated());
    } catch (error) {
      _emitIfActive(
        AuthState.failure(resolveUserErrorMessage(error, fallback: '授权失败')),
      );
    }
  }

  /// 退出登录
  Future<void> signOut() async {
    if (isClosed) {
      return;
    }

    _emitIfActive(const AuthState.checking());

    try {
      await _authRepository.clearSession();
      _emitIfActive(const AuthState.unauthenticated());
    } catch (error) {
      _emitIfActive(
        AuthState.failure(resolveUserErrorMessage(error, fallback: '退出登录失败')),
      );
    }
  }

  /// 清除错误状态
  void dismissError() {
    if (isClosed) {
      return;
    }

    if (state.status == AuthStatus.failure) {
      _emitIfActive(const AuthState.unauthenticated());
    }
  }

  /// 在 Cubit 未关闭时输出授权状态
  ///
  /// [state] 下一份授权状态
  void _emitIfActive(AuthState state) {
    if (isClosed) {
      return;
    }

    emit(state);
  }
}
