import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/features/user/model/user_ico_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 用户 ICO 二级页面控制器
class UserIcoPageController
    extends TinygrailPagedListController<UserIcoApiItem, UserIcoApiItem> {
  /// 创建用户 ICO 二级页面控制器
  ///
  /// [repository] 用户仓库
  /// [username] 用户名
  /// [pageSize] 每页 ICO 数量
  UserIcoPageController({
    required UserRepository repository,
    required String username,
    super.pageSize = defaultPageSize,
  })  : _repository = repository,
        _username = username;

  /// 用户 ICO 二级页面默认分页数量
  static const int defaultPageSize = 24;

  final UserRepository _repository;
  final String _username;

  /// 校验用户 ICO 分页请求
  @override
  Object? validatePageRequest() {
    if (_username.isEmpty) {
      return StateError('用户名不能为空');
    }

    return null;
  }

  /// 请求用户 ICO 分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页 ICO 数量
  @override
  Future<TinygrailPage<UserIcoApiItem>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchUserIcoPage(
      username: _username,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 转换用户 ICO 展示条目
  ///
  /// [items] 接口返回 ICO 条目
  @override
  List<UserIcoApiItem> convertPageItems(List<UserIcoApiItem> items) {
    return items;
  }
}
