import 'package:flutter/material.dart';
import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/features/chara/top_week/model/top_week_api_item.dart';
import 'package:magrail_app/features/chara/top_week/model/top_week_entry.dart';
import 'package:magrail_app/features/chara/top_week/model/top_week_history_api_item.dart';

/// 每周萌王仓库
class TopWeekRepository {
  /// 创建每周萌王仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  const TopWeekRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// 获取每周萌王条目
  Future<List<TopWeekEntry>> fetchTopWeekEntries() async {
    final json =
        await _apiClient.getJson<Map<String, Object?>>('chara/topweek');
    final response = TinygrailResponse<List<TopWeekApiItem>>.fromJson(
      json,
      (value) => TinygrailResponseParser.asObjectList(
        value,
        TopWeekApiItem.fromJson,
      ),
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '获取每周萌王失败');
    }

    final items = response.value;
    if (items == null || items.isEmpty) {
      return const <TopWeekEntry>[];
    }

    final scoreBase = _resolveScoreBase(items);

    return items.asMap().entries.map((entry) {
      final rank = entry.key + 1;
      return _mapItemToEntry(entry.value, rank, scoreBase);
    }).toList(growable: false);
  }

  /// 获取往期萌王分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页条目数
  Future<TinygrailPage<TopWeekHistoryApiItem>> fetchTopWeekHistory({
    int page = 1,
    int pageSize = 12,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/topweek/history/$page/$pageSize',
    );
    final response =
        TinygrailResponse<TinygrailPage<TopWeekHistoryApiItem>>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }
        return TinygrailPage.fromJson(
            valueJson, TopWeekHistoryApiItem.fromJson);
      },
    );

    if (!response.isSuccess || response.value == null) {
      throw StateError(response.message ?? '获取往期萌王失败');
    }

    return response.value!;
  }

  /// 映射接口条目到首页条目
  ///
  /// [item] 接口条目
  /// [rank] 当前排名
  /// [scoreBase] 当前榜单评分基准
  TopWeekEntry _mapItemToEntry(
    TopWeekApiItem item,
    int rank,
    double scoreBase,
  ) {
    final averagePrice = item.assets <= 0
        ? 0
        : (item.extra + item.price * item.sacrifices) / item.assets;
    final score = (item.extra + item.type * scoreBase) / 100;

    return TopWeekEntry(
      rank: rank,
      characterId: item.characterId,
      name: item.characterName,
      level: item.characterLevel,
      coverUrl: TinygrailAssetUrls.getLargeCover(item.cover),
      avatarUrl: TinygrailAssetUrls.normalizeAvatar(item.avatar),
      surplus: _formatSurplus(item.extra),
      score: Formatters.groupedNumber(score.round()),
      bidders: '${item.type}',
      bidAmount: '${Formatters.groupedNumber(item.assets)}股',
      valhallaAmount: '${Formatters.groupedNumber(item.sacrifices)}股',
      averagePrice: Formatters.tinygrailCurrency(averagePrice),
      basePrice: item.price,
      maxAuctionAmount: item.sacrifices,
      rankColor: _resolveRankColor(rank),
    );
  }

  /// 解析排名颜色
  ///
  /// [rank] 当前排名
  Color _resolveRankColor(int rank) {
    return switch (rank) {
      1 => const Color(0xFFF2B72F),
      2 => const Color(0xFF6F85A6),
      3 => const Color(0xFFA7653D),
      >= 4 && <= 6 => const Color(0xFF78A86B),
      _ => const Color(0xFFA1A1AA),
    };
  }

  /// 计算当前榜单评分基准
  ///
  /// [items] 每周萌王接口条目
  double _resolveScoreBase(List<TopWeekApiItem> items) {
    var totalExtra = 0.0;
    var totalUsers = 0;

    for (final item in items) {
      totalExtra += item.extra;
      totalUsers += item.type;
    }

    if (totalUsers <= 0) {
      return 0;
    }

    return totalExtra / totalUsers;
  }

  /// 格式化超出金额
  ///
  /// [extra] 超出金额
  String _formatSurplus(double extra) {
    final truncatedExtra = extra.truncate();
    final prefix = truncatedExtra > 0 ? '+' : '';

    return '$prefix${Formatters.tinygrailCurrency(truncatedExtra)}';
  }
}
