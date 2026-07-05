import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/features/user/model/user_item_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 用户道具二级页面控制器
class UserItemPageController extends ChangeNotifier {
  /// 创建用户道具二级页面控制器
  ///
  /// [repository] 用户仓库
  UserItemPageController({
    required UserRepository repository,
  }) : _repository = repository;

  // 已接入使用流程的道具固定置顶展示
  static const Map<int, int> _pinnedItemOrder = {
    6: 0,
    5: 1,
    1: 2,
    9: 3,
    2: 4,
  };

  final UserRepository _repository;
  List<UserItemApiItem> _items = const <UserItemApiItem>[];
  String? _errorMessage;
  bool _isLoading = true;
  bool _hasInitialized = false;
  bool _isDisposed = false;

  /// 当前展示的用户道具条目
  List<UserItemApiItem> get items => _items;

  /// 首次加载是否进行中
  bool get isLoading => _isLoading;

  /// 首次加载错误文案
  String? get errorMessage => _errorMessage;

  /// 初始化用户道具列表
  void initialize() {
    if (_hasInitialized) {
      return;
    }

    _hasInitialized = true;
    unawaited(_load(showLoading: true));
  }

  /// 刷新用户道具列表
  Future<bool> refresh() {
    return _load(showLoading: _items.isEmpty);
  }

  /// 加载用户道具列表
  ///
  /// [showLoading] 是否显示首屏加载状态
  Future<bool> _load({required bool showLoading}) async {
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final items = await _repository.fetchUserItems();
      if (_isDisposed) {
        return false;
      }

      _items = _sortItems(items);
      _errorMessage = null;
      return true;
    } catch (error) {
      if (_isDisposed) {
        return false;
      }

      _errorMessage = _resolveErrorMessage(error);
      return false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// 按用户道具展示规则排序
  ///
  /// [items] 接口返回道具条目
  List<UserItemApiItem> _sortItems(List<UserItemApiItem> items) {
    final indexedItems = items.asMap().entries.toList(growable: false);
    indexedItems.sort((left, right) {
      final leftOrder = _pinnedItemOrder[left.value.id];
      final rightOrder = _pinnedItemOrder[right.value.id];

      if (leftOrder != null || rightOrder != null) {
        if (leftOrder == null) {
          return 1;
        }

        if (rightOrder == null) {
          return -1;
        }

        return leftOrder.compareTo(rightOrder);
      }

      return left.key.compareTo(right.key);
    });

    return indexedItems.map((entry) => entry.value).toList(growable: false);
  }

  /// 解析用户道具加载错误文案
  ///
  /// [error] 原始错误
  String _resolveErrorMessage(Object error) {
    return resolveUserErrorMessage(error, fallback: '获取道具列表失败');
  }

  /// 释放用户道具二级页面控制器
  @override
  void dispose() {
    _isDisposed = true;
    _items = const <UserItemApiItem>[];
    super.dispose();
  }
}
