import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_history_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 角色详情顶部历史头像栏
class CharacterDetailHistoryBar extends StatelessWidget {
  /// 创建角色详情顶部历史头像栏
  ///
  /// [key] Flutter 组件标识
  /// [items] 角色打开历史
  /// [selectedCharacterId] 当前选中角色 ID
  /// [selectedAvatarHeroTag] 当前选中角色的头像转场标识
  /// [onItemPressed] 历史角色点击回调
  const CharacterDetailHistoryBar({
    super.key,
    required this.items,
    required this.selectedCharacterId,
    this.selectedAvatarHeroTag,
    required this.onItemPressed,
  });

  /// 角色打开历史
  final List<CharacterDetailHistoryItem> items;

  /// 当前选中角色 ID
  final int? selectedCharacterId;

  /// 当前选中角色的头像转场标识
  final String? selectedAvatarHeroTag;

  /// 历史角色点击回调
  final ValueChanged<CharacterDetailHistoryItem> onItemPressed;

  /// 构建角色详情顶部历史头像栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        itemBuilder: (context, index) {
          final item = items[index];
          return _CharacterDetailHistoryItemButton(
            item: item,
            selected: item.characterId == selectedCharacterId,
            avatarHeroTag: item.characterId == selectedCharacterId
                ? selectedAvatarHeroTag
                : null,
            onPressed: () => onItemPressed(item),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: items.length,
      ),
    );
  }
}

/// 角色详情历史头像按钮
class _CharacterDetailHistoryItemButton extends StatelessWidget {
  /// 创建角色详情历史头像按钮
  ///
  /// [item] 历史角色条目
  /// [selected] 是否为当前角色
  /// [avatarHeroTag] 头像转场标识
  /// [onPressed] 点击回调
  const _CharacterDetailHistoryItemButton({
    required this.item,
    required this.selected,
    this.avatarHeroTag,
    required this.onPressed,
  });

  /// 历史角色条目
  final CharacterDetailHistoryItem item;

  /// 是否为当前角色
  final bool selected;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建角色详情历史头像按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 72,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withValues(alpha: 0.4),
                    width: selected ? 3 : 1,
                  ),
                ),
                child: item.hasAvatar
                    ? _CharacterDetailHistoryAvatar(
                        imageUrl: item.avatarUrl,
                        heroTag: avatarHeroTag,
                      )
                    : Skeletonizer.zone(
                        child: Bone(
                          width: 56,
                          height: 56,
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
              ),
              const SizedBox(height: 5),
              Text(
                item.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.1,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 角色详情历史头像
class _CharacterDetailHistoryAvatar extends StatelessWidget {
  /// 创建角色详情历史头像
  ///
  /// [imageUrl] 头像地址
  /// [heroTag] 头像转场标识
  const _CharacterDetailHistoryAvatar({
    required this.imageUrl,
    required this.heroTag,
  });

  /// 头像地址
  final String imageUrl;

  /// 头像转场标识
  final String? heroTag;

  /// 构建角色详情历史头像
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final avatar = CharacterAvatar(
      imageUrl: imageUrl,
      size: 56,
      borderRadius: 28,
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
