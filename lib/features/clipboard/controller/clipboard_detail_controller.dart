import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/utils/app_clipboard.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_basic_info.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/search/model/tinygrail_search_keyword.dart';
import 'package:magrail_app/features/clipboard/model/clipboard_detail_target.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 应用前台剪切板详情匹配与确认调度
class ClipboardDetailController extends NavigatorObserver {
  /// 创建剪切板详情控制器
  ///
  /// [characterRepository] 角色资料查询仓库
  /// [userRepository] 用户精确查询仓库
  /// [preferences] 剪切板去重记录存储
  /// [onMatched] 展示确认面板并在展示时调用通知，返回是否已经展示
  ClipboardDetailController({
    required this._characterRepository,
    required this._userRepository,
    required this._preferences,
    required this._onMatched,
  }) {
    final state = _preferences.clipboardDetailState;
    _lastFingerprint = state?.fingerprint;
    _isHandled = state?.isHandled ?? false;
    _copySubscription = AppClipboard.internalCopies.listen(_handleInternalCopy);
  }

  final CharacterDetailRepository _characterRepository;
  final UserRepository _userRepository;
  final AppPreferences _preferences;
  final Future<bool> Function(
    ClipboardDetailTarget target,
    VoidCallback onShown,
  )
  _onMatched;
  late final StreamSubscription<String> _copySubscription;
  // 仅保存最近内容的摘要，展示或内部复制后标记为已处理，内容变化后允许再次提示
  String? _lastFingerprint;
  var _isHandled = false;
  var _isReading = false;
  var _isLookingUp = false;
  var _isPresenting = false;
  var _isForeground = false;
  var _disposed = false;
  var _readId = 0;
  var _requestId = 0;
  // 前后台切换只作废请求，内容变化或内部复制才使旧展示回调失效
  var _contentId = 0;
  Route<dynamic>? _topRoute;
  Future<dynamic>? _routeExit;
  ClipboardDetailTarget? _pendingTarget;

  /// 应用进入前台时读取系统剪切板
  void resume() {
    if (_disposed) return;
    _isForeground = true;
    // 首帧和前台事件重叠时共用在途读取，查询或弹窗期间仍检查内容变化
    if (_isReading) return;
    unawaited(_readClipboard());
  }

  /// 应用进入后台时使未完成的读取和查询失效
  void pause() {
    _isForeground = false;
    _readId += 1;
    _requestId += 1;
    _isLookingUp = false;
    _isReading = false;
    _pendingTarget = null;
  }

  /// 展示当前匹配结果，已有弹层时保留到页面恢复
  Future<void> presentPending() async {
    final target = _pendingTarget;
    final route = _topRoute;
    // 路由页面才允许自动提示，弹窗、搜索浮层及授权页面先完成当前交互
    if (_disposed ||
        !_isForeground ||
        _isPresenting ||
        _isHandled ||
        _isReading ||
        _routeExit != null ||
        target == null ||
        route is! PageRoute ||
        route.settings is! Page) {
      return;
    }

    final fingerprint = _lastFingerprint;
    final requestId = _requestId;
    final contentId = _contentId;
    _pendingTarget = null;
    _isPresenting = true;
    var presented = false;
    var wasShown = false;
    try {
      presented = await _onMatched(target, () {
        wasShown = true;
        if (!_disposed &&
            contentId == _contentId &&
            fingerprint != null &&
            fingerprint == _lastFingerprint) {
          _isHandled = true;
          // 面板展示即保存，关闭前退出应用也不会在下次启动时重复提示
          unawaited(_saveState(fingerprint, isHandled: true));
        }
      });
    } catch (_) {
      // 自动提示异常不影响当前页面，后续前台恢复仍可重新尝试
    } finally {
      _isPresenting = false;
      if (!_disposed &&
          !presented &&
          !wasShown &&
          requestId == _requestId &&
          fingerprint == _lastFingerprint) {
        _isHandled = false;
        _pendingTarget = target;
      }
    }

    if (presented && !_disposed && _pendingTarget != null) {
      await presentPending();
    }
  }

  /// 顶层页面变化后尝试显示等待中的结果
  ///
  /// [topRoute] 当前顶层路由
  /// [previousTopRoute] 上一次顶层路由
  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    _topRoute = topRoute;
    if (previousTopRoute is TransitionRoute && !previousTopRoute.isActive) {
      // 关闭路由的 Future 在退场开始时完成，等动画结束后再显示下一条提示
      final exit = previousTopRoute.completed;
      _routeExit = exit;
      unawaited(
        exit.then((_) {
          if (identical(_routeExit, exit)) {
            _routeExit = null;
            unawaited(presentPending());
          }
        }),
      );
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(presentPending());
    });
  }

  /// 释放控制器并使旧请求结果失效
  void dispose() {
    _disposed = true;
    unawaited(_copySubscription.cancel());
    pause();
  }

  /// 内部复制成功后使旧读取、查询及待展示结果失效
  ///
  /// [fingerprint] 已由复制入口保存的内容摘要
  void _handleInternalCopy(String fingerprint) {
    if (_disposed) return;
    _readId += 1;
    _requestId += 1;
    _contentId += 1;
    _isReading = false;
    _isLookingUp = false;
    _pendingTarget = null;
    _lastFingerprint = fingerprint;
    _isHandled = true;
  }

  /// 保存当前内容处理状态，存储失败时保留本次运行的去重状态
  ///
  /// [fingerprint] 本次读取或展示的内容摘要
  /// [isHandled] 是否已经展示确认面板
  Future<void> _saveState(String fingerprint, {required bool isHandled}) async {
    try {
      await _preferences.saveClipboardDetailState(
        fingerprint: fingerprint,
        isHandled: isHandled,
      );
    } catch (_) {
      // 去重记录保存失败不阻止读取、查询或显示确认面板
    }
  }

  /// 读取文本并查询特殊关键词，拒绝读取或请求失败时静默结束
  Future<void> _readClipboard() async {
    final readId = ++_readId;
    _isReading = true;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (_disposed || !_isForeground || readId != _readId) return;
      final text = data?.text?.trim() ?? '';
      final fingerprint = AppClipboard.fingerprint(text);
      if (fingerprint != _lastFingerprint) {
        _lastFingerprint = fingerprint;
        _contentId += 1;
        _isHandled = false;
        _pendingTarget = null;
        _isLookingUp = false;
        _requestId += 1;
        await _saveState(fingerprint, isHandled: false);
        if (_disposed || !_isForeground || readId != _readId) return;
      }
      _isReading = false;
      if (_isHandled || _isLookingUp) return;
      if (_pendingTarget != null) {
        await presentPending();
        return;
      }

      final keyword = TinygrailSearchKeyword.parse(text);
      if (keyword.scope == TinygrailSearchScope.all) return;
      final requestId = ++_requestId;
      _isLookingUp = true;
      ClipboardDetailTarget? target;
      try {
        target = await _findTarget(keyword);
      } finally {
        if (requestId == _requestId) _isLookingUp = false;
      }
      if (_disposed ||
          !_isForeground ||
          _isHandled ||
          requestId != _requestId) {
        return;
      }
      _pendingTarget = target;
      await presentPending();
    } catch (_) {
      // 剪切板读取或查询失败时静默结束，不影响当前页面
    } finally {
      if (readId == _readId) _isReading = false;
    }
  }

  /// 精确查询特殊关键词对应的角色或用户
  ///
  /// [keyword] 已提取的特殊关键词与查询范围
  Future<ClipboardDetailTarget?> _findTarget(
    TinygrailSearchKeyword keyword,
  ) async {
    if (keyword.scope == TinygrailSearchScope.character) {
      final id = int.tryParse(keyword.keyword);
      if (id == null || id <= 0) return null;
      final character = await _characterRepository.fetchCharacterBasicInfo(id);
      if (character.characterId != id ||
          character.name.trim().isEmpty ||
          (character.pageType == CharacterDetailPageType.trade &&
              character.tradeHeader == null) ||
          (character.pageType == CharacterDetailPageType.ico &&
              character.icoInfo == null) ||
          (character.pageType != CharacterDetailPageType.trade &&
              character.pageType != CharacterDetailPageType.ico)) {
        return null;
      }
      return ClipboardCharacterTarget(character: character);
    }

    final user = await _userRepository.findUserProfile(
      username: keyword.keyword,
    );
    if (user == null || user.name.trim() != keyword.keyword) {
      return null;
    }
    return ClipboardUserTarget(user: user);
  }
}
