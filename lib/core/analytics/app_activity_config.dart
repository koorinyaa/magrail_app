import 'package:flutter/foundation.dart';

/// 应用活跃统计配置
class AppActivityConfig {
  /// 禁用实例化
  const AppActivityConfig._();

  /// 正式版本使用的活跃统计接口
  static final Uri? endpoint =
      kReleaseMode ? Uri.https('metrics.fuyuake.top', '/v1/activity') : null;
}
