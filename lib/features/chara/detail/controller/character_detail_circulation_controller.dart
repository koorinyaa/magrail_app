import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_circulation_snapshot.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';

/// 角色实际流通采集、缓存与结算状态
class CharacterDetailCirculationController extends ChangeNotifier {
  /// 创建角色流通控制器
  ///
  /// [repository] 角色接口仓库
  /// [preferences] 本地缓存存储
  /// [onSettlement] 结算周期变化时重新读取角色资料
  CharacterDetailCirculationController({
    required this._repository,
    required this._preferences,
    required this._onSettlement,
  }) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  final CharacterDetailRepository _repository;
  final AppPreferences _preferences;
  final Future<void> Function() _onSettlement;
  Timer? _timer;
  CancelToken? _cancelToken;
  CharacterDetailCirculationSnapshot? _snapshot;
  DateTime _settlement = CharacterDetailCirculationSnapshot.settlementAt(
    DateTime.now(),
  );
  int? _characterId;
  int? _boardCount;
  int _generation = 0;
  int _completed = 0;
  int _taskCount = 0;
  bool _running = false;
  bool _disposed = false;
  bool _confirmationOpen = false;
  bool _saving = false;
  String _message = '';

  /// 当前角色 ID
  int? get characterId => _characterId;

  /// 是否正在采集或保存
  bool get isRunning => _running;

  /// 董事会就绪后允许打开确认或限制提示
  bool get canOpenDialog =>
      _boardCount != null && !_running && !_saving && !_disposed;

  /// 阻止重复打开计算确认框
  bool beginConfirmation() {
    if (!canOpenDialog || _confirmationOpen) return false;
    _confirmationOpen = true;
    return true;
  }

  /// 结束本次确认框流程
  void endConfirmation() => _confirmationOpen = false;

  /// 按钮左侧的进度或失败说明
  String get statusText => _running
      ? '${_taskCount == 0 ? 0 : (_completed * 100 ~/ _taskCount).clamp(0, 99)}%'
      : _message;

  /// 当前可展示的实际流通快照
  CharacterDetailCirculationSnapshot? get validSnapshot {
    final snapshot = _snapshot;
    return snapshot != null && snapshot.isValidAt(DateTime.now())
        ? snapshot
        : null;
  }

  /// 当前展示数据的本地更新时间
  String get updatedAtText {
    final time =
        validSnapshot?.completedAt ??
        CharacterDetailCirculationSnapshot.settlementAt(DateTime.now());
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(time.toLocal());
  }

  /// 不允许启动时的说明，空文本表示可计算
  String get restriction {
    final now = DateTime.now();
    final peakEnd = CharacterDetailCirculationSnapshot.peakEndsAt(now);
    if (peakEnd != null) {
      return '服务器高峰期暂停计算，将于 '
          '${DateFormat('MM-dd HH:mm').format(peakEnd.toLocal())} 恢复';
    }
    final snapshot = _snapshot;
    if (snapshot != null && snapshot.isValidAt(now)) {
      final remaining = snapshot.completedAt
          .add(CharacterDetailCirculationSnapshot.cooldown)
          .difference(now);
      if (remaining > Duration.zero) {
        final seconds = (remaining.inMilliseconds / 1000).ceil();
        return '计算成功后需等待 10 分钟，还需 '
            '${seconds ~/ 60} 分 ${seconds % 60} 秒';
      }
    }
    if (_boardCount == null) {
      return '请等待董事会加载完成';
    }
    if (_running) return '正在计算实际流通';
    return '';
  }

  /// 切换角色并恢复有效缓存，取消上一个角色的采集
  ///
  /// [characterId] 当前角色 ID
  void selectCharacter(int? characterId) {
    if (_characterId == characterId || _disposed) return;
    cancel();
    _characterId = characterId;
    _boardCount = null;
    _message = '';
    _snapshot = characterId == null
        ? null
        : CharacterDetailCirculationSnapshot.decode(
            _preferences.readCharacterCirculation(characterId),
          );
    _settlement = CharacterDetailCirculationSnapshot.settlementAt(
      DateTime.now(),
    );
    _notify();
  }

  /// 接收当前角色董事会加载结果
  ///
  /// [characterId] 董事会所属角色
  /// [total] 成功加载的总人数，空值表示尚未就绪
  void updateBoard(int characterId, int? total) {
    if (_disposed || characterId != _characterId) return;
    _boardCount = total;
    _notify();
  }

  /// 确认后采集完整持股与奖池，最多三个请求同时进行
  Future<void> calculate() async {
    if (_disposed || !canOpenDialog || restriction.isNotEmpty) return;
    final id = _characterId;
    final count = _boardCount;
    if (id == null || count == null) return;
    final generation = ++_generation;
    final token = CancelToken();
    _cancelToken = token;
    final startedAt = DateTime.now().toUtc();
    _running = true;
    _message = '';
    _completed = 0;
    _taskCount = 0;
    _notify();
    try {
      // 总人数为零时仍检查第一页，不能将变化后的持股用户直接遗漏
      final page = await _repository.fetchCharacterBoardMemberPage(
        characterId: id,
        page: 1,
        pageSize: count > 0 ? count : 1,
        cancelToken: token,
      );
      if (!_isCurrent(generation)) return;
      final names = page.items.map((item) => item.name.trim()).toList();
      if (page.currentPage != 1 ||
          page.totalPages > 1 ||
          page.totalItems != names.length ||
          names.any((name) => name.isEmpty) ||
          names.toSet().length != names.length) {
        throw StateError('持股用户列表不完整，请刷新董事会后重试');
      }
      final users = names.where((name) => name != 'tinygrail').toList();
      _taskCount = users.length + 1;
      var nextTask = 0;
      var total = 0;

      /// 顺序领取任务，任意失败立即取消其余在途请求
      Future<void> worker() async {
        try {
          while (_isCurrent(generation) && !token.isCancelled) {
            final index = nextTask++;
            if (index >= _taskCount) return;
            final int? value;
            if (index == users.length) {
              value = await _repository.fetchCharacterPoolAmount(
                id,
                cancelToken: token,
                requireValue: true,
              );
            } else {
              final holding = await _repository.fetchUserCharacterHolding(
                id,
                users[index],
                cancelToken: token,
                requireTotal: true,
              );
              value = holding?.total;
            }
            if (!_isCurrent(generation) || token.isCancelled) return;
            if (value == null) throw StateError('流通数据不完整');
            total += value;
            _completed++;
            _notify();
          }
        } catch (_) {
          token.cancel('实际流通采集失败');
          rethrow;
        }
      }

      await Future.wait(List.generate(3, (_) => worker()));
      if (!_isCurrent(generation)) return;
      final completedAt = DateTime.now().toUtc();
      final snapshot = CharacterDetailCirculationSnapshot(
        total: total,
        startedAt: startedAt,
        completedAt: completedAt,
      );
      if (!snapshot.isValidAt(completedAt)) {
        _message = '已跨结算，结果作废';
        _tick();
        return;
      }
      // 仅完整采集结果进入持久化，取消或跨结算时恢复原缓存
      final previous = _preferences.readCharacterCirculation(id);
      final encoded = snapshot.encode();
      _saving = true;
      try {
        await _preferences.saveCharacterCirculation(id, encoded);
        if (!_isCurrent(generation) || !snapshot.isValidAt(DateTime.now())) {
          if (_preferences.readCharacterCirculation(id) == encoded) {
            await _preferences.saveCharacterCirculation(id, previous);
          }
          return;
        }
      } catch (_) {
        // 不能撤销其他页面后来保存的完整结果
        if (_preferences.readCharacterCirculation(id) == encoded) {
          await _preferences.saveCharacterCirculation(id, previous);
        }
        rethrow;
      } finally {
        _saving = false;
        _notify();
      }
      _snapshot = snapshot;
      _message = '';
    } catch (_) {
      if (_isCurrent(generation)) _message = '计算失败';
    } finally {
      if (_isCurrent(generation)) {
        _running = false;
        _cancelToken = null;
        _notify();
      }
    }
  }

  /// 离开页面或切换角色时终止任务，不保存部分结果
  void cancel() {
    _generation++;
    _cancelToken?.cancel('离开角色页面');
    _cancelToken = null;
    _running = false;
    _message = '';
    _notify();
  }

  /// 重新检查结算边界，应用恢复前台时也调用
  void checkTime() => _tick();

  /// 更新时间边界与冷却展示，不中断跨入高峰期的任务
  void _tick() {
    if (_disposed) return;
    final settlement = CharacterDetailCirculationSnapshot.settlementAt(
      DateTime.now(),
    );
    // 冷却说明在打开弹窗时读取，空闲时不需要每秒重建整张卡片
    if (settlement == _settlement) return;
    _settlement = settlement;
    _snapshot = null;
    if (_running) {
      cancel();
      _message = '已跨结算，结果作废';
    }
    if (_characterId != null) unawaited(_refreshSettlement());
    _notify();
  }

  /// 结算后重新读取角色资料，失败时保留页面原有错误处理
  Future<void> _refreshSettlement() async {
    try {
      await _onSettlement();
    } catch (_) {
      if (!_disposed) {
        _message = '结算数据更新失败';
        _notify();
      }
    }
  }

  /// 检查响应是否仍属于当前角色任务
  ///
  /// [generation] 任务代次
  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  /// 通知仍在使用本控制器的组件
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// 释放计时器并取消在途请求
  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    cancel();
    super.dispose();
  }
}
