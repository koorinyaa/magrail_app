import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/core/widgets/pagination_footer.dart';
import 'package:magrail_app/core/widgets/temple_card.dart';
import 'package:magrail_app/features/bangumi/next/next_bangumi_subject_navigation.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_character_search_item.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_subject_search_item.dart';
import 'package:magrail_app/features/bangumi/next/repository/next_bangumi_repository.dart';
import 'package:magrail_app/features/bangumi/next/widgets/next_bangumi_subject_search_row.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_basic_info.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_search_item.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_dialog.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'character_search_page_route.dart';
part 'character_search_page_widgets.dart';
part 'character_search_page_bangumi_logic.dart';
part 'character_search_page_bangumi_subject_logic.dart';
part 'character_search_page_bangumi_widgets.dart';

const Duration _characterSearchDebounceDelay = Duration(milliseconds: 450);
const int _bangumiSearchPageSize = 20;
// 底部控件包含来源切换器和搜索框，列表需要预留防遮挡空间
const double _characterSearchBottomContentPadding = 128;
// 角色搜索页在同一个导航栈内只保留一个实例
PageRoute<void>? _activeCharacterSearchRoute;

/// 角色搜索来源
enum _CharacterSearchSource {
  /// 小圣杯角色搜索
  tinygrail,

  /// Bangumi 角色搜索
  bangumi,

  /// Bangumi 条目搜索
  bangumiSubject,
}

/// 显示角色搜索页
///
/// 已存在角色搜索页时置顶已有页面
/// 未授权时只弹出提示，不打开搜索页
///
/// [context] 当前组件树上下文
/// [repository] 角色详情仓库
/// [templeRepository] 圣殿仓库
/// [magicRepository] 圣殿资产魔法道具仓库
/// [oosRepository] Tinygrail OOS 仓库
/// [userRepository] 用户仓库
Future<void> showCharacterSearchPage(
  BuildContext context, {
  required CharacterDetailRepository repository,
  required TempleRepository templeRepository,
  required TempleAssetMagicRepository magicRepository,
  required TinygrailOosRepository oosRepository,
  required UserRepository userRepository,
}) {
  final currentUsername =
      userRepository.readCachedCurrentUserAssets()?.name.trim() ?? '';
  if (currentUsername.isEmpty) {
    AppToast.error(context, text: '该功能需要授权后才能使用');
    return Future<void>.value();
  }

  final navigator = Navigator.of(context);
  final activeRoute = _activeCharacterSearchRoute;
  if (activeRoute != null && activeRoute.navigator == navigator) {
    navigator.popUntil((route) => identical(route, activeRoute));
    return activeRoute.popped.then<void>((_) {});
  }

  final route = PageRouteBuilder<void>(
    opaque: false,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _CharacterSearchRoutePage(
        repository: repository,
        templeRepository: templeRepository,
        magicRepository: magicRepository,
        oosRepository: oosRepository,
        userRepository: userRepository,
        animation: animation,
      );
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
  _activeCharacterSearchRoute = route;
  return navigator.push<void>(route).whenComplete(() {
    if (identical(_activeCharacterSearchRoute, route)) {
      _activeCharacterSearchRoute = null;
    }
  });
}

/// 角色搜索页
class CharacterSearchPage extends StatefulWidget {
  /// 创建角色搜索页
  ///
  /// [key] Flutter 组件标识
  /// [repository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  /// [onClose] 搜索页关闭回调
  const CharacterSearchPage({
    super.key,
    required this.repository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
    required this.onClose,
  });

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// 圣殿仓库
  final TempleRepository templeRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository magicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 搜索页关闭回调
  final VoidCallback onClose;

  /// 创建角色搜索页状态
  @override
  State<CharacterSearchPage> createState() => _CharacterSearchPageState();
}

/// 角色搜索页状态
class _CharacterSearchPageState extends State<CharacterSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final NextBangumiRepository _bangumiRepository = NextBangumiRepository();

  Timer? _searchDebounce;
  var _searchSource = _CharacterSearchSource.tinygrail;
  var _requestId = 0;
  var _lastSearchText = '';
  var _isSearching = false;
  var _isSearchingTemples = false;
  var _hasSearched = false;
  var _hasSearchedTemples = false;
  var _errorMessage = '';
  var _templeErrorMessage = '';
  List<CharacterDetailSearchItem> _results =
      const <CharacterDetailSearchItem>[];
  List<UserTempleApiItem> _templeResults = const <UserTempleApiItem>[];
  List<NextBangumiCharacterSearchItem> _bangumiResults =
      const <NextBangumiCharacterSearchItem>[];
  List<NextBangumiSubjectSearchItem> _bangumiSubjectResults =
      const <NextBangumiSubjectSearchItem>[];
  Map<int, CharacterDetailBasicInfo> _bangumiStatuses =
      const <int, CharacterDetailBasicInfo>{};
  // BGM 搜索分页状态按接口原始 offset 推进
  var _bangumiNextOffset = 0;
  var _bangumiCanLoadMore = false;
  var _isBangumiLoadingMore = false;
  var _bangumiLoadMoreError = '';
  int? _bangumiLastPreloadItemCount;
  var _bangumiSubjectNextOffset = 0;
  var _bangumiSubjectCanLoadMore = false;
  var _isBangumiSubjectLoadingMore = false;
  var _bangumiSubjectLoadMoreError = '';
  int? _bangumiSubjectLastPreloadItemCount;

  /// 初始化角色搜索页状态
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchTextChanged);
    unawaited(_searchNow());
  }

  /// 释放角色搜索页状态
  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController
      ..removeListener(_handleSearchTextChanged)
      ..dispose();
    _scrollController.dispose();
    _bangumiRepository.close();
    super.dispose();
  }

  /// 构建角色搜索页
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerLowest;
    final bottomInset = mediaQuery.viewInsets.bottom > 0
        ? mediaQuery.viewInsets.bottom
        : mediaQuery.padding.bottom;

    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor),
      child: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: Padding(
          padding: AppSafeAreaInsets.fromLTRB(
            context,
            left: 20,
            top: 12,
            right: 20,
            bottom: 0,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildSearchContent(context),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: bottomInset + 14,
                child: _buildSearchField(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建角色搜索内容
  ///
  /// [context] 当前组件树上下文
  Widget _buildSearchContent(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: _buildResultState(context),
    );
  }

  /// 构建搜索结果状态
  ///
  /// [context] 当前组件树上下文
  Widget _buildResultState(BuildContext context) {
    final hasResults = _hasVisibleResults;
    final isLoadingBangumiMore =
        _searchSource == _CharacterSearchSource.bangumi &&
            _isBangumiLoadingMore;
    final isLoadingBangumiSubjectMore =
        _searchSource == _CharacterSearchSource.bangumiSubject &&
            _isBangumiSubjectLoadingMore;
    if ((_isSearching ||
            _isSearchingTemples ||
            isLoadingBangumiMore ||
            isLoadingBangumiSubjectMore) &&
        !hasResults) {
      if (_searchSource == _CharacterSearchSource.bangumiSubject) {
        return const _BangumiSubjectSearchSkeletonList();
      }

      return const _CharacterSearchSkeletonList();
    }

    if (_errorMessage.isNotEmpty && !hasResults) {
      return AppLoadFailedState(
        message: _errorMessage,
        onActionPressed: _retrySearch,
      );
    }

    if (!hasResults && _hasSearchedTemples && _errorMessage.isEmpty) {
      return _buildResultList(context);
    }

    if (!hasResults &&
        _searchSource == _CharacterSearchSource.bangumi &&
        _errorMessage.isEmpty) {
      return _buildResultList(context);
    }

    if (!hasResults &&
        _searchSource == _CharacterSearchSource.bangumiSubject &&
        _errorMessage.isEmpty) {
      return _buildResultList(context);
    }

    if (!hasResults) {
      final text = _searchSource == _CharacterSearchSource.tinygrail &&
              !_hasSearched &&
              _searchController.text.trim().isEmpty
          ? '输入角色 ID 或名称开始搜索'
          : '未找到相关角色';
      return _CharacterSearchEmptyText(text: text);
    }

    return _buildResultList(context);
  }

  /// 构建搜索结果列表
  ///
  /// [context] 当前组件树上下文
  Widget _buildResultList(BuildContext context) {
    if (_searchSource == _CharacterSearchSource.bangumi) {
      return _buildBangumiResultList(context);
    }

    if (_searchSource == _CharacterSearchSource.bangumiSubject) {
      return _buildBangumiSubjectResultList(context);
    }

    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom > 0
        ? mediaQuery.viewInsets.bottom
        : mediaQuery.padding.bottom;

    return ListView(
      controller: _scrollController,
      primary: false,
      padding: EdgeInsets.only(
        bottom: bottomInset + _characterSearchBottomContentPadding,
      ),
      children: [
        if (_templeResults.isNotEmpty || _templeErrorMessage.isNotEmpty) ...[
          const _CharacterSearchSectionLabel(text: '圣殿'),
          if (_templeErrorMessage.isNotEmpty)
            _CharacterSearchInlineWarning(text: _templeErrorMessage)
          else
            _CharacterSearchTempleResultList(
              items: _templeResults,
              ownerLabel: _cachedCurrentUserDisplayName,
              onTap: _selectTemple,
            ),
          const SizedBox(height: 14),
        ],
        const _CharacterSearchSectionLabel(text: '角色'),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CharacterSearchInlineWarning(text: _errorMessage),
          )
        else if (_results.isEmpty)
          const _CharacterSearchEmptyText(text: '未找到相关角色')
        else
          for (var index = 0; index < _results.length; index += 1) ...[
            if (index > 0) const _CharacterSearchDivider(),
            Builder(
              builder: (context) {
                final item = _results[index];
                final avatarHeroTag = createCharacterDetailAvatarHeroTag(
                  characterId: item.characterId,
                  avatarUrl: item.icon,
                  source: item,
                );

                return _CharacterSearchRow(
                  item: item,
                  avatarHeroTag: avatarHeroTag,
                  onTap: () => _selectCharacter(item, avatarHeroTag),
                );
              },
            ),
          ],
      ],
    );
  }

  /// 构建搜索输入框
  ///
  /// [context] 当前组件树上下文
  Widget _buildSearchField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const searchFieldHeight = 44.0;

    return TextFieldTapRegion(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CharacterSearchSourceSegmentedControl(
            value: _searchSource,
            onChanged: _handleSearchSourceChanged,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GlassTextField.search(
                  controller: _searchController,
                  autofocus: true,
                  placeholder: _searchPlaceholder,
                  prefixIcon: Icon(
                    LucideIcons.search,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onSubmitted: (_) => _searchNow(),
                  height: searchFieldHeight,
                  useOwnLayer: true,
                  quality: GlassQuality.minimal,
                  interactionBehavior: GlassInteractionBehavior.glowOnly,
                  textStyle: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  placeholderStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _CharacterSearchCloseButton(
                size: searchFieldHeight,
                onPressed: widget.onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 处理搜索输入变化
  void _handleSearchTextChanged() {
    final searchText = _searchController.text;
    if (searchText == _lastSearchText) {
      return;
    }

    _lastSearchText = searchText;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_characterSearchDebounceDelay, _searchNow);
  }

  /// 立即执行当前搜索
  Future<void> _searchNow() async {
    _searchDebounce?.cancel();
    return switch (_searchSource) {
      _CharacterSearchSource.tinygrail => _searchTinygrailNow(),
      _CharacterSearchSource.bangumi => _searchBangumiNow(),
      _CharacterSearchSource.bangumiSubject => _searchBangumiSubjectNow(),
    };
  }

  /// 更新搜索页状态
  ///
  /// [callback] 状态更新回调
  void _updateSearchState(VoidCallback callback) {
    setState(callback);
  }

  /// 重试当前搜索
  Future<void> _retrySearch() {
    return _searchNow();
  }

  /// 选择搜索结果角色
  ///
  /// [item] 搜索结果角色
  void _selectCharacter(
    CharacterDetailSearchItem item,
    String? avatarHeroTag,
  ) {
    if (item.characterId <= 0) {
      return;
    }

    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.name,
      avatarUrl: item.icon,
      avatarHeroTag: avatarHeroTag,
    );
  }

  /// 选择圣殿搜索结果
  ///
  /// [item] 用户圣殿条目
  void _selectTemple(UserTempleApiItem item) {
    if (item.characterId <= 0) {
      return;
    }

    final currentUser = widget.userRepository.readCachedCurrentUserAssets();
    unawaited(
      showTempleAssetCardDialogFromSource(
        context,
        source: TempleAssetDialogSource(
          ownerName: currentUser?.name ?? '',
          ownerNickname: currentUser?.nickname ?? '',
          characterId: item.characterId,
        ),
        characterRepository: widget.repository,
        templeRepository: widget.templeRepository,
        magicRepository: widget.magicRepository,
        oosRepository: widget.oosRepository,
        userRepository: widget.userRepository,
        currentUserName: currentUser?.name ?? '',
      ),
    );
  }

  /// 选择 Bangumi 条目搜索结果
  ///
  /// [item] Bangumi 条目搜索结果
  void _selectBangumiSubject(NextBangumiSubjectSearchItem item) {
    openNextBangumiSubjectFromSearchItem(context, item);
  }

  /// 当前来源搜索框占位文案
  String get _searchPlaceholder {
    return switch (_searchSource) {
      _CharacterSearchSource.tinygrail => '搜索小圣杯角色（角色ID或名称）',
      _CharacterSearchSource.bangumi => '搜索bgm角色',
      _CharacterSearchSource.bangumiSubject => '搜索bgm条目',
    };
  }

  /// 当前用户缓存用户名
  String get _cachedCurrentUserName {
    return widget.userRepository.readCachedCurrentUserAssets()?.name.trim() ??
        '';
  }

  /// 当前用户缓存展示名
  String get _cachedCurrentUserDisplayName {
    final cachedUser = widget.userRepository.readCachedCurrentUserAssets();
    final nickname = cachedUser?.nickname.trim() ?? '';
    if (nickname.isNotEmpty) {
      return '@$nickname';
    }

    final name = cachedUser?.name.trim() ?? '';
    return name.isEmpty ? '' : '@$name';
  }
}

/// 解析角色搜索错误文案
///
/// [error] 原始错误
/// [fallback] 无法解析时的兜底文案
String _messageForError(
  Object error, {
  String fallback = '搜索角色失败',
}) {
  return resolveUserErrorMessage(error, fallback: fallback);
}
