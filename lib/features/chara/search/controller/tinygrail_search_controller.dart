import 'package:flutter/foundation.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_search_item.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/search/model/tinygrail_search_keyword.dart';
import 'package:magrail_app/features/user/model/user_detail_profile.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 小圣杯角色、用户与圣殿搜索状态
class TinygrailSearchController extends ChangeNotifier {
  /// 创建小圣杯搜索控制器
  ///
  /// [characterRepository] 角色详情仓库
  /// [userRepository] 用户仓库
  TinygrailSearchController({
    required this._characterRepository,
    required this._userRepository,
  });

  final CharacterDetailRepository _characterRepository;
  final UserRepository _userRepository;
  // 输入变化、来源切换和页面关闭后，旧请求不再发布结果
  var _requestId = 0;
  var _disposed = false;
  var _searchKeyword = const TinygrailSearchKeyword(
    keyword: '',
    scope: TinygrailSearchScope.all,
  );
  var _isSearching = false;
  var _hasSearched = false;
  var _characterError = '';
  var _templeError = '';
  var _userError = '';
  List<CharacterDetailSearchItem> _characters = const [];
  List<UserTempleApiItem> _temples = const [];
  UserDetailProfile? _user;

  /// 是否正在等待当前搜索请求
  bool get isSearching => _isSearching;

  /// 当前输入提取后的关键词与查询范围
  TinygrailSearchKeyword get searchKeyword => _searchKeyword;

  /// 是否完成当前关键词搜索
  bool get hasSearched => _hasSearched;

  /// 角色搜索失败文案
  String get characterError => _characterError;

  /// 圣殿搜索失败文案
  String get templeError => _templeError;

  /// 用户查询失败文案
  String get userError => _userError;

  /// 角色搜索结果
  List<CharacterDetailSearchItem> get characters => _characters;

  /// 当前用户的圣殿搜索结果
  List<UserTempleApiItem> get temples => _temples;

  /// 精确匹配的用户资料
  UserDetailProfile? get user => _user;

  /// 是否存在可展示的搜索结果
  bool get hasResults =>
      _characters.isNotEmpty || _temples.isNotEmpty || _user != null;

  /// 按关键词范围查询角色、用户与当前用户圣殿
  ///
  /// [rawKeyword] 搜索框关键词，空值仅查询默认角色列表
  /// [currentUsername] 当前用户 BGM ID，用于查询自己的圣殿
  Future<void> search({
    required String rawKeyword,
    required String currentUsername,
  }) async {
    reset(rawKeyword: rawKeyword);
    final requestId = _requestId;
    final searchKeyword = _searchKeyword;
    final keyword = searchKeyword.keyword;
    _isSearching = true;
    notifyListeners();

    // 每个请求立即接入异常处理，避免并发请求提前失败时产生未处理异常
    await Future.wait<void>([
      if (searchKeyword.searchCharacters) _searchCharacters(requestId, keyword),
      if (searchKeyword.searchCharacters &&
          keyword.isNotEmpty &&
          currentUsername.isNotEmpty)
        _searchTemples(requestId, keyword, currentUsername),
      if (searchKeyword.searchUsers && keyword.isNotEmpty)
        _searchUser(requestId, keyword),
    ]);
    if (!_isCurrent(requestId)) {
      return;
    }

    _isSearching = false;
    _hasSearched = true;
    notifyListeners();
  }

  /// 清空结果并使在途请求失效
  ///
  /// [rawKeyword] 新的搜索框输入，用于同步当前查询范围
  void reset({String rawKeyword = ''}) {
    _requestId += 1;
    _searchKeyword = TinygrailSearchKeyword.parse(rawKeyword);
    _isSearching = false;
    _hasSearched = false;
    _characterError = '';
    _templeError = '';
    _userError = '';
    _characters = const [];
    _temples = const [];
    _user = null;
    notifyListeners();
  }

  /// 释放搜索状态并阻止旧请求发布结果
  @override
  void dispose() {
    _disposed = true;
    _requestId += 1;
    super.dispose();
  }

  /// 查询角色并记录当前请求的失败状态
  ///
  /// [requestId] 搜索任务代际
  /// [keyword] 角色 ID 或名称
  Future<void> _searchCharacters(int requestId, String keyword) async {
    try {
      final items = await _characterRepository.searchCharacters(
        keyword,
        allowEmptyKeyword: true,
      );
      if (_isCurrent(requestId)) {
        _characters = items;
      }
    } catch (error) {
      if (_isCurrent(requestId)) {
        _characterError = resolveUserErrorMessage(error, fallback: '搜索角色失败');
      }
    }
  }

  /// 查询当前用户圣殿并记录当前请求的失败状态
  ///
  /// [requestId] 搜索任务代际
  /// [keyword] 角色 ID 或名称
  /// [username] 当前用户 BGM ID
  Future<void> _searchTemples(
    int requestId,
    String keyword,
    String username,
  ) async {
    try {
      final page = await _userRepository.fetchUserTemplePage(
        username: username,
        keyword: keyword,
        pageSize: 12,
      );
      if (_isCurrent(requestId)) {
        _temples = page.items;
      }
    } catch (error) {
      if (_isCurrent(requestId)) {
        _templeError = resolveUserErrorMessage(error, fallback: '搜索圣殿失败');
      }
    }
  }

  /// 精确查询用户并记录当前请求的失败状态
  ///
  /// [requestId] 搜索任务代际
  /// [username] BGM ID
  Future<void> _searchUser(int requestId, String username) async {
    try {
      final profile = await _userRepository.findUserProfile(username: username);
      if (_isCurrent(requestId)) {
        _user = profile;
      }
    } catch (error) {
      if (_isCurrent(requestId)) {
        _userError = resolveUserErrorMessage(error, fallback: '查询用户失败');
      }
    }
  }

  /// 判断搜索结果是否仍属于当前任务
  ///
  /// [requestId] 搜索任务代际
  bool _isCurrent(int requestId) => !_disposed && requestId == _requestId;
}
