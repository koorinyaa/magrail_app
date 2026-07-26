part of 'user_asset_snapshot_repository.dart';

/// 用户资产全量刷新串行调度器
class _UserAssetSnapshotRefreshScheduler {
  final Map<String, _UserAssetSnapshotRefreshTask> _tasks = {};
  final List<_UserAssetSnapshotRefreshTask> _queue = [];
  _UserAssetSnapshotRefreshTask? _runningTask;
  int _nextSequence = 0;

  /// 合并并调度一次全量刷新
  ///
  /// [key] 用户、数据类型与存储范围组成的唯一键
  /// [priority] 当前触发场景的优先级
  /// [totalItemsHint] 当前已知的数据总数
  /// [action] 实际全量刷新操作
  Future<bool> schedule({
    required String key,
    required UserAssetSnapshotRefreshPriority priority,
    required int? totalItemsHint,
    required Future<bool> Function(int? totalItemsHint) action,
  }) {
    final existing = _tasks[key];
    if (existing != null) {
      existing.promote(priority, totalItemsHint);
      _sortQueue();
      return existing.completer.future;
    }

    final task = _UserAssetSnapshotRefreshTask(
      key: key,
      priority: priority,
      totalItemsHint: totalItemsHint,
      sequence: _nextSequence++,
      action: action,
    );
    _tasks[key] = task;
    _queue.add(task);
    _sortQueue();
    _pump();
    return task.completer.future;
  }

  /// 按优先级和进入队列顺序排列等待任务
  void _sortQueue() {
    _queue.sort((left, right) {
      final priorityOrder = right.priority.index.compareTo(left.priority.index);
      return priorityOrder != 0
          ? priorityOrder
          : left.sequence.compareTo(right.sequence);
    });
  }

  /// 执行下一个全量刷新任务
  void _pump() {
    if (_runningTask != null || _queue.isEmpty) {
      return;
    }
    final task = _queue.removeAt(0);
    _runningTask = task;
    Future.sync(() => task.action(task.totalItemsHint))
        .then(
      task.completer.complete,
      onError: task.completer.completeError,
    )
        .whenComplete(() {
      _tasks.remove(task.key);
      _runningTask = null;
      _pump();
    });
  }
}

/// 等待执行的用户资产全量刷新任务
class _UserAssetSnapshotRefreshTask {
  /// 创建用户资产全量刷新任务
  ///
  /// [key] 用户、数据类型与存储范围组成的唯一键
  /// [priority] 当前触发场景的优先级
  /// [totalItemsHint] 当前已知的数据总数
  /// [sequence] 进入队列的顺序
  /// [action] 实际全量刷新操作
  _UserAssetSnapshotRefreshTask({
    required this.key,
    required this.priority,
    required this.totalItemsHint,
    required this.sequence,
    required this.action,
  });

  final String key;
  final int sequence;
  final Future<bool> Function(int? totalItemsHint) action;
  final Completer<bool> completer = Completer<bool>();
  UserAssetSnapshotRefreshPriority priority;
  int? totalItemsHint;

  /// 提升等待任务的优先级并更新总数
  ///
  /// [nextPriority] 新触发场景的优先级
  /// [nextTotalItemsHint] 新取得的数据总数
  void promote(
    UserAssetSnapshotRefreshPriority nextPriority,
    int? nextTotalItemsHint,
  ) {
    if (nextPriority.index > priority.index) {
      priority = nextPriority;
    }
    if (nextTotalItemsHint != null && nextTotalItemsHint >= 0) {
      totalItemsHint = nextTotalItemsHint;
    }
  }
}
