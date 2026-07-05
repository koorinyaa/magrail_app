import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/user/model/user_trade_log_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 用户交易记录二级页面控制器
class UserTradeLogPageController extends TinygrailPagedListController<
    UserTradeLogApiItem, UserTradeLogApiItem> {
  /// 创建用户交易记录二级页面控制器
  ///
  /// [repository] 用户仓库
  /// [userId] 用户 ID
  /// [pageSize] 每页记录数量
  UserTradeLogPageController({
    required UserRepository repository,
    required int userId,
    super.pageSize = defaultPageSize,
  })  : _repository = repository,
        _userId = userId;

  /// 用户交易记录默认分页数量
  static const int defaultPageSize = 48;

  final UserRepository _repository;
  final int _userId;

  /// 校验交易记录分页请求边界
  @override
  Object? validatePageRequest() {
    if (_userId <= 0) {
      return StateError('缺少用户 ID');
    }

    return null;
  }

  /// 请求用户交易记录分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页记录数量
  @override
  Future<TinygrailPage<UserTradeLogApiItem>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchUserTradeLogPage(
      userId: _userId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 转换用户交易记录展示条目
  ///
  /// [items] 接口返回记录条目
  @override
  List<UserTradeLogApiItem> convertPageItems(
    List<UserTradeLogApiItem> items,
  ) {
    return items;
  }
}
