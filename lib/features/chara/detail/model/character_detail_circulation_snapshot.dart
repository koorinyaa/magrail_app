import 'dart:convert';

/// 角色实际流通的完整采集快照与结算规则
final class CharacterDetailCirculationSnapshot {
  /// 创建已完成采集的快照
  ///
  /// [total] 实际流通数量
  /// [startedAt] 开始采集时间
  /// [completedAt] 成功完成时间
  const CharacterDetailCirculationSnapshot({
    required this.total,
    required this.startedAt,
    required this.completedAt,
  });

  /// 实际流通数量
  final int total;

  /// 开始采集时间
  final DateTime startedAt;

  /// 成功完成时间
  final DateTime completedAt;

  /// 成功后十分钟内禁止重复采集
  static const cooldown = Duration(minutes: 10);

  /// 获取最近一次服务器周日零点对应的 UTC 时间
  ///
  /// [now] 当前时刻
  static DateTime settlementAt(DateTime now) {
    final server = now.toUtc().add(const Duration(hours: 8));
    final midnight = DateTime.utc(server.year, server.month, server.day);
    return midnight.subtract(Duration(days: server.weekday % 7, hours: 8));
  }

  /// 获取当前高峰期的结束时刻，非高峰期返回空值
  ///
  /// [now] 当前时刻
  static DateTime? peakEndsAt(DateTime now) {
    final settlement = settlementAt(now);
    final end = settlement.add(const Duration(minutes: 10));
    if (now.isBefore(end)) return end;
    final next = settlement.add(const Duration(days: 7));
    if (!now.isBefore(next.subtract(const Duration(minutes: 30)))) {
      return next.add(const Duration(minutes: 10));
    }
    return null;
  }

  /// 判断快照是否属于当前结算周期
  ///
  /// [now] 当前时刻，设备时钟回拨时不使用未来快照
  bool isValidAt(DateTime now) {
    return !startedAt.isBefore(settlementAt(now)) &&
        !completedAt.isBefore(startedAt) &&
        !completedAt.isAfter(now);
  }

  /// 将完整快照编码为持久化 JSON
  String encode() => jsonEncode({
    'total': total,
    'startedAt': startedAt.millisecondsSinceEpoch,
    'completedAt': completedAt.millisecondsSinceEpoch,
  });

  /// 读取缓存，损坏或字段缺失时忽略
  ///
  /// [raw] 本地缓存 JSON
  static CharacterDetailCirculationSnapshot? decode(String? raw) {
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic> ||
          json['total'] is! int ||
          json['total'] < 0 ||
          json['startedAt'] is! int ||
          json['completedAt'] is! int) {
        return null;
      }
      return CharacterDetailCirculationSnapshot(
        total: json['total'] as int,
        startedAt: DateTime.fromMillisecondsSinceEpoch(
          json['startedAt'] as int,
          isUtc: true,
        ),
        completedAt: DateTime.fromMillisecondsSinceEpoch(
          json['completedAt'] as int,
          isUtc: true,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
