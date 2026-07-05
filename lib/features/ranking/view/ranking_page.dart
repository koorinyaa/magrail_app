import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/paged_sliver_state.dart';
import 'package:magrail_app/core/widgets/tinygrail_tabbed_paged_sliver_page.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/search/view/character_search_page.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/ranking/controller/ranking_controller.dart';
import 'package:magrail_app/features/ranking/model/ranking_entry.dart';
import 'package:magrail_app/features/ranking/repository/ranking_repository.dart';
import 'package:magrail_app/features/ranking/widgets/ranking_slivers.dart';
import 'package:magrail_app/features/temple/model/temple_asset_dialog_source.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/temple/widgets/temple_asset_dialog.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

/// 排行榜一级页面
class RankingPage extends StatefulWidget {
  /// 创建排行榜一级页面
  ///
  /// [key] Flutter 组件标识
  /// [repository] 排行榜仓库
  /// [characterDetailRepository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [userRepository] 用户仓库
  /// [bottomContentPadding] 滚动内容底部额外预留高度
  /// [scrollResetToken] 滚动位置重置信号
  /// [scrollToTopToken] 平滑滚动到顶部信号
  const RankingPage({
    super.key,
    required this.repository,
    required this.characterDetailRepository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
    this.bottomContentPadding = 0,
    this.scrollResetToken = 0,
    this.scrollToTopToken = 0,
  });

  /// 排行榜仓库
  final RankingRepository repository;

  /// 角色详情仓库
  final CharacterDetailRepository characterDetailRepository;

  /// 圣殿仓库
  final TempleRepository templeRepository;

  /// 圣殿资产魔法道具仓库
  final TempleAssetMagicRepository magicRepository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 用户仓库
  final UserRepository userRepository;

  /// 滚动内容底部额外预留高度
  final double bottomContentPadding;

  /// 滚动位置重置信号
  final int scrollResetToken;

  /// 平滑滚动到顶部信号
  final int scrollToTopToken;

  /// 创建排行榜一级页面状态
  @override
  State<RankingPage> createState() => _RankingPageState();
}

/// 排行榜一级页面状态
class _RankingPageState extends State<RankingPage> {
  late final TempleRefineRankingController _refineController;
  late final UserWealthRankingController _wealthController;
  bool _hasInitializedWealth = false;

  /// 初始化排行榜分页控制器
  @override
  void initState() {
    super.initState();
    _refineController = TempleRefineRankingController(
      repository: widget.repository,
    )..initialize();
    _wealthController = UserWealthRankingController(
      repository: widget.repository,
    );
  }

  /// 释放排行榜分页控制器
  @override
  void dispose() {
    _refineController.dispose();
    _wealthController.dispose();
    super.dispose();
  }

  /// 构建排行榜一级页面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TinygrailTabbedPagedSliverPage<RankingEntry, RankingEntry>(
      title: '排行榜',
      showBackButton: false,
      onSearchPressed: _openCharacterSearchPage,
      bottomContentPadding: widget.bottomContentPadding,
      scrollResetToken: widget.scrollResetToken,
      scrollToTopToken: widget.scrollToTopToken,
      useBlurHeader: false,
      tabs: [
        _buildRefineTab(),
        _buildWealthTab(),
      ],
      onTabPrepared: _handleTabPrepared,
    );
  }

  /// 构建精炼排行标签页
  TinygrailPagedTab<RankingEntry, RankingEntry> _buildRefineTab() {
    return TinygrailPagedTab<RankingEntry, RankingEntry>(
      label: '精炼排行',
      controller: _refineController,
      loadingSliver: const TempleRefineRankingSkeletonGrid(),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无精炼排行',
          message: '当前没有可展示的精炼排行',
          icon: Icons.auto_awesome_outlined,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        final refineItems =
            items.whereType<TempleRefineRankingEntry>().toList(growable: false);

        return [
          TempleRefineRankingSliverGrid(
            items: refineItems,
            onItemBuilt: onItemBuilt,
            onAssetTap: _openTempleAssetDialog,
          ),
        ];
      },
      completedLabel: '没有更多精炼排行了',
    );
  }

  /// 构建番市首富标签页
  TinygrailPagedTab<RankingEntry, RankingEntry> _buildWealthTab() {
    return TinygrailPagedTab<RankingEntry, RankingEntry>(
      label: '番市首富',
      controller: _wealthController,
      loadingSliver: const UserWealthRankingSkeletonList(),
      emptySliverBuilder: (context, controller) {
        return const PagedSliverState(
          title: '暂无番市首富',
          message: '当前没有可展示的用户排行',
          icon: Icons.account_balance_wallet_outlined,
        );
      },
      contentSliversBuilder: (context, items, onItemBuilt) {
        final wealthItems =
            items.whereType<UserWealthRankingEntry>().toList(growable: false);

        return [
          UserWealthRankingSliverList(
            items: wealthItems,
            onItemBuilt: onItemBuilt,
          ),
        ];
      },
      completedLabel: '没有更多番市首富了',
    );
  }

  /// 处理标签页即将展示
  ///
  /// [index] 标签页索引
  void _handleTabPrepared(int index) {
    if (index != 1 || _hasInitializedWealth) {
      return;
    }

    _hasInitializedWealth = true;
    _wealthController.initialize();
  }

  /// 打开精炼排行圣殿资产弹窗
  ///
  /// [item] 精炼排行条目
  void _openTempleAssetDialog(TempleRefineRankingEntry item) {
    final currentUserName =
        widget.userRepository.readCachedCurrentUserAssets()?.name ?? '';

    unawaited(
      showTempleAssetCardDialogFromSource(
        context,
        source: TempleAssetDialogSource(
          ownerName: item.name,
          ownerNickname: item.displayNickname,
          characterId: item.characterId,
        ),
        characterRepository: widget.characterDetailRepository,
        templeRepository: widget.templeRepository,
        magicRepository: widget.magicRepository,
        oosRepository: widget.oosRepository,
        userRepository: widget.userRepository,
        currentUserName: currentUserName,
      ),
    );
  }

  /// 打开角色搜索页
  Future<void> _openCharacterSearchPage() {
    return showCharacterSearchPage(
      context,
      repository: widget.characterDetailRepository,
      templeRepository: widget.templeRepository,
      magicRepository: widget.magicRepository,
      oosRepository: widget.oosRepository,
      userRepository: widget.userRepository,
    );
  }
}
