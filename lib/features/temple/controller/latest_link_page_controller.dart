import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/temple/model/latest_link_api_item.dart';
import 'package:magrail_app/features/temple/model/latest_link_pair.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';

/// 最新连接二级页面控制器
class LatestLinkPageController
    extends TinygrailPagedListController<LatestLinkPair, LatestLinkApiItem> {
  /// 创建最新连接二级页面控制器
  ///
  /// [repository] 圣殿仓库
  /// [pairPageSize] 每页展示的有效连接组数量
  LatestLinkPageController({
    required TempleRepository repository,
    int pairPageSize = defaultPairPageSize,
  })  : assert(pairPageSize > 0),
        _repository = repository,
        super(
          pageSize: pairPageSize * 2,
          emptyPageScanLimit: 3,
        );

  /// 最新连接二级页面默认每页展示连接组数量
  static const int defaultPairPageSize = 12;

  final TempleRepository _repository;

  /// 每页展示的有效连接组数量
  int get pairPageSize => pageSize ~/ 2;

  /// 触发下一页预加载的连接组阈值
  @override
  int get itemPreloadThreshold {
    return (pairPageSize / 2).ceil();
  }

  /// 请求最新连接分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页原始角色条目数量
  @override
  Future<TinygrailPage<LatestLinkApiItem>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchLatestLinkPage(
      page: page,
      pageSize: pageSize,
    );
  }

  /// 转换可展示的最新连接组
  ///
  /// [items] 接口返回原始角色条目
  @override
  List<LatestLinkPair> convertPageItems(List<LatestLinkApiItem> items) {
    return LatestLinkPair.collectValidPairs(items);
  }
}
