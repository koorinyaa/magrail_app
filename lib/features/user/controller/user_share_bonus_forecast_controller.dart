import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/features/user/model/user_share_bonus_forecast.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 用户股息预测控制器
class UserShareBonusForecastController extends ChangeNotifier {
  /// 创建用户股息预测控制器
  ///
  /// [repository] 用户仓库
  /// [username] 目标用户名
  UserShareBonusForecastController({
    required UserRepository repository,
    required String username,
  })  : _repository = repository,
        _username = username;

  final UserRepository _repository;
  final String _username;

  UserShareBonusForecast? _forecast;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isDisposed = false;

  /// 股息预测数据
  UserShareBonusForecast? get forecast => _forecast;

  /// 加载错误文案
  String? get errorMessage => _errorMessage;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 初始化股息预测数据
  Future<void> initialize() {
    return load();
  }

  /// 加载股息预测数据
  Future<void> load() async {
    if (_isLoading || _isDisposed) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _notifyIfActive();

    try {
      final forecast = await _repository.fetchShareBonusForecast(
        username: _username,
      );
      if (_isDisposed) {
        return;
      }

      _forecast = forecast;
    } catch (error) {
      if (_isDisposed) {
        return;
      }

      _errorMessage = _resolveErrorMessage(error);
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _notifyIfActive();
      }
    }
  }

  /// 释放股息预测控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 解析加载错误文案
  ///
  /// [error] 原始错误
  String _resolveErrorMessage(Object error) {
    return resolveUserErrorMessage(error, fallback: '获取股息预测失败');
  }

  /// 通知仍挂载的监听者
  void _notifyIfActive() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
