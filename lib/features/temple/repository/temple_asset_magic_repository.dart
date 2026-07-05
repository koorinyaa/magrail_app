import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/chara/model/tinygrail_character_reward_item.dart';

/// 圣殿资产魔法道具仓库
final class TempleAssetMagicRepository {
  /// 创建圣殿资产魔法道具仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  const TempleAssetMagicRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// 使用混沌魔方
  ///
  /// [consumeCharacterId] 消耗固定资产的角色 ID
  Future<TinygrailCharacterRewardItem> useChaosCube({
    required int consumeCharacterId,
  }) {
    return _submitDrawAction(
      path: 'magic/chaos/$consumeCharacterId',
      fallbackMessage: '混沌魔方使用失败',
    );
  }

  /// 使用虚空道标
  ///
  /// [consumeCharacterId] 消耗固定资产的角色 ID
  /// [targetCharacterId] 获得股份的目标角色 ID
  Future<TinygrailCharacterRewardItem> useGuidepost({
    required int consumeCharacterId,
    required int targetCharacterId,
  }) {
    return _submitDrawAction(
      path: 'magic/guidepost/$consumeCharacterId/$targetCharacterId',
      fallbackMessage: '虚空道标使用失败',
    );
  }

  /// 使用鲤鱼之眼
  ///
  /// [consumeCharacterId] 消耗固定资产的角色 ID
  /// [targetCharacterId] 从幻想乡转移的目标角色 ID
  Future<String> useFisheye({
    required int consumeCharacterId,
    required int targetCharacterId,
  }) {
    return _submitStringAction(
      path: 'magic/fisheye/$consumeCharacterId/$targetCharacterId',
      fallbackMessage: '鲤鱼之眼使用失败',
      successMessage: '鲤鱼之眼使用成功',
    );
  }

  /// 使用星光碎片
  ///
  /// [consumeCharacterId] 消耗活股的角色 ID
  /// [targetCharacterId] 补填或降塔的目标角色 ID
  /// [amount] 消耗数量
  /// [isDownSacrifices] 是否降低固定资产上限
  Future<String> useStardust({
    required int consumeCharacterId,
    required int targetCharacterId,
    required int amount,
    bool isDownSacrifices = false,
  }) {
    final actionPath = isDownSacrifices ? 'magic/stardust2' : 'magic/stardust';
    return _submitStringAction(
      path: '$actionPath/$consumeCharacterId/$targetCharacterId/$amount/false',
      fallbackMessage: '星光碎片使用失败',
      successMessage: '星光碎片使用成功',
    );
  }

  /// 使用闪光结晶
  ///
  /// [consumeCharacterId] 发起攻击的圣殿角色 ID
  /// [targetCharacterId] 被攻击的目标角色 ID
  Future<String> useStarbreak({
    required int consumeCharacterId,
    required int targetCharacterId,
  }) {
    return _submitStringAction(
      path: 'magic/starbreak/$consumeCharacterId/$targetCharacterId',
      fallbackMessage: '闪光结晶使用失败',
      successMessage: '闪光结晶使用成功',
    );
  }

  /// 转换圣殿星之力
  ///
  /// [characterId] 角色 ID
  /// [amount] 转换数量
  Future<String> convertStarForces({
    required int characterId,
    required int amount,
  }) {
    return _submitStringAction(
      path: 'chara/star/$characterId/$amount',
      fallbackMessage: '星之力转换失败',
      successMessage: '星之力转换成功',
    );
  }

  /// 精炼圣殿角色
  ///
  /// [characterId] 角色 ID
  Future<String> refineTemple({
    required int characterId,
  }) {
    return _submitStringAction(
      path: 'magic/refine/$characterId',
      fallbackMessage: '精炼失败',
      successMessage: '精炼成功',
    );
  }

  /// 提交抽取类魔法道具
  ///
  /// [path] API 路径
  /// [fallbackMessage] 接口失败兜底文案
  Future<TinygrailCharacterRewardItem> _submitDrawAction({
    required String path,
    required String fallbackMessage,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(path);
    final response = TinygrailResponse<TinygrailCharacterRewardItem>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }

        return TinygrailCharacterRewardItem.fromJson(valueJson);
      },
    );

    final result = response.value;
    if (!response.isSuccess || result == null) {
      throw StateError(response.message ?? fallbackMessage);
    }

    return result;
  }

  /// 提交返回文本的圣殿资产魔法道具操作
  ///
  /// [path] API 路径
  /// [fallbackMessage] 接口失败兜底文案
  /// [successMessage] 接口成功兜底文案
  Future<String> _submitStringAction({
    required String path,
    required String fallbackMessage,
    required String successMessage,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(path);
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? fallbackMessage);
    }

    return response.value ?? response.message ?? successMessage;
  }
}
