import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/chara/controller/character_full_list_page_controller.dart';
import 'package:magrail_app/features/chara/model/character_full_list_sort.dart';
import 'package:magrail_app/features/ico/model/st_character_entry.dart';
import 'package:magrail_app/features/ico/repository/st_character_repository.dart';

/// ST 角色预览控制器
class StCharacterPreviewController extends ChangeNotifier {
  /// 创建 ST 角色预览控制器
  ///
  /// [repository] ST 角色仓库
  StCharacterPreviewController({
    required StCharacterRepository repository,
  }) : _repository = repository;

  final StCharacterRepository _repository;

  List<StCharacterEntry>? _items;
  int? _totalItems;
  bool _isLoading = false;
  bool _isLoadFailed = false;
  bool _isDisposed = false;

  /// 当前 ST 角色预览条目
  List<StCharacterEntry>? get items => _items;

  /// ST 角色总数
  int? get totalItems => _totalItems;

  /// 是否正在首次加载
  bool get isLoading => _isLoading;

  /// 是否加载失败
  bool get isLoadFailed => _isLoadFailed;

  /// 初始化 ST 角色预览
  void initialize() {
    unawaited(load(showSkeleton: true));
  }

  /// 加载 ST 角色预览
  ///
  /// [showSkeleton] 是否显示首次加载骨架
  Future<void> load({
    required bool showSkeleton,
  }) async {
    if (_isDisposed || _isLoading) {
      return;
    }

    if (showSkeleton) {
      _isLoading = true;
      _notifyIfActive();
    }

    try {
      final page = await _repository.fetchStCharacters();
      if (_isDisposed) {
        return;
      }

      _items = page.items;
      _totalItems = page.totalItems;
      _isLoadFailed = false;
    } catch (_) {
      if (_isDisposed) {
        return;
      }

      _items ??= const <StCharacterEntry>[];
      _isLoadFailed = true;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _notifyIfActive();
      }
    }
  }

  /// 刷新 ST 角色预览
  Future<void> refresh() async {
    if (_isDisposed || _isLoading) {
      return;
    }

    await load(showSkeleton: _items == null);
  }

  /// 释放 ST 角色预览控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 通知仍挂载的监听者
  void _notifyIfActive() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}

/// ST 角色二级页控制器
class StCharacterPageController
    extends CharacterFullListPageController<StCharacterEntry> {
  /// 创建 ST 角色二级页控制器
  ///
  /// [repository] ST 角色仓库
  /// [waitForScrollIdle] 等待列表拖动和惯性滚动结束
  /// [onBeforeFullItemsReplaced] 全量数据替换前回调
  /// [onDataRefreshFailed] 全量数据刷新失败回调
  StCharacterPageController({
    required StCharacterRepository repository,
    required super.waitForScrollIdle,
    super.onBeforeFullItemsReplaced,
    super.onDataRefreshFailed,
  })  : _repository = repository,
        super(
          pageSize: StCharacterRepository.pageSize,
          availableSorts: const <CharacterFullListSort>[
            CharacterFullListSort.st,
            CharacterFullListSort.circulation,
            CharacterFullListSort.bids,
            CharacterFullListSort.asks,
            CharacterFullListSort.dividend,
            CharacterFullListSort.towerRank,
            CharacterFullListSort.stars,
            CharacterFullListSort.currentPrice,
            CharacterFullListSort.fluctuation,
            CharacterFullListSort.marketValue,
          ],
        );

  final StCharacterRepository _repository;

  /// 请求 ST 角色分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页请求条目数量
  @override
  Future<TinygrailPage<StCharacterEntry>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchStCharacters(
      page: page,
      pageSize: pageSize,
    );
  }

  /// 请求 ST 完整角色数据
  @override
  Future<List<StCharacterEntry>> requestFullItems() async {
    final page = await _repository.fetchStCharacters(
      page: 1,
      pageSize: characterFullListRequestPageSize,
    );
    return page.items;
  }

  /// 读取 ST 角色 ID
  ///
  /// [item] ST 角色条目
  @override
  int characterIdOf(StCharacterEntry item) => item.characterId;

  /// 读取 ST 角色名称
  ///
  /// [item] ST 角色条目
  @override
  String characterNameOf(StCharacterEntry item) => item.name;

  /// 读取 ST 角色等级
  ///
  /// [item] ST 角色条目
  @override
  int characterLevelOf(StCharacterEntry item) => item.level;

  /// 读取 ST 角色排序数值
  ///
  /// [item] ST 角色条目
  /// [sort] 排序字段
  @override
  num sortValueOf(StCharacterEntry item, CharacterFullListSort sort) {
    return switch (sort) {
      CharacterFullListSort.dividend => item.singleDividend,
      CharacterFullListSort.towerRank => item.rank,
      CharacterFullListSort.stars => item.stars,
      CharacterFullListSort.currentPrice => item.current,
      CharacterFullListSort.fluctuation => item.fluctuation,
      CharacterFullListSort.marketValue => item.marketValue,
      CharacterFullListSort.st => item.zeroCount,
      CharacterFullListSort.circulation => item.total,
      CharacterFullListSort.bids => item.bids,
      CharacterFullListSort.asks => item.asks,
      _ => 0,
    };
  }
}
