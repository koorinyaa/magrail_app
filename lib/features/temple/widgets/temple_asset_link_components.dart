import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/temple_card.dart';
import 'package:magrail_app/core/widgets/temple_link_card.dart';
import 'package:magrail_app/features/temple/model/temple_asset_card_data.dart';
import 'package:magrail_app/features/user/model/user_link_api_item.dart';
import 'package:magrail_app/features/user/model/user_temple_api_item.dart';

/// 圣殿连接目标卡片
class TempleAssetLinkTempleTile extends StatelessWidget {
  /// 创建圣殿连接目标卡片
  ///
  /// [key] Flutter 组件标识
  /// [item] 用户圣殿条目
  /// [width] 卡片宽度
  /// [onSelected] 选择回调
  const TempleAssetLinkTempleTile({
    super.key,
    required this.item,
    required this.width,
    required this.onSelected,
  });

  /// 用户圣殿条目
  final UserTempleApiItem item;

  /// 卡片宽度
  final double width;

  /// 选择回调
  final ValueChanged<UserTempleApiItem> onSelected;

  /// 根据卡片宽度计算整体高度
  ///
  /// [width] 卡片宽度
  static double heightForWidth(double width) {
    return width / 3 * 4;
  }

  /// 构建圣殿连接目标卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: heightForWidth(width),
      child: TempleCard(
        width: width,
        borderRadius: 18,
        coverUrl: TinygrailAssetUrls.getSmallCover(item.cover),
        avatarUrl: TinygrailAssetUrls.normalizeAvatar(item.avatar),
        characterName: TinygrailFormatters.decodeHtmlEntities(item.name),
        characterLevel: item.characterLevel,
        zeroCount: item.zeroCount,
        ownerLabel: _linkLabel,
        templeLevel: item.level,
        refine: item.refine,
        starForces: item.starForces,
        heroTag: 'temple-asset-link-target-${item.id}-${item.characterId}',
        onTap: () => onSelected(item),
      ),
    );
  }

  /// 圣殿连接状态文案
  String get _linkLabel {
    final linkedTemple = item.link;
    if (linkedTemple == null) {
      return 'NO LINK';
    }

    final name = TinygrailFormatters.decodeHtmlEntities(linkedTemple.name);
    return '× $name';
  }
}

/// 圣殿连接效果预览
class TempleAssetLinkPreview extends StatelessWidget {
  /// 创建圣殿连接效果预览
  ///
  /// [key] Flutter 组件标识
  /// [source] 当前圣殿资产卡片数据
  /// [target] 目标圣殿条目
  const TempleAssetLinkPreview({
    super.key,
    required this.source,
    required this.target,
  });

  /// 当前圣殿资产卡片数据
  final TempleAssetCardData source;

  /// 目标圣殿条目
  final UserTempleApiItem target;

  /// 构建圣殿连接效果预览
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final linkItem = UserLinkApiItem(
      temple: _sourceTemple,
      link: target,
    );
    final left = linkItem.left;
    final right = linkItem.right;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.clamp(220.0, 288.0).toDouble();

        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: width,
            child: TempleLinkCard(
              width: width,
              leftCoverUrl: TinygrailAssetUrls.getSmallCover(left.cover),
              leftAvatarUrl: TinygrailAssetUrls.normalizeAvatar(
                left.avatar,
              ),
              leftCharacterName: TinygrailFormatters.decodeHtmlEntities(
                left.name,
              ),
              rightCoverUrl: TinygrailAssetUrls.getSmallCover(right.cover),
              rightAvatarUrl: TinygrailAssetUrls.normalizeAvatar(
                right.avatar,
              ),
              rightCharacterName: TinygrailFormatters.decodeHtmlEntities(
                right.name,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 当前圣殿对应的用户圣殿条目
  UserTempleApiItem get _sourceTemple {
    return UserTempleApiItem(
      id: source.templeId ?? 0,
      userId: source.userId,
      characterId: source.characterId,
      name: source.characterName,
      avatar: source.avatar,
      cover: source.cover,
      line: '',
      assets: source.assets,
      sacrifices: source.sacrifices,
      rate: 0,
      characterLevel: source.characterLevel,
      zeroCount: source.zeroCount,
      level: source.level,
      starForces: source.starForces,
      refine: source.refine,
    );
  }
}
