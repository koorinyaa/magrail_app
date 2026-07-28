import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/chara/controller/character_full_list_page_controller.dart';
import 'package:magrail_app/features/chara/model/character_full_list_sort.dart';
import 'package:magrail_app/features/chara/rank/model/character_rank_entry.dart';
import 'package:magrail_app/features/chara/rank/repository/character_rank_repository.dart';

/// 角色排序分页控制器
class CharacterRankPageController extends TinygrailPagedListController<
    CharacterRankEntry, CharacterRankEntry> {
  /// 创建角色排序分页控制器
  ///
  /// [repository] 角色排序仓库
  /// [sortType] 排序类型
  CharacterRankPageController({
    required CharacterRankRepository repository,
    required this.sortType,
  })  : _repository = repository,
        super(pageSize: CharacterRankRepository.pageSize);

  final CharacterRankRepository _repository;

  /// 排序类型
  final CharacterRankSortType sortType;

  /// 请求角色排序分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页请求条目数量
  @override
  Future<TinygrailPage<CharacterRankEntry>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchRankPage(
      sortType: sortType,
      page: page,
    );
  }

  /// 转换角色排序分页条目
  ///
  /// [items] 接口返回原始条目
  @override
  List<CharacterRankEntry> convertPageItems(List<CharacterRankEntry> items) {
    return items;
  }
}

/// 所有角色全量列表控制器
class AllCharacterFullListPageController
    extends CharacterFullListPageController<CharacterRankEntry> {
  /// 创建所有角色全量列表控制器
  ///
  /// [repository] 角色排序仓库
  /// [waitForScrollIdle] 等待列表拖动和惯性滚动结束
  /// [onBeforeFullItemsReplaced] 全量数据替换前回调
  /// [onDataRefreshSucceeded] 全量数据刷新成功回调
  /// [onDataRefreshFailed] 全量数据刷新失败回调
  AllCharacterFullListPageController({
    required CharacterRankRepository repository,
    required super.waitForScrollIdle,
    super.onBeforeFullItemsReplaced,
    super.onDataRefreshSucceeded,
    super.onDataRefreshFailed,
  })  : _repository = repository,
        super(
          pageSize: CharacterRankRepository.pageSize,
          availableSorts: const <CharacterFullListSort>[
            CharacterFullListSort.fluctuation,
            CharacterFullListSort.dividend,
            CharacterFullListSort.level,
            CharacterFullListSort.towerRank,
            CharacterFullListSort.stars,
            CharacterFullListSort.currentPrice,
            CharacterFullListSort.marketValue,
          ],
          initialSort: CharacterFullListSort.fluctuation,
        );

  final CharacterRankRepository _repository;

  /// 请求最大涨幅普通分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页角色数量
  @override
  Future<TinygrailPage<CharacterRankEntry>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchRankPage(
      sortType: CharacterRankSortType.maxRise,
      page: page,
    );
  }

  /// 请求最大涨幅接口完整角色数据
  @override
  Future<List<CharacterRankEntry>> requestFullItems() {
    return _repository.fetchRankCharacters(
      sortType: CharacterRankSortType.maxRise,
      page: 1,
      pageSize: characterFullListRequestPageSize,
    );
  }

  /// 读取排序角色 ID
  ///
  /// [item] 排序角色条目
  @override
  int characterIdOf(CharacterRankEntry item) => item.characterId;

  /// 读取排序角色名称
  ///
  /// [item] 排序角色条目
  @override
  String characterNameOf(CharacterRankEntry item) => item.name;

  /// 读取排序角色等级
  ///
  /// [item] 排序角色条目
  @override
  int characterLevelOf(CharacterRankEntry item) => item.level;

  /// 读取所有角色排序数值
  ///
  /// [item] 排序角色条目
  /// [sort] 排序字段
  @override
  num sortValueOf(CharacterRankEntry item, CharacterFullListSort sort) {
    return switch (sort) {
      CharacterFullListSort.level => item.level,
      CharacterFullListSort.dividend => item.singleDividend,
      CharacterFullListSort.towerRank => item.rank,
      CharacterFullListSort.stars => item.stars,
      CharacterFullListSort.currentPrice => item.current,
      CharacterFullListSort.marketValue => item.marketValue,
      CharacterFullListSort.fluctuation => item.fluctuation,
      _ => 0,
    };
  }
}
