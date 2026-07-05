import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/chara/rank/model/character_rank_entry.dart';

/// 角色排序类型
enum CharacterRankSortType {
  /// 最高股息
  highestRate(
    label: '最高股息',
    endpoint: 'chara/msrc',
  ),

  /// 最高市值
  highestMarketValue(
    label: '最高市值',
    endpoint: 'chara/mvc',
  ),

  /// 最大涨幅
  maxRise(
    label: '最大涨幅',
    endpoint: 'chara/mrc',
  ),

  /// 最大跌幅
  maxFall(
    label: '最大跌幅',
    endpoint: 'chara/mfc',
  );

  /// 创建角色排序类型
  ///
  /// [label] 切换按钮文案
  /// [endpoint] 榜单接口路径
  const CharacterRankSortType({
    required this.label,
    required this.endpoint,
  });

  /// 切换按钮文案
  final String label;

  /// 榜单接口路径
  final String endpoint;
}

/// 角色排序仓库
class CharacterRankRepository {
  /// 创建角色排序仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  const CharacterRankRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// 角色排序每页数量
  static const int pageSize = 20;

  /// 角色排序最大页数
  static const int maxPage = 5;

  final ApiClient _apiClient;

  /// 获取角色排序分页数据
  ///
  /// [sortType] 排序类型
  /// [page] 页码
  Future<TinygrailPage<CharacterRankEntry>> fetchRankPage({
    required CharacterRankSortType sortType,
    int page = 1,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      '${sortType.endpoint}/$page/$pageSize',
    );
    final response = TinygrailResponse<List<CharacterRankEntry>>.fromJson(
      json,
      (value) => TinygrailResponseParser.asObjectList(
        value,
        CharacterRankEntry.fromJson,
      ),
    );

    final items = response.value;
    if (!response.isSuccess || items == null) {
      throw StateError(response.message ?? '获取角色排序失败');
    }

    return TinygrailPage<CharacterRankEntry>(
      items: items,
      currentPage: page,
      totalPages: maxPage,
      totalItems: maxPage * pageSize,
      itemsPerPage: pageSize,
    );
  }
}
