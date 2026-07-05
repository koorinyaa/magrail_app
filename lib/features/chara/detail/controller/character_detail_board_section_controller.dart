import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_board_member.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';

/// 角色详情董事会预览区控制器
class CharacterDetailBoardSectionController extends ChangeNotifier {
  /// 创建角色详情董事会预览区控制器
  ///
  /// [repository] 角色详情仓库
  /// [characterId] 角色 ID
  CharacterDetailBoardSectionController({
    required CharacterDetailRepository repository,
    required int characterId,
  })  : _repository = repository,
        _characterId = characterId;

  /// 董事会预览请求数量
  static const int previewPageSize = 20;

  final CharacterDetailRepository _repository;
  final int _characterId;

  TinygrailPage<CharacterDetailBoardMember>? _page;
  var _isLoading = false;
  var _errorMessage = '';
  var _requestId = 0;
  var _isDisposed = false;

  /// 是否正在加载董事会预览
  bool get isLoading => _isLoading;

  /// 董事会加载失败文案
  String get errorMessage => _errorMessage;

  /// 董事会是否加载失败
  bool get hasError => _errorMessage.isNotEmpty;

  /// 董事会预览条目
  List<CharacterDetailBoardMember> get items {
    return _page?.items ?? const <CharacterDetailBoardMember>[];
  }

  /// 董事会总人数
  int get totalItems {
    return _page?.totalItems ?? items.length;
  }

  /// 初始化董事会预览数据
  void initialize() {
    unawaited(load());
  }

  /// 重新加载董事会预览数据
  Future<void> load() async {
    final requestId = ++_requestId;
    _isLoading = true;
    _errorMessage = '';
    _notify();

    try {
      final page = await _repository.fetchCharacterBoardMemberPage(
        characterId: _characterId,
        page: 1,
        pageSize: previewPageSize,
      );
      if (!_isCurrentRequest(requestId)) {
        return;
      }

      _page = page;
      _errorMessage = '';
    } catch (error) {
      if (!_isCurrentRequest(requestId)) {
        return;
      }

      _errorMessage = _messageForError(error, '董事会加载失败');
    } finally {
      if (_isCurrentRequest(requestId)) {
        _isLoading = false;
        _notify();
      }
    }
  }

  /// 释放董事会预览区控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 判断响应是否属于当前请求
  ///
  /// [requestId] 请求序号
  bool _isCurrentRequest(int requestId) {
    return !_isDisposed && requestId == _requestId;
  }

  /// 转换异常为展示文案
  ///
  /// [error] 捕获到的异常
  /// [fallback] 兜底文案
  String _messageForError(Object error, String fallback) {
    return resolveUserErrorMessage(error, fallback: fallback);
  }

  /// 通知董事会预览区状态变化
  void _notify() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
