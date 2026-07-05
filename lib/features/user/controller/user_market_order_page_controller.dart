import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/user/model/user_market_order_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 用户委托订单二级页面控制器
class UserMarketOrderPageController extends TinygrailPagedListController<
    UserMarketOrderApiItem, UserMarketOrderApiItem> {
  /// 创建用户委托订单二级页面控制器
  ///
  /// [repository] 用户仓库
  /// [side] 委托订单方向
  /// [pageSize] 每页订单数量
  UserMarketOrderPageController({
    required UserRepository repository,
    required UserMarketOrderSide side,
    super.pageSize = defaultPageSize,
  })  : _repository = repository,
        _side = side;

  /// 用户委托订单默认分页数量
  static const int defaultPageSize = 50;

  final UserRepository _repository;
  final UserMarketOrderSide _side;

  /// 请求用户委托订单分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页订单数量
  @override
  Future<TinygrailPage<UserMarketOrderApiItem>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return switch (_side) {
      UserMarketOrderSide.bid => _repository.fetchUserBidPage(
          page: page,
          pageSize: pageSize,
        ),
      UserMarketOrderSide.ask => _repository.fetchUserAskPage(
          page: page,
          pageSize: pageSize,
        ),
    };
  }

  /// 转换用户委托订单展示条目
  ///
  /// [items] 接口返回订单条目
  @override
  List<UserMarketOrderApiItem> convertPageItems(
    List<UserMarketOrderApiItem> items,
  ) {
    return items;
  }
}
