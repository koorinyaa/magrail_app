import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/features/user/model/user_link_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 用户连接二级页面控制器
class UserLinkPageController
    extends TinygrailPagedListController<UserLinkApiItem, UserLinkApiItem> {
  /// 创建用户连接二级页面控制器
  ///
  /// [repository] 用户仓库
  /// [username] 用户名
  /// [pageSize] 每页连接数量
  UserLinkPageController({
    required UserRepository repository,
    required String username,
    super.pageSize = defaultPageSize,
    super.emptyPageScanLimit = 3,
  })  : _repository = repository,
        _username = username;

  /// 用户连接二级页面默认分页数量
  static const int defaultPageSize = 12;

  final UserRepository _repository;
  final String _username;

  /// 校验用户连接分页请求
  @override
  Object? validatePageRequest() {
    if (_username.isEmpty) {
      return StateError('用户名不能为空');
    }

    return null;
  }

  /// 请求用户连接分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页连接数量
  @override
  Future<TinygrailPage<UserLinkApiItem>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchUserLinkPage(
      username: _username,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 过滤可展示的用户连接
  ///
  /// [items] 接口返回条目
  @override
  List<UserLinkApiItem> convertPageItems(List<UserLinkApiItem> items) {
    return items
        .where((UserLinkApiItem item) => item.hasLink)
        .toList(growable: false);
  }
}
