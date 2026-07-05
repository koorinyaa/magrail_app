import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/user/model/user_red_packet_log_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 用户红包记录二级页面控制器
class UserRedPacketLogPageController extends TinygrailPagedListController<
    UserRedPacketLogApiItem, UserRedPacketLogApiItem> {
  /// 创建用户红包记录二级页面控制器
  ///
  /// [repository] 用户仓库
  /// [username] 用户名
  /// [pageSize] 每页记录数量
  UserRedPacketLogPageController({
    required UserRepository repository,
    required String username,
    super.pageSize = defaultPageSize,
  })  : _repository = repository,
        _username = username;

  /// 用户红包记录默认分页数量
  static const int defaultPageSize = 20;

  final UserRepository _repository;
  final String _username;

  /// 校验红包记录分页请求边界
  @override
  Object? validatePageRequest() {
    if (_username.trim().isEmpty) {
      return StateError('缺少用户名');
    }

    return null;
  }

  /// 请求用户红包记录分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页记录数量
  @override
  Future<TinygrailPage<UserRedPacketLogApiItem>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchUserRedPacketLogPage(
      username: _username,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 转换用户红包记录展示条目
  ///
  /// [items] 接口返回记录条目
  @override
  List<UserRedPacketLogApiItem> convertPageItems(
    List<UserRedPacketLogApiItem> items,
  ) {
    return items;
  }
}
