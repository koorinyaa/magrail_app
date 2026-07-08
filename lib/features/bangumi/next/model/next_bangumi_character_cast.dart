import 'package:magrail_app/features/bangumi/next/model/next_bangumi_subject_search_item.dart';

/// Next Bangumi 角色出演作品分页结果
final class NextBangumiCharacterCastPage {
  /// 创建 Next Bangumi 角色出演作品分页结果
  ///
  /// [items] 出演作品列表
  /// [total] 接口返回的原始总数
  /// [rawItemCount] 当前页接口返回的原始条目数量
  const NextBangumiCharacterCastPage({
    required this.items,
    required this.total,
    required this.rawItemCount,
  });

  /// 出演作品列表
  final List<NextBangumiSubjectSearchItem> items;

  /// 接口返回的原始总数
  final int total;

  /// 当前页接口返回的原始条目数量
  final int rawItemCount;
}
