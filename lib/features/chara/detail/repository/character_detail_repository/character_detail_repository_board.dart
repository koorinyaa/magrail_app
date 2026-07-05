part of '../character_detail_repository.dart';

extension CharacterDetailRepositoryBoardQueries on CharacterDetailRepository {
  /// 获取角色董事会分页数据
  ///
  /// [characterId] 角色 ID
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<TinygrailPage<CharacterDetailBoardMember>>
      fetchCharacterBoardMemberPage({
    required int characterId,
    required int page,
    required int pageSize,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/users/$characterId/$page/$pageSize',
    );
    final response =
        TinygrailResponse<TinygrailPage<CharacterDetailBoardMember>>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }

        return TinygrailPage<CharacterDetailBoardMember>.fromJson(
          valueJson,
          CharacterDetailBoardMember.fromJson,
        );
      },
    );

    final pageData = response.value;
    if (!response.isSuccess || pageData == null) {
      throw StateError(response.message ?? '获取董事会失败');
    }

    return pageData;
  }

  /// 获取角色前十持股用户
  ///
  /// [characterId] 角色 ID
  Future<List<CharacterDetailBoardMember>> fetchCharacterBoardMembers(
    int characterId,
  ) async {
    try {
      final page = await fetchCharacterBoardMemberPage(
        characterId: characterId,
        page: 1,
        pageSize: 10,
      );
      return page.items;
    } catch (_) {
      return const <CharacterDetailBoardMember>[];
    }
  }

  /// 获取角色删除投票记录
  ///
  /// [characterId] 角色 ID
  Future<List<CharacterDetailKillVote>> fetchKillVotes(int characterId) async {
    try {
      final json = await _apiClient.getJson<Map<String, Object?>>(
        'chara/kill/votes/$characterId',
      );
      final response =
          TinygrailResponse<List<CharacterDetailKillVote>>.fromJson(
        json,
        (value) {
          return TinygrailResponseParser.asObjectList(
            value,
            CharacterDetailKillVote.fromJson,
          );
        },
      );

      if (!response.isSuccess) {
        return const <CharacterDetailKillVote>[];
      }

      return response.value ?? const <CharacterDetailKillVote>[];
    } catch (_) {
      return const <CharacterDetailKillVote>[];
    }
  }

  /// 投票删除角色
  ///
  /// [characterId] 角色 ID
  /// [reason] 删除理由
  Future<String> voteKillCharacter({
    required int characterId,
    required String reason,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/kill/vote/$characterId',
      data: reason,
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '投票删除失败');
    }

    return response.value ?? response.message ?? '投票删除成功';
  }

  /// 撤回角色删除投票
  ///
  /// [characterId] 角色 ID
  Future<String> revokeKillVote(int characterId) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/kill/vote/$characterId/revoke',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '撤回投票失败');
    }

    return response.value ?? response.message ?? '撤回投票成功';
  }
}
