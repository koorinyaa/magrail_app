import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_ico_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_chara_asset_row.dart';

/// 用户角色资产 sliver 列表
class UserCharacterAssetSliverList extends StatelessWidget {
  /// 创建用户角色资产 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 用户角色条目
  /// [onItemBuilt] 条目构建回调
  /// [onCharacterTap] 角色条目点击回调
  const UserCharacterAssetSliverList({
    super.key,
    required this.items,
    this.onItemBuilt,
    this.onCharacterTap,
  });

  /// 用户角色条目
  final List<UserCharacterApiItem> items;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 角色条目点击回调
  final void Function(UserCharacterApiItem item, String? avatarHeroTag)?
      onCharacterTap;

  /// 构建用户角色资产 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: _CharacterAssetSliverListMetrics.itemExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
          final avatarHeroTag = createCharacterDetailAvatarHeroTag(
            characterId: item.characterId,
            avatarUrl: avatarUrl,
            source: item,
          );

          onItemBuilt?.call(index);
          return _CharacterAssetListItem(
            child: UserCharacterAssetRow(
              item: item,
              avatarHeroTag: avatarHeroTag,
              onTap: onCharacterTap == null
                  ? null
                  : () => onCharacterTap?.call(item, avatarHeroTag),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}

/// 用户 ICO 资产 sliver 列表
class UserIcoAssetSliverList extends StatelessWidget {
  /// 创建用户 ICO 资产 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 用户 ICO 条目
  /// [onItemBuilt] 条目构建回调
  /// [onIcoTap] ICO 条目点击回调
  const UserIcoAssetSliverList({
    super.key,
    required this.items,
    this.onItemBuilt,
    this.onIcoTap,
  });

  /// 用户 ICO 条目
  final List<UserIcoApiItem> items;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// ICO 条目点击回调
  final void Function(UserIcoApiItem item, String? avatarHeroTag)? onIcoTap;

  /// 构建用户 ICO 资产 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: _CharacterAssetSliverListMetrics.itemExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
          final avatarHeroTag = createCharacterDetailAvatarHeroTag(
            characterId: item.characterId,
            avatarUrl: avatarUrl,
            source: item,
          );

          onItemBuilt?.call(index);
          return _CharacterAssetListItem(
            child: UserIcoAssetRow(
              item: item,
              avatarHeroTag: avatarHeroTag,
              onTap: onIcoTap == null
                  ? null
                  : () => onIcoTap?.call(item, avatarHeroTag),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}

/// 用户角色资产列表条目外层
class _CharacterAssetListItem extends StatelessWidget {
  /// 创建用户角色资产列表条目外层
  ///
  /// [child] 条目主体
  const _CharacterAssetListItem({
    required this.child,
  });

  /// 条目主体
  final Widget child;

  /// 构建用户角色资产列表条目外层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSafeAreaInsets.fromLTRB(
        context,
        left: 12,
        top: 0,
        right: 12,
        bottom: 4,
      ),
      child: child,
    );
  }
}

/// 用户角色资产 sliver 列表尺寸
final class _CharacterAssetSliverListMetrics {
  /// 禁止创建用户角色资产 sliver 列表尺寸实例
  const _CharacterAssetSliverListMetrics._();

  /// 列表条目高度
  static const double itemExtent = 68;
}
