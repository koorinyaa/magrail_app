import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_info.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';

/// 角色详情当前应展示的页面类型
enum CharacterDetailPageType {
  /// 正在判断角色页面类型
  pending,

  /// 已上市角色交易页
  trade,

  /// ICO 进行中页面
  ico,

  /// 未上市角色 ICO 启动页
  initial,

  /// 角色详情加载失败页
  failure,
}

/// 角色详情基础资料
class CharacterDetailBasicInfo {
  /// 创建角色详情基础资料
  ///
  /// [characterId] 角色 ID
  /// [name] 角色名称
  /// [icon] 角色头像地址
  /// [pageType] 当前应展示的角色页面类型
  /// [tradeHeader] 已上市角色头部资料
  /// [icoInfo] ICO 进行中头部资料
  const CharacterDetailBasicInfo({
    required this.characterId,
    required this.name,
    required this.icon,
    required this.pageType,
    required this.tradeHeader,
    required this.icoInfo,
  });

  /// 角色 ID
  final int characterId;

  /// 角色名称
  final String name;

  /// 角色头像地址
  final String icon;

  /// 当前应展示的角色页面类型
  final CharacterDetailPageType pageType;

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader? tradeHeader;

  /// ICO 进行中头部资料
  final CharacterDetailIcoInfo? icoInfo;

  /// 从 JSON 创建角色详情基础资料
  ///
  /// [json] 原始角色详情 JSON
  factory CharacterDetailBasicInfo.fromJson(Map<String, Object?> json) {
    final characterId = TinygrailResponseParser.asInt(json['CharacterId']);
    final isTrade = json.containsKey('Current');
    final pageType =
        isTrade ? CharacterDetailPageType.trade : CharacterDetailPageType.ico;

    return CharacterDetailBasicInfo(
      characterId: characterId > 0
          ? characterId
          : TinygrailResponseParser.asInt(json['Id']),
      name: TinygrailResponseParser.asString(json['Name']),
      icon: TinygrailResponseParser.asString(json['Icon']),
      pageType: pageType,
      tradeHeader: isTrade ? CharacterDetailTradeHeader.fromJson(json) : null,
      icoInfo: isTrade ? null : CharacterDetailIcoInfo.fromJson(json),
    );
  }
}
