import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/ico/model/st_character_entry.dart';

/// ST 角色仓库
class StCharacterRepository {
  /// 创建 ST 角色仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  const StCharacterRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// ST 角色每页数量
  static const int pageSize = 24;

  final ApiClient _apiClient;

  /// 获取 ST 角色分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<TinygrailPage<StCharacterEntry>> fetchStCharacters({
    int page = 1,
    int pageSize = StCharacterRepository.pageSize,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/delist/chara/$page/$pageSize',
    );
    final response =
        TinygrailResponse<TinygrailPage<StCharacterEntry>>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }

        return TinygrailPage.fromJson(valueJson, StCharacterEntry.fromJson);
      },
    );

    final pageData = response.value;
    if (!response.isSuccess || pageData == null) {
      throw StateError(response.message ?? '获取 ST 角色失败');
    }

    return pageData;
  }
}
