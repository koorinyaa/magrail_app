import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/page_section_sliver.dart';
import 'package:magrail_app/core/widgets/snapping_horizontal_list_view.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_collections_controller.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_board_section_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_collections_route_extra.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_board_member.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_board_member_row.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_dialog.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_skeleton.dart';

/// 角色详情董事会预览区
class CharacterDetailBoardSection extends StatefulWidget {
  /// 创建角色详情董事会预览区
  ///
  /// [key] Flutter 组件标识
  /// [repository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  /// [header] 角色详情已上市头部资料
  /// [collectionsController] 公开展示区控制器
  /// [currentUserName] 当前登录用户名
  /// [revealPrivateUserHoldings] 是否允许查看未公开用户持股
  /// [boardRefreshSignal] 董事会刷新信号
  const CharacterDetailBoardSection({
    super.key,
    required this.repository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
    required this.header,
    required this.collectionsController,
    required this.currentUserName,
    required this.revealPrivateUserHoldings,
    required this.boardRefreshSignal,
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

  /// 角色详情已上市头部资料
  final CharacterDetailTradeHeader header;

  /// 公开展示区控制器
  final CharacterDetailCollectionsController collectionsController;

  /// 当前登录用户名
  final String currentUserName;

  /// 是否允许查看未公开用户持股
  final bool revealPrivateUserHoldings;

  /// 董事会刷新信号
  final ValueListenable<int> boardRefreshSignal;

  /// 创建角色详情董事会预览区状态
  @override
  State<CharacterDetailBoardSection> createState() =>
      _CharacterDetailBoardSectionState();
}

/// 角色详情董事会预览区状态
class _CharacterDetailBoardSectionState
    extends State<CharacterDetailBoardSection> {
  late CharacterDetailBoardSectionController _controller;

  /// 初始化角色详情董事会预览区状态
  @override
  void initState() {
    super.initState();
    _controller = _createController();
    widget.boardRefreshSignal.addListener(_handleBoardRefreshSignalChanged);
  }

  /// 处理角色详情董事会预览区配置变化
  ///
  /// [oldWidget] 更新前的预览区配置
  @override
  void didUpdateWidget(covariant CharacterDetailBoardSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.header.characterId == oldWidget.header.characterId &&
        widget.repository == oldWidget.repository) {
      if (widget.boardRefreshSignal != oldWidget.boardRefreshSignal) {
        oldWidget.boardRefreshSignal.removeListener(
          _handleBoardRefreshSignalChanged,
        );
        widget.boardRefreshSignal.addListener(_handleBoardRefreshSignalChanged);
      }
      return;
    }

    oldWidget.boardRefreshSignal.removeListener(
      _handleBoardRefreshSignalChanged,
    );
    widget.boardRefreshSignal.addListener(_handleBoardRefreshSignalChanged);
    _controller.dispose();
    _controller = _createController();
  }

  /// 释放角色详情董事会预览区状态
  @override
  void dispose() {
    widget.boardRefreshSignal.removeListener(_handleBoardRefreshSignalChanged);
    _controller.dispose();
    super.dispose();
  }

  /// 构建角色详情董事会预览区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _controller,
        widget.collectionsController,
      ]),
      builder: (context, _) {
        return PageSectionSliver(
          title: _title,
          topSpacing: 12,
          onHeaderTap: _canOpenBoardPage ? _openBoardPage : null,
          child: _buildContent(context),
        );
      },
    );
  }

  /// 创建董事会预览区控制器
  CharacterDetailBoardSectionController _createController() {
    return CharacterDetailBoardSectionController(
      repository: widget.repository,
      characterId: widget.header.characterId,
    )..initialize();
  }

  /// 构建董事会预览内容
  ///
  /// [context] 当前组件树上下文
  Widget _buildContent(BuildContext context) {
    if (_controller.isLoading && _controller.items.isEmpty) {
      return const _BoardPreviewSkeleton();
    }

    if (_controller.hasError) {
      return _BoardPreviewFailedState(
        message: _controller.errorMessage,
        onRetry: _controller.load,
      );
    }

    if (_controller.items.isEmpty) {
      return const _BoardPreviewEmptyState();
    }

    final columns = _buildColumns(_controller.items);
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final columnWidth = math.max(
          248.0,
          math.min(318.0, screenWidth - 72),
        );

        return SnappingHorizontalListView(
          height: _BoardPreviewMetrics.height,
          itemCount: columns.length,
          itemExtent: columnWidth,
          separatorExtent: 12,
          padding: AppSafeAreaInsets.symmetricHorizontal(
            context,
            horizontal: 24,
          ),
          clipBehavior: Clip.none,
          itemBuilder: (context, columnIndex) {
            final column = columns[columnIndex];

            return Column(
              children: [
                for (var row = 0; row < column.length; row++) ...[
                  _buildMemberRow(
                    member: column[row],
                    serialNumber:
                        columnIndex * _BoardPreviewMetrics.rowsPerColumn +
                            row +
                            1,
                  ),
                  if (row != column.length - 1) const SizedBox(height: 4),
                ],
              ],
            );
          },
        );
      },
    );
  }

  /// 构建董事会成员行
  ///
  /// [member] 董事会成员
  /// [serialNumber] 当前成员序列号
  Widget _buildMemberRow({
    required CharacterDetailBoardMember member,
    required int serialNumber,
  }) {
    final temple = widget.collectionsController.templeForOwnerName(
      member.name,
    );

    return CharacterDetailBoardMemberRow(
      member: member,
      serialNumber: serialNumber,
      totalShares: widget.header.total,
      temple: temple,
      onTap: () => _openUser(member),
      onTempleTap: temple == null ? null : () => _openTempleAssetCard(temple),
      onRevealStock:
          widget.revealPrivateUserHoldings ? _revealMemberStock : null,
    );
  }

  /// 查询董事会成员未公开持股
  ///
  /// [member] 董事会成员
  Future<int?> _revealMemberStock(CharacterDetailBoardMember member) async {
    final username = member.name.trim();
    if (username.isEmpty) {
      return null;
    }

    final holding = await widget.repository.fetchUserCharacterHolding(
      widget.header.characterId,
      username,
    );
    return holding?.total;
  }

  /// 按列拆分董事会预览条目
  ///
  /// [items] 董事会成员
  List<List<CharacterDetailBoardMember>> _buildColumns(
    List<CharacterDetailBoardMember> items,
  ) {
    final previewItems = items
        .take(CharacterDetailBoardSectionController.previewPageSize)
        .toList();
    final result = <List<CharacterDetailBoardMember>>[];

    for (var start = 0;
        start < previewItems.length;
        start += _BoardPreviewMetrics.rowsPerColumn) {
      final end = math.min(
        start + _BoardPreviewMetrics.rowsPerColumn,
        previewItems.length,
      );
      result.add(previewItems.sublist(start, end));
    }

    return result;
  }

  /// 打开董事会二级页面
  void _openBoardPage() {
    context.pushNamed(
      'characterBoard',
      queryParameters: {
        'characterId': widget.header.characterId.toString(),
        if (widget.header.name.trim().isNotEmpty)
          'name': widget.header.name.trim(),
        'total': widget.header.total.toString(),
      },
      extra: _routeExtra,
    );
  }

  /// 打开圣殿资产卡片弹窗
  ///
  /// [temple] 董事会成员对应圣殿
  void _openTempleAssetCard(CharacterDetailTempleItem temple) {
    unawaited(
      showTempleAssetCardDialogFromSource(
        context,
        source: _sourceForTemple(temple),
        characterRepository: widget.repository,
        templeRepository: widget.templeRepository,
        magicRepository: widget.magicRepository,
        oosRepository: widget.oosRepository,
        userRepository: widget.userRepository,
        currentUserName: widget.currentUserName,
      ),
    );
  }

  /// 打开用户详情
  ///
  /// [member] 董事会成员
  void _openUser(CharacterDetailBoardMember member) {
    final username = member.name.trim();
    if (username.isEmpty) {
      return;
    }

    context.pushNamed(
      'userDetail',
      queryParameters: {'username': username},
    );
  }

  /// 创建圣殿资产弹窗入口数据
  ///
  /// [temple] 董事会成员对应圣殿
  TempleAssetDialogSource _sourceForTemple(CharacterDetailTempleItem temple) {
    final characterId =
        temple.characterId > 0 ? temple.characterId : widget.header.characterId;

    return TempleAssetDialogSource(
      ownerName: temple.ownerName,
      ownerNickname: temple.ownerNickname,
      characterId: characterId,
    );
  }

  /// 董事会二级页面路由附加数据
  CharacterDetailCollectionsRouteExtra get _routeExtra {
    return CharacterDetailCollectionsRouteExtra(
      controller: widget.collectionsController,
      header: widget.header,
      currentUserName: widget.currentUserName,
      userRepository: widget.userRepository,
      templeRepository: widget.templeRepository,
      magicRepository: widget.magicRepository,
      oosRepository: widget.oosRepository,
    );
  }

  /// 董事会标题
  String get _title {
    if (_controller.isLoading || _controller.hasError) {
      return '董事会';
    }

    return '董事会 ${_controller.totalItems}';
  }

  /// 董事会二级页面入口是否可用
  bool get _canOpenBoardPage {
    return !_controller.isLoading &&
        !_controller.hasError &&
        _controller.items.isNotEmpty;
  }

  /// 处理董事会刷新信号变化
  void _handleBoardRefreshSignalChanged() {
    unawaited(Future<void>.microtask(_controller.load));
  }
}

/// 董事会预览失败状态
class _BoardPreviewFailedState extends StatelessWidget {
  /// 创建董事会预览失败状态
  ///
  /// [message] 失败状态说明
  /// [onRetry] 重试回调
  const _BoardPreviewFailedState({
    required this.message,
    required this.onRetry,
  });

  /// 失败状态说明
  final String message;

  /// 重试回调
  final VoidCallback onRetry;

  /// 构建董事会预览失败状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSafeAreaInsets.symmetricHorizontal(
        context,
        horizontal: 12,
      ),
      child: AppLoadFailedState(
        message: message,
        onActionPressed: onRetry,
      ),
    );
  }
}

/// 董事会预览空状态
class _BoardPreviewEmptyState extends StatelessWidget {
  /// 创建董事会预览空状态
  const _BoardPreviewEmptyState();

  /// 构建董事会预览空状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: AppSafeAreaInsets.symmetricHorizontal(
        context,
        horizontal: 24,
      ),
      child: SizedBox(
        height: 88,
        child: Center(
          child: Text(
            '暂无董事会成员',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// 董事会预览骨架
class _BoardPreviewSkeleton extends StatelessWidget {
  /// 创建董事会预览骨架
  const _BoardPreviewSkeleton();

  /// 构建董事会预览骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final columnWidth = math.max(
          248.0,
          math.min(318.0, screenWidth - 72),
        );

        return SnappingHorizontalListView(
          height: _BoardPreviewMetrics.height,
          itemCount: _BoardPreviewMetrics.columnCount,
          itemExtent: columnWidth,
          separatorExtent: 12,
          padding: AppSafeAreaInsets.symmetricHorizontal(
            context,
            horizontal: 24,
          ),
          clipBehavior: Clip.none,
          itemBuilder: (context, columnIndex) {
            return Column(
              children: [
                for (var row = 0;
                    row < _BoardPreviewMetrics.rowsPerColumn;
                    row++) ...[
                  const CharacterAssetRowSkeleton(
                    showLevel: false,
                    metricCount: 3,
                    showTrailing: true,
                  ),
                  if (row != _BoardPreviewMetrics.rowsPerColumn - 1)
                    const SizedBox(height: 4),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

/// 董事会预览布局参数
final class _BoardPreviewMetrics {
  /// 禁止创建董事会预览布局参数实例
  const _BoardPreviewMetrics._();

  /// 每列行数
  static const int rowsPerColumn = 4;

  /// 预览列数
  static const int columnCount = 5;

  /// 预览区域高度
  static const double height = 268;
}
