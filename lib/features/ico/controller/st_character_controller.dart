import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
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
    extends TinygrailPagedListController<StCharacterEntry, StCharacterEntry> {
  /// 创建 ST 角色二级页控制器
  ///
  /// [repository] ST 角色仓库
  StCharacterPageController({
    required StCharacterRepository repository,
  })  : _repository = repository,
        super(pageSize: StCharacterRepository.pageSize);

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

  /// 转换 ST 角色分页条目
  ///
  /// [items] 接口返回原始条目
  @override
  List<StCharacterEntry> convertPageItems(List<StCharacterEntry> items) {
    return items;
  }
}
