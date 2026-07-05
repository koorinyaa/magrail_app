import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
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
