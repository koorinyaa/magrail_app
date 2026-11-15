import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

// 引擎自动下载可能仍在进行，有限轮询覆盖慢网络下晚于整包等待窗口的结果
const _patchStateWait = Duration(minutes: 2);
const _patchStatePollInterval = Duration(milliseconds: 500);

/// 协调补丁检查、下载及当前进程与下次启动的补丁状态
class AppPatchUpdater extends ChangeNotifier {
  /// 创建补丁更新器
  AppPatchUpdater();

  ShorebirdUpdater? _updater;
  Future<void>? _activeCheck;
  int? _currentPatch;
  int? _nextPatch;
  bool _stateKnown = false;
  bool _isChecking = false;
  bool _disposed = false;

  /// 当前进程正在运行的补丁号，空值表示基础包代码
  int? get currentPatch => _currentPatch;

  /// 是否仍在检查或准备后台补丁
  bool get isChecking => _isChecking;

  /// 下次启动的代码与当前进程不同
  bool get restartRequired =>
      _stateKnown && _currentPatch != _nextPatch;

  /// 当前补丁已被撤回，下次启动将恢复较早的代码
  bool get rollbackPending =>
      restartRequired && (_nextPatch ?? 0) < (_currentPatch ?? 0);

  /// 已有更新补丁等待下次启动，尚不能作为当前内容版本
  bool get updatePending => restartRequired && !rollbackPending;

  /// 检查并下载正式通道补丁，共用在途任务且不影响当前进程运行
  Future<void> checkForUpdate() {
    return _activeCheck ??= _runCheck().whenComplete(() {
      _activeCheck = null;
    });
  }

  /// 仅刷新磁盘补丁状态，不发起网络检查，供重新进入前台时确认晚到结果
  Future<void> refreshState() async {
    final updater = _updater;
    if (_disposed || updater == null || !updater.isAvailable) return;

    try {
      await _readPatches(updater);
    } catch (_) {
      // 保留最近一次已确认状态，下一次手动检查或完整启动重新确认
    }
  }

  /// 检查补丁并在下载后核对磁盘状态，所有失败均保留整包后备路径
  Future<void> _runCheck() async {
    // 调试及非移动平台不初始化补丁引擎，继续使用 GitHub 整包检查
    if (!kReleaseMode ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    _isChecking = true;
    _notify();
    try {
      final updater = _updater ??= ShorebirdUpdater();
      if (!updater.isAvailable) return;

      await _readPatches(updater);
      final status = await updater.checkForUpdate();
      // 检查也可能撤回当前补丁，不能将所有待重启状态当成下载成功
      await _readPatches(updater);
      if (status != UpdateStatus.outdated || _disposed) return;

      await updater.update();
      await _readPatches(updater);
      // update 在引擎自动下载已开始时可能直接返回，需确认真实待生效补丁
      final stopwatch = Stopwatch()..start();
      while (!restartRequired &&
          !_disposed &&
          stopwatch.elapsed < _patchStateWait) {
        await Future<void>.delayed(_patchStatePollInterval);
        await _readPatches(updater);
      }
    } catch (_) {
      // 网络、额度和校验失败不改变运行代码，也不阻断 GitHub 更新提示
    } finally {
      _isChecking = false;
      _notify();
    }
  }

  /// 连续读取当前补丁与下次启动补丁，避免下载返回值被误判为更新成功
  ///
  /// [updater] 当前基础包的补丁引擎
  Future<void> _readPatches(ShorebirdUpdater updater) async {
    final current = await updater.readCurrentPatch();
    final next = await updater.readNextPatch();
    if (_disposed) return;
    if (_stateKnown &&
        _currentPatch == current?.number &&
        _nextPatch == next?.number) {
      return;
    }

    _currentPatch = current?.number;
    _nextPatch = next?.number;
    _stateKnown = true;
    _notify();
  }

  /// 仅在更新器仍被持有时通知页面，后台网络任务无法通过销毁取消
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// 停止状态通知，保留引擎对已开始下载的处理
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
