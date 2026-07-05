import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';

/// 角色详情公开展示区控制器
class CharacterDetailCollectionsController extends ChangeNotifier {
  /// 创建角色详情公开展示区控制器
  ///
  /// [repository] 角色详情仓库
  /// [characterId] 角色 ID
  CharacterDetailCollectionsController({
    required CharacterDetailRepository repository,
    required int characterId,
  })  : _repository = repository,
        _characterId = characterId;

  static const int _linkPreviewLimit = 6;
  static const int _templePreviewLimit = 12;

  final CharacterDetailRepository _repository;
  final int _characterId;

  var _links = const <CharacterDetailTempleItem>[];
  var _temples = const <CharacterDetailTempleItem>[];
  var _isLoadingLinks = false;
  var _isLoadingTemples = false;
  var _linkErrorMessage = '';
  var _templeErrorMessage = '';
  var _linksRequestId = 0;
  var _templesRequestId = 0;
  var _isDisposed = false;

  /// LINK 是否正在加载
  bool get isLoadingLinks => _isLoadingLinks;

  /// 固定资产是否正在加载
  bool get isLoadingTemples => _isLoadingTemples;

  /// LINK 加载失败文案
  String get linkErrorMessage => _linkErrorMessage;

  /// 圣殿加载失败文案
  String get templeErrorMessage => _templeErrorMessage;

  /// LINK 是否加载失败
  bool get hasLinkError => _linkErrorMessage.isNotEmpty;

  /// 固定资产是否加载失败
  bool get hasTempleError => _templeErrorMessage.isNotEmpty;

  /// 角色 LINK 原始列表
  List<CharacterDetailTempleItem> get links => _links;

  /// 角色固定资产原始列表
  List<CharacterDetailTempleItem> get temples => _temples;

  /// 有效 LINK 列表
  List<CharacterDetailTempleItem> get validLinks {
    return [
      for (final item in _links)
        if (item.hasLink) item,
    ];
  }

  /// 固定资产与 LINK 合并列表
  List<CharacterDetailTempleItem> get mergedTemples {
    return [
      ..._temples,
      ...validLinks,
    ];
  }

  /// LINK 一级预览列表
  List<CharacterDetailTempleItem> get previewLinks {
    return validLinks.take(_linkPreviewLimit).toList(growable: false);
  }

  /// 固定资产一级预览列表
  List<CharacterDetailTempleItem> get previewTemples {
    return _hideDuplicateCovers(mergedTemples)
        .take(_templePreviewLimit)
        .toList(growable: false);
  }

  /// 从合并后的圣殿与连接中查找拥有者条目
  ///
  /// [ownerName] 拥有者用户名
  CharacterDetailTempleItem? templeForOwnerName(String ownerName) {
    final username = ownerName.trim();
    if (username.isEmpty) {
      return null;
    }

    for (final item in mergedTemples) {
      if (item.ownerName.trim() == username) {
        return item;
      }
    }

    return null;
  }

  /// 初始化公开展示区数据
  void initialize() {
    unawaited(loadLinks());
    unawaited(loadTemples());
  }

  /// 重新加载 LINK 数据
  Future<void> loadLinks() async {
    final requestId = ++_linksRequestId;
    _isLoadingLinks = true;
    _linkErrorMessage = '';
    _notify();

    try {
      final items = await _repository.fetchCharacterLinks(_characterId);
      if (!_isCurrentLinksRequest(requestId)) {
        return;
      }

      _links = items;
      _linkErrorMessage = '';
    } catch (error) {
      if (!_isCurrentLinksRequest(requestId)) {
        return;
      }

      _linkErrorMessage = _messageForError(error, '连接加载失败');
    } finally {
      if (_isCurrentLinksRequest(requestId)) {
        _isLoadingLinks = false;
        _notify();
      }
    }
  }

  /// 重新加载固定资产数据
  Future<void> loadTemples() async {
    final requestId = ++_templesRequestId;
    _isLoadingTemples = true;
    _templeErrorMessage = '';
    _notify();

    try {
      final items = await _repository.fetchCharacterTemples(_characterId);
      if (!_isCurrentTemplesRequest(requestId)) {
        return;
      }

      _temples = items;
      _templeErrorMessage = '';
    } catch (error) {
      if (!_isCurrentTemplesRequest(requestId)) {
        return;
      }

      _templeErrorMessage = _messageForError(error, '圣殿加载失败');
    } finally {
      if (_isCurrentTemplesRequest(requestId)) {
        _isLoadingTemples = false;
        _notify();
      }
    }
  }

  /// 释放公开展示区控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 判断 LINK 响应是否仍属于当前请求
  ///
  /// [requestId] 请求序号
  bool _isCurrentLinksRequest(int requestId) {
    return !_isDisposed && requestId == _linksRequestId;
  }

  /// 判断固定资产响应是否仍属于当前请求
  ///
  /// [requestId] 请求序号
  bool _isCurrentTemplesRequest(int requestId) {
    return !_isDisposed && requestId == _templesRequestId;
  }

  /// 通知公开展示区状态变化
  void _notify() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }

  /// 隐藏相同封面的固定资产预览条目
  ///
  /// [items] 待筛选的固定资产条目
  List<CharacterDetailTempleItem> _hideDuplicateCovers(
    List<CharacterDetailTempleItem> items,
  ) {
    final seenCovers = <String>{};
    final result = <CharacterDetailTempleItem>[];

    for (final item in items) {
      final coverKey = item.cover.trim();
      if (!seenCovers.add(coverKey)) {
        continue;
      }

      result.add(item);
    }

    return result;
  }

  /// 转换异常为展示文案
  ///
  /// [error] 捕获到的异常
  /// [fallback] 兜底文案
  String _messageForError(Object error, String fallback) {
    return resolveUserErrorMessage(error, fallback: fallback);
  }
}
