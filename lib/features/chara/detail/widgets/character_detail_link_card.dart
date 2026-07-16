import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_temple_link_order.dart';
import 'package:magrail_app/core/viewer/fullscreen_image_viewer_page.dart';
import 'package:magrail_app/core/widgets/temple_link_card.dart';
import 'package:magrail_app/core/widgets/temple_link_value_chip.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_temple_item.dart';

/// 角色详情 LINK 卡片
class CharacterDetailLinkCard extends StatelessWidget {
  /// 创建角色详情 LINK 卡片
  ///
  /// [key] Flutter 组件标识
  /// [item] 角色详情 LINK 条目
  /// [fallbackCharacterName] 当前角色名称兜底文案
  /// [width] 卡片宽度
  /// [heroTagPrefix] 图片 Hero 标识前缀
  /// [onCharacterTap] 角色点击回调
  /// [onOwnerTap] 拥有者点击回调
  /// [onTempleAssetTap] 当前角色圣殿资产入口回调
  /// [onLinkedAssetTap] LINK 圣殿资产入口回调
  const CharacterDetailLinkCard({
    super.key,
    required this.item,
    required this.fallbackCharacterName,
    this.width = defaultWidth,
    this.heroTagPrefix = 'character-link-cover',
    this.onCharacterTap,
    this.onOwnerTap,
    this.onTempleAssetTap,
    this.onLinkedAssetTap,
  });

  /// 默认卡片宽度
  static const double defaultWidth = 288;

  /// 图片区域高度
  static const double imageHeight = 222;

  /// 卡片整体高度
  static const double totalHeight = 258;

  /// 角色详情 LINK 条目
  final CharacterDetailTempleItem item;

  /// 当前角色名称兜底文案
  final String fallbackCharacterName;

  /// 卡片宽度
  final double width;

  /// 图片 Hero 标识前缀
  final String heroTagPrefix;

  /// 角色点击回调
  final ValueChanged<CharacterDetailTempleItem>? onCharacterTap;

  /// 拥有者点击回调
  final ValueChanged<CharacterDetailTempleItem>? onOwnerTap;

  /// 当前角色圣殿资产入口回调
  final ValueChanged<CharacterDetailTempleItem>? onTempleAssetTap;

  /// LINK 圣殿资产入口回调
  final void Function(
    CharacterDetailTempleItem ownerItem,
    CharacterDetailTempleItem linkedItem,
  )? onLinkedAssetTap;

  /// 根据卡片宽度计算卡片高度
  ///
  /// [width] 卡片宽度
  static double heightForWidth(double width) {
    return imageHeight * width / defaultWidth + (totalHeight - imageHeight);
  }

  /// 构建角色详情 LINK 卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final linked = item.link;
    if (linked == null) {
      return const SizedBox.shrink();
    }
    final currentOnLeft = TinygrailTempleLinkOrder.keepsFirstOnLeft(
      firstSacrifices: item.sacrifices,
      firstCreate: item.create,
      secondSacrifices: linked.sacrifices,
      secondCreate: linked.create,
    );
    final left = currentOnLeft ? item : linked;
    final right = currentOnLeft ? linked : item;

    return SizedBox(
      width: width,
      height: heightForWidth(width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TempleLinkCard(
            width: width,
            leftCoverUrl: TinygrailAssetUrls.getSmallCover(left.cover),
            leftAvatarUrl: TinygrailAssetUrls.normalizeAvatar(left.avatar),
            leftCharacterName: TinygrailFormatters.decodeHtmlEntities(
              left.displayCharacterName(
                currentOnLeft ? fallbackCharacterName : '连接角色',
              ),
            ),
            leftHeroTag: _heroTag(left, 'left'),
            onLeftCoverTap: () => _openImageViewer(context, left, 'left'),
            onLeftCharacterTap:
                onCharacterTap == null ? null : () => onCharacterTap!(left),
            onLeftAssetTap: currentOnLeft
                ? (onTempleAssetTap == null
                    ? null
                    : () => onTempleAssetTap!(item))
                : (onLinkedAssetTap == null
                    ? null
                    : () => onLinkedAssetTap!(item, linked)),
            rightCoverUrl: TinygrailAssetUrls.getSmallCover(right.cover),
            rightAvatarUrl: TinygrailAssetUrls.normalizeAvatar(right.avatar),
            rightCharacterName: TinygrailFormatters.decodeHtmlEntities(
              right.displayCharacterName(
                currentOnLeft ? '连接角色' : fallbackCharacterName,
              ),
            ),
            rightHeroTag: _heroTag(right, 'right'),
            onRightCoverTap: () => _openImageViewer(context, right, 'right'),
            onRightCharacterTap:
                onCharacterTap == null ? null : () => onCharacterTap!(right),
            onRightAssetTap: currentOnLeft
                ? (onLinkedAssetTap == null
                    ? null
                    : () => onLinkedAssetTap!(item, linked))
                : (onTempleAssetTap == null
                    ? null
                    : () => onTempleAssetTap!(item)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                Flexible(
                  child: _LinkOwnerButton(
                    label: item.ownerLabel,
                    onTap: onOwnerTap == null ? null : () => onOwnerTap!(item),
                  ),
                ),
                const SizedBox(width: 7),
                TempleLinkValueChip(
                  valueLabel: Formatters.tinygrailCompactValue(
                    item.linkValue,
                    prefix: '+',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 打开 LINK 封面大图
  ///
  /// [context] 当前组件树上下文
  /// [temple] 角色详情圣殿条目
  /// [side] LINK 卡片左右位置
  void _openImageViewer(
    BuildContext context,
    CharacterDetailTempleItem temple,
    String side,
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
            heroTag: _heroTag(temple, side),
          );
        },
      ),
    );
  }

  /// 解析图片 Hero 标识
  ///
  /// [temple] 角色详情圣殿条目
  /// [side] LINK 卡片左右位置
  String _heroTag(CharacterDetailTempleItem temple, String side) {
    return '$heroTagPrefix-$side-${temple.id}-${temple.characterId}';
  }
}

/// LINK 拥有者按钮
class _LinkOwnerButton extends StatelessWidget {
  /// 创建 LINK 拥有者按钮
  ///
  /// [label] 拥有者展示文案
  /// [onTap] 点击回调
  const _LinkOwnerButton({
    required this.label,
    this.onTap,
  });

  /// 拥有者展示文案
  final String label;

  /// 点击回调
  final VoidCallback? onTap;

  /// 构建 LINK 拥有者按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
