import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/user/model/user_auction_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 用户拍卖二级页面控制器
class UserAuctionPageController extends TinygrailPagedListController<
    UserAuctionApiItem, UserAuctionApiItem> {
  /// 创建用户拍卖二级页面控制器
  ///
  /// [repository] 用户仓库
  /// [pageSize] 每页拍卖数量
  UserAuctionPageController({
    required UserRepository repository,
    super.pageSize = defaultPageSize,
  }) : _repository = repository;

  /// 用户拍卖默认分页数量
  static const int defaultPageSize = 50;

  final UserRepository _repository;

  /// 请求用户拍卖分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页拍卖数量
  @override
  Future<TinygrailPage<UserAuctionApiItem>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchUserAuctionPage(
      page: page,
      pageSize: pageSize,
    );
  }

  /// 转换用户拍卖展示条目
  ///
  /// [items] 接口返回拍卖条目
  @override
  List<UserAuctionApiItem> convertPageItems(
    List<UserAuctionApiItem> items,
  ) {
    return items;
  }
}
