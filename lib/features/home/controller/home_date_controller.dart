import 'dart:async';

import 'package:flutter/widgets.dart';

/// 首页服务器日期与本周日期状态
class HomeDateController extends ChangeNotifier {
  /// 创建首页日期状态控制器
  HomeDateController() {
    _lifecycleListener = AppLifecycleListener(onResume: refresh);
    _startTimer();
  }

  // 服务器业务时区固定为 UTC+8，设备时区不参与周历日期判断
  static const Duration _serverOffset = Duration(hours: 8);
  // 周历不显示时分，每分钟检查日期并仅在跨日时刷新
  static const Duration _refreshInterval = Duration(minutes: 1);

  Timer? _timer;
  late final AppLifecycleListener _lifecycleListener;
  DateTime _serverDate = _readServerDate();
  bool _isDisposed = false;

  /// 服务器 UTC+8 当前日历日期，不表示 UTC 零点的真实时刻
  DateTime get serverDate => _serverDate;

  /// 服务器今天所在的列索引，周日为零
  int get todayIndex => _serverDate.weekday % DateTime.daysPerWeek;

  /// 本周周日到周六的服务器日历日期
  List<DateTime> get weekDates {
    final sunday = _serverDate.subtract(Duration(days: todayIndex));
    // 使用 UTC 日历日期做加减，避免设备夏令时改变相邻日期的间隔
    return List<DateTime>.generate(
      DateTime.daysPerWeek,
      (index) => sunday.add(Duration(days: index)),
      growable: false,
    );
  }

  /// 释放首页日期状态控制器
  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _lifecycleListener.dispose();
    super.dispose();
  }

  /// 检查服务器日期，仅在跨日时通知周历组件
  void refresh() {
    if (_isDisposed) {
      return;
    }

    final nextDate = _readServerDate();
    if (nextDate == _serverDate) return;
    _serverDate = nextDate;
    notifyListeners();
  }

  /// 从设备当前时刻换算服务器日历日期
  static DateTime _readServerDate() {
    final server = DateTime.now().toUtc().add(_serverOffset);
    return DateTime.utc(server.year, server.month, server.day);
  }

  /// 启动日期刷新定时器
  void _startTimer() {
    _timer = Timer.periodic(_refreshInterval, (_) => refresh());
  }
}
