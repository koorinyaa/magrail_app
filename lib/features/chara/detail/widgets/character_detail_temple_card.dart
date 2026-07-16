import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_temple_link_order.dart';
import 'package:magrail_app/core/viewer/fullscreen_image_viewer_page.dart';
import 'package:magrail_app/core/widgets/temple_card.dart';
import 'package:magrail_app/core/widgets/temple_link_card.dart';
import 'package:magrail_app/core/widgets/temple_link_dialog.dart';
import 'package:magrail_app/core/widgets/temple_linked_cover_stack.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';

/// 角色详情固定资产卡片
class CharacterDetailTempleCard extends StatelessWidget {
  /// 创建角色详情固定资产卡片
  ///
  /// [key] Flutter 组件标识
  /// [item] 角色详情圣殿条目
  /// [fallbackCharacterName] 角色名称兜底文案
  /// [width] 卡片宽度
  /// [heroTagPrefix] 图片 Hero 标识前缀
  /// [onCharacterTap] 角色点击回调
  /// [onOwnerTap] 拥有者点击回调
  /// [onAssetTap] 圣殿资产卡片入口回调
  /// [onLinkedAssetTap] LINK 圣殿资产卡片入口回调
  const CharacterDetailTempleCard({
    super.key,
    required this.item,
    required this.fallbackCharacterName,
    required this.width,
    this.heroTagPrefix = 'character-temple-cover',
    this.onCharacterTap,
    this.onOwnerTap,
    this.onAssetTap,
    this.onLinkedAssetTap,
  });

  /// 角色详情圣殿条目
  final CharacterDetailTempleItem item;

  /// 角色名称兜底文案
  final String fallbackCharacterName;

  /// 卡片宽度
  final double width;

  /// 图片 Hero 标识前缀
  final String heroTagPrefix;

  /// 角色点击回调
  final ValueChanged<CharacterDetailTempleItem>? onCharacterTap;

  /// 拥有者点击回调
  final ValueChanged<CharacterDetailTempleItem>? onOwnerTap;

  /// 圣殿资产卡片入口回调
  final ValueChanged<CharacterDetailTempleItem>? onAssetTap;

  /// LINK 圣殿资产卡片入口回调
  final void Function(
    CharacterDetailTempleItem ownerItem,
    CharacterDetailTempleItem linkedItem,
  )? onLinkedAssetTap;

  /// 根据卡片宽度计算整体高度
  ///
  /// [width] 卡片宽度
  static double heightForWidth(double width) {
    return width / 3 * 4 + _CharacterTempleAssetProgress.height + 10;
  }

  /// 构建角色详情固定资产卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final linkedTemple = item.link;
    final coverWidth = linkedTemple == null
        ? width
        : TempleLinkedCoverStack.coverWidthFor(width);
    final mainCard = TempleCard(
      width: coverWidth,
      coverUrl: TinygrailAssetUrls.getSmallCover(item.cover),
      avatarUrl: TinygrailAssetUrls.normalizeAvatar(item.avatar),
      characterName: TinygrailFormatters.decodeHtmlEntities(
        item.displayCharacterName(fallbackCharacterName),
      ),
      characterLevel: item.characterLevel,
      zeroCount: item.zeroCount,
      ownerLabel: item.ownerLabel,
      templeLevel: item.level,
      refine: item.refine,
      starForces: item.starForces,
      heroTag: _heroTag(item),
      showCharacterInfo: false,
      onTap: () => _openImageViewer(context, item),
      onCharacterTap:
          onCharacterTap == null ? null : () => onCharacterTap!(item),
      onUserTap: onOwnerTap == null ? null : () => onOwnerTap!(item),
      onAssetTap: onAssetTap == null ? null : () => onAssetTap!(item),
      onLinkTap: linkedTemple == null ? null : () => _openLinkDialog(context),
    );
    final cover = linkedTemple == null
        ? mainCard
        : TempleLinkedCoverStack(
            width: width,
            frontCover: mainCard,
            linkedCover: TempleLinkedCover(
              width: coverWidth,
              coverUrl: TinygrailAssetUrls.getSmallCover(linkedTemple.cover),
              avatarUrl: TinygrailAssetUrls.normalizeAvatar(
                linkedTemple.avatar,
              ),
            ),
          );

    return SizedBox(
      width: width,
      height: heightForWidth(width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width,
            height: width / 3 * 4,
            child: cover,
          ),
          const SizedBox(height: 8),
          _CharacterTempleAssetProgress(item: item),
        ],
      ),
    );
  }

  /// 打开角色圣殿 LINK 弹窗
  ///
  /// [context] 当前组件树上下文
  void _openLinkDialog(BuildContext context) {
    final linkedTemple = item.link;
    if (linkedTemple == null) {
      return;
    }
    final currentOnLeft = TinygrailTempleLinkOrder.keepsFirstOnLeft(
      firstSacrifices: item.sacrifices,
      firstCreate: item.create,
      secondSacrifices: linkedTemple.sacrifices,
      secondCreate: linkedTemple.create,
    );
    final leftTemple = currentOnLeft ? item : linkedTemple;
    final rightTemple = currentOnLeft ? linkedTemple : item;

    showTempleLinkDialog(
      context,
      cardBuilder: (cardWidth) {
        return TempleLinkCard(
          width: cardWidth,
          leftCoverUrl: TinygrailAssetUrls.getSmallCover(leftTemple.cover),
          leftAvatarUrl: TinygrailAssetUrls.normalizeAvatar(
            leftTemple.avatar,
          ),
          leftCharacterName: TinygrailFormatters.decodeHtmlEntities(
            leftTemple.displayCharacterName(
              currentOnLeft ? fallbackCharacterName : '连接角色',
            ),
          ),
          onLeftCoverTap: () => _openImageViewer(context, leftTemple),
          onLeftCharacterTap:
              onCharacterTap == null ? null : () => onCharacterTap!(leftTemple),
          onLeftAssetTap: currentOnLeft
              ? (onAssetTap == null ? null : () => onAssetTap!(item))
              : (onLinkedAssetTap == null
                  ? null
                  : () => onLinkedAssetTap!(item, linkedTemple)),
          rightCoverUrl: TinygrailAssetUrls.getSmallCover(
            rightTemple.cover,
          ),
          rightAvatarUrl: TinygrailAssetUrls.normalizeAvatar(
            rightTemple.avatar,
          ),
          rightCharacterName: TinygrailFormatters.decodeHtmlEntities(
            rightTemple.displayCharacterName(
              currentOnLeft ? '连接角色' : fallbackCharacterName,
            ),
          ),
          onRightCoverTap: () => _openImageViewer(context, rightTemple),
          onRightCharacterTap: onCharacterTap == null
              ? null
              : () => onCharacterTap!(rightTemple),
          onRightAssetTap: currentOnLeft
              ? (onLinkedAssetTap == null
                  ? null
                  : () => onLinkedAssetTap!(item, linkedTemple))
              : (onAssetTap == null ? null : () => onAssetTap!(item)),
        );
      },
    );
  }

  /// 打开固定资产封面大图
  ///
  /// [context] 当前组件树上下文
  /// [temple] 角色详情圣殿条目
  void _openImageViewer(
    BuildContext context,
    CharacterDetailTempleItem temple,
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

  /// 解析图片 Hero 标识
  ///
  /// [temple] 角色详情圣殿条目
  String _heroTag(CharacterDetailTempleItem temple) {
    return '$heroTagPrefix-${temple.id}-${temple.characterId}';
  }
}

/// 角色详情固定资产进度条
class _CharacterTempleAssetProgress extends StatelessWidget {
  /// 创建角色详情固定资产进度条
  ///
  /// [item] 角色详情圣殿条目
  const _CharacterTempleAssetProgress({
    required this.item,
  });

  /// 进度条区域高度
  static const double height = 26;

  /// 角色详情圣殿条目
  final CharacterDetailTempleItem item;

  /// 构建角色详情固定资产进度条
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trackColor = colorScheme.onSurfaceVariant.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.24 : 0.14,
    );
    final progressColor = _themeColor.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.92 : 0.86,
    );
    final progress = item.sacrifices <= 0
        ? 0.0
        : (item.assets / item.sacrifices).clamp(0.0, 1.0).toDouble();

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _assetLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: trackColor,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 固定资产进度文案
  String get _assetLabel {
    return '${Formatters.groupedNumber(item.assets)} / '
        '${Formatters.groupedNumber(item.sacrifices)}';
  }

  /// 圣殿主题色
  Color get _themeColor {
    return switch (item.level) {
      2 => const Color(0xFFEAB308),
      3 => const Color(0xFFA855F7),
      _ => const Color(0xFF9CA3AF),
    };
  }
}
