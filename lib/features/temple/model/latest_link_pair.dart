import 'dart:math' as math;

import 'package:magrail_app/core/utils/tinygrail_temple_link_order.dart';
import 'package:magrail_app/features/temple/model/latest_link_api_item.dart';

/// 最新连接展示组
class LatestLinkPair {
  /// 创建最新连接展示组
  ///
  /// [left] 左侧圣殿条目
  /// [right] 右侧圣殿条目
  /// [ownerName] 所属用户名
  /// [ownerNickname] 所属用户昵称
  const LatestLinkPair({
    required this.left,
    required this.right,
    required this.ownerName,
    required this.ownerNickname,
  });

  /// 左侧圣殿条目
  final LatestLinkApiItem left;

  /// 右侧圣殿条目
  final LatestLinkApiItem right;

  /// 所属用户名
  final String ownerName;

  /// 所属用户昵称
  final String ownerNickname;

  /// 连接值
  int get connectionValue => math.min(left.assets, right.assets);

  /// 从相邻接口条目创建展示组
  ///
  /// [first] 接口返回中的第一条圣殿
  /// [second] 接口返回中的第二条圣殿
  static LatestLinkPair? tryCreate(
    LatestLinkApiItem first,
    LatestLinkApiItem second,
  ) {
    if (!_isValidPair(first, second)) {
      return null;
    }

    final ordered = _sortForDisplay(first, second);
    return LatestLinkPair(
      left: ordered.$1,
      right: ordered.$2,
      ownerName: first.name,
      ownerNickname: first.nickname,
    );
  }

  /// 从接口条目中收集有效连接展示组
  ///
  /// [items] 接口返回的原始圣殿条目
  /// [limit] 最多返回的连接组数量
  static List<LatestLinkPair> collectValidPairs(
    List<LatestLinkApiItem> items, {
    int? limit,
  }) {
    final pairs = <LatestLinkPair>[];
    var index = 0;
    while (index < items.length - 1) {
      final pair = LatestLinkPair.tryCreate(items[index], items[index + 1]);
      if (pair == null) {
        index += 1;
        continue;
      }

      pairs.add(pair);
      if (limit != null && pairs.length >= limit) {
        break;
      }

      index += 2;
    }

    return List<LatestLinkPair>.unmodifiable(pairs);
  }

  /// 判断相邻两条圣殿是否组成有效连接
  ///
  /// [first] 接口返回中的第一条圣殿
  /// [second] 接口返回中的第二条圣殿
  static bool _isValidPair(
    LatestLinkApiItem first,
    LatestLinkApiItem second,
  ) {
    return first.characterId > 0 &&
        second.characterId > 0 &&
        first.linkId == second.characterId &&
        second.linkId == first.characterId;
  }

  /// 按原连接组件规则排序展示位置
  ///
  /// [first] 第一条圣殿
  /// [second] 第二条圣殿
  static (LatestLinkApiItem, LatestLinkApiItem) _sortForDisplay(
    LatestLinkApiItem first,
    LatestLinkApiItem second,
  ) {
    final keepsFirstOnLeft = TinygrailTempleLinkOrder.keepsFirstOnLeft(
      firstSacrifices: first.sacrifices,
      firstCreate: first.create,
      secondSacrifices: second.sacrifices,
      secondCreate: second.create,
    );
    return keepsFirstOnLeft ? (first, second) : (second, first);
  }
}
