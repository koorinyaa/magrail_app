import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/user/analysis/model/user_asset_analysis_calculations.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

/// 构建角色圆图数据
///
/// [characters] 用户全部角色
/// [temples] 用户全部圣殿
/// [characterHeadersById] 角色头部资料索引
List<UserAssetAnalysisCharacterBubble> buildUserAssetAnalysisCharacterBubbles({
  required List<UserCharacterApiItem> characters,
  required List<UserTempleApiItem> temples,
  required Map<int, CharacterDetailTradeHeader> characterHeadersById,
}) {
  final bubbles = <int, _MutableCharacterBubble>{};
  for (final character in characters) {
    if (character.characterId <= 0) {
      continue;
    }
    final header = characterHeadersById[character.characterId];
    final bubble = bubbles.putIfAbsent(character.characterId, () {
      return _MutableCharacterBubble(character.characterId);
    });
    bubble.applyCharacter(character, header);
    bubble.characterDividend += userAssetAnalysisCharacterTotalDividend(
      character,
      header: header,
    );
    bubble.characterShares += character.userTotal;
  }
  for (final temple in temples) {
    if (temple.characterId <= 0) {
      continue;
    }
    final header = characterHeadersById[temple.characterId];
    final bubble = bubbles.putIfAbsent(temple.characterId, () {
      return _MutableCharacterBubble(temple.characterId);
    });
    bubble.applyTemple(temple, header);
    bubble.templeDividend += userAssetAnalysisTempleTotalDividend(
      temple,
      header: header,
    );
    bubble.templeAssets += temple.assets;
  }

  final result =
      bubbles.values.map((bubble) => bubble.toBubble()).where((bubble) {
    return bubble.totalDividend > 0 || bubble.totalAssets > 0;
  }).toList()
        ..sort((a, b) {
          final dividendCompare = b.totalDividend.compareTo(a.totalDividend);
          if (dividendCompare != 0) {
            return dividendCompare;
          }
          final assetsCompare = b.totalAssets.compareTo(a.totalAssets);
          if (assetsCompare != 0) {
            return assetsCompare;
          }
          return a.characterId.compareTo(b.characterId);
        });
  return List<UserAssetAnalysisCharacterBubble>.unmodifiable(result);
}

/// 用户资产分析角色圆图气泡
class UserAssetAnalysisCharacterBubble {
  /// 创建用户资产分析角色圆图气泡
  ///
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [avatarUrl] 角色头像地址
  /// [level] 角色等级
  /// [characterDividend] 持股总息
  /// [templeDividend] 圣殿总息
  /// [characterShares] 角色持股数量
  /// [templeAssets] 圣殿资产值
  const UserAssetAnalysisCharacterBubble({
    required this.characterId,
    required this.name,
    required this.avatarUrl,
    required this.level,
    required this.characterDividend,
    required this.templeDividend,
    required this.characterShares,
    required this.templeAssets,
  });

  /// 从缓存 JSON 创建角色圆图气泡
  ///
  /// [json] 角色圆图气泡 JSON
  factory UserAssetAnalysisCharacterBubble.fromJson(
    Map<String, Object?> json,
  ) {
    if (!json.containsKey('characterShares') ||
        !json.containsKey('templeAssets')) {
      throw const FormatException('角色气泡缓存字段缺失');
    }
    return UserAssetAnalysisCharacterBubble(
      characterId: TinygrailResponseParser.asInt(json['characterId']),
      name: TinygrailResponseParser.asString(json['name']),
      avatarUrl: TinygrailResponseParser.asString(json['avatarUrl']),
      level: TinygrailResponseParser.asInt(json['level']),
      characterDividend: TinygrailResponseParser.asDouble(
        json['characterDividend'],
      ),
      templeDividend: TinygrailResponseParser.asDouble(
        json['templeDividend'],
      ),
      characterShares: TinygrailResponseParser.asInt(
        json['characterShares'],
      ),
      templeAssets: TinygrailResponseParser.asInt(json['templeAssets']),
    );
  }

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 角色头像地址
  final String avatarUrl;

  /// 角色等级
  final int level;

  /// 持股总息
  final double characterDividend;

  /// 圣殿总息
  final double templeDividend;

  /// 角色持股数量
  final int characterShares;

  /// 圣殿资产值
  final int templeAssets;

  /// 角色总息合计
  double get totalDividend => characterDividend + templeDividend;

  /// 角色持股与圣殿资产合计
  int get totalAssets => characterShares + templeAssets;

  /// 转换为角色圆图气泡缓存 JSON
  Map<String, Object?> toJson() {
    return {
      'characterId': characterId,
      'name': name,
      'avatarUrl': avatarUrl,
      'level': level,
      'characterDividend': characterDividend,
      'templeDividend': templeDividend,
      'characterShares': characterShares,
      'templeAssets': templeAssets,
    };
  }
}

/// 用户资产分析可变角色圆图气泡
class _MutableCharacterBubble {
  /// 创建可变角色圆图气泡
  ///
  /// [characterId] 角色 ID
  _MutableCharacterBubble(this.characterId);

  final int characterId;
  String name = '';
  String avatarUrl = '';
  int level = 0;
  double characterDividend = 0;
  double templeDividend = 0;
  int characterShares = 0;
  int templeAssets = 0;

  /// 应用用户角色条目
  ///
  /// [item] 用户角色条目
  /// [header] 角色头部资料
  void applyCharacter(
    UserCharacterApiItem item,
    CharacterDetailTradeHeader? header,
  ) {
    if (name.trim().isEmpty) {
      name = item.name.trim().isNotEmpty ? item.name : header?.name ?? '';
    }
    if (avatarUrl.trim().isEmpty) {
      avatarUrl = item.icon.trim().isNotEmpty ? item.icon : header?.icon ?? '';
    }
    if (item.level > 0) {
      level = item.level;
      return;
    }
    if (level <= 0 && header != null) {
      level = header.level;
    }
  }

  /// 应用用户圣殿条目
  ///
  /// [item] 用户圣殿条目
  /// [header] 角色头部资料
  void applyTemple(
    UserTempleApiItem item,
    CharacterDetailTradeHeader? header,
  ) {
    if (name.trim().isEmpty) {
      name = item.name.trim().isNotEmpty ? item.name : header?.name ?? '';
    }
    if (avatarUrl.trim().isEmpty) {
      avatarUrl =
          item.avatar.trim().isNotEmpty ? item.avatar : header?.icon ?? '';
    }
    if (level <= 0 && item.characterLevel > 0) {
      level = item.characterLevel;
      return;
    }
    if (level <= 0 && header != null) {
      level = header.level;
    }
  }

  /// 转换为角色圆图气泡
  UserAssetAnalysisCharacterBubble toBubble() {
    return UserAssetAnalysisCharacterBubble(
      characterId: characterId,
      name: name,
      avatarUrl: avatarUrl,
      level: level,
      characterDividend: characterDividend,
      templeDividend: templeDividend,
      characterShares: characterShares,
      templeAssets: templeAssets,
    );
  }
}
