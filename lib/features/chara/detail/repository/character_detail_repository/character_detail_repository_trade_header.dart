part of '../character_detail_repository.dart';

/// 角色详情交易头部查询
extension CharacterDetailRepositoryTradeHeaderQueries
    on CharacterDetailRepository {
  /// 获取英灵殿角色持股数据
  ///
  /// [characterId] 角色 ID
  Future<CharacterDetailUserCharacter?> fetchValhallaCharacter(
    int characterId,
  ) async {
    return fetchUserCharacterHolding(characterId, 'tinygrail');
  }

  /// 获取幻想乡角色持股数量
  ///
  /// [characterId] 角色 ID
  Future<int?> fetchGensokyoAmount(int characterId) async {
    final holding = await fetchUserCharacterHolding(characterId, 'blueleaf');
    return holding?.amount;
  }

  /// 获取指定用户在角色上的持股数据
  ///
  /// [characterId] 角色 ID
  /// [username] Tinygrail 用户名
  /// [cancelToken] 取消本次持股请求
  /// [requireTotal] 是否严格校验总持股并向调用方传递异常
  Future<CharacterDetailUserCharacter?> fetchUserCharacterHolding(
    int characterId,
    String username, {
    CancelToken? cancelToken,
    bool requireTotal = false,
  }) async {
    try {
      final json = await _apiClient.getJson<Map<String, Object?>>(
        'chara/user/$characterId/${Uri.encodeComponent(username)}/false',
        cancelToken: cancelToken,
      );
      final response = TinygrailResponse<CharacterDetailUserCharacter>.fromJson(
        json,
        (value) {
          final valueJson = TinygrailResponseParser.asObjectMap(value);
          if (valueJson == null) {
            return null;
          }

          final total = valueJson['Total'];
          if (requireTotal &&
              (total is! num ||
                  !total.isFinite ||
                  total < 0 ||
                  total != total.roundToDouble())) {
            throw StateError('用户持股数据不完整');
          }

          return CharacterDetailUserCharacter.fromJson(valueJson);
        },
      );

      if (!response.isSuccess) {
        if (requireTotal) {
          throw StateError(response.message ?? '获取用户持股失败');
        }
        return null;
      }

      return response.value;
    } catch (_) {
      if (requireTotal) rethrow;
      return null;
    }
  }

  /// 获取角色奖池数量
  ///
  /// [characterId] 角色 ID
  /// [cancelToken] 取消本次奖池请求
  /// [requireValue] 是否严格校验奖池数量并向调用方传递异常
  Future<int?> fetchCharacterPoolAmount(
    int characterId, {
    CancelToken? cancelToken,
    bool requireValue = false,
  }) async {
    try {
      final json = await _apiClient.getJson<Map<String, Object?>>(
        'chara/pool/$characterId',
        cancelToken: cancelToken,
      );
      final response = TinygrailResponse<int>.fromJson(json, (value) {
        if (requireValue &&
            (value is! num ||
                !value.isFinite ||
                value < 0 ||
                value != value.roundToDouble())) {
          throw StateError('奖池数据不完整');
        }
        return TinygrailResponseParser.asInt(value);
      });

      if (!response.isSuccess) {
        if (requireValue) {
          throw StateError(response.message ?? '获取奖池失败');
        }
        return null;
      }

      return response.value;
    } catch (_) {
      if (requireValue) rethrow;
      return null;
    }
  }
}
