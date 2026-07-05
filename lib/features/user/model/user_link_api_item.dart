import 'dart:math' as math;

import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

/// 用户连接接口条目
class UserLinkApiItem {
  /// 创建用户连接接口条目
  ///
  /// [temple] 连接左侧圣殿
  /// [link] 连接右侧圣殿
  const UserLinkApiItem({
    required this.temple,
    required this.link,
  });

  /// 连接左侧圣殿
  final UserTempleApiItem temple;

  /// 连接右侧圣殿
  final UserTempleApiItem? link;

  /// 是否存在有效连接
  bool get hasLink => link != null;

  /// 连接值
  int get connectionValue {
    final linked = link;
    if (linked == null) {
      return 0;
    }

    return math.min(temple.assets, linked.assets);
  }

  /// 左侧展示圣殿
  UserTempleApiItem get left {
    final linked = link;
    if (linked == null || temple.sacrifices >= linked.sacrifices) {
      return temple;
    }

    return linked;
  }

  /// 右侧展示圣殿
  UserTempleApiItem get right {
    final linked = link;
    if (linked == null || temple.sacrifices >= linked.sacrifices) {
      return linked ?? temple;
    }

    return temple;
  }

  /// 从 JSON 创建用户连接接口条目
  ///
  /// [json] 原始条目 JSON
  factory UserLinkApiItem.fromJson(Map<String, Object?> json) {
    final linkJson = TinygrailResponseParser.asObjectMap(json['Link']);

    return UserLinkApiItem(
      temple: UserTempleApiItem.fromJson(json),
      link: linkJson == null ? null : UserTempleApiItem.fromJson(linkJson),
    );
  }

  /// 转换为缓存 JSON
  Map<String, Object?> toJson() {
    return {
      ...temple.toJson(),
      'Link': link?.toJson(),
    };
  }
}
