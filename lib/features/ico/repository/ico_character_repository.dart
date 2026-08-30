import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/ico/model/ico_character_entry.dart';

/// ICO 角色仓库
class IcoCharacterRepository {
  /// 创建 ICO 角色仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  const IcoCharacterRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  /// ICO 即将结束接口一次性获取完整列表时使用的请求上限
  static const int fetchLimit = 999999;

  final ApiClient _apiClient;

  /// 获取即将结束的完整 ICO 角色列表
  Future<List<IcoCharacterEntry>> fetchEndingSoonCharacters() {
    return _fetchCharacters(
      endpoint: 'chara/mri',
      fallbackMessage: '获取即将结束 ICO 失败',
    );
  }

  /// 从指定榜单接口获取完整 ICO 角色列表
  ///
  /// [endpoint] 榜单接口路径
  /// [fallbackMessage] 请求失败兜底文案
  Future<List<IcoCharacterEntry>> _fetchCharacters({
    required String endpoint,
    required String fallbackMessage,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      '$endpoint/1/$fetchLimit',
    );
    final response = TinygrailResponse<List<IcoCharacterEntry>>.fromJson(
      json,
      (value) => TinygrailResponseParser.asObjectList(
        value,
        IcoCharacterEntry.fromJson,
      ),
    );

    final items = response.value;
    if (!response.isSuccess || items == null) {
      throw StateError(response.message ?? fallbackMessage);
    }

    return items;
  }
}
