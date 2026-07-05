import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/chara/auction/model/auction_api_item.dart';
import 'package:magrail_app/features/chara/auction/model/auction_history_api_item.dart';

/// 拍卖仓库
class AuctionRepository {
  /// 创建拍卖仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  const AuctionRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// 获取角色当前拍卖列表
  ///
  /// [characterIds] 角色 ID 列表
  Future<List<AuctionApiItem>> fetchAuctionList(
    List<int> characterIds,
  ) async {
    if (characterIds.isEmpty) {
      return const <AuctionApiItem>[];
    }

    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/auction/list',
      data: characterIds,
    );
    final response = TinygrailResponse<List<AuctionApiItem>>.fromJson(
      json,
      (value) {
        return TinygrailResponseParser.asObjectList(
          value,
          AuctionApiItem.fromJson,
        );
      },
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '获取拍卖列表失败');
    }

    return response.value ?? const <AuctionApiItem>[];
  }

  /// 获取角色当前拍卖映射
  ///
  /// [characterIds] 角色 ID 列表
  Future<Map<int, AuctionApiItem>> fetchAuctionMap(
    List<int> characterIds,
  ) async {
    final auctions = await fetchAuctionList(characterIds);
    return {
      for (final auction in auctions) auction.characterId: auction,
    };
  }

  /// 获取单个角色当前拍卖
  ///
  /// [characterId] 角色 ID
  Future<AuctionApiItem?> fetchAuctionDetail(int characterId) async {
    final auctions = await fetchAuctionList([characterId]);
    return auctions.isEmpty ? null : auctions.first;
  }

  /// 获取角色往期拍卖列表
  ///
  /// [characterId] 角色 ID
  /// [page] 页码
  Future<List<AuctionHistoryApiItem>> fetchAuctionHistory({
    required int characterId,
    required int page,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/auction/list/$characterId/$page',
    );
    final response = TinygrailResponse<List<AuctionHistoryApiItem>>.fromJson(
      json,
      (value) {
        return TinygrailResponseParser.asObjectList(
          value,
          AuctionHistoryApiItem.fromJson,
        );
      },
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '获取往期拍卖失败');
    }

    return response.value ?? const <AuctionHistoryApiItem>[];
  }

  /// 提交角色竞拍
  ///
  /// [characterId] 角色 ID
  /// [price] 出价价格
  /// [amount] 出价数量
  Future<String> bidAuction({
    required int characterId,
    required double price,
    required int amount,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/auction/$characterId/$price/$amount',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '竞拍失败');
    }

    return response.value ?? response.message ?? '竞拍成功';
  }

  /// 取消当前用户拍卖
  ///
  /// [auctionId] 拍卖记录 ID
  Future<String> cancelAuction(int auctionId) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/auction/cancel/$auctionId',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '撤销竞拍失败');
    }

    return response.value ?? response.message ?? '撤销竞拍成功';
  }
}
