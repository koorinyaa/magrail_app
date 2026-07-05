part of '../character_detail_repository.dart';

extension CharacterDetailRepositorySacrificeActions
    on CharacterDetailRepository {
  /// 提交角色资产重组或股权融资
  ///
  /// [characterId] 角色 ID
  /// [amount] 提交数量
  /// [isFinancing] 是否为股权融资
  Future<CharacterDetailSacrificeResult> sacrificeCharacter({
    required int characterId,
    required int amount,
    required bool isFinancing,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/sacrifice/$characterId/$amount/$isFinancing',
    );
    final response = TinygrailResponse<CharacterDetailSacrificeResult>.fromJson(
      json,
      (value) {
        final valueJson = TinygrailResponseParser.asObjectMap(value);
        if (valueJson == null) {
          return null;
        }

        return CharacterDetailSacrificeResult.fromJson(valueJson);
      },
    );

    if (!response.isSuccess) {
      throw StateError(
        response.message ?? (isFinancing ? '股权融资失败' : '资产重组失败'),
      );
    }

    return response.value ?? const CharacterDetailSacrificeResult.empty();
  }
}
