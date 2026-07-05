import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/ranking/model/ranking_entry.dart';
import 'package:magrail_app/features/ranking/repository/ranking_repository.dart';

/// 圣殿精炼排行分页控制器
class TempleRefineRankingController
    extends TinygrailPagedListController<RankingEntry, RankingEntry> {
  /// 创建圣殿精炼排行分页控制器
  ///
  /// [repository] 排行榜仓库
  /// [pageSize] 每页条目数量
  TempleRefineRankingController({
    required RankingRepository repository,
    super.pageSize = defaultPageSize,
  }) : _repository = repository;

  /// 精炼排行默认分页数量
  static const int defaultPageSize = 20;

  final RankingRepository _repository;

  /// 请求精炼排行分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页条目数量
  @override
  Future<TinygrailPage<RankingEntry>> requestPage({
    required int page,
    required int pageSize,
  }) async {
    final result = await _repository.fetchRefineRankingPage(
      page: page,
      pageSize: pageSize,
    );

    return TinygrailPage<RankingEntry>(
      items: result.items,
      currentPage: result.currentPage,
      totalPages: result.totalPages,
      totalItems: result.totalItems,
      itemsPerPage: result.itemsPerPage,
    );
  }

  /// 转换精炼排行展示条目
  ///
  /// [items] 接口返回条目
  @override
  List<RankingEntry> convertPageItems(
    List<RankingEntry> items,
  ) {
    return items;
  }
}

/// 番市首富分页控制器
class UserWealthRankingController
    extends TinygrailPagedListController<RankingEntry, RankingEntry> {
  /// 创建番市首富分页控制器
  ///
  /// [repository] 排行榜仓库
  /// [pageSize] 每页条目数量
  UserWealthRankingController({
    required RankingRepository repository,
    super.pageSize = defaultPageSize,
  }) : _repository = repository;

  /// 番市首富默认分页数量
  static const int defaultPageSize = 20;

  final RankingRepository _repository;

  /// 请求番市首富分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页条目数量
  @override
  Future<TinygrailPage<RankingEntry>> requestPage({
    required int page,
    required int pageSize,
  }) async {
    final result = await _repository.fetchWealthRankingPage(
      page: page,
      pageSize: pageSize,
    );

    return TinygrailPage<RankingEntry>(
      items: result.items,
      currentPage: result.currentPage,
      totalPages: result.totalPages,
      totalItems: result.totalItems,
      itemsPerPage: result.itemsPerPage,
    );
  }

  /// 转换番市首富展示条目
  ///
  /// [items] 接口返回条目
  @override
  List<RankingEntry> convertPageItems(
    List<RankingEntry> items,
  ) {
    return items;
  }
}
