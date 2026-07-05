import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/viewer/fullscreen_image_viewer_page.dart';
import 'package:magrail_app/core/widgets/temple_card.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

/// 用户圣殿卡片
class UserTempleCard extends StatelessWidget {
  /// 创建用户圣殿卡片
  ///
  /// [key] Flutter 组件标识
  /// [item] 用户圣殿接口条目
  /// [ownerLabel] 用户展示文案
  /// [width] 卡片宽度
  /// [heroTagPrefix] 图片 Hero 标识前缀
  /// [onCharacterTap] 角色区域点击回调
  /// [onAssetTap] 圣殿资产入口点击回调
  const UserTempleCard({
    super.key,
    required this.item,
    required this.ownerLabel,
    required this.width,
    this.heroTagPrefix = 'user-temple-cover',
    this.onCharacterTap,
    this.onAssetTap,
  });

  /// 用户圣殿接口条目
  final UserTempleApiItem item;

  /// 用户展示文案
  final String ownerLabel;

  /// 卡片宽度
  final double width;

  /// 图片 Hero 标识前缀
  final String heroTagPrefix;

  /// 角色区域点击回调
  final ValueChanged<UserTempleApiItem>? onCharacterTap;

  /// 圣殿资产入口点击回调
  final ValueChanged<UserTempleApiItem>? onAssetTap;

  /// 根据卡片宽度计算整体高度
  ///
  /// [width] 卡片宽度
  static double heightForWidth(double width) {
    return width / 3 * 4 + _TempleAssetProgress.height + 10;
  }

  /// 构建用户圣殿卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: heightForWidth(width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TempleCard(
            width: width,
            coverUrl: TinygrailAssetUrls.getSmallCover(item.cover),
            avatarUrl: TinygrailAssetUrls.normalizeAvatar(item.avatar),
            characterName: TinygrailFormatters.decodeHtmlEntities(item.name),
            characterLevel: item.characterLevel,
            zeroCount: item.zeroCount,
            ownerLabel: ownerLabel,
            templeLevel: item.level,
            refine: item.refine,
            starForces: item.starForces,
            heroTag: _heroTag(item),
            onTap: () => _openImageViewer(context, item),
            onCharacterTap:
                onCharacterTap == null ? null : () => onCharacterTap!(item),
            onAssetTap: onAssetTap == null ? null : () => onAssetTap!(item),
          ),
          const SizedBox(height: 8),
          _TempleAssetProgress(item: item),
        ],
      ),
    );
  }

  /// 打开全屏图片查看
  ///
  /// [context] 当前组件树上下文
  /// [temple] 用户圣殿接口条目
  void _openImageViewer(BuildContext context, UserTempleApiItem temple) {
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
  /// [temple] 用户圣殿接口条目
  String _heroTag(UserTempleApiItem temple) {
    return '$heroTagPrefix-${temple.id}-${temple.characterId}';
  }
}

/// 用户圣殿资产进度条
class _TempleAssetProgress extends StatelessWidget {
  /// 创建用户圣殿资产进度条
  ///
  /// [item] 用户圣殿接口条目
  const _TempleAssetProgress({
    required this.item,
  });

  /// 进度条区域高度
  static const double height = 26;

  /// 用户圣殿接口条目
  final UserTempleApiItem item;

  /// 构建用户圣殿资产进度条
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

  /// 资产进度文案
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
