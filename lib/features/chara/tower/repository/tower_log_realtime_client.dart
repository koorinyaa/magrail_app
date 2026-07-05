import 'package:magrail_app/core/auth/tinygrail_site_config.dart';
import 'package:magrail_app/features/chara/tower/model/tower_log_api_item.dart';
import 'package:signalr_netcore/signalr_client.dart';

/// 通天塔日志实时客户端
class TowerLogRealtimeClient {
  /// 创建通天塔日志实时客户端
  ///
  /// [onLog] 收到实时日志后的回调
  TowerLogRealtimeClient({
    required void Function(TowerLogApiItem item) onLog,
  }) : _onLog = onLog;

  static final String _hubUrl =
      TinygrailSiteConfig.siteUri.resolve('actionhub').toString();

  final void Function(TowerLogApiItem item) _onLog;

  HubConnection? _connection;
  bool _isStarted = false;
  bool _isDisposed = false;

  /// 启动通天塔日志实时连接
  Future<void> start() async {
    if (_isDisposed || _isStarted) {
      return;
    }

    final connection =
        HubConnectionBuilder().withUrl(_hubUrl).withAutomaticReconnect(
      retryDelays: const <int>[0, 2000, 5000, 10000],
    ).build();

    connection.on('ReceiveStarLog', _handleStarLog);
    connection.onclose(({error}) {
      if (identical(_connection, connection)) {
        _isStarted = false;
      }
    });

    _connection = connection;

    try {
      await connection.start();
      if (_isDisposed || !identical(_connection, connection)) {
        await _stopConnectionSafely(connection);
        return;
      }
      _isStarted = true;
    } catch (_) {
      if (identical(_connection, connection)) {
        _connection = null;
        _isStarted = false;
      }
    }
  }

  /// 停止通天塔日志实时连接
  Future<void> stop() async {
    _isDisposed = true;
    final connection = _connection;
    _connection = null;
    _isStarted = false;

    if (connection == null) {
      return;
    }

    await _stopConnectionSafely(connection);
  }

  /// 处理通天塔日志推送
  ///
  /// [arguments] SignalR 事件参数
  void _handleStarLog(List<Object?>? arguments) {
    if (_isDisposed || arguments == null || arguments.isEmpty) {
      return;
    }

    final json = _asStringObjectMap(arguments.first);
    if (json == null) {
      return;
    }

    try {
      _onLog(TowerLogApiItem.fromJson(json));
    } catch (_) {
      return;
    }
  }

  /// 转换 SignalR 推送 JSON
  ///
  /// [value] SignalR 事件参数
  Map<String, Object?>? _asStringObjectMap(Object? value) {
    if (value is Map<String, Object?>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    return null;
  }

  /// 安全停止 SignalR 连接
  ///
  /// [connection] 需要停止的 SignalR 连接
  Future<void> _stopConnectionSafely(HubConnection connection) async {
    try {
      await connection.stop();
    } catch (_) {
      return;
    }
  }
}
