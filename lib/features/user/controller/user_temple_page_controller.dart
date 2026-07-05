import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 用户圣殿二级页面控制器
class UserTemplePageController
    extends TinygrailPagedListController<UserTempleApiItem, UserTempleApiItem> {
  /// 创建用户圣殿二级页面控制器
  ///
  /// [repository] 用户仓库
  /// [username] 用户名
  /// [pageSize] 每页圣殿数量
  UserTemplePageController({
    required UserRepository repository,
    required String username,
    super.pageSize = defaultPageSize,
  })  : _repository = repository,
        _username = username;

  /// 用户圣殿二级页面默认分页数量
  static const int defaultPageSize = 24;

  final UserRepository _repository;
  final String _username;

  /// 校验用户圣殿分页请求
  @override
  Object? validatePageRequest() {
    if (_username.isEmpty) {
      return StateError('用户名不能为空');
    }

    return null;
  }

  /// 请求用户圣殿分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页圣殿数量
  @override
  Future<TinygrailPage<UserTempleApiItem>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchUserTemplePage(
      username: _username,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 转换用户圣殿展示条目
  ///
  /// [items] 接口返回圣殿条目
  @override
  List<UserTempleApiItem> convertPageItems(List<UserTempleApiItem> items) {
    return items;
  }
}
