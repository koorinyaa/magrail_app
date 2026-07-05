import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/features/chara/trade_history/model/character_trade_history_item.dart';
import 'package:magrail_app/features/chara/trade_history/repository/character_trade_history_repository.dart';

/// 角色交易记录底部抽屉控制器
class CharacterTradeHistorySheetController extends ChangeNotifier {
  /// 创建角色交易记录底部抽屉控制器
  ///
  /// [repository] 角色交易记录仓库
  /// [characterId] 角色 ID
  CharacterTradeHistorySheetController({
    required CharacterTradeHistoryRepository repository,
    required int characterId,
  })  : _repository = repository,
        _characterId = characterId;

  final CharacterTradeHistoryRepository _repository;
  final int _characterId;
  List<CharacterTradeHistoryItem> _items = const <CharacterTradeHistoryItem>[];
  bool _isLoading = false;
  String? _loadError;
  bool _isDisposed = false;

  /// 当前角色全部交易记录
  List<CharacterTradeHistoryItem> get items => _items;

  /// 是否正在读取交易记录
  bool get isLoading => _isLoading;

  /// 交易记录读取失败文案
  String? get loadError => _loadError;

  /// 初始化角色交易记录
  Future<void> initialize() {
    return _loadTradeHistory();
  }

  /// 重新读取角色交易记录
  Future<void> reload() {
    return _loadTradeHistory();
  }

  /// 释放角色交易记录底部抽屉控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 执行角色交易记录读取
  Future<void> _loadTradeHistory() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _loadError = null;
    _notifyIfActive();

    try {
      final items = await _repository.fetchCharacterTradeHistory(
        characterId: _characterId,
      );
      if (_isDisposed) {
        return;
      }

      // 图表接口返回旧记录在前，抽屉按交易时间倒序展示
      _items = List<CharacterTradeHistoryItem>.unmodifiable(
        items.reversed.toList(growable: false),
      );
    } catch (error) {
      if (_isDisposed) {
        return;
      }

      _loadError = _resolveErrorText(error);
    } finally {
      _isLoading = false;
      _notifyIfActive();
    }
  }

  /// 解析加载失败文案
  ///
  /// [error] 异常对象
  String _resolveErrorText(Object error) {
    return resolveUserErrorMessage(error, fallback: '获取交易记录失败');
  }

  /// 通知仍处于活动状态的监听者
  void _notifyIfActive() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
