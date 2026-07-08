import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/controller/tinygrail_paged_list_controller.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/core/widgets/page_section_sliver.dart';
import 'package:magrail_app/core/widgets/pagination_footer_sliver.dart';
import 'package:magrail_app/features/chara/detail/controller/character_detail_ico_participants_controller.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_info.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_participant.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_prediction.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/user/widgets/user_avatar.dart';
import 'package:magrail_app/features/user/widgets/user_profile_card_components.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'character_detail_ico_participant_row.dart';

/// 角色详情 ICO 参与者区
class CharacterDetailIcoParticipantsSection extends StatefulWidget {
  /// 创建角色详情 ICO 参与者区
  ///
  /// [key] Flutter 组件标识
  /// [repository] 角色详情仓库
  /// [icoInfo] ICO 头部资料
  const CharacterDetailIcoParticipantsSection({
    super.key,
    required this.repository,
    required this.icoInfo,
  });

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// ICO 头部资料
  final CharacterDetailIcoInfo icoInfo;

  /// 创建角色详情 ICO 参与者区状态
  @override
  State<CharacterDetailIcoParticipantsSection> createState() {
    return _CharacterDetailIcoParticipantsSectionState();
  }
}

/// 角色详情 ICO 参与者区状态
class _CharacterDetailIcoParticipantsSectionState
    extends State<CharacterDetailIcoParticipantsSection> {
  late CharacterDetailIcoParticipantsController _controller;

  /// 初始化角色详情 ICO 参与者区状态
  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  /// 处理角色详情 ICO 参与者区配置变化
  ///
  /// [oldWidget] 更新前的参与者区配置
  @override
  void didUpdateWidget(
    covariant CharacterDetailIcoParticipantsSection oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (widget.icoInfo.id == oldWidget.icoInfo.id &&
        widget.repository == oldWidget.repository) {
      return;
    }

    _controller.dispose();
    _controller = _createController();
  }

  /// 释放角色详情 ICO 参与者区状态
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建角色详情 ICO 参与者区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return SliverMainAxisGroup(
          slivers: [
            PageSectionSliver(
              title: '参与者',
              topSpacing: 12,
              titleTrailing: _IcoParticipantsHeaderTrailing(
                totalItems: _displayTotalItems,
                nextLevelUsers: _nextLevelUsers,
              ),
              child: const SizedBox.shrink(),
            ),
            ..._buildContentSlivers(),
          ],
        );
      },
    );
  }

  /// 创建角色详情 ICO 参与者控制器
  CharacterDetailIcoParticipantsController _createController() {
    return CharacterDetailIcoParticipantsController(
      repository: widget.repository,
      icoId: widget.icoInfo.id,
    )..initialize();
  }

  /// 构建参与者内容 sliver
  List<Widget> _buildContentSlivers() {
    if (_controller.isInitialLoading) {
      return const <Widget>[_IcoParticipantsSkeletonGrid()];
    }

    final initialError = _controller.initialError;
    if (initialError != null) {
      return <Widget>[
        _IcoParticipantsErrorSliver(
          message: _errorMessage(initialError),
          onRetry: _controller.loadNextPage,
        ),
      ];
    }

    if (_controller.items.isEmpty) {
      return const <Widget>[_IcoParticipantsEmptySliver()];
    }

    return <Widget>[
      _IcoParticipantsGrid(
        items: _controller.items,
        prediction: CharacterDetailIcoPrediction.fromInfo(widget.icoInfo),
        onItemBuilt: _controller.handleItemBuilt,
        onParticipantTap: _openUser,
      ),
      PaginationFooterSliver(
        isLoadingMore: _controller.isLoadingMore,
        hasLoadMoreError: _controller.loadMoreError != null,
        canLoadMore: _controller.canLoadMore,
        completedLabel: '没有更多参与者了',
        onRetry: _controller.loadNextPage,
      ),
    ];
  }

  /// 打开用户详情
  ///
  /// [participant] ICO 参与者资料
  void _openUser(CharacterDetailIcoParticipant participant) {
    final username = participant.name.trim();
    if (username.isEmpty) {
      return;
    }

    context.pushNamed(
      'userDetail',
      queryParameters: {'username': username},
    );
  }

  /// 获取错误展示文案
  ///
  /// [error] 分页错误
  String _errorMessage(Object error) {
    final source = error is TinygrailPagedListException ? error.source : error;
    return resolveUserErrorMessage(source, fallback: '获取 ICO 参与者失败');
  }

  /// 标题展示的参与者总数
  int get _displayTotalItems {
    if (_controller.totalItems > 0) {
      return _controller.totalItems;
    }

    return widget.icoInfo.users;
  }

  /// 下一等级所需参与人数
  int get _nextLevelUsers {
    final prediction = CharacterDetailIcoPrediction.fromInfo(widget.icoInfo);
    return _displayTotalItems + prediction.users;
  }
}

/// ICO 参与者标题辅助文本
class _IcoParticipantsHeaderTrailing extends StatelessWidget {
  /// 创建 ICO 参与者标题辅助文本
  ///
  /// [totalItems] 已参与人数
  /// [nextLevelUsers] 下一等级所需参与人数
  const _IcoParticipantsHeaderTrailing({
    required this.totalItems,
    required this.nextLevelUsers,
  });

  /// 已参与人数
  final int totalItems;

  /// 下一等级所需参与人数
  final int nextLevelUsers;

  /// 构建 ICO 参与者标题辅助文本
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      '$totalItems / $nextLevelUsers',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
  }
}

/// ICO 参与者响应式网格
class _IcoParticipantsGrid extends StatelessWidget {
  /// 创建 ICO 参与者响应式网格
  ///
  /// [items] 参与者条目
  /// [prediction] ICO 预测数据
  /// [onItemBuilt] 条目构建回调
  /// [onParticipantTap] 参与者点击回调
  const _IcoParticipantsGrid({
    required this.items,
    required this.prediction,
    required this.onItemBuilt,
    required this.onParticipantTap,
  });

  /// 参与者条目
  final List<CharacterDetailIcoParticipant> items;

  /// ICO 预测数据
  final CharacterDetailIcoPrediction prediction;

  /// 条目构建回调
  final ValueChanged<int> onItemBuilt;

  /// 参与者点击回调
  final ValueChanged<CharacterDetailIcoParticipant> onParticipantTap;

  /// 构建 ICO 参与者响应式网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 12,
        top: 0,
        right: 12,
        bottom: 0,
      ),
      sliver: SliverGrid(
        gridDelegate: _IcoParticipantsGridMetrics.delegate,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];

            onItemBuilt(index);
            return _IcoParticipantRow(
              participant: item,
              prediction: prediction,
              serialNumber: index + 1,
              onTap: () => onParticipantTap(item),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

/// ICO 参与者骨架网格
class _IcoParticipantsSkeletonGrid extends StatelessWidget {
  /// 创建 ICO 参与者骨架网格
  const _IcoParticipantsSkeletonGrid();

  /// 构建 ICO 参与者骨架网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 12,
        top: 0,
        right: 12,
        bottom: 0,
      ),
      sliver: SliverGrid(
        gridDelegate: _IcoParticipantsGridMetrics.delegate,
        delegate: SliverChildBuilderDelegate(
          (context, index) => const _IcoParticipantRowSkeleton(),
          childCount: CharacterDetailIcoParticipantsController.defaultPageSize,
        ),
      ),
    );
  }
}

/// ICO 参与者失败状态
class _IcoParticipantsErrorSliver extends StatelessWidget {
  /// 创建 ICO 参与者失败状态
  ///
  /// [message] 失败说明
  /// [onRetry] 重试回调
  const _IcoParticipantsErrorSliver({
    required this.message,
    required this.onRetry,
  });

  /// 失败说明
  final String message;

  /// 重试回调
  final VoidCallback onRetry;

  /// 构建 ICO 参与者失败状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: AppSafeAreaInsets.symmetricHorizontal(
          context,
          horizontal: 12,
        ),
        child: AppLoadFailedState(
          message: message,
          onActionPressed: onRetry,
        ),
      ),
    );
  }
}

/// ICO 参与者空状态
class _IcoParticipantsEmptySliver extends StatelessWidget {
  /// 创建 ICO 参与者空状态
  const _IcoParticipantsEmptySliver();

  /// 构建 ICO 参与者空状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: AppSafeAreaInsets.fromLTRB(
          context,
          left: 24,
          top: 8,
          right: 24,
          bottom: 24,
        ),
        child: Text(
          '暂无参与者',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
