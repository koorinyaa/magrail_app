import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/viewer/fullscreen_image_viewer_page.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/core/widgets/temple_cover_image.dart';
import 'package:magrail_app/features/chara/detail/character_detail_navigation.dart';
import 'package:magrail_app/features/chara/model/tinygrail_character_reward_item.dart';

/// Tinygrail 角色抽奖卡片
class TinygrailCharacterRewardCard extends StatelessWidget {
  /// 创建 Tinygrail 角色抽奖卡片
  ///
  /// [item] 角色抽奖条目
  /// [heroTag] 封面 Hero 标识
  /// [enableCoverPreview] 是否允许打开封面大图
  const TinygrailCharacterRewardCard({
    super.key,
    required this.item,
    this.heroTag,
    this.enableCoverPreview = false,
  });

  /// 角色抽奖条目
  final TinygrailCharacterRewardItem item;

  /// 封面 Hero 标识
  final String? heroTag;

  /// 是否允许打开封面大图
  final bool enableCoverPreview;

  /// 构建 Tinygrail 角色抽奖卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: _RewardCover(
            item: item,
            heroTag: heroTag,
            enableCoverPreview: enableCoverPreview,
          ),
        ),
        const SizedBox(height: 8),
        _RewardTitle(item: item),
      ],
    );
  }
}

/// Tinygrail 角色抽奖封面
class _RewardCover extends StatelessWidget {
  /// 创建 Tinygrail 角色抽奖封面
  ///
  /// [item] 角色抽奖条目
  /// [heroTag] 封面 Hero 标识
  /// [enableCoverPreview] 是否允许打开封面大图
  const _RewardCover({
    required this.item,
    required this.heroTag,
    required this.enableCoverPreview,
  });

  /// 角色抽奖条目
  final TinygrailCharacterRewardItem item;

  /// 封面 Hero 标识
  final String? heroTag;

  /// 是否允许打开封面大图
  final bool enableCoverPreview;

  /// 构建 Tinygrail 角色抽奖封面
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final coverUrl = TinygrailAssetUrls.getLargeCover(item.cover);
    final image = TempleCoverImage(
      coverUrl: coverUrl,
      avatarUrl: '',
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (heroTag == null)
            image
          else
            Hero(
              tag: heroTag!,
              child: image,
            ),
          Positioned(
            right: 8,
            top: 8,
            child: _RewardAmountPill(amount: item.amount),
          ),
          if (enableCoverPreview && heroTag != null)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openImage(context, coverUrl, heroTag!),
                  splashColor: Colors.white.withValues(alpha: 0.12),
                  highlightColor: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 打开角色封面大图
  ///
  /// [context] 当前组件树上下文
  /// [coverUrl] 封面大图地址
  /// [heroTag] 封面 Hero 标识
  void _openImage(BuildContext context, String coverUrl, String heroTag) {
    if (coverUrl.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullscreenImageViewerPage(
            imageUrl: coverUrl,
            heroTag: heroTag,
          );
        },
      ),
    );
  }
}

/// Tinygrail 角色抽奖名称与价格区域
class _RewardTitle extends StatelessWidget {
  /// 创建 Tinygrail 角色抽奖名称与价格区域
  ///
  /// [item] 角色抽奖条目
  const _RewardTitle({
    required this.item,
  });

  /// 角色抽奖条目
  final TinygrailCharacterRewardItem item;

  /// 构建 Tinygrail 角色抽奖名称与价格区域
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = TinygrailFormatters.decodeHtmlEntities(item.name);

    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openCharacter(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          name.isEmpty ? '#${item.id}' : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      LevelBadge(
                        level: item.level,
                        isCompact: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _RewardPricePill(price: item.currentPrice),
      ],
    );
  }

  /// 打开角色详情
  ///
  /// [context] 当前组件树上下文
  void _openCharacter(BuildContext context) {
    openCharacterDetail(
      context,
      characterId: item.id,
      name: item.name,
    );
  }
}

/// Tinygrail 角色抽奖获得数量胶囊
class _RewardAmountPill extends StatelessWidget {
  /// 创建 Tinygrail 角色抽奖获得数量胶囊
  ///
  /// [amount] 获得数量
  const _RewardAmountPill({
    required this.amount,
  });

  /// 获得数量
  final int amount;

  /// 构建 Tinygrail 角色抽奖获得数量胶囊
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          '×${Formatters.groupedNumber(amount)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Tinygrail 角色抽奖当前价格胶囊
class _RewardPricePill extends StatelessWidget {
  /// 创建 Tinygrail 角色抽奖当前价格胶囊
  ///
  /// [price] 当前价格
  const _RewardPricePill({
    required this.price,
  });

  /// 当前价格
  final double price;

  /// 构建 Tinygrail 角色抽奖当前价格胶囊
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.42 : 0.72,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.18 : 0.46,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          Formatters.tinygrailCurrency(price),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}
