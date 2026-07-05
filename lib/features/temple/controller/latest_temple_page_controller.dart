import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/temple/model/temple_api_item.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';

/// 最新圣殿二级页面控制器
class LatestTemplePageController
    extends TinygrailPagedListController<TempleApiItem, TempleApiItem> {
  /// 创建最新圣殿二级页面控制器
  ///
  /// [repository] 圣殿仓库
  /// [pageSize] 每页圣殿数量
  LatestTemplePageController({
    required TempleRepository repository,
    super.pageSize = defaultPageSize,
  }) : _repository = repository;

  /// 最新圣殿二级页面默认分页数量
  static const int defaultPageSize = 24;

  final TempleRepository _repository;

  /// 请求最新圣殿分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页圣殿数量
  @override
  Future<TinygrailPage<TempleApiItem>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchLatestTemplePage(
      page: page,
      pageSize: pageSize,
    );
  }

  /// 转换最新圣殿展示条目
  ///
  /// [items] 接口返回圣殿条目
  @override
  List<TempleApiItem> convertPageItems(List<TempleApiItem> items) {
    return items;
  }
}
