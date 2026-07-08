import 'package:magrail_app/features/bangumi/next/model/next_bangumi_subject_character.dart';

/// Next Bangumi 角色关联分页结果
final class NextBangumiCharacterRelationPage {
  /// 创建 Next Bangumi 角色关联分页结果
  ///
  /// [items] 关联角色列表
  /// [total] 接口返回的原始总数
  /// [rawItemCount] 当前页接口返回的原始条目数量
  const NextBangumiCharacterRelationPage({
    required this.items,
    required this.total,
    required this.rawItemCount,
  });

  /// 关联角色列表
  final List<NextBangumiSubjectCharacterItem> items;

  /// 接口返回的原始总数
  final int total;

  /// 当前页接口返回的原始条目数量
  final int rawItemCount;
}
