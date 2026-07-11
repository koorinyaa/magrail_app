import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/features/bangumi/next/model/next_bangumi_subject_character.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_basic_info.dart';

/// Next Bangumi 角色网格条目
class NextBangumiCharacterGridItem extends StatelessWidget {
  /// 创建 Next Bangumi 角色网格条目
  ///
  /// [key] Flutter 组件标识
  /// [item] Bangumi 角色
  /// [status] 小圣杯角色状态
  /// [heroSource] 头像转场来源
  /// [onTap] 点击回调
  const NextBangumiCharacterGridItem({
    super.key,
    required this.item,
    required this.status,
    required this.onTap,
    this.heroSource,
  });

  /// Bangumi 角色
  final NextBangumiSubjectCharacterItem item;

  /// 小圣杯角色状态
  final CharacterDetailBasicInfo? status;

  /// 头像转场来源
  final Object? heroSource;

  /// 点击回调
  final VoidCallback onTap;

  /// 构建 Next Bangumi 角色网格条目
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rawAvatarUrl = resolveNextBangumiCharacterAvatarUrl(item, status);
    final avatarUrl = normalizeNextBangumiCharacterAvatarUrl(rawAvatarUrl);
    final avatarHeroTag = createCharacterDetailAvatarHeroTag(
      characterId: item.characterId,
      avatarUrl: rawAvatarUrl,
      source: heroSource ?? item,
    );
    final name = TinygrailFormatters.decodeHtmlEntities(item.displayName);
    final avatar = CharacterAvatar(
      imageUrl: avatarUrl,
      size: 48,
      borderRadius: 18,
    );

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 104,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (avatarHeroTag == null)
                    avatar
                  else
                    Hero(
                      tag: avatarHeroTag,
                      transitionOnUserGestures: true,
                      child: avatar,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    name.isEmpty ? '未知角色' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NextBangumiCharacterStatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '#${item.characterId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Next Bangumi 角色状态胶囊
class _NextBangumiCharacterStatusBadge extends StatelessWidget {
  /// 创建 Next Bangumi 角色状态胶囊
  ///
  /// [status] 小圣杯角色状态
  const _NextBangumiCharacterStatusBadge({
    required this.status,
  });

  /// 小圣杯角色状态
  final CharacterDetailBasicInfo? status;

  /// 构建 Next Bangumi 角色状态胶囊
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final resolvedStatus = status;
    if (resolvedStatus?.pageType == CharacterDetailPageType.trade) {
      final header = resolvedStatus?.tradeHeader;
      return LevelBadge(
        level: header?.level ?? 0,
        zeroCount: header?.zeroCount ?? 0,
        isCompact: true,
      );
    }

    if (resolvedStatus?.pageType == CharacterDetailPageType.ico) {
      return const LevelBadge.ico(isCompact: true);
    }

    return const LevelBadge.unlisted(isCompact: true);
  }
}

/// 解析 Next Bangumi 角色原始头像地址
///
/// [item] Bangumi 角色
/// [status] 小圣杯角色状态
String resolveNextBangumiCharacterAvatarUrl(
  NextBangumiSubjectCharacterItem item,
  CharacterDetailBasicInfo? status,
) {
  final tinygrailAvatar = status?.icon.trim();
  if (tinygrailAvatar != null && tinygrailAvatar.isNotEmpty) {
    return tinygrailAvatar;
  }

  return item.avatarUrl;
}

/// 标准化 Next Bangumi 角色头像地址
///
/// [avatarUrl] 原始头像地址
String normalizeNextBangumiCharacterAvatarUrl(String avatarUrl) {
  return TinygrailAssetUrls.normalizeAvatar(avatarUrl.trim());
}
