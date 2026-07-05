import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/features/ico/model/ico_character_entry.dart';
import 'package:magrail_app/features/ico/repository/ico_character_repository.dart';

/// ICO 角色列表控制器
class IcoCharacterController extends ChangeNotifier {
  /// 创建 ICO 角色列表控制器
  ///
  /// [repository] ICO 角色仓库
  IcoCharacterController({
    required IcoCharacterRepository repository,
  }) : _repository = repository;

  final IcoCharacterRepository _repository;

  final Map<IcoCharacterSortType, List<IcoCharacterEntry>> _itemsByType = {};
  final Set<IcoCharacterSortType> _loadingTypes = {};
  final Set<IcoCharacterSortType> _failedTypes = {};
  var _selectedType = IcoCharacterSortType.endingSoon;
  var _isDisposed = false;

  /// 当前排序类型
  IcoCharacterSortType get selectedType => _selectedType;

  /// 当前排序下的 ICO 角色条目
  List<IcoCharacterEntry> get items {
    return _itemsByType[_selectedType] ?? const <IcoCharacterEntry>[];
  }

  /// 当前排序是否正在加载
  bool get isLoading => _loadingTypes.contains(_selectedType);

  /// 当前排序是否加载失败
  bool get isLoadFailed => _failedTypes.contains(_selectedType);

  /// 当前排序是否已有缓存
  bool get hasLoadedCurrentType => _itemsByType.containsKey(_selectedType);

  /// 初始化 ICO 角色列表
  void initialize() {
    unawaited(_load(_selectedType));
  }

  /// 选择 ICO 角色排序类型
  ///
  /// [type] 目标排序类型
  void selectType(IcoCharacterSortType type) {
    if (_isDisposed || type == _selectedType) {
      return;
    }

    _selectedType = type;
    _notifyIfActive();

    if (!_itemsByType.containsKey(type)) {
      unawaited(_load(type));
    }
  }

  /// 刷新当前排序下的 ICO 角色列表
  Future<void> refresh() {
    return _load(_selectedType, force: true);
  }

  /// 释放 ICO 角色列表控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 加载指定排序下的 ICO 角色列表
  ///
  /// [type] 目标排序类型
  /// [force] 是否忽略已有缓存
  Future<void> _load(
    IcoCharacterSortType type, {
    bool force = false,
  }) async {
    if (_isDisposed || _loadingTypes.contains(type)) {
      return;
    }

    if (!force && _itemsByType.containsKey(type)) {
      return;
    }

    _loadingTypes.add(type);
    _failedTypes.remove(type);
    _notifyIfActive();

    try {
      final items = await _repository.fetchIcoCharacters(sortType: type);
      if (_isDisposed) {
        return;
      }

      _itemsByType[type] = List<IcoCharacterEntry>.unmodifiable(items);
      _failedTypes.remove(type);
    } catch (_) {
      if (_isDisposed) {
        return;
      }

      _failedTypes.add(type);
    } finally {
      if (!_isDisposed) {
        _loadingTypes.remove(type);
        _notifyIfActive();
      }
    }
  }

  /// 通知仍挂载的监听者
  void _notifyIfActive() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
