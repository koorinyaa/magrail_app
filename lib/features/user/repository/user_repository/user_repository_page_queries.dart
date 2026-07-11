part of '../user_repository.dart';

/// 用户仓库分页与列表查询
mixin _UserRepositoryPageQueries {
  /// Tinygrail API 客户端
  ApiClient get _apiClient;

  /// 拍卖仓库
  AuctionRepository get _auctionRepository;

  /// 编码用户名
  ///
  /// [username] 原始用户名
  String _encodeUsername(String username);

  /// 获取当前用户市场订单分页数据
  ///
  /// [path] 请求路径
  /// [fallbackMessage] 请求失败兜底文案
  Future<TinygrailPage<UserMarketOrderApiItem>> _fetchUserMarketOrderPage({
    required String path,
    required String fallbackMessage,
  });

  /// 解析用户分页响应
  ///
  /// [json] 原始响应 JSON
  /// [itemFromJson] 分页条目转换函数
  /// [fallbackMessage] 失败兜底文案
  TinygrailPage<T> _parsePageResponse<T>({
    required Map<String, Object?> json,
    required T Function(Map<String, Object?> json) itemFromJson,
    required String fallbackMessage,
  });

  /// 获取当前用户资金日志分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页日志数量
  Future<TinygrailPage<UserBalanceLogApiItem>> fetchUserBalanceLogPage({
    int page = 1,
    int pageSize = 50,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/user/balance/$page/$pageSize',
    );

    return _parsePageResponse(
      json: json,
      itemFromJson: UserBalanceLogApiItem.fromJson,
      fallbackMessage: '获取资金日志失败',
    );
  }

  /// 获取当前用户拍卖分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页拍卖数量
  Future<TinygrailPage<UserAuctionApiItem>> fetchUserAuctionPage({
    int page = 1,
    int pageSize = 50,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/user/auction/$page/$pageSize',
    );
    final pageData = _parsePageResponse(
      json: json,
      itemFromJson: UserAuctionApiItem.fromJson,
      fallbackMessage: '获取拍卖列表失败',
    );

    if (pageData.items.isEmpty) {
      return pageData;
    }

    try {
      final details = await _auctionRepository.fetchAuctionMap(
        pageData.items.map((item) => item.characterId).toList(growable: false),
      );
      return TinygrailPage(
        items: pageData.items
            .map(
              (item) => item.copyWith(
                auctionDetail: details[item.characterId],
              ),
            )
            .toList(growable: false),
        currentPage: pageData.currentPage,
        totalPages: pageData.totalPages,
        totalItems: pageData.totalItems,
        itemsPerPage: pageData.itemsPerPage,
      );
    } catch (_) {
      // 拍卖详情仅用于补充竞拍人数和数量，失败时保留基础拍卖列表
      return pageData;
    }
  }

  /// 获取当前用户买单分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页买单数量
  Future<TinygrailPage<UserMarketOrderApiItem>> fetchUserBidPage({
    int page = 1,
    int pageSize = 50,
  }) {
    return _fetchUserMarketOrderPage(
      path: 'chara/bids/0/$page/$pageSize',
      fallbackMessage: '获取买单列表失败',
    );
  }

  /// 获取当前用户卖单分页数据
  ///
  /// [page] 页码
  /// [pageSize] 每页卖单数量
  Future<TinygrailPage<UserMarketOrderApiItem>> fetchUserAskPage({
    int page = 1,
    int pageSize = 50,
  }) {
    return _fetchUserMarketOrderPage(
      path: 'chara/asks/0/$page/$pageSize',
      fallbackMessage: '获取卖单列表失败',
    );
  }

  /// 获取当前用户道具列表
  ///
  /// [pageSize] 单次请求道具数量
  Future<List<UserItemApiItem>> fetchUserItems({
    int pageSize = 50,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/user/item/0/1/$pageSize',
    );

    final page = _parsePageResponse(
      json: json,
      itemFromJson: UserItemApiItem.fromJson,
      fallbackMessage: '获取道具列表失败',
    );
    return page.items;
  }

  /// 获取用户红包记录分页数据
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页记录数量
  Future<TinygrailPage<UserRedPacketLogApiItem>> fetchUserRedPacketLogPage({
    required String username,
    int page = 1,
    int pageSize = 20,
  }) async {
    final encodedUsername = _encodeUsername(username);
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/user/send/log/$encodedUsername/$page/$pageSize',
    );

    return _parsePageResponse(
      json: json,
      itemFromJson: UserRedPacketLogApiItem.fromJson,
      fallbackMessage: '获取红包记录失败',
    );
  }

  /// 获取用户交易记录分页数据
  ///
  /// [userId] 用户 ID
  /// [page] 页码
  /// [pageSize] 每页记录数量
  Future<TinygrailPage<UserTradeLogApiItem>> fetchUserTradeLogPage({
    required int userId,
    int page = 1,
    int pageSize = 48,
  }) async {
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/user/history/$userId/$page/$pageSize',
    );

    return _parsePageResponse(
      json: json,
      itemFromJson: UserTradeLogApiItem.fromJson,
      fallbackMessage: '获取交易记录失败',
    );
  }

  /// 获取用户连接分页数据
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页条目数量
  Future<TinygrailPage<UserLinkApiItem>> fetchUserLinkPage({
    required String username,
    int page = 1,
    int pageSize = 12,
  }) async {
    final encodedUsername = _encodeUsername(username);
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/user/link/$encodedUsername/$page/$pageSize',
    );

    return _parsePageResponse(
      json: json,
      itemFromJson: UserLinkApiItem.fromJson,
      fallbackMessage: '获取连接列表失败',
    );
  }

  /// 获取用户圣殿分页数据
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页条目数量
  /// [keyword] 搜索关键字
  /// [characterIds] 限定角色 ID 列表
  Future<TinygrailPage<UserTempleApiItem>> fetchUserTemplePage({
    required String username,
    int page = 1,
    int pageSize = 24,
    String keyword = '',
    List<int> characterIds = const [],
  }) async {
    final encodedUsername = _encodeUsername(username);
    final queryParameters = <String, Object?>{
      if (keyword.isNotEmpty) 'keyword': keyword,
      if (characterIds.isNotEmpty) 'characterIds': characterIds.join(','),
    };
    final json = await _apiClient.getJson<Map<String, Object?>>(
      'chara/user/temple/$encodedUsername/$page/$pageSize',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    return _parsePageResponse(
      json: json,
      itemFromJson: UserTempleApiItem.fromJson,
      fallbackMessage: '获取圣殿列表失败',
    );
  }

  /// 获取用户角色分页数据
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页条目数量
  /// [sort] 排序方式
  /// [characterIds] 限定角色 ID 列表
  Future<TinygrailPage<UserCharacterApiItem>> fetchUserCharacterPage({
    required String username,
    int page = 1,
    int pageSize = 24,
    String sort = '',
    List<int> characterIds = const [],
  }) async {
    final encodedUsername = _encodeUsername(username);
    final queryParameters = <String, Object?>{
      if (sort.isNotEmpty) 'sort': sort,
      if (characterIds.isNotEmpty) 'characterIds': characterIds.join(','),
    };
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/user/chara/$encodedUsername/$page/$pageSize',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    return _parsePageResponse(
      json: json,
      itemFromJson: UserCharacterApiItem.fromJson,
      fallbackMessage: '获取角色列表失败',
    );
  }

  /// 获取用户 ICO 分页数据
  ///
  /// [username] 用户名
  /// [page] 页码
  /// [pageSize] 每页条目数量
  Future<TinygrailPage<UserIcoApiItem>> fetchUserIcoPage({
    required String username,
    int page = 1,
    int pageSize = 24,
  }) async {
    final encodedUsername = _encodeUsername(username);
    final json = await _apiClient.postJson<Map<String, Object?>>(
      'chara/user/initial/$encodedUsername/$page/$pageSize',
    );

    return _parsePageResponse(
      json: json,
      itemFromJson: UserIcoApiItem.fromJson,
      fallbackMessage: '获取 ICO 列表失败',
    );
  }
}
