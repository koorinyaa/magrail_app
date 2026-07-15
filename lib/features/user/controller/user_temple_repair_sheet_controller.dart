import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_repository.dart';
import 'package:magrail_app/features/user/controller/current_user_temple_page_controller.dart';
import 'package:magrail_app/features/user/model/user_temple_repair_entry.dart';

/// 受损圣殿批量补塔抽屉控制器
final class UserTempleRepairSheetController extends ChangeNotifier {
  /// 创建受损圣殿批量补塔抽屉控制器
  ///
  /// [snapshotRepository] 用户资产快照仓库
  /// [characterRepository] 角色详情仓库
  /// [pageController] 当前用户圣殿页面控制器
  /// [username] 当前登录用户名
  UserTempleRepairSheetController({
    required UserAssetSnapshotRepository snapshotRepository,
    required CharacterDetailRepository characterRepository,
    required CurrentUserTemplePageController pageController,
    required String username,
  })  : _snapshotRepository = snapshotRepository,
        _characterRepository = characterRepository,
        _pageController = pageController,
        _username = username.trim();

  // 批量补塔最多同时提交三个资产重组请求
  static const int _maxConcurrentRepairs = 3;

  final UserAssetSnapshotRepository _snapshotRepository;
  final CharacterDetailRepository _characterRepository;
  final CurrentUserTemplePageController _pageController;
  final String _username;

  List<UserTempleRepairEntry> _entries = const [];
  Set<int> _selectedCharacterIds = <int>{};
  Future<bool>? _reloadOperation;
  String _errorMessage = '';
  int? _observedRevision;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isSubmitting = false;
  bool _isDisposed = false;

  /// 受损圣殿列表
  List<UserTempleRepairEntry> get entries => _entries;

  /// 加载失败文案
  String get errorMessage => _errorMessage;

  /// 是否正在首次加载
  bool get isLoading => _isLoading;

  /// 是否正在刷新已有数据
  bool get isRefreshing => _isRefreshing;

  /// 是否正在执行批量补塔
  bool get isSubmitting => _isSubmitting;

  /// 可补塔圣殿数量
  int get repairableCount => _entries.where((entry) => entry.canRepair).length;

  /// 已选择圣殿数量
  int get selectedCount => selectedEntries.length;

  /// 是否已选中全部可补塔圣殿
  bool get isAllRepairableSelected {
    final repairableEntries = _entries.where((entry) => entry.canRepair);
    return repairableEntries.isNotEmpty &&
        repairableEntries.every(
          (entry) => _selectedCharacterIds.contains(entry.temple.characterId),
        );
  }

  /// 当前选择的可补塔圣殿
  List<UserTempleRepairEntry> get selectedEntries => [
        for (final entry in _entries)
          if (entry.canRepair &&
              _selectedCharacterIds.contains(entry.temple.characterId))
            entry,
      ];

  /// 初始化抽屉并加载补塔数据
  Future<bool> initialize() {
    _observedRevision = _pageController.templeSnapshotRevision;
    _pageController.addListener(_handleTemplePageChanged);
    return reload(preserveSelection: false);
  }

  /// 重新加载受损圣殿与持股数据
  ///
  /// [preserveSelection] 是否保留当前选择状态
  Future<bool> reload({bool preserveSelection = true}) {
    final existing = _reloadOperation;
    if (existing != null) {
      return existing;
    }
    late final Future<bool> operation;
    operation = _loadRepairEntries(
      preserveSelection: preserveSelection,
    ).whenComplete(() {
      if (identical(_reloadOperation, operation)) {
        _reloadOperation = null;
      }
    });
    _reloadOperation = operation;
    return operation;
  }

  /// 判断指定圣殿是否已选择
  ///
  /// [entry] 受损圣殿补塔条目
  bool isSelected(UserTempleRepairEntry entry) {
    return _selectedCharacterIds.contains(entry.temple.characterId);
  }

  /// 切换指定圣殿的选择状态
  ///
  /// [entry] 受损圣殿补塔条目
  void toggleEntry(UserTempleRepairEntry entry) {
    if (!entry.canRepair || _isSubmitting || _isRefreshing) {
      return;
    }
    final characterId = entry.temple.characterId;
    if (!_selectedCharacterIds.remove(characterId)) {
      _selectedCharacterIds.add(characterId);
    }
    _notify();
  }

  /// 切换全部可补塔圣殿的选择状态
  void toggleAll() {
    if (_isSubmitting || _isRefreshing) {
      return;
    }
    final repairableIds = {
      for (final entry in _entries)
        if (entry.canRepair) entry.temple.characterId,
    };
    if (repairableIds.isEmpty) {
      return;
    }
    if (repairableIds.every(_selectedCharacterIds.contains)) {
      _selectedCharacterIds.removeAll(repairableIds);
    } else {
      _selectedCharacterIds.addAll(repairableIds);
    }
    _notify();
  }

  /// 执行当前选中的批量补塔任务并返回数据刷新结果
  ///
  /// [onProgress] 单项任务完成后的进度回调
  /// [onRepairsCompleted] 全部补塔请求完成回调，依次传递成功和失败数量
  Future<bool> submitSelected({
    required void Function(
      int completed,
      int total,
      int succeeded,
      int failed,
    ) onProgress,
    required void Function(int succeeded, int failed) onRepairsCompleted,
  }) async {
    final targets = selectedEntries;
    if (_isSubmitting || _isRefreshing || targets.isEmpty) {
      throw StateError('请选择需要补充的圣殿');
    }
    _isSubmitting = true;
    _notify();

    var nextIndex = 0;
    var completedCount = 0;
    var successCount = 0;
    var failureCount = 0;

    /// 依次领取一个补塔任务并提交
    Future<void> runWorker() async {
      while (nextIndex < targets.length) {
        final entry = targets[nextIndex];
        nextIndex += 1;
        try {
          await _characterRepository.sacrificeCharacter(
            characterId: entry.temple.characterId,
            amount: entry.requiredAmount,
            isFinancing: false,
          );
          successCount += 1;
        } catch (_) {
          failureCount += 1;
        } finally {
          completedCount += 1;
          try {
            onProgress(
              completedCount,
              targets.length,
              successCount,
              failureCount,
            );
          } catch (_) {
            // 界面进度反馈失败不应终止剩余补塔任务
          }
        }
      }
    }

    var dataRefreshSucceeded = false;
    try {
      final workerCount = math.min(_maxConcurrentRepairs, targets.length);
      await Future.wait([
        for (var index = 0; index < workerCount; index += 1) runWorker(),
      ]);
    } finally {
      try {
        onRepairsCompleted(successCount, failureCount);
      } catch (_) {
        // 界面反馈失败不应阻断抽屉和页面数据刷新
      }
      try {
        try {
          final refreshResults = await Future.wait<bool>([
            reload(),
            _pageController.refresh(),
          ]);
          dataRefreshSucceeded = refreshResults.every((result) => result);
        } catch (_) {
          dataRefreshSucceeded = false;
        }
      } finally {
        _observedRevision = _pageController.templeSnapshotRevision;
        _isSubmitting = false;
        _notify();
      }
    }

    return dataRefreshSucceeded;
  }

  /// 释放批量补塔抽屉控制器
  @override
  void dispose() {
    _isDisposed = true;
    _pageController.removeListener(_handleTemplePageChanged);
    super.dispose();
  }

  /// 加载并整理补塔列表
  ///
  /// [preserveSelection] 是否保留当前选择状态
  Future<bool> _loadRepairEntries({required bool preserveSelection}) async {
    final hadEntries = _entries.isNotEmpty;
    _isLoading = !hadEntries;
    _isRefreshing = hadEntries;
    _errorMessage = '';
    _notify();
    try {
      final source = await _snapshotRepository.fetchTempleRepairSource(
        username: _username,
      );
      if (_isDisposed) {
        return false;
      }
      final charactersById = {
        for (final character in source.characters)
          character.characterId: character,
      };
      final indexedEntries =
          <({int originalIndex, UserTempleRepairEntry entry})>[];
      for (var index = 0; index < source.temples.length; index += 1) {
        final temple = source.temples[index];
        if (temple.assets >= temple.sacrifices) {
          continue;
        }
        final character = charactersById[temple.characterId];
        indexedEntries.add((
          originalIndex: index,
          entry: UserTempleRepairEntry(
            temple: temple,
            availableAmount: math.max(0, character?.userAmount ?? 0),
            hasCharacterData: character != null,
          ),
        ));
      }
      indexedEntries.sort((left, right) {
        final damagedComparison =
            right.entry.damagedAmount.compareTo(left.entry.damagedAmount);
        return damagedComparison != 0
            ? damagedComparison
            : left.originalIndex.compareTo(right.originalIndex);
      });
      final nextEntries = [for (final item in indexedEntries) item.entry];
      final previousIds = {
        for (final entry in _entries) entry.temple.characterId,
      };
      final nextSelectedIds = <int>{};
      for (final entry in nextEntries) {
        if (!entry.canRepair) {
          continue;
        }
        final characterId = entry.temple.characterId;
        if (!preserveSelection ||
            !previousIds.contains(characterId) ||
            _selectedCharacterIds.contains(characterId)) {
          nextSelectedIds.add(characterId);
        }
      }
      _entries = List<UserTempleRepairEntry>.unmodifiable(nextEntries);
      _selectedCharacterIds = nextSelectedIds;
      _observedRevision = _pageController.templeSnapshotRevision;
      return true;
    } catch (error) {
      if (_isDisposed) {
        return false;
      }
      _errorMessage = resolveUserErrorMessage(
        error,
        fallback: '获取受损圣殿失败',
      );
      return false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _isRefreshing = false;
        _notify();
      }
    }
  }

  /// 处理圣殿页面快照变化
  void _handleTemplePageChanged() {
    final revision = _pageController.templeSnapshotRevision;
    if (_isDisposed || revision == null || revision == _observedRevision) {
      return;
    }
    _observedRevision = revision;
    unawaited(reload());
  }

  /// 通知抽屉状态变化
  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
