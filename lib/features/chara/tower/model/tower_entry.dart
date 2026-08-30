import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';

/// 通天塔排名条目
class TowerEntry {
  /// 创建通天塔排名条目
  ///
  /// [characterId] 角色 ID
  /// [rank] 排名
  /// [name] 角色名称
  /// [level] 角色等级
  /// [zeroCount] ST 等级
  /// [stars] 角色星级
  /// [starForces] 星之力原始数值
  /// [avatarUrl] 角色头像地址
  const TowerEntry({
    required this.characterId,
    required this.rank,
    required this.name,
    required this.level,
    required this.zeroCount,
    required this.stars,
    required this.starForces,
    required this.avatarUrl,
  });

  /// 角色 ID
  final int characterId;

  /// 排名
  final int rank;

  /// 角色名称
  final String name;

  /// 角色等级
  final int level;

  /// ST 等级
  final int zeroCount;

  /// 角色星级
  final int stars;

  /// 星之力原始数值
  final int starForces;

  /// 角色头像地址
  final String avatarUrl;

  /// 排名字体颜色
  Color get rankColor {
    return switch (rank) {
      1 => const Color(0xFFF2B72F),
      2 => const Color(0xFF6F85A6),
      3 => const Color(0xFFA7653D),
      _ => const Color(0xFFA1A1AA),
    };
  }

  /// 星之力显示文本
  String get starForcesLabel {
    return Formatters.tinygrailCompactValue(starForces);
  }
}
