part of '../character_detail_repository.dart';

extension CharacterDetailRepositoryBasicQueries on CharacterDetailRepository {
  /// 获取角色详情基础资料
  ///
  /// [characterId] 角色 ID
  Future<CharacterDetailBasicInfo> fetchCharacterBasicInfo(
    int characterId,
  ) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/$characterId',
    );
    final response = TinygrailResponse<CharacterDetailBasicInfo>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }
        return CharacterDetailBasicInfo.fromJson(valueJson);
      },
    );

    if (!response.isSuccess) {
      // State 不为 0 表示角色处于未上市状态
      return CharacterDetailBasicInfo(
        characterId: characterId,
        name: '',
        icon: '',
        pageType: CharacterDetailPageType.initial,
        tradeHeader: null,
        icoInfo: null,
      );
    }

    if (response.value == null) {
      throw StateError(response.message ?? '获取角色详情失败');
    }

    return response.value!;
  }

  /// 批量获取角色详情基础资料
  ///
  /// [characterIds] 角色 ID 列表
  Future<Map<int, CharacterDetailBasicInfo>> fetchCharacterBasicInfoList(
    List<int> characterIds,
  ) async {
    final resolvedIds = characterIds
        .where((characterId) => characterId > 0)
        .toSet()
        .toList(growable: false);
    if (resolvedIds.isEmpty) {
      return const <int, CharacterDetailBasicInfo>{};
    }

    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/list',
      data: resolvedIds,
    );
    final response = TinygrailResponse<List<CharacterDetailBasicInfo>>.fromJson(
      json,
      (value) {
        return TinygrailResponseParser.asObjectList(
          value,
          CharacterDetailBasicInfo.fromJson,
        );
      },
    );

    if (!response.isSuccess) {
      // State 不为 0 与详情页保持一致，按未上市缺失状态处理
      return const <int, CharacterDetailBasicInfo>{};
    }

    final items = response.value ?? const <CharacterDetailBasicInfo>[];
    return {
      for (final item in items)
        if (item.characterId > 0) item.characterId: item,
    };
  }

  /// 获取角色深度信息
  ///
  /// [characterId] 角色 ID
  Future<CharacterDetailTradeDepth> fetchCharacterTradeDepth(
    int characterId,
  ) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/depth/$characterId',
    );
    final response = TinygrailResponse<CharacterDetailTradeDepth>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }

        return CharacterDetailTradeDepth.fromJson(valueJson);
      },
    );

    final depth = response.value;
    if (!response.isSuccess || depth == null) {
      throw StateError(response.message ?? '获取深度信息失败');
    }

    return depth;
  }

  /// 获取当前用户在角色上的交易资料
  ///
  /// [characterId] 角色 ID
  Future<CharacterDetailUserTrading> fetchCurrentUserTrading(
    int characterId,
  ) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/user/$characterId',
    );
    final response = TinygrailResponse<CharacterDetailUserTrading>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }

        return CharacterDetailUserTrading.fromJson(valueJson);
      },
    );

    final trading = response.value;
    if (!response.isSuccess || trading == null) {
      throw StateError(response.message ?? '获取用户交易资料失败');
    }

    return trading;
  }

  /// 搜索 Tinygrail 角色
  ///
  /// [keyword] 搜索关键字
  /// [allowEmptyKeyword] 是否允许请求空关键字
  Future<List<CharacterDetailSearchItem>> searchCharacters(
    String keyword, {
    bool allowEmptyKeyword = false,
  }) async {
    final resolvedKeyword = keyword.trim();
    if (resolvedKeyword.isEmpty && !allowEmptyKeyword) {
      return const <CharacterDetailSearchItem>[];
    }

    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/search/character',
      queryParameters: {'keyword': resolvedKeyword},
    );
    final response =
        TinygrailResponse<List<CharacterDetailSearchItem>>.fromJson(
      json,
      (value) {
        return TinygrailResponseParser.asObjectList(
          value,
          CharacterDetailSearchItem.fromJson,
        );
      },
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '搜索角色失败');
    }

    return response.value ?? const <CharacterDetailSearchItem>[];
  }
}
