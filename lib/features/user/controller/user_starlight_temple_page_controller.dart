import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/features/user/assets/repository/user_asset_snapshot_repository.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

/// 用户星光圣殿二级页面控制器
class UserStarlightTemplePageController extends TinygrailPagedListController<
    UserTempleApiItem, UserTempleApiItem> {
  /// 创建用户星光圣殿二级页面控制器
  ///
  /// [snapshotRepository] 用户资产快照仓库
  /// [username] 用户名
  /// [pageSize] 每页圣殿数量
  UserStarlightTemplePageController({
    required UserAssetSnapshotRepository snapshotRepository,
    required String username,
    super.pageSize = defaultPageSize,
  })  : _snapshotRepository = snapshotRepository,
        _username = username.trim();

  /// 用户星光圣殿默认分页数量
  static const int defaultPageSize = 100;

  final UserAssetSnapshotRepository _snapshotRepository;
  final String _username;

  /// 校验星光圣殿分页请求
  @override
  Object? validatePageRequest() {
    if (_username.isEmpty) {
      return StateError('用户名不能为空');
    }
    return null;
  }

  /// 读取星光圣殿本地分页
  ///
  /// [page] 页码
  /// [pageSize] 每页圣殿数量
  @override
  Future<TinygrailPage<UserTempleApiItem>> requestPage({
    required int page,
    required int pageSize,
  }) {
    return _snapshotRepository.readStarlightTemplePage(
      username: _username,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 转换星光圣殿展示条目
  ///
  /// [items] 本地快照圣殿条目
  @override
  List<UserTempleApiItem> convertPageItems(List<UserTempleApiItem> items) {
    return items;
  }
}
