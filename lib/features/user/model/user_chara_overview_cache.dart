import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_ico_api_item.dart';
import 'package:magrail_app/features/user/model/user_link_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

/// 用户角色资产预览缓存
class UserCharaOverviewCache {
  /// 创建用户角色资产预览缓存
  ///
  /// [username] 用户名
  /// [links] 用户连接预览
  /// [temples] 用户圣殿预览
  /// [characters] 用户角色预览
  /// [icos] 用户 ICO 预览
  /// [linkTotalItems] 用户连接总数
  /// [templeTotalItems] 用户圣殿总数
  /// [characterTotalItems] 用户角色总数
  /// [icoTotalItems] 用户 ICO 总数
  /// [updatedAtMilliseconds] 缓存更新时间戳，由仓库写入缓存时刷新
  const UserCharaOverviewCache({
    required this.username,
    required this.links,
    required this.temples,
    required this.characters,
    required this.icos,
    required this.linkTotalItems,
    required this.templeTotalItems,
    required this.characterTotalItems,
    required this.icoTotalItems,
    this.updatedAtMilliseconds = 0,
  });

  /// 用户名
  final String username;

  /// 用户连接预览
  final List<UserLinkApiItem> links;

  /// 用户圣殿预览
  final List<UserTempleApiItem> temples;

  /// 用户角色预览
  final List<UserCharacterApiItem> characters;

  /// 用户 ICO 预览
  final List<UserIcoApiItem> icos;

  /// 用户连接总数
  final int? linkTotalItems;

  /// 用户圣殿总数
  final int? templeTotalItems;

  /// 用户角色总数
  final int? characterTotalItems;

  /// 用户 ICO 总数
  final int? icoTotalItems;

  /// 缓存更新时间戳
  final int updatedAtMilliseconds;

  /// 从 JSON 创建用户角色资产预览缓存
  ///
  /// [json] 原始缓存 JSON
  factory UserCharaOverviewCache.fromJson(Map<String, Object?> json) {
    return UserCharaOverviewCache(
      username: TinygrailResponseParser.asString(json['Username']),
      links: TinygrailResponseParser.asObjectList(
            json['Links'],
            UserLinkApiItem.fromJson,
          ) ??
          const <UserLinkApiItem>[],
      temples: TinygrailResponseParser.asObjectList(
            json['Temples'],
            UserTempleApiItem.fromJson,
          ) ??
          const <UserTempleApiItem>[],
      characters: TinygrailResponseParser.asObjectList(
            json['Characters'],
            UserCharacterApiItem.fromJson,
          ) ??
          const <UserCharacterApiItem>[],
      icos: TinygrailResponseParser.asObjectList(
            json['Icos'],
            UserIcoApiItem.fromJson,
          ) ??
          const <UserIcoApiItem>[],
      linkTotalItems: _asNullableInt(json['LinkTotalItems']),
      templeTotalItems: _asNullableInt(json['TempleTotalItems']),
      characterTotalItems: _asNullableInt(json['CharacterTotalItems']),
      icoTotalItems: _asNullableInt(json['IcoTotalItems']),
      updatedAtMilliseconds: TinygrailResponseParser.asInt(json['UpdatedAt']),
    );
  }

  /// 转换为缓存 JSON
  Map<String, Object?> toJson() {
    return {
      'Username': username,
      'Links': links.map((item) => item.toJson()).toList(growable: false),
      'Temples': temples.map((item) => item.toJson()).toList(growable: false),
      'Characters':
          characters.map((item) => item.toJson()).toList(growable: false),
      'Icos': icos.map((item) => item.toJson()).toList(growable: false),
      'LinkTotalItems': linkTotalItems,
      'TempleTotalItems': templeTotalItems,
      'CharacterTotalItems': characterTotalItems,
      'IcoTotalItems': icoTotalItems,
      'UpdatedAt': updatedAtMilliseconds,
    };
  }

  /// 转换可空整数值
  ///
  /// [value] 原始值
  static int? _asNullableInt(Object? value) {
    if (value == null) {
      return null;
    }

    return TinygrailResponseParser.asInt(value);
  }
}
