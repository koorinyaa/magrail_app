import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/user/model/user_balance_log_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 用户资金日志二级页面控制器
class UserBalanceLogPageController extends TinygrailPagedListController<
    UserBalanceLogApiItem, UserBalanceLogApiItem> {
  /// 创建用户资金日志二级页面控制器
  ///
  /// [repository] 用户仓库
  /// [pageSize] 每页日志数量
  UserBalanceLogPageController({
    required UserRepository repository,
    super.pageSize = defaultPageSize,
  }) : _repository = repository;

  /// 用户资金日志默认分页数量
  static const int defaultPageSize = 50;

  final UserRepository _repository;

  /// 请求用户资金日志分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页日志数量
  @override
  Future<TinygrailPage<UserBalanceLogApiItem>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchUserBalanceLogPage(
      page: page,
      pageSize: pageSize,
    );
  }

  /// 转换用户资金日志展示条目
  ///
  /// [items] 接口返回日志条目
  @override
  List<UserBalanceLogApiItem> convertPageItems(
    List<UserBalanceLogApiItem> items,
  ) {
    return items;
  }
}
