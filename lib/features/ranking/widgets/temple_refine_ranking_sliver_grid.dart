import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/viewer/fullscreen_image_viewer_page.dart';
import 'package:magrail_app/core/widgets/temple_card.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/ranking/model/ranking_entry.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 精炼排行 sliver 网格
class TempleRefineRankingSliverGrid extends StatelessWidget {
  /// 创建精炼排行 sliver 网格
  ///
  /// [key] Flutter 组件标识
  /// [items] 精炼排行条目
  /// [onItemBuilt] 条目构建回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const TempleRefineRankingSliverGrid({
    super.key,
    required this.items,
    required this.onItemBuilt,
    required this.onAssetTap,
  });

  static const double _horizontalPadding = 12;
  static const double _spacing = 10;
  static const double _maxCardExtent = 190;
  static const double _cardAspectRatio = 3 / 4;
  static const double _infoHeight = 28;

  /// 精炼排行条目
  final List<TempleRefineRankingEntry> items;

  /// 条目构建回调
  final ValueChanged<int> onItemBuilt;

  /// 圣殿资产入口点击回调
  final ValueChanged<TempleRefineRankingEntry> onAssetTap;

  /// 构建精炼排行 sliver 网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: _horizontalPadding,
        top: 10,
        right: _horizontalPadding,
        bottom: 0,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: _maxCardExtent,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
          childAspectRatio: _cardAspectRatio /
              (1 + _infoHeight * _cardAspectRatio / _maxCardExtent),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            onItemBuilt(index);

            return _RefineRankingGridItem(
              item: item,
              onAssetTap: () => onAssetTap(item),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

/// 精炼排行骨架网格
class TempleRefineRankingSkeletonGrid extends StatelessWidget {
  /// 创建精炼排行骨架网格
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  const TempleRefineRankingSkeletonGrid({
    super.key,
    this.itemCount = 20,
  });

  /// 骨架条目数量
  final int itemCount;

  /// 构建精炼排行骨架网格
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: TempleRefineRankingSliverGrid._horizontalPadding,
        top: 10,
        right: TempleRefineRankingSliverGrid._horizontalPadding,
        bottom: 0,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: TempleRefineRankingSliverGrid._maxCardExtent,
          mainAxisSpacing: TempleRefineRankingSliverGrid._spacing,
          crossAxisSpacing: TempleRefineRankingSliverGrid._spacing,
          childAspectRatio: TempleRefineRankingSliverGrid._cardAspectRatio /
              (1 +
                  TempleRefineRankingSliverGrid._infoHeight *
                      TempleRefineRankingSliverGrid._cardAspectRatio /
                      TempleRefineRankingSliverGrid._maxCardExtent),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return const _RefineRankingSkeletonItem();
          },
          childCount: itemCount,
        ),
      ),
    );
  }
}

/// 精炼排行网格条目
class _RefineRankingGridItem extends StatelessWidget {
  /// 创建精炼排行网格条目
  ///
  /// [item] 精炼排行条目
  /// [onAssetTap] 圣殿资产入口点击回调
  const _RefineRankingGridItem({
    required this.item,
    required this.onAssetTap,
  });

  /// 精炼排行条目
  final TempleRefineRankingEntry item;

  /// 圣殿资产入口点击回调
  final VoidCallback onAssetTap;

  /// 构建精炼排行网格条目
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = cardWidth / 3 * 4;

        return SizedBox(
          height: constraints.maxHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: cardHeight,
                child: TempleCard(
                  width: cardWidth,
                  coverUrl: TinygrailAssetUrls.getSmallCover(item.cover),
                  avatarUrl: TinygrailAssetUrls.normalizeAvatar(item.avatar),
                  characterName: item.displayCharacterName,
                  characterLevel: item.characterLevel,
                  zeroCount: item.zeroCount,
                  ownerLabel: '@${item.displayNickname}',
                  templeLevel: item.level,
                  refine: item.refine,
                  starForces: item.starForces,
                  borderRadius: 20,
                  heroTag: _heroTag(item),
                  onTap: () => _openImageViewer(context, item),
                  onAssetTap: onAssetTap,
                  onCharacterTap: () => openCharacterDetail(
                    context,
                    characterId: item.characterId,
                    name: item.displayCharacterName,
                  ),
                  onUserTap: () => _openUser(context, item.name),
                ),
              ),
              const SizedBox(height: 6),
              _RefineRankingMeta(item: item),
            ],
          ),
        );
      },
    );
  }

  /// 打开圣殿封面大图
  ///
  /// [context] 当前组件树上下文
  /// [temple] 精炼排行条目
  void _openImageViewer(
    BuildContext context,
    TempleRefineRankingEntry temple,
  ) {
    final coverUrl = TinygrailAssetUrls.getLargeCover(temple.cover);
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(temple.avatar);
    final imageUrl = coverUrl.isNotEmpty ? coverUrl : avatarUrl;
    if (imageUrl.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullscreenImageViewerPage(
            imageUrl: imageUrl,
            heroTag: _heroTag(temple),
          );
        },
      ),
    );
  }

  /// 打开用户详情页
  ///
  /// [context] 当前组件树上下文
  /// [username] 用户名
  void _openUser(BuildContext context, String username) {
    if (username.trim().isEmpty) {
      return;
    }

    context.pushNamed(
      'userDetail',
      queryParameters: {'username': username},
    );
  }

  /// 生成圣殿封面 Hero 标识
  ///
  /// [temple] 精炼排行条目
  String _heroTag(TempleRefineRankingEntry temple) {
    return 'refine-ranking-temple-cover-${temple.id}-${temple.characterId}';
  }
}

/// 精炼排行元信息
class _RefineRankingMeta extends StatelessWidget {
  /// 创建精炼排行元信息
  ///
  /// [item] 精炼排行条目
  const _RefineRankingMeta({
    required this.item,
  });

  /// 精炼排行条目
  final TempleRefineRankingEntry item;

  /// 构建精炼排行元信息
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeText = TinygrailFormatters.shortRelativeTime(
      item.lastActiveDate,
    );
    final timeColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.72);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          _RankBadge(rank: item.rank),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  LucideIcons.clock3,
                  size: 11,
                  color: timeColor,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    timeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: timeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 精炼排行骨架条目
class _RefineRankingSkeletonItem extends StatelessWidget {
  /// 创建精炼排行骨架条目
  const _RefineRankingSkeletonItem();

  /// 构建精炼排行骨架条目
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Skeletonizer.zone(
          child: SizedBox(
            height: constraints.maxHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth / 3 * 4,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 6),
                const _RefineRankingSkeletonMeta(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 精炼排行元信息骨架
class _RefineRankingSkeletonMeta extends StatelessWidget {
  /// 创建精炼排行元信息骨架
  const _RefineRankingSkeletonMeta();

  /// 构建精炼排行元信息骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Bone(
            width: 34,
            height: 17,
            borderRadius: BorderRadius.circular(7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Bone(
                  width: 11,
                  height: 11,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Bone(
                    width: 48,
                    height: 11,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 排名徽标
class _RankBadge extends StatelessWidget {
  /// 创建排名徽标
  ///
  /// [rank] 当前排名
  const _RankBadge({
    required this.rank,
  });

  /// 当前排名
  final int rank;

  /// 构建排名徽标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 17,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        '#$rank',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
