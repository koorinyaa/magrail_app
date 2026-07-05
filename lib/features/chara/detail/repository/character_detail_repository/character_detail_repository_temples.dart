part of '../character_detail_repository.dart';

extension CharacterDetailRepositoryTempleQueries on CharacterDetailRepository {
  /// 获取角色 LINK 圣殿列表
  ///
  /// [characterId] 角色 ID
  Future<List<CharacterDetailTempleItem>> fetchCharacterLinks(
    int characterId,
  ) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/links/$characterId',
    );
    final response =
        TinygrailResponse<List<CharacterDetailTempleItem>>.fromJson(
      json,
      (value) {
        return TinygrailResponseParser.asObjectList(
          value,
          CharacterDetailTempleItem.fromJson,
        );
      },
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '获取连接失败');
    }

    return response.value ?? const <CharacterDetailTempleItem>[];
  }

  /// 获取角色固定资产圣殿列表
  ///
  /// [characterId] 角色 ID
  Future<List<CharacterDetailTempleItem>> fetchCharacterTemples(
    int characterId,
  ) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/temple/$characterId',
    );
    final response =
        TinygrailResponse<List<CharacterDetailTempleItem>>.fromJson(
      json,
      (value) {
        return TinygrailResponseParser.asObjectList(
          value,
          CharacterDetailTempleItem.fromJson,
        );
      },
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '获取圣殿失败');
    }

    return response.value ?? const <CharacterDetailTempleItem>[];
  }
}
