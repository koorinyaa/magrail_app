import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/ranking/model/ranking_entry.dart';

/// 排行榜仓库
class RankingRepository {
  /// 创建排行榜仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  const RankingRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// 获取精炼排行分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页条目数量
  Future<TinygrailPage<TempleRefineRankingEntry>> fetchRefineRankingPage({
    int page = 1,
    int pageSize = 20,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/refine/temple/$page/$pageSize',
    );
    final response =
        TinygrailResponse<TinygrailPage<TempleRefineRankingEntry>>.fromJson(
      json,
      (value) => _parseRefinePage(value, fallbackPage: page),
    );

    final pageData = response.value;
    if (!response.isSuccess || pageData == null) {
      throw StateError(response.message ?? '获取精炼排行失败');
    }

    return pageData;
  }

  /// 获取番市首富排行分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页条目数量
  Future<TinygrailPage<UserWealthRankingEntry>> fetchWealthRankingPage({
    int page = 1,
    int pageSize = 20,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/top/$page/$pageSize',
    );
    final response = TinygrailResponse<List<UserWealthRankingEntry>>.fromJson(
      json,
      (value) => _parseWealthItems(value, page: page, pageSize: pageSize),
    );

    final items = response.value;
    if (!response.isSuccess || items == null) {
      throw StateError(response.message ?? '获取番市首富失败');
    }

    return TinygrailPage<UserWealthRankingEntry>(
      items: items,
      currentPage: page,
      totalPages: RankingRepository.wealthRankingMaxPage,
      totalItems: RankingRepository.wealthRankingMaxPage * pageSize,
      itemsPerPage: pageSize,
    );
  }

  /// 番市首富最大页数
  static const int wealthRankingMaxPage = 5;

  /// 解析精炼排行分页
  ///
  /// [value] 响应 Value 字段
  /// [fallbackPage] 请求页码
  TinygrailPage<TempleRefineRankingEntry>? _parseRefinePage(
    Object? value, {
    required int fallbackPage,
  }) {
    final valueJson = TinygrailResponseParser.asObjectMap(value);
    if (valueJson == null) {
      return null;
    }

    final currentPage = TinygrailResponseParser.asInt(valueJson['CurrentPage']);
    final resolvedPage = currentPage > 0 ? currentPage : fallbackPage;
    final itemsPerPage =
        TinygrailResponseParser.asInt(valueJson['ItemsPerPage']);
    final resolvedPageSize = itemsPerPage > 0 ? itemsPerPage : 20;
    return TinygrailPage<TempleRefineRankingEntry>(
      items: _withRankingIndexes(
            valueJson['Items'],
            (itemJson) => TempleRefineRankingEntry.fromJson(
              itemJson.json,
              rank: (resolvedPage - 1) * resolvedPageSize + itemJson.index + 1,
            ),
          ) ??
          const [],
      currentPage: resolvedPage,
      totalPages: TinygrailResponseParser.asInt(valueJson['TotalPages']),
      totalItems: TinygrailResponseParser.asInt(valueJson['TotalItems']),
      itemsPerPage: resolvedPageSize,
    );
  }

  /// 解析番市首富条目
  ///
  /// [value] 响应 Value 字段
  /// [page] 页码
  /// [pageSize] 每页条目数量
  List<UserWealthRankingEntry>? _parseWealthItems(
    Object? value, {
    required int page,
    required int pageSize,
  }) {
    return _withRankingIndexes(
      value,
      (itemJson) => UserWealthRankingEntry.fromJson(
        itemJson.json,
        rank: (page - 1) * pageSize + itemJson.index + 1,
      ),
    );
  }

  /// 解析带索引的对象数组
  ///
  /// [value] 原始数组
  /// [fromJson] 条目转换函数
  List<T>? _withRankingIndexes<T>(
    Object? value,
    T Function(_IndexedJson itemJson) fromJson,
  ) {
    if (value is! List) {
      return null;
    }

    final items = <T>[];
    for (var index = 0; index < value.length; index += 1) {
      final item = value[index];
      if (item is! Map<Object?, Object?>) {
        continue;
      }

      items.add(
        fromJson(
          _IndexedJson(
            index: index,
            json: item.map(
              (key, itemValue) => MapEntry(key.toString(), itemValue),
            ),
          ),
        ),
      );
    }

    return items;
  }
}

/// 带原始索引的 JSON 条目
final class _IndexedJson {
  /// 创建带原始索引的 JSON 条目
  ///
  /// [index] 原始数组索引
  /// [json] 原始条目 JSON
  const _IndexedJson({
    required this.index,
    required this.json,
  });

  /// 原始数组索引
  final int index;

  /// 原始条目 JSON
  final Map<String, Object?> json;
}
