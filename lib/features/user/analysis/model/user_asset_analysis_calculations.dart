import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

// 星光股息按每股每点星级固定折算 ₵2
const double _starlightDividendPerStar = 2.0;

/// 计算角色持股总息
///
/// [item] 用户角色条目
double userAssetAnalysisCharacterTotalDividend(UserCharacterApiItem item) {
  return item.singleDividend * item.userAmount;
}

/// 计算圣殿总息
///
/// [item] 用户圣殿条目
double userAssetAnalysisTempleTotalDividend(UserTempleApiItem item) {
  return userAssetAnalysisTempleSingleDividend(item) * item.assets;
}

/// 计算圣殿单期股息
///
/// [item] 用户圣殿条目
double userAssetAnalysisTempleSingleDividend(UserTempleApiItem item) {
  final rank = item.characterRank;
  final dividend = rank > 0 && rank <= 500
      ? item.rate * 0.005 * (601 - rank)
      : item.characterStars * _starlightDividendPerStar;
  // 500 名外的圣殿股息不受等级和精炼影响
  if (rank <= 0 || rank > 500) {
    return dividend;
  }

  final levelCoefficient = 2 * item.characterLevel + 1;
  if (levelCoefficient <= 0) {
    return 0;
  }
  final refineCoefficient = 2 * (item.characterLevel + item.refine) + 1;
  return dividend / levelCoefficient * refineCoefficient;
}

/// 计算角色持股星光股息
///
/// [item] 用户角色条目
double userAssetAnalysisCharacterStarlightDividend(
  UserCharacterApiItem item,
) {
  return item.userAmount * _starlightDividendPerStar * item.stars;
}

/// 计算圣殿星光股息
///
/// [item] 用户圣殿条目
double userAssetAnalysisTempleStarlightDividend(UserTempleApiItem item) {
  return item.assets * _starlightDividendPerStar * item.characterStars;
}
