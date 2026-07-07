import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/features/chara/tower/model/tower_entry.dart';
import 'package:magrail_app/features/chara/tower/widgets/tower_ranking_badges.dart';

/// 通天塔排名行
class TowerRankingRow extends StatelessWidget {
  /// 创建通天塔排名行
  ///
  /// [key] Flutter 组件标识
  /// [entry] 通天塔条目
  /// [avatarHeroTag] 头像转场标识
  /// [onTap] 条目点击回调
  const TowerRankingRow({
    super.key,
    required this.entry,
    this.avatarHeroTag,
    this.onTap,
  });

  /// 通天塔条目
  final TowerEntry entry;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 条目点击回调
  final VoidCallback? onTap;

  /// 构建通天塔排名行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${entry.rank}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: entry.rankColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                _TowerRankingAvatar(
                  imageUrl: entry.avatarUrl,
                  heroTag: avatarHeroTag,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              entry.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          LevelBadge(
                            level: entry.level,
                            zeroCount: entry.zeroCount,
                            isCompact: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TowerStarsRow(stars: entry.stars),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TowerStarForcesBadge(value: entry.starForcesLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 通天塔排名行头像
class _TowerRankingAvatar extends StatelessWidget {
  /// 创建通天塔排名行头像
  ///
  /// [imageUrl] 头像地址
  /// [heroTag] 头像转场标识
  const _TowerRankingAvatar({
    required this.imageUrl,
    required this.heroTag,
  });

  /// 头像地址
  final String imageUrl;

  /// 头像转场标识
  final String? heroTag;

  /// 构建通天塔排名行头像
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final avatar = CharacterAvatar(
      imageUrl: imageUrl,
      size: 48,
      borderRadius: 16,
    );
    final resolvedHeroTag = heroTag?.trim();
    if (resolvedHeroTag == null || resolvedHeroTag.isEmpty) {
      return avatar;
    }

    return Hero(
      tag: resolvedHeroTag,
      transitionOnUserGestures: true,
      child: avatar,
    );
  }
}
