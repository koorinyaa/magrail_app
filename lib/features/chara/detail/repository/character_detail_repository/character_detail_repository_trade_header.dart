part of '../character_detail_repository.dart';

extension CharacterDetailRepositoryTradeHeaderQueries
    on CharacterDetailRepository {
  /// 获取全部已上市角色头部资料
  Future<List<CharacterDetailTradeHeader>>
      fetchAllListedCharacterHeaders() async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/msrc/1/$_listedCharacterFetchLimit',
    );
    final response =
        TinygrailResponse<List<CharacterDetailTradeHeader>>.fromJson(
      json,
      (value) {
        return TinygrailResponseParser.asObjectList(
          value,
          CharacterDetailTradeHeader.fromJson,
        );
      },
    );

    final characters = response.value;
    if (!response.isSuccess || characters == null) {
      throw StateError(response.message ?? '获取全部角色资料失败');
    }

    return characters;
  }

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
  Future<CharacterDetailUserCharacter?> fetchUserCharacterHolding(
    int characterId,
    String username,
  ) async {
    try {
      final json = await _apiClient.getJson<Map<String, Object?>>(
        'chara/user/$characterId/$username/false',
      );
      final response = TinygrailResponse<CharacterDetailUserCharacter>.fromJson(
        json,
        (value) {
          final valueJson = TinygrailResponseParser.asObjectMap(value);
          if (valueJson == null) {
            return null;
          }

          return CharacterDetailUserCharacter.fromJson(valueJson);
        },
      );

      if (!response.isSuccess) {
        return null;
      }

      return response.value;
    } catch (_) {
      return null;
    }
  }

  /// 获取角色奖池数量
  ///
  /// [characterId] 角色 ID
  Future<int?> fetchCharacterPoolAmount(int characterId) async {
    try {
      final json = await _apiClient.getJson<Map<String, Object?>>(
        'chara/pool/$characterId',
      );
      final response = TinygrailResponse<int>.fromJson(
        json,
        TinygrailResponseParser.asInt,
      );

      if (!response.isSuccess) {
        return null;
      }

      return response.value;
    } catch (_) {
      return null;
    }
  }
}

// 已上市角色接口使用足够大的页容量一次获取完整资料
const int _listedCharacterFetchLimit = 999999;
