import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
  /// [onMatched] 展示确认面板，返回是否已经展示
  ClipboardDetailController({
    required this._characterRepository,
    required this._userRepository,
    required this._onMatched,
  });

  final CharacterDetailRepository _characterRepository;
  final UserRepository _userRepository;
  final Future<bool> Function(ClipboardDetailTarget target) _onMatched;
  // 只记录最近读取内容，内容变化后再次允许提示
  String? _lastText;
  var _hasPrompted = false;
  var _isReading = false;
  var _isLookingUp = false;
  var _isPresenting = false;
  var _isForeground = false;
  var _disposed = false;
  var _readId = 0;
  var _requestId = 0;
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
        _isReading ||
        _routeExit != null ||
        target == null ||
        route is! PageRoute ||
        route.settings is! Page) {
      return;
    }

    final text = _lastText;
    _pendingTarget = null;
    _isPresenting = true;
    _hasPrompted = true;
    var presented = false;
    try {
      presented = await _onMatched(target);
    } catch (_) {
      // 自动提示异常不影响当前页面，后续前台恢复仍可重新尝试
    } finally {
      _isPresenting = false;
      if (!_disposed && !presented && text == _lastText) {
        _hasPrompted = false;
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
    pause();
  }

  /// 读取文本并查询特殊关键词，拒绝读取或请求失败时静默结束
  Future<void> _readClipboard() async {
    final readId = ++_readId;
    _isReading = true;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (_disposed || !_isForeground || readId != _readId) return;
      _isReading = false;
      final text = data?.text?.trim() ?? '';
      if (text != _lastText) {
        _lastText = text;
        _hasPrompted = false;
        _pendingTarget = null;
        _isLookingUp = false;
        _requestId += 1;
      }
      if (_hasPrompted || _isLookingUp) return;
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
      if (_disposed || !_isForeground || requestId != _requestId) return;
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
