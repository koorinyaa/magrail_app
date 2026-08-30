import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/features/ico/model/ico_character_entry.dart';
import 'package:magrail_app/features/ico/model/ico_character_sort.dart';
import 'package:magrail_app/features/ico/repository/ico_character_repository.dart';

/// ICO 角色全量列表控制器
class IcoCharacterController extends ChangeNotifier {
  /// 创建 ICO 角色全量列表控制器
  ///
  /// [repository] ICO 角色仓库
  IcoCharacterController({required IcoCharacterRepository repository})
    : _repository = repository;

  /// ICO 一级页面预览数量
  static const int previewItemCount = 24;

  final IcoCharacterRepository _repository;

  List<IcoCharacterEntry>? _sourceItems;
  List<IcoCharacterEntry> _previewItems = const <IcoCharacterEntry>[];
  List<IcoCharacterEntry> _items = const <IcoCharacterEntry>[];
  IcoCharacterSort _selectedSort = IcoCharacterSort.endingSoon;
  String _searchKeyword = '';
  Future<bool>? _loadOperation;
  bool _isLoading = false;
  bool _isLoadFailed = false;
  bool _isDisposed = false;

  /// 一级页面即将结束预览条目
  List<IcoCharacterEntry> get previewItems => _previewItems;

  /// 二级页面当前排序和筛选后的条目
  List<IcoCharacterEntry> get items => _items;

  /// 当前本地排序字段
  IcoCharacterSort get selectedSort => _selectedSort;

  /// 当前角色 ID 或名称筛选词
  String get searchKeyword => _searchKeyword;

  /// 完整 ICO 角色数量
  int? get totalItems => _sourceItems?.length;

  /// 是否正在请求完整 ICO 数据
  bool get isLoading => _isLoading;

  /// 是否尚未取得可展示数据
  bool get isInitialLoading => _isLoading && _sourceItems == null;

  /// 最近一次完整 ICO 请求是否失败
  bool get isLoadFailed => _isLoadFailed;

  /// 是否已经取得完整 ICO 数据
  bool get hasLoadedData => _sourceItems != null;

  /// 初始化完整 ICO 数据
  void initialize() {
    unawaited(_startOrJoinLoad());
  }

  /// 刷新完整 ICO 数据
  Future<bool> refresh() => _startOrJoinLoad();

  /// 为新打开的二级页面恢复默认查询
  void prepareSecondaryPage() {
    if (_isDisposed ||
        (_selectedSort == IcoCharacterSort.endingSoon &&
            _searchKeyword.isEmpty)) {
      return;
    }
    _selectedSort = IcoCharacterSort.endingSoon;
    _searchKeyword = '';
    _rebuildDisplayItems();
    notifyListeners();
  }

  /// 选择本地排序字段
  ///
  /// [sort] 目标排序字段
  void selectSort(IcoCharacterSort sort) {
    if (_isDisposed || sort == _selectedSort) {
      return;
    }
    _selectedSort = sort;
    _rebuildDisplayItems();
    notifyListeners();
  }

  /// 应用角色 ID 或名称筛选词
  ///
  /// [keyword] 角色 ID 或名称筛选词
  void applySearchFilter(String keyword) {
    if (_isDisposed) {
      return;
    }
    final normalizedKeyword = keyword.trim();
    if (_searchKeyword == normalizedKeyword) {
      return;
    }
    _searchKeyword = normalizedKeyword;
    _rebuildDisplayItems();
    notifyListeners();
  }

  /// 释放 ICO 角色全量列表控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 启动或复用完整 ICO 请求
  Future<bool> _startOrJoinLoad() {
    final existingOperation = _loadOperation;
    if (existingOperation != null) {
      return existingOperation;
    }

    late final Future<bool> operation;
    operation = _load().whenComplete(() {
      if (identical(_loadOperation, operation)) {
        _loadOperation = null;
      }
    });
    _loadOperation = operation;
    return operation;
  }

  /// 使用即将结束接口刷新唯一全量数据源
  Future<bool> _load() async {
    if (_isDisposed) {
      return false;
    }
    _isLoading = true;
    _isLoadFailed = false;
    notifyListeners();

    try {
      final requestedItems = await _repository.fetchEndingSoonCharacters();
      if (_isDisposed) {
        return false;
      }
      final endingSoonItems = List<IcoCharacterEntry>.of(requestedItems)
        ..sort(_compareEndingSoon);
      _sourceItems = List<IcoCharacterEntry>.unmodifiable(endingSoonItems);
      _previewItems = List<IcoCharacterEntry>.unmodifiable(
        endingSoonItems.take(previewItemCount),
      );
      _rebuildDisplayItems();
      return true;
    } catch (_) {
      if (!_isDisposed) {
        _isLoadFailed = true;
      }
      return false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// 按当前筛选和排序生成二级页面展示列表
  void _rebuildDisplayItems() {
    final sourceItems = _sourceItems ?? const <IcoCharacterEntry>[];
    final rawKeyword = _searchKeyword.toLowerCase();
    // 角色 ID 支持 #123 输入格式
    final normalizedKeyword = RegExp(r'^#[0-9]+$').hasMatch(rawKeyword)
        ? rawKeyword.substring(1)
        : rawKeyword;
    final displayItems = sourceItems
        .where((item) {
          if (normalizedKeyword.isEmpty) {
            return true;
          }
          return item.characterId.toString().contains(normalizedKeyword) ||
              item.name.toLowerCase().contains(normalizedKeyword);
        })
        .toList(growable: false);
    if (_selectedSort != IcoCharacterSort.endingSoon) {
      displayItems.sort(_compareItems);
    }
    _items = List<IcoCharacterEntry>.unmodifiable(displayItems);
  }

  /// 比较当前本地排序下的两个 ICO 角色
  ///
  /// [left] 左侧 ICO 角色
  /// [right] 右侧 ICO 角色
  int _compareItems(IcoCharacterEntry left, IcoCharacterEntry right) {
    final comparison = switch (_selectedSort) {
      IcoCharacterSort.endingSoon => _compareEndingSoon(left, right),
      IcoCharacterSort.maxValue => right.total.compareTo(left.total),
      IcoCharacterSort.maxUsers => right.users.compareTo(left.users),
      IcoCharacterSort.recentActive => _compareTime(
        left.last,
        right.last,
        latestFirst: true,
      ),
    };
    return comparison != 0
        ? comparison
        : left.characterId.compareTo(right.characterId);
  }

  /// 按结束时间由近到远比较 ICO 角色
  ///
  /// [left] 左侧 ICO 角色
  /// [right] 右侧 ICO 角色
  int _compareEndingSoon(IcoCharacterEntry left, IcoCharacterEntry right) {
    final comparison = _compareTime(left.end, right.end, latestFirst: false);
    return comparison != 0
        ? comparison
        : left.characterId.compareTo(right.characterId);
  }

  /// 比较服务端时间并将无效时间固定放在末尾
  ///
  /// [left] 左侧服务端时间
  /// [right] 右侧服务端时间
  /// [latestFirst] 是否将较新的时间排在前面
  int _compareTime(String left, String right, {required bool latestFirst}) {
    final leftTime = TinygrailFormatters.parseServerTime(left);
    final rightTime = TinygrailFormatters.parseServerTime(right);
    if (leftTime == null || rightTime == null) {
      if (leftTime == null && rightTime == null) {
        return 0;
      }
      return leftTime == null ? 1 : -1;
    }
    return latestFirst
        ? rightTime.compareTo(leftTime)
        : leftTime.compareTo(rightTime);
  }
}
