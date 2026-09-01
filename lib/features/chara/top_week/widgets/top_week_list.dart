import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/top_week/model/top_week_entry.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 每周萌王二级列表
class TopWeekList extends StatelessWidget {
  /// 创建每周萌王二级列表
  ///
  /// [key] Flutter 组件标识
  /// [entries] 当前每周萌王条目
  /// [onCharacterPressed] 角色详情点击回调
  /// [onAuctionPressed] 拍卖按钮点击回调
  const TopWeekList({
    super.key,
    required this.entries,
    required this.onCharacterPressed,
    required this.onAuctionPressed,
  });

  static const double _itemExtent = 80;
  static const double _horizontalPadding = 12;
  static const double _rankWidth = 34;
  static const double _rankAvatarGap = 6;
  static const double _avatarSize = 48;
  static const double _avatarTextGap = 10;
  static const double _dividerIndent =
      _horizontalPadding +
      _rankWidth +
      _rankAvatarGap +
      _avatarSize +
      _avatarTextGap;

  /// 当前每周萌王条目
  final List<TopWeekEntry> entries;

  /// 角色详情点击回调
  final void Function(TopWeekEntry entry, String? avatarHeroTag)
  onCharacterPressed;

  /// 拍卖按钮点击回调
  final ValueChanged<TopWeekEntry> onAuctionPressed;

  /// 构建每周萌王二级列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        final entry = entries[index];
        final avatarHeroTag = createCharacterDetailAvatarHeroTag(
          characterId: entry.characterId,
          avatarUrl: entry.avatarUrl,
          source: entry,
        );
        return TopWeekListRow(
          entry: entry,
          avatarHeroTag: avatarHeroTag,
          onCharacterPressed: onCharacterPressed,
          onAuctionPressed: onAuctionPressed,
        );
      },
      separatorBuilder: (context, index) => const _TopWeekListDivider(),
      itemCount: entries.length,
    );
  }
}

/// 每周萌王列表行
class TopWeekListRow extends StatelessWidget {
  /// 创建每周萌王列表行
  ///
  /// [key] Flutter 组件标识
  /// [entry] 每周萌王条目
  /// [avatarHeroTag] 头像转场标识
  /// [onCharacterPressed] 角色详情点击回调
  /// [onAuctionPressed] 拍卖按钮点击回调
  const TopWeekListRow({
    super.key,
    required this.entry,
    required this.avatarHeroTag,
    required this.onCharacterPressed,
    required this.onAuctionPressed,
  });

  /// 每周萌王条目
  final TopWeekEntry entry;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 角色详情点击回调
  final void Function(TopWeekEntry entry, String? avatarHeroTag)
  onCharacterPressed;

  /// 拍卖按钮点击回调
  final ValueChanged<TopWeekEntry> onAuctionPressed;

  /// 构建每周萌王列表行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final canOpenCharacter = entry.characterId > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canOpenCharacter
            ? () => onCharacterPressed(entry, avatarHeroTag)
            : null,
        child: SizedBox(
          height: TopWeekList._itemExtent,
          child: Padding(
            padding: AppSafeAreaInsets.fromLTRB(
              context,
              left: TopWeekList._horizontalPadding,
              top: 7,
              right: TopWeekList._horizontalPadding,
              bottom: 7,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: TopWeekList._rankWidth,
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
                const SizedBox(width: TopWeekList._rankAvatarGap),
                _TopWeekListAvatar(
                  imageUrl: entry.avatarUrl,
                  heroTag: avatarHeroTag,
                ),
                const SizedBox(width: TopWeekList._avatarTextGap),
                Expanded(child: _TopWeekListInfo(entry: entry)),
                const SizedBox(width: 8),
                _TopWeekListAuctionButton(
                  hasUserBid: entry.hasUserBid,
                  onPressed: canOpenCharacter
                      ? () => onAuctionPressed(entry)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 每周萌王列表行角色信息
class _TopWeekListInfo extends StatelessWidget {
  /// 创建每周萌王列表行角色信息
  ///
  /// [entry] 每周萌王条目
  const _TopWeekListInfo({required this.entry});

  /// 每周萌王条目
  final TopWeekEntry entry;

  /// 构建每周萌王列表行角色信息
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = TinygrailFormatters.decodeHtmlEntities(entry.name);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 6),
            LevelBadge(level: entry.level, isCompact: true),
          ],
        ),
        const SizedBox(height: 5),
        Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.group_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextSpan(text: entry.bidders),
              const WidgetSpan(child: SizedBox(width: 9)),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.gavel_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextSpan(text: entry.bidAmount),
              const WidgetSpan(child: SizedBox(width: 9)),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.account_balance_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextSpan(text: entry.valhallaAmount),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: entry.surplus),
              const TextSpan(text: ' · '),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.insights_rounded,
                    size: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextSpan(text: entry.score),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: entry.averagePrice),
              TextSpan(
                text: ' / ',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: '均价',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ],
    );
  }
}

/// 每周萌王列表行头像
class _TopWeekListAvatar extends StatelessWidget {
  /// 创建每周萌王列表行头像
  ///
  /// [imageUrl] 头像地址
  /// [heroTag] 头像转场标识
  const _TopWeekListAvatar({required this.imageUrl, required this.heroTag});

  /// 头像地址
  final String imageUrl;

  /// 头像转场标识
  final String? heroTag;

  /// 构建每周萌王列表行头像
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final avatar = CharacterAvatar(
      imageUrl: imageUrl,
      size: TopWeekList._avatarSize,
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

/// 每周萌王列表行竞拍按钮
class _TopWeekListAuctionButton extends StatelessWidget {
  /// 创建每周萌王列表行竞拍按钮
  ///
  /// [hasUserBid] 是否已有当前用户竞拍
  /// [onPressed] 点击回调
  const _TopWeekListAuctionButton({
    required this.hasUserBid,
    required this.onPressed,
  });

  static const double _width = 52;
  static const double _height = 28;

  /// 是否已有当前用户竞拍
  final bool hasUserBid;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 构建每周萌王列表行竞拍按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onPressed != null;
    final foregroundColor = hasUserBid
        ? Colors.white
        : colorScheme.onSurfaceVariant.withValues(
            alpha: isEnabled ? (isDark ? 0.86 : 0.76) : 0.38,
          );
    final backgroundColor = hasUserBid
        ? colorScheme.primary.withValues(alpha: isEnabled ? 0.92 : 0.38)
        : colorScheme.onSurfaceVariant.withValues(
            alpha: isEnabled ? (isDark ? 0.12 : 0.08) : 0.05,
          );

    return SizedBox(
      width: _width,
      height: _height,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Center(
            child: Text(
              hasUserBid ? '改价' : '竞拍',
              style: TextStyle(
                color: foregroundColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 每周萌王列表分隔线
class _TopWeekListDivider extends StatelessWidget {
  /// 创建每周萌王列表分隔线
  const _TopWeekListDivider();

  /// 构建每周萌王列表分隔线
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: TopWeekList._dividerIndent,
        top: 0,
        right: TopWeekList._horizontalPadding,
        bottom: 0,
      ),
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: colorScheme.outlineVariant.withValues(
          alpha: isDark ? 0.32 : 0.58,
        ),
      ),
    );
  }
}

/// 每周萌王列表骨架
class TopWeekListSkeleton extends StatelessWidget {
  /// 创建每周萌王列表骨架
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  const TopWeekListSkeleton({super.key, this.itemCount = 12});

  /// 骨架条目数量
  final int itemCount;

  /// 构建每周萌王列表骨架
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (context, index) => const _TopWeekListSkeletonRow(),
      separatorBuilder: (context, index) => const _TopWeekListDivider(),
      itemCount: itemCount,
    );
  }
}

/// 每周萌王列表骨架行
class _TopWeekListSkeletonRow extends StatelessWidget {
  /// 创建每周萌王列表骨架行
  const _TopWeekListSkeletonRow();

  /// 构建每周萌王列表骨架行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: TopWeekList._horizontalPadding,
        top: 7,
        right: TopWeekList._horizontalPadding,
        bottom: 7,
      ),
      child: const Skeletonizer.zone(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              SizedBox(
                width: TopWeekList._rankWidth,
                child: Center(
                  child: Bone(
                    width: 24,
                    height: 22,
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                  ),
                ),
              ),
              SizedBox(width: TopWeekList._rankAvatarGap),
              Bone(
                width: TopWeekList._avatarSize,
                height: TopWeekList._avatarSize,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              SizedBox(width: TopWeekList._avatarTextGap),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Bone(
                            width: 92,
                            height: 16,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Bone(
                          width: 34,
                          height: 15,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Bone(
                      width: 150,
                      height: 10,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    SizedBox(height: 2),
                    Bone(
                      width: 132,
                      height: 11,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    SizedBox(height: 3),
                    Bone(
                      width: 58,
                      height: 11,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Bone(
                width: _TopWeekListAuctionButton._width,
                height: _TopWeekListAuctionButton._height,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
