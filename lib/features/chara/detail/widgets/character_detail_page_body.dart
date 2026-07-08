import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:magrail_app/features/chara/auction/repository/auction_repository.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_basic_info.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_history_item.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_ico_info.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_sacrifice_result.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_user_assets.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_auth_guide.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_bangumi_actions_card.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_ico_header_card.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_ico_start_section.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_ico_participants_section.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_public_sections.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_trade_header_card.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_trade_section.dart';
import 'package:magrail_app/features/chara/detail/widgets/character_detail_user_assets_section.dart';
import 'package:magrail_app/features/chara/trade_history/repository/character_trade_history_repository.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_asset_magic_repository.dart';
import 'package:magrail_app/features/temple/repository/temple_repository.dart';
import 'package:magrail_app/features/user/repository/user_repository.dart';

part 'character_detail_page_body_initial.dart';
part 'character_detail_page_body_states.dart';

/// 角色详情页主体 sliver
class CharacterDetailPageBody extends StatelessWidget {
  /// 创建角色详情页主体 sliver
  ///
  /// [key] Flutter 组件标识
  /// [current] 当前角色资料
  /// [pageType] 当前角色对应的页面类型
  /// [tradeHeader] 当前角色已上市头部资料
  /// [icoInfo] 当前角色 ICO 头部资料
  /// [userAssets] 当前用户在当前角色上的资产状态
  /// [showAuthGuide] 是否显示授权引导
  /// [showTradeSection] 是否显示交易区
  /// [currentUserName] 当前登录用户名
  /// [currentUserDisplayName] 当前登录用户显示名称
  /// [currentUserBalance] 当前登录用户余额
  /// [repository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [userRepository] 用户仓库
  /// [auctionRepository] 拍卖仓库
  /// [tradeHistoryRepository] 角色交易记录仓库
  /// [revealPrivateUserHoldings] 是否允许查看未公开用户持股
  /// [isGameMaster] 当前用户是否为 GM
  /// [collectionsRefreshSignal] 连接与圣殿预览刷新信号
  /// [boardRefreshSignal] 董事会预览刷新信号
  /// [onSacrificeChanged] 资产重组或股权融资成功回调
  /// [onAuctionChanged] 拍卖变更回调
  /// [onAvatarChanged] 头像更换成功回调
  /// [onUserAssetsRetry] 当前用户资产重试回调
  /// [onAuthorize] 打开 Tinygrail 授权页回调
  /// [onIcoStarted] ICO 启动成功回调
  /// [onVoteKill] 投票删除回调
  /// [onRevokeVote] 撤回投票回调
  const CharacterDetailPageBody({
    super.key,
    required this.current,
    required this.pageType,
    required this.tradeHeader,
    required this.icoInfo,
    required this.userAssets,
    required this.showAuthGuide,
    required this.showTradeSection,
    required this.currentUserName,
    required this.currentUserDisplayName,
    required this.currentUserBalance,
    required this.repository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
    required this.auctionRepository,
    required this.tradeHistoryRepository,
    required this.revealPrivateUserHoldings,
    required this.isGameMaster,
    required this.collectionsRefreshSignal,
    required this.boardRefreshSignal,
    required this.onSacrificeChanged,
    required this.onAuctionChanged,
    required this.onAvatarChanged,
    required this.onUserAssetsRetry,
    required this.onAuthorize,
    required this.onIcoStarted,
    required this.onVoteKill,
    required this.onRevokeVote,
  });

  /// 当前角色资料
  final CharacterDetailHistoryItem? current;

  /// 当前角色对应的页面类型
  final CharacterDetailPageType? pageType;

  /// 当前角色已上市头部资料
  final CharacterDetailTradeHeader? tradeHeader;

  /// 当前角色 ICO 头部资料
  final CharacterDetailIcoInfo? icoInfo;

  /// 当前用户在当前角色上的资产状态
  final CharacterDetailUserAssets userAssets;

  /// 是否显示授权引导
  final bool showAuthGuide;

  /// 是否显示交易区
  final bool showTradeSection;

  /// 当前登录用户名
  final String currentUserName;

  /// 当前登录用户显示名称
  final String currentUserDisplayName;

  /// 当前登录用户余额
  final double? currentUserBalance;

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

  /// 拍卖仓库
  final AuctionRepository auctionRepository;

  /// 角色交易记录仓库
  final CharacterTradeHistoryRepository tradeHistoryRepository;

  /// 是否允许查看未公开用户持股
  final bool revealPrivateUserHoldings;

  /// 当前用户是否为 GM
  final bool isGameMaster;

  /// 连接与圣殿预览刷新信号
  final ValueListenable<int> collectionsRefreshSignal;

  /// 董事会预览刷新信号
  final ValueListenable<int> boardRefreshSignal;

  /// 资产重组或股权融资成功回调
  final Future<void> Function(CharacterDetailSacrificeMode mode)
      onSacrificeChanged;

  /// 拍卖变更回调
  final Future<void> Function() onAuctionChanged;

  /// 头像更换成功回调
  final Future<void> Function() onAvatarChanged;

  /// 当前用户资产重试回调
  final Future<void> Function() onUserAssetsRetry;

  /// 打开 Tinygrail 授权页回调
  final Future<void> Function() onAuthorize;

  /// ICO 启动成功回调
  final Future<void> Function() onIcoStarted;

  /// 投票删除回调
  final Future<String> Function({required String reason}) onVoteKill;

  /// 撤回投票回调
  final Future<String> Function() onRevokeVote;

  /// 构建角色详情页主体 sliver
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final currentItem = current;

    if (currentItem == null) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _CharacterDetailInvalidState(),
      );
    }

    return switch (pageType ?? CharacterDetailPageType.pending) {
      CharacterDetailPageType.pending => _CharacterDetailLoadingBody(
          key: ValueKey<String>('loading-${currentItem.characterId}'),
          isGameMaster: isGameMaster,
        ),
      CharacterDetailPageType.trade when tradeHeader == null =>
        _CharacterDetailLoadingBody(
          key: ValueKey<String>('loading-${currentItem.characterId}'),
          isGameMaster: isGameMaster,
        ),
      CharacterDetailPageType.trade => _CharacterDetailTradeBody(
          key: ValueKey<String>('trade-${currentItem.characterId}'),
          tradeHeader: tradeHeader!,
          auctionRepository: auctionRepository,
          tradeHistoryRepository: tradeHistoryRepository,
          isGameMaster: isGameMaster,
          onAuctionChanged: onAuctionChanged,
          userAssets: userAssets,
          showAuthGuide: showAuthGuide,
          showTradeSection: showTradeSection,
          currentUserName: currentUserName,
          currentUserDisplayName: currentUserDisplayName,
          repository: repository,
          templeRepository: templeRepository,
          magicRepository: magicRepository,
          oosRepository: oosRepository,
          userRepository: userRepository,
          revealPrivateUserHoldings: revealPrivateUserHoldings,
          collectionsRefreshSignal: collectionsRefreshSignal,
          boardRefreshSignal: boardRefreshSignal,
          onSacrificeChanged: onSacrificeChanged,
          onAvatarChanged: onAvatarChanged,
          onUserAssetsRetry: onUserAssetsRetry,
          onAuthorize: onAuthorize,
          onVoteKill: onVoteKill,
          onRevokeVote: onRevokeVote,
        ),
      CharacterDetailPageType.ico when icoInfo == null =>
        _CharacterDetailLoadingBody(
          key: ValueKey<String>('loading-${currentItem.characterId}'),
          isGameMaster: isGameMaster,
        ),
      CharacterDetailPageType.ico => _CharacterDetailIcoBody(
          key: ValueKey<String>('ico-${currentItem.characterId}'),
          repository: repository,
          icoInfo: icoInfo!,
          onCharacterSynced: onAvatarChanged,
        ),
      CharacterDetailPageType.initial => _CharacterDetailInitialBody(
          key: ValueKey<String>('initial-${currentItem.characterId}'),
          item: currentItem,
          repository: repository,
          isAuthorized: showTradeSection,
          showAuthGuide: showAuthGuide,
          currentUserBalance: currentUserBalance,
          onAuthorize: onAuthorize,
          onIcoStarted: onIcoStarted,
        ),
      CharacterDetailPageType.failure => const SliverFillRemaining(
          hasScrollBody: false,
          child: _CharacterDetailCenteredMessage(
            icon: Icons.account_circle_outlined,
            title: '角色详情加载失败',
            message: '请稍后重试',
          ),
        ),
    };
  }
}

/// 角色详情 ICO 主体
class _CharacterDetailIcoBody extends StatelessWidget {
  /// 创建角色详情 ICO 主体
  ///
  /// [key] Flutter 组件标识
  /// [repository] 角色详情仓库
  /// [icoInfo] 当前角色 ICO 头部资料
  /// [onCharacterSynced] 角色资料同步后的刷新回调
  const _CharacterDetailIcoBody({
    super.key,
    required this.repository,
    required this.icoInfo,
    required this.onCharacterSynced,
  });

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// 当前角色 ICO 头部资料
  final CharacterDetailIcoInfo icoInfo;

  /// 角色资料同步后的刷新回调
  final Future<void> Function() onCharacterSynced;

  /// 构建角色详情 ICO 主体
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
          sliver: SliverList.list(
            children: [
              CharacterDetailIcoHeaderCard(info: icoInfo),
              const SizedBox(height: 12),
              CharacterDetailBangumiActionsCard(
                characterId: icoInfo.characterId,
                characterName: icoInfo.name,
                characterIcon: icoInfo.icon,
                repository: repository,
                onCharacterSynced: onCharacterSynced,
              ),
            ],
          ),
        ),
        CharacterDetailIcoParticipantsSection(
          key: ValueKey<String>(
            'ico-participants-${icoInfo.id}-${icoInfo.users}-${icoInfo.total}',
          ),
          repository: repository,
          icoInfo: icoInfo,
        ),
      ],
    );
  }
}

/// 角色详情统一加载主体
class _CharacterDetailLoadingBody extends StatelessWidget {
  /// 创建角色详情统一加载主体
  ///
  /// [key] Flutter 组件标识
  /// [isGameMaster] 当前用户是否为 GM
  const _CharacterDetailLoadingBody({
    super.key,
    required this.isGameMaster,
  });

  /// 当前用户是否为 GM
  final bool isGameMaster;

  /// 构建角色详情统一加载主体
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      sliver: SliverList.list(
        children: [
          const CharacterDetailTradeHeaderSkeleton(),
          const SizedBox(height: 12),
          CharacterDetailTradeHeaderActionsSkeleton(
            isGameMaster: isGameMaster,
          ),
          const SizedBox(height: 12),
          const CharacterDetailUserAssetsSkeleton(),
          const SizedBox(height: 12),
          const CharacterDetailTradeSectionSkeleton(),
        ],
      ),
    );
  }
}

/// 角色详情已上市主体占位区
class _CharacterDetailTradeBody extends StatelessWidget {
  /// 创建角色详情已上市主体占位区
  ///
  /// [key] Flutter 组件标识
  /// [tradeHeader] 当前角色已上市头部资料
  /// [auctionRepository] 拍卖仓库
  /// [tradeHistoryRepository] 角色交易记录仓库
  /// [isGameMaster] 当前用户是否为 GM
  /// [onAuctionChanged] 拍卖变更回调
  /// [userAssets] 当前用户在当前角色上的资产状态
  /// [showAuthGuide] 是否显示授权引导
  /// [showTradeSection] 是否显示交易区
  /// [currentUserName] 当前登录用户名
  /// [currentUserDisplayName] 当前登录用户显示名称
  /// [repository] 角色详情仓库
  /// [templeRepository] 圣殿仓库
  /// [magicRepository] 圣殿资产魔法道具仓库
  /// [userRepository] 用户仓库
  /// [revealPrivateUserHoldings] 是否允许查看未公开用户持股
  /// [collectionsRefreshSignal] 连接与圣殿预览刷新信号
  /// [boardRefreshSignal] 董事会预览刷新信号
  /// [onSacrificeChanged] 资产重组或股权融资成功回调
  /// [onAvatarChanged] 头像更换成功回调
  /// [onUserAssetsRetry] 当前用户资产重试回调
  /// [onAuthorize] 打开 Tinygrail 授权页回调
  /// [onVoteKill] 投票删除回调
  /// [onRevokeVote] 撤回投票回调
  const _CharacterDetailTradeBody({
    super.key,
    required this.tradeHeader,
    required this.auctionRepository,
    required this.tradeHistoryRepository,
    required this.isGameMaster,
    required this.onAuctionChanged,
    required this.userAssets,
    required this.showAuthGuide,
    required this.showTradeSection,
    required this.currentUserName,
    required this.currentUserDisplayName,
    required this.repository,
    required this.templeRepository,
    required this.magicRepository,
    required this.oosRepository,
    required this.userRepository,
    required this.revealPrivateUserHoldings,
    required this.collectionsRefreshSignal,
    required this.boardRefreshSignal,
    required this.onSacrificeChanged,
    required this.onAvatarChanged,
    required this.onUserAssetsRetry,
    required this.onAuthorize,
    required this.onVoteKill,
    required this.onRevokeVote,
  });

  /// 当前角色已上市头部资料
  final CharacterDetailTradeHeader tradeHeader;

  /// 拍卖仓库
  final AuctionRepository auctionRepository;

  /// 角色交易记录仓库
  final CharacterTradeHistoryRepository tradeHistoryRepository;

  /// 当前用户是否为 GM
  final bool isGameMaster;

  /// 拍卖变更回调
  final Future<void> Function() onAuctionChanged;

  /// 当前用户在当前角色上的资产状态
  final CharacterDetailUserAssets userAssets;

  /// 是否显示授权引导
  final bool showAuthGuide;

  /// 是否显示交易区
  final bool showTradeSection;

  /// 当前登录用户名
  final String currentUserName;

  /// 当前登录用户显示名称
  final String currentUserDisplayName;

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

  /// 是否允许查看未公开用户持股
  final bool revealPrivateUserHoldings;

  /// 连接与圣殿预览刷新信号
  final ValueListenable<int> collectionsRefreshSignal;

  /// 董事会预览刷新信号
  final ValueListenable<int> boardRefreshSignal;

  /// 资产重组或股权融资成功回调
  final Future<void> Function(CharacterDetailSacrificeMode mode)
      onSacrificeChanged;

  /// 头像更换成功回调
  final Future<void> Function() onAvatarChanged;

  /// 当前用户资产重试回调
  final Future<void> Function() onUserAssetsRetry;

  /// 打开 Tinygrail 授权页回调
  final Future<void> Function() onAuthorize;

  /// 投票删除回调
  final Future<String> Function({required String reason}) onVoteKill;

  /// 撤回投票回调
  final Future<String> Function() onRevokeVote;

  /// 构建角色详情已上市主体占位区
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
          sliver: SliverList.list(
            children: [
              CharacterDetailTradeHeaderSection(header: tradeHeader),
              const SizedBox(height: 12),
              CharacterDetailTradeHeaderActions(
                header: tradeHeader,
                repository: repository,
                userRepository: userRepository,
                auctionRepository: auctionRepository,
                tradeHistoryRepository: tradeHistoryRepository,
                oosRepository: oosRepository,
                isGameMaster: isGameMaster,
                currentUserName: currentUserName,
                onSacrificeChanged: onSacrificeChanged,
                onAuctionChanged: onAuctionChanged,
                onAvatarChanged: onAvatarChanged,
                onVoteKill: onVoteKill,
                onRevokeVote: onRevokeVote,
              ),
              const SizedBox(height: 12),
              if (showAuthGuide)
                CharacterDetailAuthGuideSection(
                  onAuthorize: onAuthorize,
                )
              else ...[
                CharacterDetailUserAssetsSection(
                  header: tradeHeader,
                  assets: userAssets,
                  currentUserDisplayName: currentUserDisplayName,
                  currentUserName: currentUserName,
                  repository: repository,
                  templeRepository: templeRepository,
                  magicRepository: magicRepository,
                  oosRepository: oosRepository,
                  userRepository: userRepository,
                  onRetry: onUserAssetsRetry,
                  onAuthorize: onAuthorize,
                ),
                if (showTradeSection) ...[
                  const SizedBox(height: 12),
                  CharacterDetailTradeSection(
                    key: ValueKey<String>(
                      'trade-section-${tradeHeader.characterId}-'
                      '${tradeHeader.currentUserId ?? 0}',
                    ),
                    repository: repository,
                    header: tradeHeader,
                    onChanged: onAuctionChanged,
                  ),
                ],
              ],
            ],
          ),
        ),
        CharacterDetailPublicSections(
          key: ValueKey<String>('public-${tradeHeader.characterId}'),
          repository: repository,
          templeRepository: templeRepository,
          magicRepository: magicRepository,
          oosRepository: oosRepository,
          userRepository: userRepository,
          header: tradeHeader,
          currentUserName: currentUserName,
          revealPrivateUserHoldings: revealPrivateUserHoldings,
          collectionsRefreshSignal: collectionsRefreshSignal,
          boardRefreshSignal: boardRefreshSignal,
        ),
      ],
    );
  }
}
