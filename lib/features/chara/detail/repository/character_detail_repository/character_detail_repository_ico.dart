part of '../character_detail_repository.dart';

extension CharacterDetailRepositoryIcoQueries on CharacterDetailRepository {
  /// 获取当前用户 ICO 注资资料
  ///
  /// 未参与 ICO 时接口可能返回业务失败，此处按未注资处理
  ///
  /// [icoId] ICO 记录 ID
  Future<CharacterDetailIcoUserInfo> fetchCharacterIcoUserInfo({
    required int icoId,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/initial/$icoId',
    );
    final response = TinygrailResponse<CharacterDetailIcoUserInfo>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return const CharacterDetailIcoUserInfo.empty();
        }

        return CharacterDetailIcoUserInfo.fromJson(valueJson);
      },
    );

    if (!response.isSuccess) {
      return const CharacterDetailIcoUserInfo.empty();
    }

    return response.value ?? const CharacterDetailIcoUserInfo.empty();
  }

  /// 获取角色 ICO 参与者分页数据
  ///
  /// [icoId] ICO 记录 ID
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<TinygrailPage<CharacterDetailIcoParticipant>>
      fetchCharacterIcoParticipantPage({
    required int icoId,
    required int page,
    required int pageSize,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/initial/users/$icoId/$page/$pageSize',
    );
    final response = TinygrailResponse<
        TinygrailPage<CharacterDetailIcoParticipant>>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }

        return TinygrailPage<CharacterDetailIcoParticipant>.fromJson(
          valueJson,
          CharacterDetailIcoParticipant.fromJson,
        );
      },
    );

    final pageData = response.value;
    if (!response.isSuccess || pageData == null) {
      throw StateError(response.message ?? '获取 ICO 参与者失败');
    }

    return pageData;
  }

  /// 提交 ICO 注资
  ///
  /// [icoId] ICO 记录 ID
  /// [amount] 注资金额
  Future<String> joinCharacterIco({
    required int icoId,
    required double amount,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/join/$icoId/${_formatIcoAmount(amount)}',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '注资失败');
    }

    return response.value ?? response.message ?? '注资成功';
  }

  /// 启动角色 ICO
  ///
  /// [characterId] 角色 ID
  /// [amount] 初始注资金额
  Future<String> initCharacterIco({
    required int characterId,
    required double amount,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/init/$characterId/${_formatIcoAmount(amount)}',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '启动 ICO 失败');
    }

    return 'ICO启动成功，邀请更多朋友加入吧。';
  }

  /// 格式化 ICO 注资金额路径参数
  ///
  /// [amount] 注资金额
  String _formatIcoAmount(double amount) {
    return Formatters.plainDecimal(amount);
  }
}
