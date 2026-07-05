import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/viewer/fullscreen_image_viewer_page.dart';
import 'package:magrail_app/core/widgets/temple_card.dart';
import 'package:magrail_app/features/temple/model/temple_api_item.dart';

/// 最新圣殿条目卡片
class LatestTempleCard extends StatelessWidget {
  /// 创建最新圣殿条目卡片
  ///
  /// [item] 最新圣殿条目
  /// [width] 卡片宽度
  /// [heroTagPrefix] 图片 Hero 标识前缀
  /// [onCharacterTap] 角色区域点击回调
  /// [onUserTap] 用户区域点击回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const LatestTempleCard({
    super.key,
    required this.item,
    required this.width,
    this.heroTagPrefix = 'latest-temple-cover',
    this.onCharacterTap,
    this.onUserTap,
    this.onAssetTap,
  });

  /// 最新圣殿条目
  final TempleApiItem item;

  /// 卡片宽度
  final double width;

  /// 图片 Hero 标识前缀
  final String heroTagPrefix;

  /// 角色区域点击回调
  final ValueChanged<TempleApiItem>? onCharacterTap;

  /// 用户区域点击回调
  final ValueChanged<TempleApiItem>? onUserTap;

  /// 圣殿资产入口点击回调
  final ValueChanged<TempleApiItem>? onAssetTap;

  /// 构建最新圣殿条目卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return TempleCard(
      width: width,
      coverUrl: TinygrailAssetUrls.getSmallCover(item.cover),
      avatarUrl: TinygrailAssetUrls.normalizeAvatar(item.avatar),
      characterName: TinygrailFormatters.decodeHtmlEntities(
        item.characterName,
      ),
      characterLevel: item.characterLevel,
      zeroCount: item.zeroCount,
      ownerLabel: _resolveOwnerLabel(item),
      templeLevel: item.level,
      refine: item.refine,
      starForces: item.starForces,
      heroTag: _heroTag(item),
      onTap: () => _openImageViewer(context, item),
      onCharacterTap: () => onCharacterTap?.call(item),
      onUserTap: () => onUserTap?.call(item),
      onAssetTap: onAssetTap == null ? null : () => onAssetTap!(item),
    );
  }

  /// 打开全屏图片查看
  ///
  /// [context] 当前组件树上下文
  /// [item] 最新圣殿条目
  void _openImageViewer(BuildContext context, TempleApiItem item) {
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
  /// [item] 最新圣殿条目
  String _resolveOwnerLabel(TempleApiItem item) {
    final nickname = TinygrailFormatters.decodeHtmlEntities(item.nickname);
    if (nickname.isNotEmpty) {
      return '@$nickname';
    }

    return '@${item.name}';
  }

  /// 解析图片 Hero 标识
  ///
  /// [item] 最新圣殿条目
  String _heroTag(TempleApiItem item) {
    return '$heroTagPrefix-${item.id}-${item.characterId}';
  }
}
