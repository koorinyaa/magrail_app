import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/viewer/fullscreen_image_viewer_page.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/core/widgets/page_section_sliver.dart';
import 'package:magrail_app/core/widgets/pagination_footer_sliver.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_subject_character.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_subject.dart';
import 'package:magrail_app/features/bangumi/next/repository/next_bangumi_repository.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_basic_info.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/search/view/character_search_page.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'next_bangumi_subject_page_widgets.dart';
part 'next_bangumi_subject_page_states.dart';
part 'next_bangumi_subject_page_characters.dart';

/// Next Bangumi 条目二级页面
class NextBangumiSubjectPage extends StatefulWidget {
  /// 创建 Next Bangumi 条目二级页面
  ///
  /// [key] Flutter 组件标识
  /// [subjectId] 条目 ID
  /// [characterRepository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  const NextBangumiSubjectPage({
    super.key,
    required this.subjectId,
    required this.characterRepository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
  });

  /// 条目 ID
  final int subjectId;

  /// 角色详情仓库
  final CharacterDetailRepository characterRepository;

  /// 圣殿仓库
  final TempleRepository templeRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository magicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 创建 Next Bangumi 条目二级页面状态
  @override
  State<NextBangumiSubjectPage> createState() => _NextBangumiSubjectPageState();
}

/// Next Bangumi 条目二级页面状态
class _NextBangumiSubjectPageState extends State<NextBangumiSubjectPage> {
  static const double _topToolbarHeight = 48;
  static const double _topActionBlurExtent = 72;
  static const double _topTitleStartOffset = 156;
  static const double _topTitleFadeExtent = 32;
  static const int _subjectCharacterPageSize = 20;

  late final NextBangumiRepository _repository;
  late final ScrollController _scrollController;
  late final ValueNotifier<double> _topActionBlurProgress;
  late final ValueNotifier<double> _topTitleProgress;

  NextBangumiSubject? _subject;
  var _isLoading = true;
  var _errorMessage = '';
  var _subjectRequestId = 0;
  List<NextBangumiSubjectCharacterItem> _subjectCharacters =
      const <NextBangumiSubjectCharacterItem>[];
  Map<int, CharacterDetailBasicInfo> _subjectCharacterStatuses =
      const <int, CharacterDetailBasicInfo>{};
  var _isCharactersInitialLoading = true;
  var _charactersInitialError = '';
  var _isCharactersLoadingMore = false;
  var _charactersLoadMoreError = '';
  var _charactersCanLoadMore = false;
  var _charactersNextOffset = 0;
  int? _charactersLastPreloadItemCount;
  var _charactersRequestId = 0;

  /// 初始化 Next Bangumi 条目二级页面状态
  @override
  void initState() {
    super.initState();
    _repository = NextBangumiRepository();
    _scrollController = ScrollController()
      ..addListener(_handleScrollOffsetChanged);
    _topActionBlurProgress = ValueNotifier<double>(0);
    _topTitleProgress = ValueNotifier<double>(0);
    unawaited(_loadSubject());
    unawaited(_loadSubjectCharacters(reset: true));
  }

  /// 处理 Next Bangumi 条目二级页面配置变化
  ///
  /// [oldWidget] 更新前的条目二级页面配置
  @override
  void didUpdateWidget(covariant NextBangumiSubjectPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.subjectId == oldWidget.subjectId) {
      return;
    }

    _subjectRequestId += 1;
    _charactersRequestId += 1;
    _resetSubjectCharacterPagination();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    setState(() {
      _subject = null;
      _isLoading = true;
      _errorMessage = '';
      _subjectCharacters = const <NextBangumiSubjectCharacterItem>[];
      _subjectCharacterStatuses = const <int, CharacterDetailBasicInfo>{};
      _isCharactersInitialLoading = true;
      _charactersInitialError = '';
    });
    unawaited(_loadSubject());
    unawaited(_loadSubjectCharacters(reset: true));
  }

  /// 释放 Next Bangumi 条目二级页面状态
  @override
  void dispose() {
    _scrollController.removeListener(_handleScrollOffsetChanged);
    _scrollController.dispose();
    _topActionBlurProgress.dispose();
    _topTitleProgress.dispose();
    _repository.close();
    super.dispose();
  }

  /// 构建 Next Bangumi 条目二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final systemOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: SizedBox(height: _topToolbarHeight),
                  ),
                  _buildContent(context),
                ],
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: _topActionBlurProgress,
              builder: (context, progress, _) {
                return ValueListenableBuilder<double>(
                  valueListenable: _topTitleProgress,
                  builder: (context, titleProgress, _) {
                    return _NextBangumiSubjectFloatingToolbar(
                      toolbarHeight: _topToolbarHeight,
                      progress: progress,
                      titleProgress: titleProgress,
                      title: _title,
                      onSearchPressed: _openCharacterSearchPage,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建条目详情内容
  ///
  /// [context] 当前组件树上下文
  Widget _buildContent(BuildContext context) {
    if (widget.subjectId <= 0) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: AppLoadFailedState(
          title: '条目无效',
          message: '当前 BGM 条目不存在',
          actionLabel: null,
        ),
      );
    }

    if (_isLoading) {
      return const _NextBangumiSubjectSkeletonSliver();
    }

    if (_errorMessage.isNotEmpty) {
      return AppLoadFailedSliver(
        message: _errorMessage,
        onActionPressed: _loadSubject,
      );
    }

    final subject = _subject;
    if (subject == null) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: AppLoadFailedState(
          title: '暂无条目',
          message: '当前 BGM 条目没有可展示的数据',
          actionLabel: null,
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        _NextBangumiSubjectDetailSliver(subject: subject),
        _NextBangumiSubjectCharacterSection(
          items: _subjectCharacters,
          statuses: _subjectCharacterStatuses,
          isInitialLoading: _isCharactersInitialLoading,
          initialError: _charactersInitialError,
          isLoadingMore: _isCharactersLoadingMore,
          hasLoadMoreError: _charactersLoadMoreError.isNotEmpty,
          canLoadMore: _charactersCanLoadMore,
          onRetryInitial: () => _loadSubjectCharacters(reset: true),
          onRetryMore: _retryNextSubjectCharacterPage,
          onItemBuilt: _handleSubjectCharacterItemBuilt,
          onItemTap: _openSubjectCharacter,
        ),
      ],
    );
  }

  /// 加载条目详情
  Future<void> _loadSubject() async {
    final requestId = ++_subjectRequestId;
    if (widget.subjectId <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final subject = await _repository.fetchSubject(widget.subjectId);
      if (!mounted || requestId != _subjectRequestId) {
        return;
      }

      setState(() {
        _subject = subject;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _subjectRequestId) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = resolveUserErrorMessage(
          error,
          fallback: '获取 BGM 条目失败',
        );
      });
    }
  }

  /// 加载条目角色
  ///
  /// [reset] 是否重新加载第一页
  Future<void> _loadSubjectCharacters({required bool reset}) async {
    if (widget.subjectId <= 0) {
      setState(() {
        _isCharactersInitialLoading = false;
        _charactersInitialError = '';
      });
      return;
    }

    final requestId = reset ? ++_charactersRequestId : _charactersRequestId;
    final requestedOffset = reset ? 0 : _charactersNextOffset;
    if (reset) {
      _resetSubjectCharacterPagination();
      setState(() {
        _subjectCharacters = const <NextBangumiSubjectCharacterItem>[];
        _subjectCharacterStatuses = const <int, CharacterDetailBasicInfo>{};
        _isCharactersInitialLoading = true;
        _charactersInitialError = '';
      });
    } else if (!_canLoadNextSubjectCharacterPage) {
      return;
    } else {
      setState(() {
        _isCharactersLoadingMore = true;
        _charactersLoadMoreError = '';
      });
    }

    try {
      final page = await _repository.fetchSubjectCharacters(
        widget.subjectId,
        limit: _subjectCharacterPageSize,
        offset: requestedOffset,
      );
      final existingIds =
          _subjectCharacters.map((item) => item.characterId).toSet();
      final items = reset
          ? page.items
          : page.items
              .where((item) => !existingIds.contains(item.characterId))
              .toList(growable: false);
      final statuses =
          await widget.characterRepository.fetchCharacterBasicInfoList(
        items.map((item) => item.characterId).toList(growable: false),
      );
      if (!mounted || requestId != _charactersRequestId) {
        return;
      }

      setState(() {
        if (reset) {
          _subjectCharacters = items;
          _subjectCharacterStatuses = statuses;
          _isCharactersInitialLoading = false;
        } else {
          _subjectCharacters = <NextBangumiSubjectCharacterItem>[
            ..._subjectCharacters,
            ...items,
          ];
          _subjectCharacterStatuses = <int, CharacterDetailBasicInfo>{
            ..._subjectCharacterStatuses,
            ...statuses,
          };
          _isCharactersLoadingMore = false;
        }
        _syncSubjectCharacterPagination(
          requestedOffset: requestedOffset,
          total: page.total,
          rawItemCount: page.rawItemCount,
        );
      });
    } catch (error) {
      if (!mounted || requestId != _charactersRequestId) {
        return;
      }

      setState(() {
        final message = resolveUserErrorMessage(
          error,
          fallback: '获取 BGM 条目角色失败',
        );
        if (reset) {
          _isCharactersInitialLoading = false;
          _charactersInitialError = message;
        } else {
          _isCharactersLoadingMore = false;
          _charactersLoadMoreError = message;
        }
      });
    }
  }

  /// 重试加载下一页条目角色
  Future<void> _retryNextSubjectCharacterPage() async {
    if (_charactersLoadMoreError.isNotEmpty) {
      setState(() {
        _charactersLoadMoreError = '';
      });
    }

    await _loadSubjectCharacters(reset: false);
  }

  /// 重置条目角色分页状态
  void _resetSubjectCharacterPagination() {
    _charactersNextOffset = 0;
    _charactersCanLoadMore = false;
    _isCharactersLoadingMore = false;
    _charactersLoadMoreError = '';
    _charactersLastPreloadItemCount = null;
  }

  /// 同步条目角色分页状态
  ///
  /// [requestedOffset] 请求起始偏移量
  /// [total] 接口返回总数
  /// [rawItemCount] 接口返回原始条目数量
  void _syncSubjectCharacterPagination({
    required int requestedOffset,
    required int total,
    required int rawItemCount,
  }) {
    final nextOffset = requestedOffset + _subjectCharacterPageSize;
    _charactersNextOffset = nextOffset;
    _charactersCanLoadMore = rawItemCount > 0 && nextOffset < total;
  }

  /// 处理条目角色构建触发的分页预加载
  ///
  /// [index] 当前构建的条目下标
  void _handleSubjectCharacterItemBuilt(int index) {
    final itemCount = _subjectCharacters.length;
    if (itemCount == 0 || _charactersLastPreloadItemCount == itemCount) {
      return;
    }

    final maxIndex = itemCount - 1;
    final triggerIndex =
        (maxIndex - (_subjectCharacterPageSize / 2).ceil()).clamp(0, maxIndex);
    if (index < triggerIndex || !_canLoadNextSubjectCharacterPage) {
      return;
    }

    _charactersLastPreloadItemCount = itemCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(_loadSubjectCharacters(reset: false));
    });
  }

  /// 打开条目角色详情
  ///
  /// [item] 条目角色
  void _openSubjectCharacter(NextBangumiSubjectCharacterItem item) {
    final avatarUrl = _avatarUrlForSubjectCharacter(item);
    final heroTag = createCharacterDetailAvatarHeroTag(
      characterId: item.characterId,
      avatarUrl: avatarUrl,
      source: item,
    );

    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.displayName,
      avatarUrl: avatarUrl,
      avatarHeroTag: heroTag,
    );
  }

  /// 解析条目角色头像
  ///
  /// [item] 条目角色
  String _avatarUrlForSubjectCharacter(NextBangumiSubjectCharacterItem item) {
    return _rawAvatarUrlForSubjectCharacter(
      item,
      _subjectCharacterStatuses[item.characterId],
    );
  }

  void _handleScrollOffsetChanged() {
    if (!_scrollController.hasClients) {
      return;
    }

    final scrollOffset = _scrollController.offset;
    final nextBlurProgress =
        (scrollOffset / _topActionBlurExtent).clamp(0.0, 1.0).toDouble();
    if ((nextBlurProgress - _topActionBlurProgress.value).abs() >= 0.01) {
      _topActionBlurProgress.value = nextBlurProgress;
    }

    final nextTitleProgress =
        ((scrollOffset - _topTitleStartOffset) / _topTitleFadeExtent)
            .clamp(0.0, 1.0)
            .toDouble();
    if ((nextTitleProgress - _topTitleProgress.value).abs() >= 0.01) {
      _topTitleProgress.value = nextTitleProgress;
    }
  }

  /// 当前是否允许加载下一页条目角色
  bool get _canLoadNextSubjectCharacterPage {
    return _charactersCanLoadMore &&
        !_isCharactersInitialLoading &&
        !_isCharactersLoadingMore &&
        _charactersLoadMoreError.isEmpty;
  }

  /// 打开角色搜索页
  Future<void> _openCharacterSearchPage() {
    return showCharacterSearchPage(
      context,
      repository: widget.characterRepository,
      templeRepository: widget.templeRepository,
      magicRepository: widget.magicRepository,
      oosRepository: widget.oosRepository,
      userRepository: widget.userRepository,
    );
  }

  /// 当前条目标题
  String get _title {
    return _subject?.displayName ?? 'bgm条目';
  }
}

/// 解码条目展示文本
///
/// [text] 原始文本
String _decodeBangumiSubjectText(String text) {
  return TinygrailFormatters.decodeHtmlEntities(text).trim();
}

/// 标准化条目封面地址
///
/// [url] 原始封面地址
String _normalizeBangumiSubjectCover(String url) {
  return TinygrailAssetUrls.normalizeBangumiUrl(url.trim());
}

/// 生成条目封面 Hero 标识
///
/// [url] 已标准化的封面地址
String _bangumiSubjectCoverHeroTag(String url) {
  return 'next-bangumi-subject-cover-$url';
}
