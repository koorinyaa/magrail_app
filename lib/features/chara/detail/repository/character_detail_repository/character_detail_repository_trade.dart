part of '../character_detail_repository.dart';

extension CharacterDetailRepositoryTradeActions on CharacterDetailRepository {
  /// 买入角色
  ///
  /// [characterId] 角色 ID
  /// [price] 买入价格
  /// [amount] 买入数量
  /// [isIceberg] 是否为冰山委托
  Future<String> bidCharacter({
    required int characterId,
    required double price,
    required int amount,
    bool isIceberg = false,
  }) {
    return _submitTradeOrder(
      pathSegment: 'bid',
      characterId: characterId,
      price: price,
      amount: amount,
      isIceberg: isIceberg,
      fallbackMessage: '买入失败',
      successMessage: '买入委托成功',
    );
  }

  /// 卖出角色
  ///
  /// [characterId] 角色 ID
  /// [price] 卖出价格
  /// [amount] 卖出数量
  /// [isIceberg] 是否为冰山委托
  Future<String> askCharacter({
    required int characterId,
    required double price,
    required int amount,
    bool isIceberg = false,
  }) {
    return _submitTradeOrder(
      pathSegment: 'ask',
      characterId: characterId,
      price: price,
      amount: amount,
      isIceberg: isIceberg,
      fallbackMessage: '卖出失败',
      successMessage: '卖出委托成功',
    );
  }

  /// 取消买入委托
  ///
  /// [orderId] 委托 ID
  Future<String> cancelBidOrder(int orderId) {
    return _cancelTradeOrder(
      pathSegment: 'bid',
      orderId: orderId,
      fallbackMessage: '取消买入委托失败',
      successMessage: '取消买入委托成功',
    );
  }

  /// 取消卖出委托
  ///
  /// [orderId] 委托 ID
  Future<String> cancelAskOrder(int orderId) {
    return _cancelTradeOrder(
      pathSegment: 'ask',
      orderId: orderId,
      fallbackMessage: '取消卖出委托失败',
      successMessage: '取消卖出委托成功',
    );
  }

  /// 提交角色交易委托
  ///
  /// [pathSegment] 交易接口路径片段
  /// [characterId] 角色 ID
  /// [price] 委托价格
  /// [amount] 委托数量
  /// [isIceberg] 是否为冰山委托
  /// [fallbackMessage] 接口失败兜底文案
  /// [successMessage] 接口成功兜底文案
  Future<String> _submitTradeOrder({
    required String pathSegment,
    required int characterId,
    required double price,
    required int amount,
    required bool isIceberg,
    required String fallbackMessage,
    required String successMessage,
  }) async {
    final priceText = _formatTradePrice(price);
    final path = isIceberg
        ? 'chara/$pathSegment/$characterId/$priceText/$amount/true'
        : 'chara/$pathSegment/$characterId/$priceText/$amount';
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

  /// 取消角色交易委托
  ///
  /// [pathSegment] 交易接口路径片段
  /// [orderId] 委托 ID
  /// [fallbackMessage] 接口失败兜底文案
  /// [successMessage] 接口成功兜底文案
  Future<String> _cancelTradeOrder({
    required String pathSegment,
    required int orderId,
    required String fallbackMessage,
    required String successMessage,
  }) async {
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/$pathSegment/cancel/$orderId',
    );
    final response = TinygrailResponse<String>.fromJson(
      json,
      TinygrailResponseParser.asNullableString,
    );

    if (!response.isSuccess) {
      throw StateError(response.message ?? fallbackMessage);
    }

    return response.value ?? response.message ?? successMessage;
  }

  /// 格式化交易接口价格路径参数
  ///
  /// [price] 委托价格
  String _formatTradePrice(double price) {
    return Formatters.plainDecimal(price);
  }
}
