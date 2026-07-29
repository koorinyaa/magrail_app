import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/chara/model/character_full_list_sort.dart';

// 全量接口使用单次超大分页，避免串行扫描多页延长排序可用时间
const int characterFullListRequestPageSize = 99999999;

/// 角色全量列表替换前回调
///
/// [previousItems] 替换前正在展示的角色
/// [replacementItems] 即将展示的新角色
/// [previousHasLevelHeaders] 替换前是否包含等级标题
/// [replacementHasLevelHeaders] 替换后是否包含等级标题
typedef CharacterFullListReplacementCallback<ItemType> = void Function(
  List<ItemType> previousItems,
  List<ItemType> replacementItems, {
  required bool previousHasLevelHeaders,
  required bool replacementHasLevelHeaders,
});

/// 角色全量列表二级页面控制器
abstract class CharacterFullListPageController<ItemType>
    extends TinygrailPagedListController<ItemType, ItemType> {
  /// 创建角色全量列表二级页面控制器
  ///
  /// [pageSize] 普通后端分页每页角色数量
  /// [availableSorts] 当前页面允许使用的排序字段
  /// [initialSort] 页面首次启用全量数据时的排序字段
  /// [waitForScrollIdle] 等待列表拖动和惯性滚动结束
  /// [onBeforeFullItemsReplaced] 全量数据替换前回调
  /// [onDataRefreshFailed] 全量数据刷新失败回调
  CharacterFullListPageController({
    required super.pageSize,
    required List<CharacterFullListSort> availableSorts,
    CharacterFullListSort? initialSort,
    required Future<void> Function() waitForScrollIdle,
    CharacterFullListReplacementCallback<ItemType>? onBeforeFullItemsReplaced,
    VoidCallback? onDataRefreshFailed,
  })  : assert(availableSorts.isNotEmpty),
        assert(initialSort == null || availableSorts.contains(initialSort)),
        _availableSorts = List<CharacterFullListSort>.unmodifiable(
          availableSorts,
        ),
        _sort = initialSort,
        _waitForScrollIdle = waitForScrollIdle,
        _onBeforeFullItemsReplaced = onBeforeFullItemsReplaced,
        _onDataRefreshFailed = onDataRefreshFailed;

  final List<CharacterFullListSort> _availableSorts;
  final Future<void> Function() _waitForScrollIdle;
  final CharacterFullListReplacementCallback<ItemType>?
      _onBeforeFullItemsReplaced;
  final VoidCallback? _onDataRefreshFailed;

  List<ItemType>? _fullSourceItems;
  List<ItemType>? _fullDisplayItems;
  List<CharacterFullListLevelPosition> _levelPositions = const [];
  CharacterFullListSort? _sort;
  CharacterFullListSortDirection _direction =
      CharacterFullListSortDirection.descending;
  String _searchKeyword = '';
  Future<bool>? _fullLoadOperation;
  bool _isCommittingFullView = false;
  bool _isDisposed = false;
  int _queryGeneration = 0;

  /// 当前页面允许使用的排序字段
  List<CharacterFullListSort> get availableSorts => _availableSorts;

  /// 当前排序字段，未选择时保留服务器顺序
  CharacterFullListSort? get sort => _sort;

  /// 当前排序方向
  CharacterFullListSortDirection get direction => _direction;

  /// 当前角色 ID 或名称筛选词
  String get searchKeyword => _searchKeyword;

  /// 等级快速跳转位置
  List<CharacterFullListLevelPosition> get levelPositions => _levelPositions;

  /// 是否已经启用全量数据
  bool get hasFullData => _fullSourceItems != null;

  /// 当前分页或全量模式已经提交的展示角色
  @override
  List<ItemType> get items => _fullDisplayItems ?? super.items;

  /// 当前列表是否显示等级标题
  bool get showsLevelHeaders =>
      hasFullData && _sort == CharacterFullListSort.level;

  /// 全量数据提交或启用后暂停下一页请求
  @override
  bool get isNextPageLoadPaused => _isCommittingFullView || hasFullData;

  /// 初始化普通分页并请求全量数据
  @override
  void initialize() {
    super.initialize();
    unawaited(_startOrJoinFullLoad());
  }

  /// 刷新当前页面数据
  @override
  Future<bool> refresh() async {
    if (_isDisposed) {
      return false;
    }

    final pagingOperation = hasFullData ? _probeFirstPage() : super.refresh();
    final fullOperation = _startOrJoinFullLoad();
    await Future.wait<bool>([pagingOperation, fullOperation]);
    // 全量请求已经通过统一回调提示结果，避免页面壳层重复弹出失败提示
    return true;
  }

  /// 切换本地排序字段或方向
  ///
  /// [sort] 目标排序字段
  Future<bool> selectSort(CharacterFullListSort sort) async {
    final sourceItems = _fullSourceItems;
    if (_isDisposed || sourceItems == null || !_availableSorts.contains(sort)) {
      return false;
    }

    final previousSort = _sort;
    final previousDirection = _direction;
    if (_sort == sort) {
      _direction = _direction == CharacterFullListSortDirection.descending
          ? CharacterFullListSortDirection.ascending
          : CharacterFullListSortDirection.descending;
    } else {
      _sort = sort;
      _direction = CharacterFullListSortDirection.descending;
    }
    final generation = ++_queryGeneration;
    final success = await _replaceFullView(
      sourceItems,
      commitSource: false,
      preserveVisibleItem: false,
    );
    if (success || generation != _queryGeneration || _isDisposed) {
      return success || generation != _queryGeneration;
    }

    _sort = previousSort;
    _direction = previousDirection;
    _queryGeneration += 1;
    notifyListeners();
    return false;
  }

  /// 应用角色 ID 或名称筛选词
  ///
  /// [keyword] 角色 ID 或名称筛选词
  Future<bool> applySearchFilter(String keyword) async {
    final sourceItems = _fullSourceItems;
    if (_isDisposed || sourceItems == null) {
      return false;
    }
    final normalizedKeyword = keyword.trim();
    if (_searchKeyword == normalizedKeyword) {
      return true;
    }

    final previousKeyword = _searchKeyword;
    _searchKeyword = normalizedKeyword;
    final generation = ++_queryGeneration;
    final success = await _replaceFullView(
      sourceItems,
      commitSource: false,
      preserveVisibleItem: false,
    );
    if (success || generation != _queryGeneration || _isDisposed) {
      return success || generation != _queryGeneration;
    }

    _searchKeyword = previousKeyword;
    _queryGeneration += 1;
    notifyListeners();
    return false;
  }

  /// 释放角色全量列表控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 读取角色 ID
  ///
  /// [item] 角色条目
  int characterIdOf(ItemType item);

  /// 读取角色名称
  ///
  /// [item] 角色条目
  String characterNameOf(ItemType item);

  /// 读取角色等级
  ///
  /// [item] 角色条目
  int characterLevelOf(ItemType item);

  /// 读取指定排序字段数值
  ///
  /// [item] 角色条目
  /// [sort] 排序字段
  num sortValueOf(ItemType item, CharacterFullListSort sort);

  /// 请求当前页面完整角色数据
  @protected
  Future<List<ItemType>> requestFullItems();

  /// 保留接口条目作为展示条目
  ///
  /// [items] 接口返回角色条目
  @override
  List<ItemType> convertPageItems(List<ItemType> items) => items;

  /// 启动或复用当前全量请求
  Future<bool> _startOrJoinFullLoad() {
    final existingOperation = _fullLoadOperation;
    if (existingOperation != null) {
      return existingOperation;
    }

    late final Future<bool> operation;
    operation = _loadFullItems().whenComplete(() {
      if (identical(_fullLoadOperation, operation)) {
        _fullLoadOperation = null;
      }
    });
    _fullLoadOperation = operation;
    return operation;
  }

  /// 请求完整角色数据并在列表停止滚动后提交
  Future<bool> _loadFullItems() async {
    var commitPending = false;
    try {
      final requestedItems = await requestFullItems();
      if (_isDisposed) {
        return false;
      }
      // 暂停新的普通分页，再等待已有分页与滚动结束，避免等待期间重新产生提交竞态
      _isCommittingFullView = true;
      commitPending = true;
      notifyListeners();
      await waitForPagingIdle();
      if (_isDisposed) {
        return false;
      }
      await _waitForScrollIdle();
      if (_isDisposed) {
        return false;
      }
      final sourceItems = List<ItemType>.unmodifiable(requestedItems);
      final success = await _replaceFullView(
        sourceItems,
        commitSource: true,
        preserveVisibleItem: true,
      );
      if (_isDisposed) {
        return false;
      }
      if (!success) {
        _onDataRefreshFailed?.call();
      }
      return success;
    } catch (_) {
      if (!_isDisposed) {
        _onDataRefreshFailed?.call();
      }
      return false;
    } finally {
      if (!_isDisposed && commitPending && _isCommittingFullView) {
        _isCommittingFullView = false;
        notifyListeners();
      }
    }
  }

  /// 使用当前查询生成并替换全量展示列表
  ///
  /// [sourceItems] 完整角色源数据
  /// [commitSource] 是否将源数据提交为最新全量数据
  /// [preserveVisibleItem] 是否在替换时保留当前可视角色
  Future<bool> _replaceFullView(
    List<ItemType> sourceItems, {
    required bool commitSource,
    required bool preserveVisibleItem,
  }) async {
    while (!_isDisposed) {
      final generation = _queryGeneration;
      final replacementItems = _buildDisplayItems(sourceItems);
      final replacementPositions = _buildLevelPositions(replacementItems);
      final previousItems = items;
      final previousHasLevelHeaders = showsLevelHeaders;
      final replacementHasLevelHeaders = _sort == CharacterFullListSort.level;

      _isCommittingFullView = true;
      notifyListeners();
      final success = await replaceFromPage(
        1,
        shouldCommit: () => !_isDisposed && generation == _queryGeneration,
        beforeCommit: (_) {
          if (preserveVisibleItem) {
            _onBeforeFullItemsReplaced?.call(
              previousItems,
              replacementItems,
              previousHasLevelHeaders: previousHasLevelHeaders,
              replacementHasLevelHeaders: replacementHasLevelHeaders,
            );
          }
          if (commitSource) {
            _fullSourceItems = sourceItems;
          }
          _fullDisplayItems = replacementItems;
          _levelPositions = replacementPositions;
        },
        pageLoader: ({required page, required pageSize}) async {
          return TinygrailPage<ItemType>(
            items: replacementItems,
            currentPage: 1,
            totalPages: 1,
            totalItems: replacementItems.length,
            itemsPerPage: replacementItems.length,
          );
        },
      );
      _isCommittingFullView = false;
      if (_isDisposed) {
        return false;
      }
      if (success) {
        notifyListeners();
        return true;
      }
      if (generation != _queryGeneration) {
        continue;
      }
      notifyListeners();
      return false;
    }
    return false;
  }

  /// 按当前筛选和排序生成展示角色
  ///
  /// [sourceItems] 完整角色源数据
  List<ItemType> _buildDisplayItems(List<ItemType> sourceItems) {
    final rawKeyword = _searchKeyword.toLowerCase();
    // 角色 ID 常用 #123 形式输入，仅纯数字编号去掉前缀参与搜索
    final normalizedKeyword = RegExp(r'^#[0-9]+$').hasMatch(rawKeyword)
        ? rawKeyword.substring(1)
        : rawKeyword;
    final displayItems = sourceItems.where((item) {
      if (normalizedKeyword.isEmpty) {
        return true;
      }
      return characterIdOf(item).toString().contains(normalizedKeyword) ||
          characterNameOf(item).toLowerCase().contains(normalizedKeyword);
    }).toList(growable: false);
    if (_sort != null) {
      displayItems.sort(_compareItems);
    }
    return List<ItemType>.unmodifiable(displayItems);
  }

  /// 比较两个角色的本地排序位置
  ///
  /// [left] 左侧角色
  /// [right] 右侧角色
  int _compareItems(ItemType left, ItemType right) {
    final sort = _sort;
    if (sort == null) {
      return 0;
    }
    final comparison = sort == CharacterFullListSort.towerRank
        ? _compareTowerRanks(
            sortValueOf(left, sort).toInt(),
            sortValueOf(right, sort).toInt(),
          )
        : _compareValues(
            sortValueOf(left, sort),
            sortValueOf(right, sort),
          );
    if (comparison != 0) {
      return comparison;
    }
    return characterIdOf(left).compareTo(characterIdOf(right));
  }

  /// 比较普通排序数值
  ///
  /// [left] 左侧数值
  /// [right] 右侧数值
  int _compareValues(num left, num right) {
    final comparison = left.compareTo(right);
    return _direction == CharacterFullListSortDirection.descending
        ? -comparison
        : comparison;
  }

  /// 比较通天塔排名并保持无效排名始终位于末尾
  ///
  /// [left] 左侧通天塔排名
  /// [right] 右侧通天塔排名
  int _compareTowerRanks(int left, int right) {
    final leftValid = left > 0;
    final rightValid = right > 0;
    if (leftValid != rightValid) {
      return leftValid ? -1 : 1;
    }
    if (!leftValid) {
      return 0;
    }
    final comparison = left.compareTo(right);
    // 降序语义为更好排名优先，因此数值顺序与普通降序相反
    return _direction == CharacterFullListSortDirection.descending
        ? comparison
        : -comparison;
  }

  /// 构建等级快速跳转目录
  ///
  /// [displayItems] 当前展示角色
  List<CharacterFullListLevelPosition> _buildLevelPositions(
    List<ItemType> displayItems,
  ) {
    if (_sort != CharacterFullListSort.level || displayItems.isEmpty) {
      return const <CharacterFullListLevelPosition>[];
    }
    final positions = <CharacterFullListLevelPosition>[];
    var groupStart = 0;
    for (var index = 1; index <= displayItems.length; index += 1) {
      if (index < displayItems.length &&
          characterLevelOf(displayItems[index]) ==
              characterLevelOf(displayItems[groupStart])) {
        continue;
      }
      positions.add(
        CharacterFullListLevelPosition(
          level: characterLevelOf(displayItems[groupStart]),
          itemIndex: groupStart,
        ),
      );
      groupStart = index;
    }
    return List<CharacterFullListLevelPosition>.unmodifiable(positions);
  }

  /// 探测普通分页首屏但不替换当前全量列表
  Future<bool> _probeFirstPage() async {
    try {
      await requestPage(page: 1, pageSize: pageSize);
      return !_isDisposed;
    } catch (_) {
      return false;
    }
  }
}
