import 'package:magrail_app/core/network/tinygrail_response.dart';

/// 角色资产重组提交类型
enum CharacterDetailSacrificeMode {
  /// 将活股转为固定资产
  restructure,

  /// 将活股出售给幻想乡
  financing,
}

/// 角色资产重组提交结果
final class CharacterDetailSacrificeResult {
  /// 创建角色资产重组提交结果
  ///
  /// [balance] 本次获得资金
  /// [items] 本次掉落道具
  const CharacterDetailSacrificeResult({
    required this.balance,
    required this.items,
  });

  /// 创建空的角色资产重组提交结果
  const CharacterDetailSacrificeResult.empty()
      : balance = 0,
        items = const <CharacterDetailSacrificeItem>[];

  /// 本次获得资金
  final double balance;

  /// 本次掉落道具
  final List<CharacterDetailSacrificeItem> items;

  /// 从 JSON 创建角色资产重组提交结果
  ///
  /// [json] 原始提交结果 JSON
  factory CharacterDetailSacrificeResult.fromJson(
    Map<String, Object?> json,
  ) {
    return CharacterDetailSacrificeResult(
      balance: TinygrailResponseParser.asDouble(json['Balance']),
      items: TinygrailResponseParser.asObjectList(
            json['Items'],
            CharacterDetailSacrificeItem.fromJson,
          ) ??
          const <CharacterDetailSacrificeItem>[],
    );
  }
}

/// 角色资产重组掉落道具
final class CharacterDetailSacrificeItem {
  /// 创建角色资产重组掉落道具
  ///
  /// [id] 道具 ID
  /// [name] 道具名称
  /// [icon] 道具图标
  /// [count] 道具数量
  const CharacterDetailSacrificeItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.count,
  });

  /// 道具 ID
  final int id;

  /// 道具名称
  final String name;

  /// 道具图标
  final String icon;

  /// 道具数量
  final int count;

  /// 从 JSON 创建角色资产重组掉落道具
  ///
  /// [json] 原始道具 JSON
  factory CharacterDetailSacrificeItem.fromJson(
    Map<String, Object?> json,
  ) {
    return CharacterDetailSacrificeItem(
      id: TinygrailResponseParser.asInt(json['Id']),
      name: TinygrailResponseParser.asString(json['Name']),
      icon: TinygrailResponseParser.asString(json['Icon']),
      count: TinygrailResponseParser.asInt(json['Count']),
    );
  }
}
