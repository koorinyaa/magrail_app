import 'package:magrail_app/core/network/api_client.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/features/temple/model/latest_link_api_item.dart';
import 'package:magrail_app/features/temple/model/temple_api_item.dart';

/// 圣殿仓库
class TempleRepository {
  /// 创建圣殿仓库
  ///
  /// [apiClient] Tinygrail API 客户端
  const TempleRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// 获取最新圣殿分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页条目数量
  Future<TinygrailPage<TempleApiItem>> fetchLatestTemplePage({
    int page = 1,
    int pageSize = 12,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/temple/last/$page/$pageSize',
    );
    final response = TinygrailResponse<TinygrailPage<TempleApiItem>>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }
        return TinygrailPage.fromJson(valueJson, TempleApiItem.fromJson);
      },
    );

    if (!response.isSuccess || response.value == null) {
      throw StateError(response.message ?? '获取最新圣殿失败');
    }

    return response.value!;
  }

  /// 获取最新连接分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页条目数量
  Future<TinygrailPage<LatestLinkApiItem>> fetchLatestLinkPage({
    int page = 1,
    int pageSize = 48,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/link/last/$page/$pageSize',
    );
    final response =
        TinygrailResponse<TinygrailPage<LatestLinkApiItem>>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }
        return TinygrailPage.fromJson(valueJson, LatestLinkApiItem.fromJson);
      },
    );

    if (!response.isSuccess || response.value == null) {
      throw StateError(response.message ?? '获取最新连接失败');
    }

    return response.value!;
  }

  /// 修改圣殿封面地址
  ///
  /// [characterId] 圣殿角色 ID
  /// [coverUrl] 新封面 OOS 地址
  Future<String> changeTempleCover({
    required int characterId,
    required String coverUrl,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/temple/cover/$characterId',
      data: coverUrl,
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '修改封面失败');
    }

    return response.value ?? response.message ?? '更换封面成功';
  }

  /// 重置圣殿图片
  ///
  /// [characterId] 圣殿角色 ID
  /// [userId] 圣殿所属用户 ID
  Future<String> resetTempleCover({
    required int characterId,
    required int userId,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/temple/cover/reset/$characterId/$userId',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '重置圣殿图片失败');
    }

    return response.message ?? response.value ?? '重置圣殿图片成功';
  }

  /// 连接两座圣殿
  ///
  /// [sourceCharacterId] 当前圣殿角色 ID
  /// [targetCharacterId] 目标圣殿角色 ID
  Future<String> linkTemples({
    required int sourceCharacterId,
    required int targetCharacterId,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/link/$sourceCharacterId/$targetCharacterId',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '连接圣殿失败');
    }

    return response.value ?? response.message ?? '连接圣殿成功';
  }

  /// 修改圣殿台词
  ///
  /// [characterId] 圣殿角色 ID
  /// [line] 台词内容
  Future<String> changeTempleLine({
    required int characterId,
    required String line,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/temple/line/$characterId',
      data: line,
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '修改台词失败');
    }

    return response.value ?? response.message ?? '修改台词成功';
  }

  /// 拆除圣殿
  ///
  /// [characterId] 圣殿角色 ID
  Future<String> destroyTemple({
    required int characterId,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/temple/destroy/$characterId',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '拆除圣殿失败');
    }

    return response.value ?? response.message ?? '圣殿拆除成功';
  }
}
