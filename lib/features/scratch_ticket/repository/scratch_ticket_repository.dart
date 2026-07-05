import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/chara/model/tinygrail_character_reward_item.dart';

/// 刮刮乐仓库
class ScratchTicketRepository {
  /// 创建刮刮乐仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  const ScratchTicketRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// 获取幻想乡刮刮乐当日使用次数
  Future<int> fetchLotusScratchCount() async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'event/daily/count/10',
    );
    final response = TinygrailResponse<int>.fromJson(
      json,
      TinygrailResponseParser.asInt,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '获取幻想乡刮刮乐次数失败');
    }

    return response.value ?? 0;
  }

  /// 购买刮刮乐
  ///
  /// [isLotus] 是否购买幻想乡刮刮乐
  Future<List<TinygrailCharacterRewardItem>> scratchTicket({
    required bool isLotus,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      isLotus ? 'event/scratch/bonus2/true' : 'event/scratch/bonus2',
    );
    final response =
        TinygrailResponse<List<TinygrailCharacterRewardItem>>.fromJson(
      json,
      (value) {
        return TinygrailResponseParser.asObjectList(
          value,
          TinygrailCharacterRewardItem.fromJson,
        );
      },
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '刮刮乐施法失败');
    }

    return response.value ?? const <TinygrailCharacterRewardItem>[];
  }
}
