import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

// 星光股息按每股每点星级固定折算 ₵2
const double _starlightDividendPerStar = 2.0;

/// 计算角色持股总息
///
/// [item] 用户角色条目
/// [header] 角色头部资料
double userAssetAnalysisCharacterTotalDividend(
  UserCharacterApiItem item, {
  CharacterDetailTradeHeader? header,
}) {
  return (header?.dividend ?? item.rate) * item.userAmount;
}

/// 计算圣殿总息
///
/// [item] 用户圣殿条目
/// [header] 角色头部资料
double userAssetAnalysisTempleTotalDividend(
  UserTempleApiItem item, {
  CharacterDetailTradeHeader? header,
}) {
  return userAssetAnalysisTempleSingleDividend(item, header: header) *
      item.assets;
}

/// 计算圣殿单期股息
///
/// [item] 用户圣殿条目
/// [header] 角色头部资料
double userAssetAnalysisTempleSingleDividend(
  UserTempleApiItem item, {
  CharacterDetailTradeHeader? header,
}) {
  if (header == null) {
    return item.rate;
  }

  return header.templeDividend(
    characterLevel: item.characterLevel,
    refine: item.refine,
  );
}

/// 计算角色持股星光股息
///
/// [item] 用户角色条目
/// [header] 角色头部资料
double userAssetAnalysisCharacterStarlightDividend(
  UserCharacterApiItem item, {
  CharacterDetailTradeHeader? header,
}) {
  final stars = header?.stars ?? 0;
  return item.userAmount * _starlightDividendPerStar * stars;
}

/// 计算圣殿星光股息
///
/// [item] 用户圣殿条目
/// [header] 角色头部资料
double userAssetAnalysisTempleStarlightDividend(
  UserTempleApiItem item, {
  CharacterDetailTradeHeader? header,
}) {
  final stars = header?.stars ?? 0;
  return item.assets * _starlightDividendPerStar * stars;
}
