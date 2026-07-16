import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/network/tinygrail_page.dart';
import 'package:magrail_app/core/storage/app_preferences.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/features/bangumi/next/repository/next_bangumi_repository.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_basic_info.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_board_member.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_history_item.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_info.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_user_assets.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_user_character.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/user/model/user_assets_fetch_result.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

part 'character_detail_controller_refresh.dart';
part 'character_detail_controller_history.dart';
part 'character_detail_controller_user_assets.dart';

/// 角色详情页状态控制器
class CharacterDetailController extends ChangeNotifier {
  /// 创建角色详情页状态控制器
  ///
  /// [preferences] 本地偏好设置
  /// [initialCharacterId] 初始角色 ID
  /// [initialName] 初始角色名称
  /// [initialAvatarUrl] 初始角色头像地址
  /// [initialAvatarHeroTag] 初始入口头像转场标识
  /// [repository] 角色详情仓库
  /// [userRepository] 用户仓库
  CharacterDetailController({
    required AppPreferences preferences,
    required CharacterDetailRepository repository,
    required UserRepository userRepository,
    required int? initialCharacterId,
    String? initialName,
    String? initialAvatarUrl,
    String? initialAvatarHeroTag,
  })  : _preferences = preferences,
        _repository = repository,
        _userRepository = userRepository,
        _initialCharacterId = initialCharacterId,
        _initialName = initialName ?? '',
        _initialAvatarUrl = initialAvatarUrl ?? '',
        _initialAvatarHeroTag = initialAvatarHeroTag ?? '';

  // 历史头像切换只保留最近十个
  static const int _maxHistoryItems = 10;

  final AppPreferences _preferences;
  final CharacterDetailRepository _repository;
  final UserRepository _userRepository;
  final NextBangumiRepository _bangumiRepository = NextBangumiRepository();
  final int? _initialCharacterId;
  final String _initialName;
  final String _initialAvatarUrl;
  final String _initialAvatarHeroTag;
  UserDetailProfile? _currentUser;

  CharacterDetailHistoryItem? _current;
  List<CharacterDetailHistoryItem> _history =
      const <CharacterDetailHistoryItem>[];
  final Map<int, CharacterDetailPageType> _pageTypes =
      <int, CharacterDetailPageType>{};
  // 已上市头部只保存可直接展示的数据，补充接口未完成前不写入
  final Map<int, CharacterDetailTradeHeader> _tradeHeaders =
      <int, CharacterDetailTradeHeader>{};
  // ICO 头部只保存进行中页面的接口直出数据
  final Map<int, CharacterDetailIcoInfo> _icoInfos =
      <int, CharacterDetailIcoInfo>{};
  final Map<int, CharacterDetailUserAssets> _userAssets =
      <int, CharacterDetailUserAssets>{};
  String? _currentAvatarHeroTag;
  final Set<int> _refreshingCharacterIds = <int>{};
  // 操作后的强制刷新会提升代次，避免旧请求返回后覆盖角色状态
  final Map<int, int> _refreshGenerations = <int, int>{};
  bool _isDisposed = false;
  bool _isResolvingCurrentUser = false;
  bool _hasResolvedCurrentUser = false;

  /// 当前角色资料
  CharacterDetailHistoryItem? get current => _current;

  /// 角色打开历史
  List<CharacterDetailHistoryItem> get history => _history;

  /// 当前角色入口头像转场标识
  String? get currentAvatarHeroTag => _currentAvatarHeroTag;

  /// 当前角色对应的页面类型
  CharacterDetailPageType? get currentPageType {
    final current = _current;
    if (current == null) {
      return null;
    }

    return _pageTypes[current.characterId] ?? CharacterDetailPageType.pending;
  }

  /// 当前角色已上市头部完整资料
  CharacterDetailTradeHeader? get currentTradeHeader {
    final current = _current;
    if (current == null) {
      return null;
    }

    return _tradeHeaders[current.characterId];
  }

  /// 当前角色 ICO 头部完整资料
  CharacterDetailIcoInfo? get currentIcoInfo {
    final current = _current;
    if (current == null) {
      return null;
    }

    return _icoInfos[current.characterId];
  }

  /// 当前用户在当前角色上的资产状态
  CharacterDetailUserAssets get currentUserAssets {
    final current = _current;
    final currentUser = _currentUser;
    if (current == null) {
      return const CharacterDetailUserAssets.signedOut();
    }

    if (_isResolvingCurrentUser && !_hasResolvedCurrentUser) {
      return const CharacterDetailUserAssets.loading();
    }

    if (currentUser == null || currentUser.name.trim().isEmpty) {
      return const CharacterDetailUserAssets.signedOut();
    }

    return _userAssets[current.characterId] ??
        const CharacterDetailUserAssets.loading();
  }

  /// 是否存在有效当前角色
  bool get hasValidCharacter => _current != null;

  /// 当前用户是否为 GM
  bool get isGameMaster => _currentUser?.isGameMaster ?? false;

  /// 当前已验证的登录用户
  UserDetailProfile? get currentUser => _currentUser;

  /// 当前 Tinygrail 会话是否已验证完成
  bool get hasResolvedCurrentUser => _hasResolvedCurrentUser;

  /// 当前 Tinygrail 会话是否可用
  bool get isAuthorized => currentUser != null;

  /// 静默刷新当前角色资料
  Future<void> refreshCurrentCharacter() async {
    final characterId = _current?.characterId;
    if (characterId == null || characterId <= 0) {
      return;
    }

    await _refreshCharacterInfo(characterId, force: true);
  }

  /// 重试加载当前用户在当前角色上的资产
  Future<void> retryCurrentUserAssets() async {
    final characterId = _current?.characterId;
    if (characterId == null || characterId <= 0) {
      return;
    }

    if (_currentUser == null) {
      await refreshCurrentUserSession();
      return;
    }

    await _CharacterDetailControllerUserAssets(this)._refreshCurrentUserAssets(
      characterId,
      refreshGeneration: _refreshGenerations[characterId],
    );
  }

  /// 重新验证当前 Tinygrail 用户会话
  Future<void> refreshCurrentUserSession() async {
    await _resolveCurrentUser(refreshCurrentCharacter: true);
  }

  /// 释放角色详情页状态控制器
  @override
  void dispose() {
    _isDisposed = true;
    _bangumiRepository.close();
    super.dispose();
  }

  /// 初始化角色详情历史与当前角色
  void initialize() {
    _history = _CharacterDetailControllerHistory(this)._readHistory();
    final characterId = _initialCharacterId;
    if (characterId == null || characterId <= 0) {
      return;
    }

    _openCharacter(
      CharacterDetailHistoryItem(
        characterId: characterId,
        name: _initialName.trim(),
        avatarUrl: _initialAvatarUrl.trim(),
      ),
      avatarHeroTag: _initialAvatarHeroTag,
      notify: false,
    );

    unawaited(_resolveCurrentUser(refreshCurrentCharacter: true));
  }

  /// 刷新当前登录用户并按需刷新当前角色
  ///
  /// [refreshCurrentCharacter] 是否在用户状态变化后刷新当前角色
  Future<void> _resolveCurrentUser({
    required bool refreshCurrentCharacter,
  }) async {
    if (_isDisposed || _isResolvingCurrentUser) {
      return;
    }

    _isResolvingCurrentUser = true;
    _notifyIfActive();

    final previousUserId = _currentUser?.userId;
    var hasCookie = false;
    try {
      hasCookie = await _userRepository.hasCurrentUserSessionCookie();
    } catch (_) {
      hasCookie = false;
    }
    if (_isDisposed) {
      return;
    }

    if (!hasCookie) {
      await _userRepository.clearCurrentUserAssetsCache();
      if (_isDisposed) {
        return;
      }

      _currentUser = null;
      _CharacterDetailControllerUserAssets(this)._clearCurrentUserAssets();
    } else {
      final result = await _userRepository.fetchUserAssets();
      if (_isDisposed) {
        return;
      }

      if (result.status == UserAssetsFetchStatus.success &&
          result.profile != null) {
        _currentUser = result.profile;
      } else {
        _currentUser = null;
        _CharacterDetailControllerUserAssets(this)._clearCurrentUserAssets();
      }
    }

    _hasResolvedCurrentUser = true;
    _isResolvingCurrentUser = false;

    final currentCharacterId = _current?.characterId;
    final nextUserId = _currentUser?.userId;
    if (refreshCurrentCharacter &&
        currentCharacterId != null &&
        currentCharacterId > 0 &&
        previousUserId != nextUserId) {
      _notifyIfActive();
      await _refreshCharacterInfo(currentCharacterId, force: true);
      return;
    }

    _notifyIfActive();
  }

  /// 切换到历史角色
  ///
  /// [item] 目标历史角色
  void selectHistoryItem(CharacterDetailHistoryItem item) {
    _openCharacter(item);
  }

  /// 合并当前角色入口提供的非空历史字段
  ///
  /// [item] 当前角色入口提供的角色资料
  void mergeCurrentHistoryItem(CharacterDetailHistoryItem item) {
    final current = _current;
    if (current == null || current.characterId != item.characterId) {
      return;
    }

    final mergedItem = item.mergeWith(current);
    if (mergedItem.name == current.name &&
        mergedItem.avatarUrl == current.avatarUrl) {
      return;
    }

    _current = mergedItem;
    _history = List<CharacterDetailHistoryItem>.unmodifiable(
      _history.map(
        (historyItem) => historyItem.characterId == item.characterId
            ? mergedItem
            : historyItem,
      ),
    );
    _CharacterDetailControllerHistory(this)._persistHistory();
    _notifyIfActive();
  }

  /// 投票删除当前角色
  ///
  /// [reason] 删除理由
  Future<String> voteKillCurrentCharacter({required String reason}) async {
    final header = currentTradeHeader;
    if (header == null) {
      throw StateError('缺少可投票的角色');
    }

    final message = await _repository.voteKillCharacter(
      characterId: header.characterId,
      reason: reason,
    );
    await _refreshCharacterInfo(header.characterId, force: true);

    return message;
  }

  /// 撤回当前角色删除投票
  Future<String> revokeCurrentKillVote() async {
    final header = currentTradeHeader;
    if (header == null) {
      throw StateError('缺少可撤回投票的角色');
    }

    final message = await _repository.revokeKillVote(header.characterId);
    await _refreshCharacterInfo(header.characterId, force: true);

    return message;
  }

  /// 打开角色并写入最近历史
  ///
  /// [item] 入口提供的角色资料
  /// [avatarHeroTag] 入口头像转场标识
  /// [notify] 是否通知页面刷新
  void _openCharacter(
    CharacterDetailHistoryItem item, {
    String? avatarHeroTag,
    bool notify = true,
  }) {
    if (item.characterId <= 0) {
      return;
    }

    CharacterDetailHistoryItem? cached;
    final nextHistory = <CharacterDetailHistoryItem>[];
    for (final historyItem in _history) {
      if (historyItem.characterId == item.characterId) {
        cached = historyItem;
        continue;
      }
      nextHistory.add(historyItem);
    }

    final resolvedItem = item.mergeWith(cached);
    _current = resolvedItem;
    final resolvedAvatarHeroTag = avatarHeroTag?.trim() ?? '';
    _currentAvatarHeroTag =
        resolvedItem.hasAvatar && resolvedAvatarHeroTag.isNotEmpty
            ? resolvedAvatarHeroTag
            : null;
    // 每次打开角色都等待当前请求完成，避免旧头部与新头部切换造成宽度抖动
    _pageTypes[item.characterId] = CharacterDetailPageType.pending;
    _tradeHeaders.remove(item.characterId);
    _icoInfos.remove(item.characterId);
    _userAssets.remove(item.characterId);
    _history = List<CharacterDetailHistoryItem>.unmodifiable(
      <CharacterDetailHistoryItem>[
        resolvedItem,
        ...nextHistory,
      ].take(_maxHistoryItems),
    );
    final historyIds =
        _history.map((historyItem) => historyItem.characterId).toSet();
    _pageTypes.removeWhere(
      (characterId, _) => !historyIds.contains(characterId),
    );
    _tradeHeaders.removeWhere(
      (characterId, _) => !historyIds.contains(characterId),
    );
    _icoInfos.removeWhere(
      (characterId, _) => !historyIds.contains(characterId),
    );
    _userAssets.removeWhere(
      (characterId, _) => !historyIds.contains(characterId),
    );
    _CharacterDetailControllerHistory(this)._persistHistory();

    if (notify) {
      _notifyIfActive();
    }

    unawaited(_refreshCharacterInfo(item.characterId));
  }

  /// 静默刷新角色详情基础资料
  ///
  /// [characterId] 角色 ID
  /// [force] 是否允许操作后的刷新压过正在进行的旧刷新
  Future<void> _refreshCharacterInfo(
    int characterId, {
    bool force = false,
  }) async {
    if (characterId <= 0) {
      return;
    }

    if (_refreshingCharacterIds.contains(characterId) && !force) {
      return;
    }

    final generation = _CharacterDetailControllerRefresh(this)
        ._nextRefreshGeneration(characterId);
    _refreshingCharacterIds.add(characterId);
    try {
      final info = await _repository.fetchCharacterBasicInfo(characterId);
      if (_isDisposed ||
          !_CharacterDetailControllerRefresh(this)
              ._isLatestCharacterRefresh(characterId, generation)) {
        return;
      }

      final name = TinygrailFormatters.decodeHtmlEntities(info.name).trim();
      final icon = info.icon.trim();
      // 小圣杯未返回头像时保留入口或 BGM 补全头像
      final avatarUrl =
          icon.isEmpty ? '' : TinygrailAssetUrls.normalizeAvatar(icon);
      final icoInfo = info.icoInfo;

      _CharacterDetailControllerHistory(this)._updateCharacterInfo(
        CharacterDetailHistoryItem(
          characterId: characterId,
          name: name,
          avatarUrl: avatarUrl,
        ),
        pageType: info.pageType,
        icoInfo: icoInfo,
      );

      if (info.pageType == CharacterDetailPageType.initial) {
        unawaited(
          _refreshInitialBangumiCharacterInfo(
            characterId,
            refreshGeneration: generation,
          ),
        );
      }

      final tradeHeader = info.tradeHeader;
      if (tradeHeader != null) {
        unawaited(
          _CharacterDetailControllerUserAssets(this)._refreshCurrentUserAssets(
            characterId,
            refreshGeneration: generation,
          ),
        );
        await _CharacterDetailControllerRefresh(this)
            ._refreshTradeHeaderSupplementalStats(
          characterId,
          tradeHeader,
          refreshGeneration: generation,
        );
      }
    } catch (_) {
      if (_isDisposed ||
          !_CharacterDetailControllerRefresh(this)
              ._isLatestCharacterRefresh(characterId, generation)) {
        return;
      }

      final hasHistoryItem = _history.any(
        (item) => item.characterId == characterId,
      );
      if (!hasHistoryItem) {
        return;
      }

      // 角色详情请求失败显示失败状态
      _pageTypes[characterId] = CharacterDetailPageType.failure;
      _tradeHeaders.remove(characterId);
      _icoInfos.remove(characterId);
      _userAssets.remove(characterId);
      if (_current?.characterId == characterId) {
        _notifyIfActive();
      }
    } finally {
      if (_CharacterDetailControllerRefresh(this)
          ._isLatestCharacterRefresh(characterId, generation)) {
        _refreshingCharacterIds.remove(characterId);
      }
    }
  }

  /// 静默刷新启动 ICO 页面的 Bangumi 展示资料
  ///
  /// [characterId] 角色 ID
  /// [refreshGeneration] 当前角色刷新代次
  Future<void> _refreshInitialBangumiCharacterInfo(
    int characterId, {
    required int refreshGeneration,
  }) async {
    if (characterId <= 0) {
      return;
    }

    try {
      final character = await _bangumiRepository.fetchCharacter(characterId);
      if (_isDisposed ||
          !_CharacterDetailControllerRefresh(this)._isLatestCharacterRefresh(
            characterId,
            refreshGeneration,
          )) {
        return;
      }

      if (_pageTypes[characterId] != CharacterDetailPageType.initial) {
        return;
      }

      final rawName = character.nameCn.trim().isNotEmpty
          ? character.nameCn
          : character.name;
      final name = TinygrailFormatters.decodeHtmlEntities(rawName).trim();
      final rawAvatarUrl = character.avatarUrl.trim();
      final avatarUrl = rawAvatarUrl.isEmpty
          ? ''
          : TinygrailAssetUrls.normalizeAvatar(rawAvatarUrl);
      if (name.isEmpty && avatarUrl.isEmpty) {
        return;
      }

      _CharacterDetailControllerHistory(this)._updateCharacterInfo(
        CharacterDetailHistoryItem(
          characterId: characterId,
          name: name,
          avatarUrl: avatarUrl,
        ),
        pageType: CharacterDetailPageType.initial,
      );
    } catch (_) {
      // BGM 补充资料失败时保持启动 ICO 页面的原始展示
    }
  }

  /// 通知仍处于活动状态的页面刷新
  void _notifyIfActive() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }
}
