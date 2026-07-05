import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/chara/tower/model/tower_api_item.dart';
import 'package:magrail_app/features/chara/tower/model/tower_log_api_item.dart';

/// 通天塔仓库
class TowerRepository {
  /// 创建通天塔仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  const TowerRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// 获取通天塔角色列表
  ///
  /// [page] 页码
  /// [pageSize] 每页条目数量
  Future<List<TowerApiItem>> fetchTowerItems({
    int page = 1,
    int pageSize = 24,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/babel/$page/$pageSize',
    );
    final response = TinygrailResponse<List<TowerApiItem>>.fromJson(
      json,
      (value) => TinygrailResponseParser.asObjectList(
        value,
        TowerApiItem.fromJson,
      ),
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '获取通天塔数据失败');
    }

    return response.value ?? const <TowerApiItem>[];
  }

  /// 获取通天塔日志分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页条目数量
  Future<TinygrailPage<TowerLogApiItem>> fetchTowerLogPage({
    int page = 1,
    int pageSize = 30,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/star/log/$page/$pageSize',
    );
    final response = TinygrailResponse<TinygrailPage<TowerLogApiItem>>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }
        return TinygrailPage.fromJson(valueJson, TowerLogApiItem.fromJson);
      },
    );

    if (!response.isSuccess || response.value == null) {
      throw StateError(response.message ?? '获取通天塔日志失败');
    }

    return response.value!;
  }
}
