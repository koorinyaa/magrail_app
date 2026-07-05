import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/ico/model/ico_character_entry.dart';

/// ICO 角色排序类型
enum IcoCharacterSortType {
  /// 即将结束
  endingSoon(
    label: '即将结束',
    endpoint: 'chara/mri',
  ),

  /// 最多资金
  maxValue(
    label: '最多资金',
    endpoint: 'chara/mvi',
  ),

  /// 最近活跃
  recentActive(
    label: '最近活跃',
    endpoint: 'chara/rai',
  );

  /// 创建 ICO 角色排序类型
  ///
  /// [label] 菜单文案
  /// [endpoint] 排序接口路径
  const IcoCharacterSortType({
    required this.label,
    required this.endpoint,
  });

  /// 菜单文案
  final String label;

  /// 排序接口路径
  final String endpoint;
}

/// ICO 角色仓库
class IcoCharacterRepository {
  /// 创建 ICO 角色仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  const IcoCharacterRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// ICO 排序接口一次性获取完整列表时使用的请求上限
  static const int fetchLimit = 999999;

  final ApiClient _apiClient;

  /// 获取指定排序下的 ICO 角色列表
  ///
  /// [sortType] 排序类型
  Future<List<IcoCharacterEntry>> fetchIcoCharacters({
    required IcoCharacterSortType sortType,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      '${sortType.endpoint}/1/$fetchLimit',
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
      throw StateError(response.message ?? '获取 ICO 角色失败');
    }

    return items;
  }
}
