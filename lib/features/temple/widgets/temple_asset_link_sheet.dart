import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/theme/app_blur_style.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/core/widgets/app_confirm_dialog.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/features/temple/model/temple_asset_card_data.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_link_components.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'temple_asset_link_sheet_widgets.dart';

const int _templeAssetLinkPageSize = 20;
const double _templeAssetLinkGridSpacing = 10;
const double _templeAssetLinkMinTileWidth = 132;
const double _templeAssetLinkBodyVisibleMinHeight = 160;

/// 显示圣殿 LINK 选择抽屉
///
/// [context] 当前组件树上下文
/// [data] 圣殿资产卡片展示数据
Future<void> showTempleAssetLinkSheet(
  BuildContext context, {
  required TempleAssetCardData data,
}) {
  if (data.actionContext == null) {
    AppToast.error(context, text: '缺少操作上下文');
    return Future<void>.value();
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: BoxConstraints.tightFor(
      width: MediaQuery.sizeOf(context).width,
    ),
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      const topGap = 32.0;
      final availableHeight =
          mediaQuery.size.height - mediaQuery.padding.top - topGap;
      final heightCap = mediaQuery.size.height *
          (mediaQuery.orientation == Orientation.landscape ? 0.9 : 0.86);
      final maxHeight = availableHeight.clamp(0.0, heightCap).toDouble();

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: TempleAssetLinkSheet(data: data),
      );
    },
  );
}

/// 圣殿 LINK 选择抽屉
class TempleAssetLinkSheet extends StatefulWidget {
  /// 创建圣殿 LINK 选择抽屉
  ///
  /// [key] Flutter 组件标识
  /// [data] 圣殿资产卡片展示数据
  const TempleAssetLinkSheet({
    super.key,
    required this.data,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 创建圣殿 LINK 选择抽屉状态
  @override
  State<TempleAssetLinkSheet> createState() => _TempleAssetLinkSheetState();
}

/// 圣殿 LINK 选择抽屉状态
class _TempleAssetLinkSheetState extends State<TempleAssetLinkSheet> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _searchDebounce;
  var _items = const <UserTempleApiItem>[];
  var _lastSearchText = '';
  var _requestId = 0;
  var _nextPage = 1;
  var _canLoadMore = true;
  int? _lastPreloadItemCount;
  var _isSearching = false;
  var _isLoadingMore = false;
  var _isConfirmDialogOpen = false;
  var _searchError = '';
  var _loadMoreError = '';

  /// 初始化圣殿 LINK 选择抽屉状态
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchTextChanged);
    unawaited(_loadFirstPage());
  }

  /// 释放圣殿 LINK 选择抽屉状态
  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController
      ..removeListener(_handleSearchTextChanged)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 构建圣殿 LINK 选择抽屉
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerLowest;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.32 : 0.58,
                ),
              ),
            ),
          ),
          child: SafeArea(
            left: false,
            right: false,
            top: false,
            child: Padding(
              padding: AppSafeAreaInsets.fromLTRB(
                context,
                left: 20,
                top: 10,
                right: 20,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppBottomSheetDragHandle(),
                  const SizedBox(height: 10),
                  Flexible(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final showSearchBody = constraints.maxHeight >=
                            _templeAssetLinkBodyVisibleMinHeight;
                        return Stack(
                          children: [
                            if (showSearchBody)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _TempleAssetLinkSheetHeader(
                                    data: widget.data,
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(child: _buildSearchContent(context)),
                                ],
                              ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 6,
                              child: _buildSearchField(context),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建圣殿搜索内容
  ///
  /// [context] 当前组件树上下文
  Widget _buildSearchContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_searchError.isNotEmpty && _items.isNotEmpty) ...[
          _TempleAssetLinkInlineWarning(text: _searchError),
          const SizedBox(height: 12),
        ],
        Text(
          '选择你想要连接的圣殿',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.68),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: _buildSearchResultState(context),
          ),
        ),
      ],
    );
  }

  /// 构建圣殿搜索结果状态
  ///
  /// [context] 当前组件树上下文
  Widget _buildSearchResultState(BuildContext context) {
    if (_isSearching && _items.isEmpty) {
      return const _TempleAssetLinkSkeletonGrid();
    }

    if (_searchError.isNotEmpty && _items.isEmpty) {
      return AppLoadFailedState(
        message: '请检查网络后重试',
        onActionPressed: () => unawaited(_loadFirstPage()),
      );
    }

    if (_items.isEmpty) {
      return _TempleAssetLinkEmptyText(
        text: _searchController.text.trim().isEmpty ? '暂无可选圣殿' : '未找到相关圣殿',
      );
    }

    return _buildGrid();
  }

  /// 构建圣殿网格
  Widget _buildGrid() {
    final hasFooter = _isLoadingMore || _loadMoreError.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _TempleAssetLinkGridLayout.resolve(
          constraints.maxWidth,
        );

        return CustomScrollView(
          controller: _scrollController,
          primary: false,
          slivers: [
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: layout.crossAxisCount,
                mainAxisSpacing: _templeAssetLinkGridSpacing,
                crossAxisSpacing: _templeAssetLinkGridSpacing,
                childAspectRatio: layout.childAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  _handleItemBuilt(index);
                  return TempleAssetLinkTempleTile(
                    item: _items[index],
                    width: layout.tileWidth,
                    onSelected: _selectTemple,
                  );
                },
                childCount: _items.length,
              ),
            ),
            if (hasFooter)
              SliverToBoxAdapter(
                child: _loadMoreError.isNotEmpty
                    ? _TempleAssetLinkLoadMoreError(
                        onRetry: () => unawaited(_retryNextPage()),
                      )
                    : const _TempleAssetLinkLoadingMore(),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 58),
            ),
          ],
        );
      },
    );
  }

  /// 构建底部浮动搜索框
  ///
  /// [context] 当前组件树上下文
  Widget _buildSearchField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final borderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.26 : 0.42,
    );
    final focusedBorderColor = colorScheme.primary.withValues(
      alpha: isDark ? 0.34 : 0.30,
    );
    final borderRadius = BorderRadius.circular(999);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: AppBlurStyle.filter,
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(LucideIcons.search, size: 18),
            hintText: '搜索圣殿',
            filled: true,
            fillColor: AppBlurStyle.surfaceColor(context),
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: borderColor, width: 0.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: borderColor, width: 0.8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: focusedBorderColor, width: 0.9),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
          ),
        ),
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
    _searchDebounce = Timer(const Duration(milliseconds: 450), _loadFirstPage);
  }

  /// 选择目标圣殿
  ///
  /// [item] 用户圣殿条目
  void _selectTemple(UserTempleApiItem item) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (item.characterId == widget.data.characterId) {
      AppToast.error(context, text: '不能连接自己');
      return;
    }

    unawaited(_showConfirmDialog(item));
  }

  /// 显示圣殿 LINK 确认框
  ///
  /// [item] 目标圣殿条目
  Future<void> _showConfirmDialog(UserTempleApiItem item) async {
    if (_isConfirmDialogOpen) {
      return;
    }

    final actionContext = widget.data.actionContext;
    if (actionContext == null) {
      AppToast.error(context, text: '缺少操作上下文');
      return;
    }

    _isConfirmDialogOpen = true;
    var refreshFailed = false;
    var resultMessage = '';
    try {
      final confirmed = await showAppConfirmDialog(
        context,
        title: '',
        message: '',
        content: TempleAssetLinkPreview(
          source: widget.data,
          target: item,
        ),
        confirmText: 'LINK',
        showCancelButton: false,
        onConfirm: () async {
          try {
            resultMessage = await actionContext.templeRepository.linkTemples(
              sourceCharacterId: widget.data.characterId,
              targetCharacterId: item.characterId,
            );
            try {
              await actionContext.onActionCompleted?.call();
            } catch (_) {
              refreshFailed = true;
            }
            return true;
          } catch (error) {
            if (mounted) {
              AppToast.error(context, text: _messageForError(error));
            }
            return false;
          }
        },
      );
      if (!mounted || !confirmed) {
        return;
      }

      if (refreshFailed) {
        AppToast.error(context, text: '圣殿已连接，刷新圣殿数据失败');
      } else {
        AppToast.info(
          context,
          text: resultMessage.isEmpty ? '连接圣殿成功' : resultMessage,
        );
      }
      await Navigator.of(context).maybePop();
    } finally {
      _isConfirmDialogOpen = false;
    }
  }

  /// 加载第一页圣殿数据
  Future<void> _loadFirstPage() async {
    final actionContext = widget.data.actionContext;
    final username = actionContext?.currentUserName.trim() ?? '';
    final requestId = ++_requestId;
    _resetPagination();

    setState(() {
      _isSearching = true;
      _isLoadingMore = false;
      _searchError = '';
      _loadMoreError = '';
      _items = const <UserTempleApiItem>[];
    });

    if (actionContext == null || username.isEmpty) {
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        _isSearching = false;
        _searchError = '请先授权';
      });
      return;
    }

    try {
      final page = await actionContext.userRepository.fetchUserTemplePage(
        username: username,
        page: 1,
        pageSize: _templeAssetLinkPageSize,
        keyword: _searchController.text.trim(),
      );
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        _items = page.items;
        _isSearching = false;
        _syncPagination(
          requestedPage: 1,
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          rawItemCount: page.items.length,
        );
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        _searchError = _messageForError(error);
        _isSearching = false;
      });
    }
  }

  /// 加载下一页圣殿数据
  Future<void> _loadNextPage() async {
    if (!_canLoadNextPage) {
      return;
    }

    final actionContext = widget.data.actionContext;
    final username = actionContext?.currentUserName.trim() ?? '';
    final requestId = _requestId;
    final requestedPage = _nextPage;
    if (actionContext == null || username.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _loadMoreError = '';
    });

    try {
      final page = await actionContext.userRepository.fetchUserTemplePage(
        username: username,
        page: requestedPage,
        pageSize: _templeAssetLinkPageSize,
        keyword: _searchController.text.trim(),
      );
      final existingIds = _items.map((item) => item.characterId).toSet();
      final items = page.items
          .where((item) => !existingIds.contains(item.characterId))
          .toList(growable: false);
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        _items = <UserTempleApiItem>[
          ..._items,
          ...items,
        ];
        _isLoadingMore = false;
        _syncPagination(
          requestedPage: requestedPage,
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          rawItemCount: page.items.length,
        );
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) {
        return;
      }

      setState(() {
        _loadMoreError = _messageForError(error);
        _isLoadingMore = false;
      });
    }
  }

  /// 重试加载下一页圣殿数据
  Future<void> _retryNextPage() async {
    if (_loadMoreError.isNotEmpty) {
      setState(() {
        _loadMoreError = '';
      });
    }
    await _loadNextPage();
  }

  /// 重置分页状态
  void _resetPagination() {
    _nextPage = 1;
    _canLoadMore = true;
    _lastPreloadItemCount = null;
    _isLoadingMore = false;
    _loadMoreError = '';
  }

  /// 同步分页状态
  ///
  /// [requestedPage] 请求页码
  /// [currentPage] 接口返回页码
  /// [totalPages] 接口返回总页数
  /// [rawItemCount] 接口返回条目数量
  void _syncPagination({
    required int requestedPage,
    required int currentPage,
    required int totalPages,
    required int rawItemCount,
  }) {
    final resolvedPage =
        currentPage > requestedPage ? currentPage : requestedPage;
    _nextPage = resolvedPage + 1;
    _canLoadMore = rawItemCount > 0 && resolvedPage < totalPages;
  }

  /// 处理圣殿网格条目构建触发的分页预加载
  ///
  /// [index] 当前构建的条目下标
  void _handleItemBuilt(int index) {
    final itemCount = _items.length;
    if (itemCount == 0 || _lastPreloadItemCount == itemCount) {
      return;
    }

    final maxIndex = itemCount - 1;
    final triggerIndex =
        (maxIndex - (_templeAssetLinkPageSize / 2).ceil()).clamp(0, maxIndex);
    if (index < triggerIndex || !_canLoadNextPage) {
      return;
    }

    _lastPreloadItemCount = itemCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(_loadNextPage());
    });
  }

  /// 是否可以加载下一页
  bool get _canLoadNextPage {
    return _canLoadMore &&
        !_isSearching &&
        !_isLoadingMore &&
        _loadMoreError.isEmpty;
  }

  /// 转换圣殿 LINK 错误文案
  ///
  /// [error] 捕获到的异常
  String _messageForError(Object error) {
    return resolveUserErrorMessage(error, fallback: '连接圣殿失败');
  }
}
