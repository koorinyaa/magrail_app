import 'dart:math' as math;

import 'package:magrail_app/features/chara/detail/model/character_detail_ico_info.dart';

/// 角色详情 ICO 预测数据
class CharacterDetailIcoPrediction {
  /// 创建角色详情 ICO 预测数据
  ///
  /// [level] ICO 等级
  /// [next] 下一档所需金额
  /// [price] 原始发行价
  /// [amount] 发行量
  /// [users] 下一档还需参与人数
  /// [total] 已筹集金额
  const CharacterDetailIcoPrediction({
    required this.level,
    required this.next,
    required this.price,
    required this.amount,
    required this.users,
    required this.total,
  });

  /// ICO 等级
  final int level;

  /// 下一档所需金额
  final double next;

  /// 原始发行价
  final double price;

  /// 发行量
  final double amount;

  /// 下一档还需参与人数
  final int users;

  /// 已筹集金额
  final double total;

  /// 从 ICO 头部资料创建预测数据
  ///
  /// [info] ICO 头部资料
  factory CharacterDetailIcoPrediction.fromInfo(
    CharacterDetailIcoInfo info,
  ) {
    return CharacterDetailIcoPrediction.fromTotals(
      total: info.total,
      users: info.users,
    );
  }

  /// 从 ICO 金额和参与人数创建预测数据
  ///
  /// [total] 已筹集金额
  /// [users] 参与人数
  factory CharacterDetailIcoPrediction.fromTotals({
    required double total,
    required int users,
  }) {
    var level = 0;
    var next = 600000.0;

    final headLevel = math.max(((users - 10) / 5).floor(), 0);
    while (total >= next && level < headLevel) {
      level += 1;
      next += math.pow(level + 1, 2).toDouble() * 100000;
    }

    final amount = 10000 + (level - 1) * 7500.0;
    final price = amount == 0 ? 10.0 : (total - 500000) / amount;
    final nextUser = (level + 1) * 5 + 10;

    return CharacterDetailIcoPrediction(
      level: level,
      next: next,
      price: price,
      amount: amount,
      users: nextUser - users,
      total: total,
    );
  }

  /// 展示用发行价
  double get displayPrice => math.max(price, 10);

  /// 上市等级
  int get listingLevel {
    if (amount <= 0) {
      return 0;
    }

    final value = math.log(amount / 7500.0) / math.log(1.3) + 1;
    if (value.isNaN || value.isInfinite) {
      return 0;
    }

    return math.max(value.floor(), 0);
  }

  /// 进度百分比文本数值
  int get percent {
    if (next <= 0) {
      return 0;
    }

    return (total / next * 100).round();
  }

  /// 进度条数值
  double get progress {
    if (next <= 0) {
      return 0;
    }

    return (total / next).clamp(0.0, 1.0).toDouble();
  }
}
