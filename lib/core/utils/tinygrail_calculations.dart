import 'dart:math' as math;

/// Tinygrail 通用业务计算
final class TinygrailCalculations {
  /// 阻止实例化通用计算工具
  const TinygrailCalculations._();

  // 角色等级计算以 7500 作为流通基准
  static const double _characterLevelBaseCirculation = 7500;

  // 角色等级公式中的对数底数
  static const double _characterLevelLogBase = 1.3;

  /// 根据流通计算角色等级
  ///
  /// floor(log(流通 / 7500) / log(1.3) + 1)
  ///
  /// [circulation] 流通股数
  static int characterLevelFromCirculation(num circulation) {
    if (!circulation.isFinite || circulation <= 0) {
      return 0;
    }

    final level = (math.log(circulation / _characterLevelBaseCirculation) /
                math.log(_characterLevelLogBase) +
            1)
        .floor();
    if (level < 0) {
      return 0;
    }

    return level;
  }

  /// 根据角色等级计算最低流通
  ///
  /// ceil(7500 × 1.3 ^ (等级 - 1))
  ///
  /// [level] 角色等级
  static int minimumCirculationForCharacterLevel(int level) {
    if (level <= 0) {
      return 0;
    }

    final circulation = _characterLevelBaseCirculation *
        math.pow(_characterLevelLogBase, level - 1);

    return circulation.ceil();
  }
}
