part of '../character_detail_repository.dart';

extension CharacterDetailRepositoryAvatarActions on CharacterDetailRepository {
  /// 更换角色头像
  ///
  /// [characterId] 角色 ID
  /// [avatarUrl] 新头像 OOS 地址
  Future<String> changeCharacterAvatar({
    required int characterId,
    required String avatarUrl,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/avatar/$characterId',
      data: avatarUrl,
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? '更换头像失败');
    }

    return response.value ?? response.message ?? '更换头像成功';
  }
}
