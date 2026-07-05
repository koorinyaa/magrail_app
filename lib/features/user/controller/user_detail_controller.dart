import 'package:flutter/foundation.dart';
import 'package:magrail_app/features/user/controller/user_action_resolver.dart';
import 'package:magrail_app/features/user/controller/user_chara_overview_loader.dart';
import 'package:magrail_app/features/user/model/user_action_entry.dart';
import 'package:magrail_app/features/user/model/user_assets_fetch_result.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_chara_overview_cache.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';
import 'package:magrail_app/features/user/model/user_ico_api_item.dart';
import 'package:magrail_app/features/user/model/user_link_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 用户详情页控制器
class UserDetailController extends ChangeNotifier {
  /// 创建用户详情页控制器
  ///
  /// [repository] 用户仓库
  /// [username] 用户名，不传时展示当前登录用户
  UserDetailController({
    required UserRepository repository,
    String? username,
  })  : _repository = repository,
        _charaOverviewLoader = UserCharaOverviewLoader(
          repository: repository,
        ),
        _username = username;

  final UserRepository _repository;
  final UserCharaOverviewLoader _charaOverviewLoader;
  final UserActionResolver _actionResolver = const UserActionResolver();
  final String? _username;

  UserDetailProfile? _profile;
  // 当前角色资产预览归属用户，用于账号切换时放行新请求并丢弃旧响应
  String? _charaOverviewUsername;
  List<UserLinkApiItem>? _links;
  List<UserTempleApiItem>? _temples;
  List<UserCharacterApiItem>? _characters;
  List<UserIcoApiItem>? _icos;
  int? _linkTotalItems;
  int? _templeTotalItems;
  int? _characterTotalItems;
  int? _icoTotalItems;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isCharaLoading = false;
  bool _isCharaLoadFailed = false;
  bool _isAuthExpired = false;
  bool _isInitialized = false;
  bool _isDisposed = false;
  int _failureNotificationToken = 0;
  // 用户资料失效或重新加载时递增，用于丢弃旧资产预览响应
  int _charaLoadGeneration = 0;

  /// 用户资产资料
  UserDetailProfile? get profile => _profile;

  /// 用户连接预览
  List<UserLinkApiItem>? get links => _links;

  /// 用户圣殿预览
  List<UserTempleApiItem>? get temples => _temples;

  /// 用户角色预览
  List<UserCharacterApiItem>? get characters => _characters;

  /// 用户 ICO 预览
  List<UserIcoApiItem>? get icos => _icos;

  /// 用户连接总数
  int? get linkTotalItems => _linkTotalItems;

  /// 用户圣殿总数
  int? get templeTotalItems => _templeTotalItems;

  /// 用户角色总数
  int? get characterTotalItems => _characterTotalItems;

  /// 用户 ICO 总数
  int? get icoTotalItems => _icoTotalItems;

  /// 加载错误文案
  String? get errorMessage => _errorMessage;

  /// 是否正在首次加载
  bool get isLoading => _isLoading;

  /// 是否正在刷新已有用户资料
  bool get isRefreshing => _isRefreshing;

  /// 是否正在加载用户角色资产预览
  bool get isCharaLoading => _isCharaLoading;

  /// 用户角色资产预览是否加载失败
  bool get isCharaLoadFailed => _isCharaLoadFailed;

  /// 当前用户资产请求是否需要重新授权
  bool get isAuthExpired => _isAuthExpired;

  /// 是否已完成首次初始化
  bool get isInitialized => _isInitialized;

  /// 刷新失败提示版本
  int get failureNotificationToken => _failureNotificationToken;

  /// 是否正在查看当前登录用户
  bool get isCurrentUser => _repository.isCachedCurrentUser(_username);

  /// 初始化用户详情页
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;

    if (_username == null || _username.isEmpty) {
      final cached = _repository.readCachedCurrentUserAssets();
      if (cached != null) {
        _profile = cached;
        _restoreCachedCharaOverview(cached.name);
        _notifyIfActive();
        await refresh(silent: true);
        return;
      }
    }

    await refresh();
  }

  /// 刷新用户资产资料
  ///
  /// [silent] 是否静默刷新
  Future<void> refresh({bool silent = false}) async {
    if (_isDisposed || _isLoading || _isRefreshing) {
      return;
    }

    final shouldShowInitialLoading = !silent && _profile == null;
    _isLoading = shouldShowInitialLoading;
    _isRefreshing = !shouldShowInitialLoading;
    if (!silent) {
      _errorMessage = null;
      _isAuthExpired = false;
    }
    _notifyIfActive();

    final result = await _repository.fetchUserAssets(username: _username);
    if (_isDisposed) {
      return;
    }

    if (result.status == UserAssetsFetchStatus.success) {
      final profile = result.profile;
      if (profile == null) {
        _errorMessage = '获取用户资产失败';
        _isLoading = false;
        _isRefreshing = false;
        _notifyIfActive();
        return;
      }

      var nextProfile = profile;
      final previousProfileName = _profile?.name;
      if (_repository.isCachedCurrentUser(_username)) {
        final holidayName = await _repository.fetchHolidayName();
        if (_isDisposed) {
          return;
        }

        nextProfile = nextProfile.copyWithHoliday(
          showHoliday: holidayName != null && holidayName.isNotEmpty,
          holidayName: holidayName,
        );
        try {
          await _repository.cacheCurrentUserAssets(nextProfile);
        } catch (_) {
          // 节日状态缓存失败不影响当前用户资料展示
        }
        if (_isDisposed) {
          return;
        }
      }

      _profile = nextProfile;
      _errorMessage = null;
      _isAuthExpired = false;
      _isLoading = false;
      if (previousProfileName != null &&
          previousProfileName != nextProfile.name) {
        _clearCharaOverview();
      }
      if (_repository.isCachedCurrentUser(_username) && _hasNoCharaOverview) {
        _restoreCachedCharaOverview(nextProfile.name);
      }
      _notifyIfActive();
      await _loadCharaOverview(
        nextProfile.name,
        showSkeleton: _hasNoCharaOverview,
      );
    } else if (result.status == UserAssetsFetchStatus.authExpired) {
      _clearLoadedUserData();
      _errorMessage = result.message ?? '登录已过期';
      _isAuthExpired = true;
    } else if (result.status == UserAssetsFetchStatus.failure) {
      final message = result.message ?? '获取用户资产失败';
      _errorMessage = message;
      _isAuthExpired = false;
      if (_profile != null) {
        _failureNotificationToken += 1;
      }
    }

    _isLoading = false;
    _isRefreshing = false;
    _notifyIfActive();
  }

  /// 构建当前可见操作入口
  List<UserActionEntry> visibleActions() {
    final profile = _profile;
    if (profile == null) {
      return const [];
    }

    final cachedUser = _repository.readCachedCurrentUserAssets();
    final isCurrentUserRequest = _username == null || _username.isEmpty;
    return _actionResolver.resolve(
      profile: profile,
      cachedUser: cachedUser,
      isCurrentUserRequest: isCurrentUserRequest,
    );
  }

  /// 刷新用户角色资产预览
  Future<void> refreshCharaOverview() async {
    final profile = _profile;
    if (profile == null) {
      return;
    }

    await _loadCharaOverview(
      profile.name,
      showSkeleton: _hasNoVisibleCharaOverview,
    );
  }

  /// 释放用户详情页控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 加载用户角色资产预览
  ///
  /// [username] 用户名
  /// [showSkeleton] 是否显示首次加载骨架
  Future<void> _loadCharaOverview(
    String username, {
    required bool showSkeleton,
  }) async {
    if (_isDisposed || username.isEmpty) {
      return;
    }

    if (_isCharaLoading && _charaOverviewUsername == username) {
      return;
    }

    final loadGeneration = ++_charaLoadGeneration;
    _charaOverviewUsername = username;
    _isCharaLoading = true;
    if (showSkeleton) {
      _isCharaLoadFailed = false;
    }
    _notifyIfActive();

    try {
      final result = await _charaOverviewLoader.load(username: username);
      if (_isDisposed || loadGeneration != _charaLoadGeneration) {
        return;
      }

      if (result.didLoadLinks) {
        _links = List<UserLinkApiItem>.unmodifiable(result.links);
        _linkTotalItems = result.linkTotalItems;
      } else {
        _links ??= const <UserLinkApiItem>[];
      }

      if (result.didLoadTemples) {
        _temples = List<UserTempleApiItem>.unmodifiable(result.temples);
        _templeTotalItems = result.templeTotalItems;
      } else {
        _temples ??= const <UserTempleApiItem>[];
      }

      if (result.didLoadCharacters) {
        _characters = List<UserCharacterApiItem>.unmodifiable(
          result.characters,
        );
        _characterTotalItems = result.characterTotalItems;
      } else {
        _characters ??= const <UserCharacterApiItem>[];
      }

      if (result.didLoadIcos) {
        _icos = List<UserIcoApiItem>.unmodifiable(result.icos);
        _icoTotalItems = result.icoTotalItems;
      } else {
        _icos ??= const <UserIcoApiItem>[];
      }

      _isCharaLoadFailed = result.hasError && _hasNoVisibleCharaOverview;

      // 部分区块失败时不写缓存，避免静默刷新用缺失区块覆盖旧缓存
      if (!result.hasError && _repository.isCachedCurrentUser(username)) {
        final cachedLinks = _links ?? const <UserLinkApiItem>[];
        final cachedTemples = _temples ?? const <UserTempleApiItem>[];
        final cachedCharacters = _characters ?? const <UserCharacterApiItem>[];
        final cachedIcos = _icos ?? const <UserIcoApiItem>[];

        try {
          await _repository.cacheCurrentUserCharaOverview(
            UserCharaOverviewCache(
              username: username,
              links: cachedLinks,
              temples: cachedTemples,
              characters: cachedCharacters,
              icos: cachedIcos,
              linkTotalItems: _linkTotalItems,
              templeTotalItems: _templeTotalItems,
              characterTotalItems: _characterTotalItems,
              icoTotalItems: _icoTotalItems,
            ),
          );
        } catch (_) {
          // 缓存写入失败不影响本次已加载数据展示
        }
        if (_isDisposed || loadGeneration != _charaLoadGeneration) {
          return;
        }
      }
    } catch (_) {
      if (_isDisposed || loadGeneration != _charaLoadGeneration) {
        return;
      }

      _links ??= const <UserLinkApiItem>[];
      _temples ??= const <UserTempleApiItem>[];
      _characters ??= const <UserCharacterApiItem>[];
      _icos ??= const <UserIcoApiItem>[];
      _isCharaLoadFailed = true;
    } finally {
      if (!_isDisposed && loadGeneration == _charaLoadGeneration) {
        _isCharaLoading = false;
        _notifyIfActive();
      }
    }
  }

  /// 是否尚未加载任一角色资产预览
  bool get _hasNoCharaOverview {
    return _links == null &&
        _temples == null &&
        _characters == null &&
        _icos == null;
  }

  /// 是否没有可展示的角色资产预览
  bool get _hasNoVisibleCharaOverview {
    return (_links?.isEmpty ?? true) &&
        (_temples?.isEmpty ?? true) &&
        (_characters?.isEmpty ?? true) &&
        (_icos?.isEmpty ?? true);
  }

  /// 恢复当前登录用户角色资产预览缓存
  ///
  /// [username] 用户名
  bool _restoreCachedCharaOverview(String username) {
    final cache = _repository.readCachedCurrentUserCharaOverview(username);
    if (cache == null) {
      return false;
    }

    _links = List<UserLinkApiItem>.unmodifiable(cache.links);
    _temples = List<UserTempleApiItem>.unmodifiable(cache.temples);
    _characters = List<UserCharacterApiItem>.unmodifiable(cache.characters);
    _icos = List<UserIcoApiItem>.unmodifiable(cache.icos);
    _linkTotalItems = cache.linkTotalItems;
    _templeTotalItems = cache.templeTotalItems;
    _characterTotalItems = cache.characterTotalItems;
    _icoTotalItems = cache.icoTotalItems;
    _isCharaLoadFailed = false;
    _charaOverviewUsername = username;
    return true;
  }

  /// 清空已加载的用户资料和角色资产预览
  void _clearLoadedUserData() {
    _charaLoadGeneration += 1;
    _profile = null;
    _isAuthExpired = false;
    _clearCharaOverview(resetGeneration: false);
  }

  /// 清空已加载的角色资产预览
  ///
  /// [resetGeneration] 是否递增加载世代
  void _clearCharaOverview({bool resetGeneration = true}) {
    if (resetGeneration) {
      _charaLoadGeneration += 1;
    }
    _charaOverviewUsername = null;
    _links = null;
    _temples = null;
    _characters = null;
    _icos = null;
    _linkTotalItems = null;
    _templeTotalItems = null;
    _characterTotalItems = null;
    _icoTotalItems = null;
    _isCharaLoading = false;
    _isCharaLoadFailed = false;
  }

  /// 通知仍挂载的监听者
  void _notifyIfActive() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
