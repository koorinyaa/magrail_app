import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/features/user/analysis/model/user_asset_analysis.dart';
import 'package:magrail_app/features/user/analysis/repository/user_asset_analysis_repository.dart';

/// 用户资产分析控制器
class UserAssetAnalysisController extends ChangeNotifier {
  /// 创建用户资产分析控制器
  ///
  /// [repository] 用户资产分析仓库
  /// [username] 用户名
  /// [nickname] 用户昵称
  UserAssetAnalysisController({
    required UserAssetAnalysisRepository repository,
    required String username,
    required String nickname,
  })  : _repository = repository,
        _username = username.trim(),
        _nickname = nickname.trim();

  final UserAssetAnalysisRepository _repository;
  final String _username;
  final String _nickname;

  UserAssetAnalysis? _analysis;
  String? _errorMessage;
  String _progressLabel = '';
  double _progress = 0;
  int _characterCompletedSteps = 0;
  int _characterTotalSteps = 1;
  int _templeCompletedSteps = 0;
  int _templeTotalSteps = 1;
  int _analysisCompletedSteps = 0;
  int _analysisTotalSteps = 1;
  bool _isInitialLoading = false;
  bool _isRefreshing = false;
  bool _isDisposed = false;
  Future<void>? _initializeOperation;
  Future<bool>? _refreshOperation;

  /// 用户资产分析结果
  UserAssetAnalysis? get analysis => _analysis;

  /// 加载错误文案
  String? get errorMessage => _errorMessage;

  /// 是否正在首次加载
  bool get isInitialLoading => _isInitialLoading;

  /// 是否正在刷新
  bool get isRefreshing => _isRefreshing;

  /// 加载进度文案
  String get progressLabel => _progressLabel;

  /// 加载进度
  double get progress => _progress;

  /// 资产分析更新时间文案
  String get analysisAgeLabel {
    final analysis = _analysis;
    if (analysis == null) {
      return '';
    }

    final elapsed = DateTime.now().difference(analysis.updatedAt);
    if (elapsed.inMinutes < 1) {
      return '刚刚';
    }
    if (elapsed.inHours < 1) {
      return '${elapsed.inMinutes} 分钟前';
    }
    if (elapsed.inDays < 1) {
      return '${elapsed.inHours} 小时前';
    }
    return '${elapsed.inDays} 天前';
  }

  /// 初始化用户资产分析
  Future<void> initialize() {
    final existingOperation = _initializeOperation;
    if (existingOperation != null) {
      return existingOperation;
    }

    late final Future<void> operation;
    operation = _initialize().whenComplete(() {
      if (identical(_initializeOperation, operation)) {
        _initializeOperation = null;
      }
    });
    _initializeOperation = operation;
    return operation;
  }

  /// 执行用户资产分析初始化
  Future<void> _initialize() async {
    if (_username.isEmpty || _isDisposed) {
      _errorMessage = '缺少用户名';
      _notifyIfActive();
      return;
    }

    _isInitialLoading = _analysis == null;
    _progressLabel = '正在加载资产分析';
    _notifyIfActive();

    UserAssetAnalysis? analysis;
    try {
      analysis = await _repository.loadAnalysis(_username);
    } catch (error) {
      if (_isDisposed) {
        return;
      }

      _errorMessage = resolveUserErrorMessage(
        error,
        fallback: '加载资产分析失败',
      );
      _isInitialLoading = false;
      _notifyIfActive();
      return;
    }
    if (_isDisposed) {
      return;
    }
    if (analysis != null) {
      _analysis = analysis;
      _isInitialLoading = false;
      _notifyIfActive();
      return;
    }

    await refresh();
  }

  /// 刷新用户资产分析数据
  Future<bool> refresh() {
    if (_isRefreshing || _isDisposed) {
      return Future.value(false);
    }

    late final Future<bool> operation;
    operation = _refresh().whenComplete(() {
      if (identical(_refreshOperation, operation)) {
        _refreshOperation = null;
      }
    });
    _refreshOperation = operation;
    return operation;
  }

  /// 执行用户资产分析刷新
  Future<bool> _refresh() async {
    _isRefreshing = true;
    _isInitialLoading = _analysis == null;
    _errorMessage = null;
    _resetProgress();
    _notifyIfActive();

    try {
      final analysis = await _repository.refreshAnalysis(
        username: _username,
        nickname: _nickname,
        onProgress: _handleProgress,
      );
      if (_isDisposed) {
        return false;
      }

      _analysis = analysis;
      return true;
    } catch (error) {
      if (_isDisposed) {
        return false;
      }

      _errorMessage = resolveUserErrorMessage(
        error,
        fallback: '获取资产分析失败',
      );
      return false;
    } finally {
      if (!_isDisposed) {
        _isRefreshing = false;
        _isInitialLoading = false;
        _notifyIfActive();
      }
    }
  }

  /// 等待当前初始化与刷新任务结束
  Future<void> waitForPendingOperations() async {
    final initializeOperation = _initializeOperation;
    if (initializeOperation != null) {
      await initializeOperation;
    }

    final refreshOperation = _refreshOperation;
    if (refreshOperation != null) {
      await refreshOperation;
    }
  }

  /// 释放用户资产分析控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 处理加载进度
  ///
  /// [progress] 最新加载进度
  void _handleProgress(UserAssetAnalysisLoadProgress progress) {
    switch (progress.kind) {
      case UserAssetAnalysisLoadKind.characters:
        _characterCompletedSteps = progress.completedSteps;
        _characterTotalSteps = progress.totalSteps;
      case UserAssetAnalysisLoadKind.temples:
        _templeCompletedSteps = progress.completedSteps;
        _templeTotalSteps = progress.totalSteps;
      case UserAssetAnalysisLoadKind.analysis:
        _analysisCompletedSteps = progress.completedSteps;
        _analysisTotalSteps = progress.totalSteps;
    }
    _progressLabel = progress.label;
    final completedSteps = _characterCompletedSteps +
        _templeCompletedSteps +
        _analysisCompletedSteps;
    final totalSteps =
        _characterTotalSteps + _templeTotalSteps + _analysisTotalSteps;
    _progress = totalSteps <= 0
        ? 0
        : (completedSteps / totalSteps).clamp(0, 1).toDouble();
    _notifyIfActive();
  }

  /// 重置加载进度
  void _resetProgress() {
    _progressLabel = '正在准备资产分析';
    _progress = 0;
    _characterCompletedSteps = 0;
    _characterTotalSteps = 1;
    _templeCompletedSteps = 0;
    _templeTotalSteps = 1;
    _analysisCompletedSteps = 0;
    _analysisTotalSteps = 2;
  }

  /// 通知仍挂载的监听者
  void _notifyIfActive() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
