import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/viewer/fullscreen_image_viewer_page.dart';
import 'package:magrail_app/core/widgets/temple_link_card.dart';
import 'package:magrail_app/core/widgets/temple_link_value_chip.dart';
import 'package:magrail_app/features/temple/model/latest_link_api_item.dart';
import 'package:magrail_app/features/temple/model/latest_link_pair.dart';

/// 最新连接卡片
class LatestLinkCard extends StatelessWidget {
  /// 创建最新连接卡片
  ///
  /// [pair] 最新连接展示组
  /// [width] 卡片宽度
  /// [heroTagPrefix] 图片 Hero 标识前缀
  /// [onCharacterTap] 角色名称点击回调
  /// [onUserTap] 用户名称点击回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const LatestLinkCard({
    super.key,
    required this.pair,
    this.width = defaultWidth,
    this.heroTagPrefix = 'latest-link-cover',
    this.onCharacterTap,
    this.onUserTap,
    this.onAssetTap,
  });

  /// 默认卡片宽度
  static const double defaultWidth = 288;

  /// 图片区域高度
  static const double imageHeight = 222;

  /// 卡片整体高度
  static const double totalHeight = 256;

  /// 图片圆角
  static const double imageRadius = 24;

  /// 根据卡片宽度计算图片高度
  ///
  /// [width] 卡片宽度
  static double imageHeightForWidth(double width) {
    return imageHeight * width / defaultWidth;
  }

  /// 根据卡片宽度计算卡片高度
  ///
  /// [width] 卡片宽度
  static double heightForWidth(double width) {
    return imageHeightForWidth(width) + (totalHeight - imageHeight);
  }

  /// 最新连接展示组
  final LatestLinkPair pair;

  /// 卡片宽度
  final double width;

  /// 图片 Hero 标识前缀
  final String heroTagPrefix;

  /// 角色名称点击回调
  final ValueChanged<LatestLinkApiItem>? onCharacterTap;

  /// 用户名称点击回调
  final ValueChanged<LatestLinkPair>? onUserTap;

  /// 圣殿资产入口点击回调
  final void Function(LatestLinkPair pair, LatestLinkApiItem item)? onAssetTap;

  /// 构建最新连接卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      height: heightForWidth(width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TempleLinkCard(
            width: width,
            leftCoverUrl: TinygrailAssetUrls.getSmallCover(pair.left.cover),
            leftAvatarUrl: TinygrailAssetUrls.normalizeAvatar(
              pair.left.avatar,
            ),
            leftCharacterName: TinygrailFormatters.decodeHtmlEntities(
              pair.left.characterName,
            ),
            leftHeroTag: _heroTag(pair.left),
            onLeftCoverTap: () => _openImageViewer(context, pair.left),
            onLeftCharacterTap: onCharacterTap == null
                ? null
                : () => onCharacterTap!(pair.left),
            onLeftAssetTap:
                onAssetTap == null ? null : () => onAssetTap!(pair, pair.left),
            rightCoverUrl: TinygrailAssetUrls.getSmallCover(pair.right.cover),
            rightAvatarUrl: TinygrailAssetUrls.normalizeAvatar(
              pair.right.avatar,
            ),
            rightCharacterName: TinygrailFormatters.decodeHtmlEntities(
              pair.right.characterName,
            ),
            rightHeroTag: _heroTag(pair.right),
            onRightCoverTap: () => _openImageViewer(context, pair.right),
            onRightCharacterTap: onCharacterTap == null
                ? null
                : () => onCharacterTap!(pair.right),
            onRightAssetTap:
                onAssetTap == null ? null : () => onAssetTap!(pair, pair.right),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                Flexible(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: onUserTap == null ? null : () => onUserTap!(pair),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 3,
                        ),
                        child: Text(
                          _resolveOwnerLabel(pair),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.brightness == Brightness.dark
                                ? colorScheme.onSurfaceVariant
                                : const Color(0xFF73626A),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                TempleLinkValueChip(
                  valueLabel: Formatters.tinygrailCompactValue(
                    pair.connectionValue,
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

  /// 打开全屏图片查看
  ///
  /// [context] 当前组件树上下文
  /// [item] 最新连接接口条目
  void _openImageViewer(BuildContext context, LatestLinkApiItem item) {
    final coverUrl = TinygrailAssetUrls.getLargeCover(item.cover);
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.avatar);
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
            heroTag: _heroTag(item),
          );
        },
      ),
    );
  }

  /// 解析用户展示文案
  ///
  /// [pair] 最新连接展示组
  String _resolveOwnerLabel(LatestLinkPair pair) {
    final nickname = TinygrailFormatters.decodeHtmlEntities(
      pair.ownerNickname,
    );
    if (nickname.isNotEmpty) {
      return '@$nickname';
    }

    return '@${pair.ownerName}';
  }

  /// 解析图片 Hero 标识
  ///
  /// [item] 最新连接接口条目
  String _heroTag(LatestLinkApiItem item) {
    return '$heroTagPrefix-${item.id}-${item.characterId}';
  }
}
