import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/chara/trade_history/model/character_gm_trade_history_item.dart';
import 'package:magrail_app/features/chara/trade_history/model/character_trade_history_item.dart';

/// 角色交易记录仓库
class CharacterTradeHistoryRepository {
  /// 创建角色交易记录仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  const CharacterTradeHistoryRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  // 历史图表接口需要传入起始日期来覆盖完整查询范围
  static const String _historyStartDate = '2019-08-08';

  final ApiClient _apiClient;

  /// 获取角色交易记录
  ///
  /// [characterId] 角色 ID
  Future<List<CharacterTradeHistoryItem>> fetchCharacterTradeHistory({
    required int characterId,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/charts/$characterId/$_historyStartDate',
    );
    final response =
        TinygrailResponse<List<CharacterTradeHistoryItem>>.fromJson(
      json,
      (value) {
        return TinygrailResponseParser.asObjectList(
          value,
          CharacterTradeHistoryItem.fromJson,
        );
      },
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '获取交易记录失败');
    }

    return response.value ?? const <CharacterTradeHistoryItem>[];
  }

  /// 获取角色 GM 交易记录分页
  ///
  /// [characterId] 角色 ID
  /// [page] 页码
  /// [pageSize] 每页条目数
  Future<TinygrailPage<CharacterGmTradeHistoryItem>>
      fetchCharacterGmTradeHistory({
    required int characterId,
    required int page,
    required int pageSize,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/history/$characterId/$page/$pageSize',
    );
    final response =
        TinygrailResponse<TinygrailPage<CharacterGmTradeHistoryItem>>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }

        return TinygrailPage<CharacterGmTradeHistoryItem>.fromJson(
          valueJson,
          CharacterGmTradeHistoryItem.fromJson,
        );
      },
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '获取 GM 交易记录失败');
    }

    return response.value ??
        const TinygrailPage<CharacterGmTradeHistoryItem>(
          items: <CharacterGmTradeHistoryItem>[],
          currentPage: 1,
          totalPages: 0,
          totalItems: 0,
          itemsPerPage: 0,
        );
  }
}
