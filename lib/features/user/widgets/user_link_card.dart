import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/viewer/fullscreen_image_viewer_page.dart';
import 'package:magrail_app/core/widgets/temple_link_card.dart';
import 'package:magrail_app/core/widgets/temple_link_value_chip.dart';
import 'package:magrail_app/features/user/model/user_link_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

/// 用户连接卡片
class UserLinkCard extends StatelessWidget {
  /// 创建用户连接卡片
  ///
  /// [key] Flutter 组件标识
  /// [item] 用户连接接口条目
  /// [width] 卡片宽度
  /// [heroTagPrefix] 图片 Hero 标识前缀
  /// [onCharacterTap] 角色名称点击回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const UserLinkCard({
    super.key,
    required this.item,
    this.width = defaultWidth,
    this.heroTagPrefix = 'user-link-cover',
    this.onCharacterTap,
    this.onAssetTap,
  });

  /// 默认卡片宽度
  static const double defaultWidth = 288;

  /// 图片区域高度
  static const double imageHeight = 222;

  /// 卡片整体高度
  static const double totalHeight = 256;

  /// 根据卡片宽度计算卡片高度
  ///
  /// [width] 卡片宽度
  static double heightForWidth(double width) {
    return imageHeight * width / defaultWidth + (totalHeight - imageHeight);
  }

  /// 用户连接接口条目
  final UserLinkApiItem item;

  /// 卡片宽度
  final double width;

  /// 图片 Hero 标识前缀
  final String heroTagPrefix;

  /// 角色名称点击回调
  final ValueChanged<UserTempleApiItem>? onCharacterTap;

  /// 圣殿资产入口点击回调
  final ValueChanged<UserTempleApiItem>? onAssetTap;

  /// 构建用户连接卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final left = item.left;
    final right = item.right;

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
              left.name,
            ),
            leftHeroTag: _heroTag(left, 'left'),
            onLeftCoverTap: () => _openImageViewer(context, left, 'left'),
            onLeftCharacterTap:
                onCharacterTap == null ? null : () => onCharacterTap!(left),
            onLeftAssetTap: onAssetTap == null ? null : () => onAssetTap!(left),
            rightCoverUrl: TinygrailAssetUrls.getSmallCover(right.cover),
            rightAvatarUrl: TinygrailAssetUrls.normalizeAvatar(right.avatar),
            rightCharacterName: TinygrailFormatters.decodeHtmlEntities(
              right.name,
            ),
            rightHeroTag: _heroTag(right, 'right'),
            onRightCoverTap: () => _openImageViewer(context, right, 'right'),
            onRightCharacterTap:
                onCharacterTap == null ? null : () => onCharacterTap!(right),
            onRightAssetTap:
                onAssetTap == null ? null : () => onAssetTap!(right),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                TempleLinkValueChip(
                  valueLabel: Formatters.tinygrailCompactValue(
                    item.connectionValue,
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
  /// [temple] 用户圣殿接口条目
  /// [side] 连接卡片左右位置
  void _openImageViewer(
    BuildContext context,
    UserTempleApiItem temple,
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
  /// [temple] 用户圣殿接口条目
  /// [side] 连接卡片左右位置
  String _heroTag(UserTempleApiItem temple, String side) {
    return '$heroTagPrefix-$side-${temple.id}-${temple.characterId}';
  }
}
