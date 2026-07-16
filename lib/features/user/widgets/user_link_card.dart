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
  /// [showConnectionValue] 是否显示连接值
  /// [onCharacterTap] 角色名称点击回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const UserLinkCard({
    super.key,
    required this.item,
    this.width = defaultWidth,
    this.heroTagPrefix = 'user-link-cover',
    this.showConnectionValue = true,
    this.onCharacterTap,
    this.onAssetTap,
  });

  /// 默认卡片宽度
  static const double defaultWidth = 288;

  /// 图片区域高度
  static const double imageHeight = 222;

  /// 卡片整体高度
  static const double totalHeight = 256;

  /// 生成用户连接封面的 Hero 标识
  ///
  /// [prefix] Hero 标识前缀
  /// [temple] 用户圣殿接口条目
  static String heroTagFor(String prefix, UserTempleApiItem temple) {
    return '$prefix-${temple.id}-${temple.characterId}';
  }

  /// 根据卡片宽度计算卡片高度
  ///
  /// [width] 卡片宽度
  /// [showConnectionValue] 是否预留连接值区域
  static double heightForWidth(
    double width, {
    bool showConnectionValue = true,
  }) {
    return imageHeight * width / defaultWidth +
        (showConnectionValue ? totalHeight - imageHeight : 0);
  }

  /// 用户连接接口条目
  final UserLinkApiItem item;

  /// 卡片宽度
  final double width;

  /// 图片 Hero 标识前缀
  final String heroTagPrefix;

  /// 是否显示连接值
  final bool showConnectionValue;

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
      height: heightForWidth(
        width,
        showConnectionValue: showConnectionValue,
      ),
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
            leftHeroTag: heroTagFor(heroTagPrefix, left),
            onLeftCoverTap: () => _openImageViewer(context, left),
            onLeftCharacterTap:
                onCharacterTap == null ? null : () => onCharacterTap!(left),
            onLeftAssetTap: onAssetTap == null ? null : () => onAssetTap!(left),
            rightCoverUrl: TinygrailAssetUrls.getSmallCover(right.cover),
            rightAvatarUrl: TinygrailAssetUrls.normalizeAvatar(right.avatar),
            rightCharacterName: TinygrailFormatters.decodeHtmlEntities(
              right.name,
            ),
            rightHeroTag: heroTagFor(heroTagPrefix, right),
            onRightCoverTap: () => _openImageViewer(context, right),
            onRightCharacterTap:
                onCharacterTap == null ? null : () => onCharacterTap!(right),
            onRightAssetTap:
                onAssetTap == null ? null : () => onAssetTap!(right),
          ),
          if (showConnectionValue) ...[
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
        ],
      ),
    );
  }

  /// 打开全屏图片查看
  ///
  /// [context] 当前组件树上下文
  /// [temple] 用户圣殿接口条目
  void _openImageViewer(
    BuildContext context,
    UserTempleApiItem temple,
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
            heroTag: heroTagFor(heroTagPrefix, temple),
          );
        },
      ),
    );
  }
}
