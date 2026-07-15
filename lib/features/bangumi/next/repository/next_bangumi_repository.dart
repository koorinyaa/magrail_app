import 'package:dio/dio.dart';
import 'package:magrail_app/core/network/api_exception.dart';
import 'package:magrail_app/core/network/tinygrail_response.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_character.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_character_cast.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_character_relation.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_subject.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_character_search_item.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_subject_character.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_subject_search_item.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Next Bangumi API 仓库
class NextBangumiRepository {
  /// 创建 Next Bangumi API 仓库
  NextBangumiRepository()
      : _cookieManager = WebViewCookieManager(),
        _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            responseType: ResponseType.json,
            // Next Bangumi 镜像会拦截非浏览器客户端请求
            headers: {
              'User-Agent': _fallbackUserAgent,
              Headers.acceptHeader: 'application/json, text/plain, */*',
              'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
              Headers.contentTypeHeader: Headers.jsonContentType,
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _attachBangumiCookies),
    );
  }

  static const _apiBaseUrl = 'https://next.bgm.tv/p1';
  static const _searchCharactersUrl = '$_apiBaseUrl/search/characters';
  static const _searchSubjectsUrl = '$_apiBaseUrl/search/subjects';
  static const _characterUrl = '$_apiBaseUrl/characters';
  static const _subjectUrl = '$_apiBaseUrl/subjects';
  static const _fallbackUserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/126.0.0.0 Safari/537.36';
  static final Future<String?> _platformUserAgent = _loadPlatformUserAgent();

  final Dio _dio;
  final WebViewCookieManager _cookieManager;

  /// 读取当前平台 WebView 的默认 User-Agent
  static Future<String?> _loadPlatformUserAgent() async {
    try {
      final userAgent = await WebViewController().getUserAgent();
      final normalizedUserAgent = userAgent?.trim();
      if (normalizedUserAgent == null || normalizedUserAgent.isEmpty) {
        return null;
      }

      return normalizedUserAgent;
    } catch (_) {
      return null;
    }
  }

  /// 为 Next Bangumi 请求附加当前域名的 WebView Cookie
  ///
  /// [options] 当前请求配置
  /// [handler] Dio 请求拦截处理器
  Future<void> _attachBangumiCookies(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final platformUserAgent = await _platformUserAgent;
    if (platformUserAgent != null) {
      options.headers['User-Agent'] = platformUserAgent;
    }

    try {
      var cookies = await _cookieManager.getCookies(domain: options.uri);
      if (!cookies.any(
        (cookie) => cookie.name.trim().isNotEmpty && cookie.value.isNotEmpty,
      )) {
        final officialHost = Uri.parse(_apiBaseUrl).host;
        final fallbackHost = options.uri.host == officialHost
            ? 'next.${TinygrailAssetUrls.bangumiMirrorHost}'
            : officialHost;
        // 当前请求域名没有 Cookie 时尝试复用另一侧的 WebView 会话
        cookies = await _cookieManager.getCookies(
          domain: options.uri.replace(host: fallbackHost),
        );
      }
      final cookieHeader = cookies
          .where((cookie) =>
              cookie.name.trim().isNotEmpty && cookie.value.isNotEmpty)
          .map((cookie) => '${cookie.name}=${cookie.value}')
          .join('; ');
      if (cookieHeader.isNotEmpty) {
        options.headers['Cookie'] = cookieHeader;
      }
    } catch (_) {
      // WebView Cookie 不可用时继续请求公开接口
    }
    handler.next(options);
  }

  /// 搜索 Bangumi 角色
  ///
  /// [keyword] 搜索关键字
  /// [limit] 每页条目数量
  /// [offset] 起始偏移量
  Future<NextBangumiCharacterSearchPage> searchCharacters(
    String keyword, {
    required int limit,
    required int offset,
  }) async {
    final resolvedKeyword = keyword.trim();
    if (resolvedKeyword.isEmpty) {
      return const NextBangumiCharacterSearchPage(
        items: <NextBangumiCharacterSearchItem>[],
        total: 0,
        rawItemCount: 0,
      );
    }

    try {
      final response = await _dio.post<dynamic>(
        TinygrailAssetUrls.normalizeBangumiUrl(_searchCharactersUrl),
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
        data: {
          'filter': {'nsfw': true},
          'keyword': resolvedKeyword,
        },
      );
      final responseJson = TinygrailResponseParser.asObjectMap(response.data);
      if (responseJson == null) {
        throw const ApiException(message: '搜索 BGM 角色失败');
      }

      final rawItems = TinygrailResponseParser.asObjectList(
            responseJson['data'],
            NextBangumiCharacterSearchItem.fromJson,
          ) ??
          const <NextBangumiCharacterSearchItem>[];
      return NextBangumiCharacterSearchPage(
        items: rawItems
            .where((item) => item.characterId > 0)
            .toList(growable: false),
        total: TinygrailResponseParser.asInt(responseJson['total']),
        rawItemCount: rawItems.length,
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// 搜索 Bangumi 条目
  ///
  /// [keyword] 搜索关键字
  /// [limit] 每页条目数量
  /// [offset] 起始偏移量
  Future<NextBangumiSubjectSearchPage> searchSubjects(
    String keyword, {
    required int limit,
    required int offset,
  }) async {
    final resolvedKeyword = keyword.trim();
    if (resolvedKeyword.isEmpty) {
      return const NextBangumiSubjectSearchPage(
        items: <NextBangumiSubjectSearchItem>[],
        total: 0,
        rawItemCount: 0,
      );
    }

    try {
      final response = await _dio.post<dynamic>(
        TinygrailAssetUrls.normalizeBangumiUrl(_searchSubjectsUrl),
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
        data: {
          'filter': {
            'date': <Object?>[],
            'metaTags': <Object?>[],
            'nsfw': true,
            'rank': <Object?>[],
            'rating': <Object?>[],
            'tags': <Object?>[],
            'type': <Object?>[],
          },
          'keyword': resolvedKeyword,
          'sort': 'match',
        },
      );
      final responseJson = TinygrailResponseParser.asObjectMap(response.data);
      if (responseJson == null) {
        throw const ApiException(message: '搜索 BGM 条目失败');
      }

      final rawItems = TinygrailResponseParser.asObjectList(
            responseJson['data'],
            NextBangumiSubjectSearchItem.fromJson,
          ) ??
          const <NextBangumiSubjectSearchItem>[];
      return NextBangumiSubjectSearchPage(
        items: rawItems
            .where((item) => item.subjectId > 0)
            .toList(growable: false),
        total: TinygrailResponseParser.asInt(responseJson['total']),
        rawItemCount: rawItems.length,
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// 获取 Bangumi 角色详情
  ///
  /// [characterId] 角色 ID
  Future<NextBangumiCharacter> fetchCharacter(int characterId) async {
    if (characterId <= 0) {
      throw const ApiException(message: '获取 BGM 角色失败');
    }

    try {
      final response = await _dio.get<dynamic>(
        TinygrailAssetUrls.normalizeBangumiUrl(
          '$_characterUrl/$characterId',
        ),
      );
      final responseJson = TinygrailResponseParser.asObjectMap(response.data);
      if (responseJson == null) {
        throw const ApiException(message: '获取 BGM 角色失败');
      }

      return NextBangumiCharacter.fromJson(responseJson);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// 获取 Bangumi 角色关联角色
  ///
  /// [characterId] 角色 ID
  /// [limit] 每页条目数量
  /// [offset] 起始偏移量
  Future<NextBangumiCharacterRelationPage> fetchCharacterRelations(
    int characterId, {
    required int limit,
    required int offset,
  }) async {
    if (characterId <= 0) {
      throw const ApiException(message: '获取 BGM 关联角色失败');
    }

    try {
      final response = await _dio.get<dynamic>(
        TinygrailAssetUrls.normalizeBangumiUrl(
          '$_characterUrl/$characterId/relations',
        ),
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      final responseJson = TinygrailResponseParser.asObjectMap(response.data);
      if (responseJson == null) {
        throw const ApiException(message: '获取 BGM 关联角色失败');
      }

      final rawItems = TinygrailResponseParser.asObjectList(
            responseJson['data'],
            NextBangumiSubjectCharacterItem.fromJson,
          ) ??
          const <NextBangumiSubjectCharacterItem>[];
      return NextBangumiCharacterRelationPage(
        items: rawItems
            .where((item) => item.characterId > 0)
            .toList(growable: false),
        total: TinygrailResponseParser.asInt(responseJson['total']),
        rawItemCount: rawItems.length,
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// 获取 Bangumi 角色出演作品
  ///
  /// [characterId] 角色 ID
  /// [limit] 每页条目数量
  /// [offset] 起始偏移量
  Future<NextBangumiCharacterCastPage> fetchCharacterCasts(
    int characterId, {
    required int limit,
    required int offset,
  }) async {
    if (characterId <= 0) {
      throw const ApiException(message: '获取 BGM 出演作品失败');
    }

    try {
      final response = await _dio.get<dynamic>(
        TinygrailAssetUrls.normalizeBangumiUrl(
          '$_characterUrl/$characterId/casts',
        ),
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      final responseJson = TinygrailResponseParser.asObjectMap(response.data);
      if (responseJson == null) {
        throw const ApiException(message: '获取 BGM 出演作品失败');
      }

      final rawItems = TinygrailResponseParser.asObjectList(
            responseJson['data'],
            _castSubjectFromJson,
          ) ??
          const <NextBangumiCharacterCastItem>[];
      return NextBangumiCharacterCastPage(
        items: rawItems
            .where((item) => item.subject.subjectId > 0)
            .toList(growable: false),
        total: TinygrailResponseParser.asInt(responseJson['total']),
        rawItemCount: rawItems.length,
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// 获取 Bangumi 条目详情
  ///
  /// [subjectId] 条目 ID
  Future<NextBangumiSubject> fetchSubject(int subjectId) async {
    if (subjectId <= 0) {
      throw const ApiException(message: '获取 BGM 条目失败');
    }

    try {
      final response = await _dio.get<dynamic>(
        TinygrailAssetUrls.normalizeBangumiUrl(
          '$_subjectUrl/$subjectId',
        ),
      );
      final responseJson = TinygrailResponseParser.asObjectMap(response.data);
      if (responseJson == null) {
        throw const ApiException(message: '获取 BGM 条目失败');
      }

      return NextBangumiSubject.fromJson(responseJson);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// 获取 Bangumi 条目角色
  ///
  /// [subjectId] 条目 ID
  /// [limit] 每页条目数量
  /// [offset] 起始偏移量
  Future<NextBangumiSubjectCharacterPage> fetchSubjectCharacters(
    int subjectId, {
    required int limit,
    required int offset,
  }) async {
    if (subjectId <= 0) {
      throw const ApiException(message: '获取 BGM 条目角色失败');
    }

    try {
      final response = await _dio.get<dynamic>(
        TinygrailAssetUrls.normalizeBangumiUrl(
          '$_subjectUrl/$subjectId/characters',
        ),
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      final responseJson = TinygrailResponseParser.asObjectMap(response.data);
      if (responseJson == null) {
        throw const ApiException(message: '获取 BGM 条目角色失败');
      }

      final rawItems = TinygrailResponseParser.asObjectList(
            responseJson['data'],
            NextBangumiSubjectCharacterItem.fromJson,
          ) ??
          const <NextBangumiSubjectCharacterItem>[];
      return NextBangumiSubjectCharacterPage(
        items: rawItems
            .where((item) => item.characterId > 0)
            .toList(growable: false),
        total: TinygrailResponseParser.asInt(responseJson['total']),
        rawItemCount: rawItems.length,
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// 关闭仓库持有的网络客户端
  void close() {
    _dio.close(force: true);
  }
}

/// 从出演作品 JSON 读取条目资料
///
/// [json] 原始出演作品 JSON
NextBangumiCharacterCastItem _castSubjectFromJson(
  Map<String, Object?> json,
) {
  final subject = TinygrailResponseParser.asObjectMap(json['subject']);
  return NextBangumiCharacterCastItem(
    subject: NextBangumiSubjectSearchItem.fromSubjectJson(
      subject ?? const <String, Object?>{},
    ),
    type: TinygrailResponseParser.asInt(json['type']),
  );
}
