import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/auth/tinygrail_auth_repository.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/features/bot/model/bot_models.dart';
import 'package:magrail_app/features/bot/repository/bot_repository.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// bot 配置页控制器
class BotConfigController extends ChangeNotifier {
  /// 创建 bot 配置页控制器
  ///
  /// [authRepository] Tinygrail 授权仓库
  /// [repository] fuyuake bot 仓库
  /// [characterRepository] Tinygrail 角色仓库
  /// [userRepository] Tinygrail 用户仓库
  BotConfigController({
    required TinygrailAuthRepository authRepository,
    required BotRepository repository,
    required CharacterDetailRepository characterRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _repository = repository,
        _characterRepository = characterRepository,
        _userRepository = userRepository;

  final TinygrailAuthRepository _authRepository;
  final BotRepository _repository;
  final CharacterDetailRepository _characterRepository;
  final UserRepository _userRepository;

  String? _token;
  BotConfig? _config;
  List<BotLogEntry> _logs = const <BotLogEntry>[];
  final Map<int, BotTempleOption> _templeOptions = <int, BotTempleOption>{};
  final Map<int, BotCharacterOption> _characterOptions =
      <int, BotCharacterOption>{};
  String? _errorMessage;
  String? _logErrorMessage;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isSaving = false;
  bool _isRevoking = false;
  bool _isLoadingLogs = false;
  bool _isDisposed = false;

  /// 当前 bot 配置
  BotConfig? get config => _config;

  /// bot 操作日志
  List<BotLogEntry> get logs => _logs;

  /// 初始加载错误文案
  String? get errorMessage => _errorMessage;

  /// 日志加载错误文案
  String? get logErrorMessage => _logErrorMessage;

  /// 是否正在首次加载
  bool get isLoading => _isLoading;

  /// 是否正在刷新
  bool get isRefreshing => _isRefreshing;

  /// 是否正在保存
  bool get isSaving => _isSaving;

  /// 是否正在取消授权
  bool get isRevoking => _isRevoking;

  /// 是否正在加载 bot 操作日志
  bool get isLoadingLogs => _isLoadingLogs;

  /// 初始化 bot 配置页
  Future<void> initialize() async {
    if (_config != null || _isLoading) {
      return;
    }

    await refresh();
  }

  /// 刷新 bot 配置
  Future<void> refresh() async {
    if (_isDisposed || _isLoading || _isRefreshing) {
      return;
    }

    final isInitialLoad = _config == null;
    _isLoading = isInitialLoad;
    _isRefreshing = !isInitialLoad;
    _errorMessage = null;
    _notifyIfActive();

    try {
      final token = await _ensureToken();
      final config = await _repository.fetchConfig(token: token);
      _config = config;
      await _restoreSelectedOptions(config);
    } catch (error) {
      _errorMessage = resolveUserErrorMessage(
        error,
        fallback: '获取 Bot 配置失败，请稍后重试',
      );
      if (_config == null) {
        _logs = const <BotLogEntry>[];
      }
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      _notifyIfActive();
    }
  }

  /// 标记配置已变更
  void notifyConfigChanged() {
    _notifyIfActive();
  }

  /// 记录已选圣殿
  ///
  /// [option] 圣殿选择项
  void rememberTempleOption(BotTempleOption? option) {
    if (option == null) {
      return;
    }

    _templeOptions[option.characterId] = option;
  }

  /// 记录已选角色
  ///
  /// [option] 角色选择项
  void rememberCharacterOption(BotCharacterOption? option) {
    if (option == null) {
      return;
    }

    _characterOptions[option.characterId] = option;
  }

  /// 读取已缓存圣殿选择项
  ///
  /// [characterId] 圣殿角色 ID
  BotTempleOption? templeOptionFor(int? characterId) {
    if (characterId == null) {
      return null;
    }

    return _templeOptions[characterId];
  }

  /// 读取已缓存角色选择项
  ///
  /// [characterId] 角色 ID
  BotCharacterOption? characterOptionFor(int? characterId) {
    if (characterId == null) {
      return null;
    }

    return _characterOptions[characterId];
  }

  /// 分页搜索圣殿
  ///
  /// [page] 页码
  /// [pageSize] 每页条目数量
  /// [keyword] 搜索关键词
  Future<TinygrailPage<BotTempleOption>> searchTemplePage({
    required int page,
    required int pageSize,
    required String keyword,
  }) async {
    final config = _config;
    if (config == null) {
      return const TinygrailPage(
        items: <BotTempleOption>[],
        currentPage: 1,
        totalPages: 0,
        totalItems: 0,
        itemsPerPage: 0,
      );
    }

    final templePage = await _userRepository.fetchUserTemplePage(
      username: config.userId,
      page: page,
      pageSize: pageSize,
      keyword: keyword,
    );
    final items = templePage.items.map(_templeOptionFromUserTemple).toList(
          growable: false,
        );
    for (final item in items) {
      _templeOptions[item.characterId] = item;
    }

    return TinygrailPage(
      items: items,
      currentPage: templePage.currentPage,
      totalPages: templePage.totalPages,
      totalItems: templePage.totalItems,
      itemsPerPage: templePage.itemsPerPage,
    );
  }

  /// 回显指定圣殿
  ///
  /// [characterIds] 圣殿角色 ID 列表
  Future<List<BotTempleOption>> restoreTempleOptions(
    List<int> characterIds,
  ) async {
    final config = _config;
    final ids = characterIds.where((id) => id > 0).toSet().toList();
    if (config == null || ids.isEmpty) {
      return const <BotTempleOption>[];
    }

    final page = await _userRepository.fetchUserTemplePage(
      username: config.userId,
      page: 1,
      pageSize: ids.length,
      characterIds: ids,
    );
    final items =
        page.items.map(_templeOptionFromUserTemple).toList(growable: false);
    for (final item in items) {
      _templeOptions[item.characterId] = item;
    }

    return items;
  }

  /// 搜索角色
  ///
  /// [keyword] 搜索关键词
  Future<List<BotCharacterOption>> searchCharacters(String keyword) async {
    final searchItems = await _characterRepository.searchCharacters(keyword);
    final items = searchItems
        .map(
          (item) => BotCharacterOption(
            characterId: item.characterId,
            name: item.name,
            level: item.level,
            icon: item.icon,
          ),
        )
        .toList(growable: false);
    for (final item in items) {
      _characterOptions[item.characterId] = item;
    }

    return items;
  }

  /// 保存 bot 配置
  Future<void> save() async {
    final config = _config;
    if (config == null || _isSaving) {
      return;
    }

    _isSaving = true;
    _notifyIfActive();

    try {
      await _repository.saveConfig(
        token: await _ensureToken(),
        config: config,
      );
    } finally {
      _isSaving = false;
      _notifyIfActive();
    }
  }

  /// 取消 bot 授权
  Future<void> revokeAuthorization() async {
    final config = _config;
    if (config == null || _isRevoking) {
      return;
    }

    _isRevoking = true;
    _notifyIfActive();

    try {
      await _repository.revokeAuthorization(
        token: await _ensureToken(),
        userId: config.userId,
      );
    } finally {
      _isRevoking = false;
      _notifyIfActive();
    }
  }

  /// 释放 bot 配置页控制器
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 读取并缓存本次页面使用的 bot token
  Future<String> _ensureToken() async {
    final cachedToken = _token;
    if (cachedToken != null && cachedToken.isNotEmpty) {
      return cachedToken;
    }

    final token = await _authRepository.readFuyuakeBotToken();
    _token = token;
    return token;
  }

  /// 回显已选圣殿和角色
  ///
  /// [config] 当前 bot 配置
  Future<void> _restoreSelectedOptions(BotConfig config) async {
    final templeIds = <int>{
      ...config.templeBlacklist,
      if (config.chaosUseTemple != null) config.chaosUseTemple!,
      if (config.guidepostUseTemple != null) config.guidepostUseTemple!,
      if (config.fishUseTemple != null) config.fishUseTemple!,
    }.where((id) => id > 0).toList(growable: false);

    await restoreTempleOptions(templeIds);

    await _restoreCharacterOption(config.guidepostTarget);
    await _restoreCharacterOption(config.fishTarget);
  }

  /// 转换用户圣殿条目为 bot 圣殿选择项
  ///
  /// [item] 用户圣殿接口条目
  BotTempleOption _templeOptionFromUserTemple(UserTempleApiItem item) {
    return BotTempleOption(
      characterId: item.characterId,
      name: item.name,
      assets: item.assets.toDouble(),
      sacrifices: item.sacrifices.toDouble(),
      level: item.level,
      avatar: item.avatar,
      cover: item.cover,
      characterLevel: item.characterLevel,
      zeroCount: item.zeroCount,
      starForces: item.starForces,
      refine: item.refine,
    );
  }

  /// 回显已选角色
  ///
  /// [characterId] 角色 ID
  Future<void> _restoreCharacterOption(int? characterId) async {
    if (characterId == null || characterId <= 0) {
      return;
    }

    final items = await searchCharacters(characterId.toString());
    for (final item in items) {
      _characterOptions[item.characterId] = item;
    }
  }

  /// 刷新 bot 操作日志
  Future<void> refreshLogs() async {
    final config = _config;
    if (_isDisposed || _isLoadingLogs || config == null) {
      return;
    }

    _isLoadingLogs = true;
    _logErrorMessage = null;
    _notifyIfActive();

    try {
      _logs = await _repository.fetchLogs(
        token: await _ensureToken(),
        userId: config.userId,
      );
      _logErrorMessage = null;
    } catch (error) {
      _logs = const <BotLogEntry>[];
      _logErrorMessage = resolveUserErrorMessage(
        error,
        fallback: '获取 Bot 日志失败，请稍后重试',
      );
    } finally {
      _isLoadingLogs = false;
      _notifyIfActive();
    }
  }

  /// 在控制器未释放时通知页面
  void _notifyIfActive() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
