import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_tabbed_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/user/controller/user_market_order_page_controller.dart';
import 'package:magrail_app/features/user/model/user_market_order_api_item.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_sliver_list.dart';

/// 用户委托订单二级页面
class UserMarketOrderPage extends StatefulWidget {
  /// 创建用户委托订单二级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 用户仓库
  const UserMarketOrderPage({
    super.key,
    required this.repository,
  });

  /// 用户仓库
  final UserRepository repository;

  /// 创建用户委托订单二级页面状态
  @override
  State<UserMarketOrderPage> createState() => _UserMarketOrderPageState();
}

/// 用户委托订单二级页面状态
class _UserMarketOrderPageState extends State<UserMarketOrderPage> {
  late final UserMarketOrderPageController _bidController;
  late final UserMarketOrderPageController _askController;
  bool _hasInitializedAsk = false;

  /// 初始化用户委托订单二级页面状态
  @override
  void initState() {
    super.initState();
    _bidController = UserMarketOrderPageController(
      repository: widget.repository,
      side: UserMarketOrderSide.bid,
    )..initialize();
    _askController = UserMarketOrderPageController(
      repository: widget.repository,
      side: UserMarketOrderSide.ask,
    );
  }

  /// 释放用户委托订单二级页面状态
  @override
  void dispose() {
    _bidController.dispose();
    _askController.dispose();
    super.dispose();
  }

  /// 构建用户委托订单二级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailTabbedPagedSliverPage<UserMarketOrderApiItem,
        UserMarketOrderApiItem>(
      title: '委托订单',
      tabs: [
        _buildOrderTab(
          label: '我的买单',
          side: UserMarketOrderSide.bid,
          controller: _bidController,
        ),
        _buildOrderTab(
          label: '我的卖单',
          side: UserMarketOrderSide.ask,
          controller: _askController,
        ),
      ],
      onTabPrepared: _handleTabPrepared,
      useSecondaryTitleStyle: true,
    );
  }

  /// 创建委托订单标签页配置
  ///
  /// [label] 标签文案
  /// [side] 委托订单方向
  /// [controller] 委托订单分页控制器
  TinygrailPagedTab<UserMarketOrderApiItem, UserMarketOrderApiItem>
      _buildOrderTab({
    required String label,
    required UserMarketOrderSide side,
    required UserMarketOrderPageController controller,
  }) {
    return TinygrailPagedTab<UserMarketOrderApiItem, UserMarketOrderApiItem>(
      label: label,
      controller: controller,
      loadingSliver: const UserMarketOrderSkeletonSliverList(),
      emptySliverBuilder: (context, controller) {
        return PagedSliverState(
          title: _emptyTitle(side),
          message: _emptyMessage(side),
          icon: Icons.receipt_long_outlined,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        return [
          UserMarketOrderSliverList(
            items: items,
            side: side,
            onItemBuilt: onItemBuilt,
            onOrderTap: _handleOrderTap,
          ),
        ];
      },
      completedLabel: _completedLabel(side),
    );
  }

  /// 处理标签页即将展示
  ///
  /// [index] 标签页索引
  void _handleTabPrepared(int index) {
    final side = _sideAt(index);
    if (side == UserMarketOrderSide.ask && !_hasInitializedAsk) {
      _hasInitializedAsk = true;
      _askController.initialize();
    }
  }

  /// 按索引获取委托订单方向
  ///
  /// [index] 标签页索引
  UserMarketOrderSide _sideAt(int index) {
    return switch (index) {
      0 => UserMarketOrderSide.bid,
      _ => UserMarketOrderSide.ask,
    };
  }

  /// 获取空状态标题
  ///
  /// [side] 委托订单方向
  String _emptyTitle(UserMarketOrderSide side) {
    return switch (side) {
      UserMarketOrderSide.bid => '暂无买单',
      UserMarketOrderSide.ask => '暂无卖单',
    };
  }

  /// 获取空状态说明
  ///
  /// [side] 委托订单方向
  String _emptyMessage(UserMarketOrderSide side) {
    return switch (side) {
      UserMarketOrderSide.bid => '当前没有可展示的买单',
      UserMarketOrderSide.ask => '当前没有可展示的卖单',
    };
  }

  /// 获取完成加载文案
  ///
  /// [side] 委托订单方向
  String _completedLabel(UserMarketOrderSide side) {
    return switch (side) {
      UserMarketOrderSide.bid => '没有更多买单了',
      UserMarketOrderSide.ask => '没有更多卖单了',
    };
  }

  /// 处理委托订单点击
  ///
  /// [item] 用户委托订单条目
  /// [avatarHeroTag] 头像转场标识
  void _handleOrderTap(
    UserMarketOrderApiItem item,
    String? avatarHeroTag,
  ) {
    openCharacterDetail(
      context,
      characterId: item.characterId,
      name: item.name,
      avatarUrl: item.icon,
      avatarHeroTag: avatarHeroTag,
    );
  }
}
