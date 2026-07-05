import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_ico_api_item.dart';
import 'package:magrail_app/features/user/model/user_link_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 用户角色资产预览加载器
class UserCharaOverviewLoader {
  /// 创建用户角色资产预览加载器
  ///
  /// [repository] 用户仓库
  const UserCharaOverviewLoader({
    required UserRepository repository,
  }) : _repository = repository;

  final UserRepository _repository;

  // 用户页连接预览只展示少量连接组，接口返回无 Link 的条目会在加载器内过滤
  static const int _linkPreviewPageSize = 6;

  // 用户页圣殿预览按首页横向卡片节奏展示 12 座
  static const int _templePreviewPageSize = 12;

  // 角色和 ICO 预览每次加载 24 条
  static const int _charaAssetPreviewPageSize = 24;

  /// 加载用户角色资产预览
  ///
  /// [username] 用户名
  Future<UserCharaOverviewLoadResult> load({
    required String username,
  }) async {
    var links = const <UserLinkApiItem>[];
    var temples = const <UserTempleApiItem>[];
    var characters = const <UserCharacterApiItem>[];
    var icos = const <UserIcoApiItem>[];
    int? linkTotalItems;
    int? templeTotalItems;
    int? characterTotalItems;
    int? icoTotalItems;
    var hasError = false;
    var didLoadLinks = false;
    var didLoadTemples = false;
    var didLoadCharacters = false;
    var didLoadIcos = false;

    /// 加载连接预览
    Future<void> loadLinks() async {
      try {
        final page = await _repository.fetchUserLinkPage(
          username: username,
          pageSize: _linkPreviewPageSize,
        );
        linkTotalItems = page.totalItems;
        links = page.items
            .where((UserLinkApiItem item) => item.hasLink)
            .toList(growable: false);
        didLoadLinks = true;
      } catch (_) {
        hasError = true;
      }
    }

    /// 加载圣殿预览
    Future<void> loadTemples() async {
      try {
        final page = await _repository.fetchUserTemplePage(
          username: username,
          pageSize: _templePreviewPageSize,
        );
        templeTotalItems = page.totalItems;
        temples = page.items;
        didLoadTemples = true;
      } catch (_) {
        hasError = true;
      }
    }

    /// 加载角色预览
    Future<void> loadCharacters() async {
      try {
        final page = await _repository.fetchUserCharacterPage(
          username: username,
          pageSize: _charaAssetPreviewPageSize,
        );
        characterTotalItems = page.totalItems;
        characters = page.items;
        didLoadCharacters = true;
      } catch (_) {
        hasError = true;
      }
    }

    /// 加载 ICO 预览
    Future<void> loadIcos() async {
      try {
        final page = await _repository.fetchUserIcoPage(
          username: username,
          pageSize: _charaAssetPreviewPageSize,
        );
        icoTotalItems = page.totalItems;
        icos = page.items;
        didLoadIcos = true;
      } catch (_) {
        hasError = true;
      }
    }

    await Future.wait<void>([
      loadLinks(),
      loadTemples(),
      loadCharacters(),
      loadIcos(),
    ]);

    return UserCharaOverviewLoadResult(
      links: links,
      temples: temples,
      characters: characters,
      icos: icos,
      linkTotalItems: linkTotalItems,
      templeTotalItems: templeTotalItems,
      characterTotalItems: characterTotalItems,
      icoTotalItems: icoTotalItems,
      didLoadLinks: didLoadLinks,
      didLoadTemples: didLoadTemples,
      didLoadCharacters: didLoadCharacters,
      didLoadIcos: didLoadIcos,
      hasError: hasError,
    );
  }
}

/// 用户角色资产预览加载结果
class UserCharaOverviewLoadResult {
  /// 创建用户角色资产预览加载结果
  ///
  /// [links] 用户连接预览
  /// [temples] 用户圣殿预览
  /// [characters] 用户角色预览
  /// [icos] 用户 ICO 预览
  /// [linkTotalItems] 用户连接总数
  /// [templeTotalItems] 用户圣殿总数
  /// [characterTotalItems] 用户角色总数
  /// [icoTotalItems] 用户 ICO 总数
  /// [didLoadLinks] 连接区是否请求成功
  /// [didLoadTemples] 圣殿区是否请求成功
  /// [didLoadCharacters] 角色区是否请求成功
  /// [didLoadIcos] ICO 区是否请求成功
  /// [hasError] 是否存在任一区块请求失败
  const UserCharaOverviewLoadResult({
    required this.links,
    required this.temples,
    required this.characters,
    required this.icos,
    required this.linkTotalItems,
    required this.templeTotalItems,
    required this.characterTotalItems,
    required this.icoTotalItems,
    required this.didLoadLinks,
    required this.didLoadTemples,
    required this.didLoadCharacters,
    required this.didLoadIcos,
    required this.hasError,
  });

  /// 用户连接预览
  final List<UserLinkApiItem> links;

  /// 用户圣殿预览
  final List<UserTempleApiItem> temples;

  /// 用户角色预览
  final List<UserCharacterApiItem> characters;

  /// 用户 ICO 预览
  final List<UserIcoApiItem> icos;

  /// 用户连接总数
  final int? linkTotalItems;

  /// 用户圣殿总数
  final int? templeTotalItems;

  /// 用户角色总数
  final int? characterTotalItems;

  /// 用户 ICO 总数
  final int? icoTotalItems;

  /// 连接区是否请求成功
  final bool didLoadLinks;

  /// 圣殿区是否请求成功
  final bool didLoadTemples;

  /// 角色区是否请求成功
  final bool didLoadCharacters;

  /// ICO 区是否请求成功
  final bool didLoadIcos;

  /// 是否存在任一区块请求失败
  final bool hasError;
}
