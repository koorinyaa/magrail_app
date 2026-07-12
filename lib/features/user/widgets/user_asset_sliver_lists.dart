import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/user/assets/model/user_character_snapshot_query.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_ico_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_rows.dart';

/// 用户角色资产 sliver 列表
class UserCharacterAssetSliverList extends StatelessWidget {
  static const double _contentLeadingInset = 18;
  static const double _textLeadingInset = 74;
  static const double _contentTrailingInset = 18;
  static const double _levelContentTrailingInset = 26;

  /// 角色列表条目固定高度
  static const double itemExtent = 68;

  /// 等级分组标题固定高度
  static const double levelHeaderExtent = 40;

  /// 创建用户角色资产 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 用户角色条目
  /// [showLevelHeaders] 是否显示等级分组标题
  /// [sort] 当前用户角色排序字段
  /// [onItemBuilt] 条目构建回调
  /// [onCharacterTap] 角色条目点击回调
  const UserCharacterAssetSliverList({
    super.key,
    required this.items,
    this.showLevelHeaders = false,
    this.sort = UserCharacterSnapshotSort.holdings,
    this.onItemBuilt,
    this.onCharacterTap,
  });

  /// 用户角色条目
  final List<UserCharacterApiItem> items;

  /// 是否显示等级分组标题
  final bool showLevelHeaders;

  /// 当前用户角色排序字段
  final UserCharacterSnapshotSort sort;

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
    if (!showLevelHeaders || items.isEmpty) {
      return SliverFixedExtentList(
        itemExtent: itemExtent,
        delegate: SliverChildBuilderDelegate(
          _buildCharacterItem,
          childCount: items.length,
        ),
      );
    }

    final groups = <({int start, int end, int level})>[];
    var groupStart = 0;
    for (var index = 1; index <= items.length; index += 1) {
      if (index < items.length &&
          items[index].level == items[groupStart].level) {
        continue;
      }
      groups.add((
        start: groupStart,
        end: index,
        level: items[groupStart].level,
      ));
      groupStart = index;
    }

    return SliverMainAxisGroup(
      slivers: [
        for (final group in groups) ...[
          SliverToBoxAdapter(
            child: _CharacterLevelHeader(level: group.level),
          ),
          SliverFixedExtentList(
            itemExtent: itemExtent,
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildCharacterItem(context, group.start + index),
              childCount: group.end - group.start,
            ),
          ),
        ],
      ],
    );
  }

  /// 计算角色列表内容高度
  ///
  /// [items] 已加载角色条目
  /// [showLevelHeaders] 是否包含等级分组标题
  static double listExtent(
    List<UserCharacterApiItem> items, {
    bool showLevelHeaders = false,
  }) {
    if (items.isEmpty) {
      return 0;
    }
    if (!showLevelHeaders) {
      return items.length * itemExtent;
    }
    var groupCount = 1;
    for (var index = 1; index < items.length; index += 1) {
      if (items[index].level != items[index - 1].level) {
        groupCount += 1;
      }
    }
    return items.length * itemExtent + groupCount * levelHeaderExtent;
  }

  /// 计算角色条目在列表内容中的顶部位置
  ///
  /// [items] 当前列表角色条目
  /// [itemIndex] 角色条目下标
  /// [showLevelHeaders] 是否包含等级分组标题
  static double itemOffsetForIndex(
    List<UserCharacterApiItem> items,
    int itemIndex, {
    bool showLevelHeaders = false,
  }) {
    if (items.isEmpty) {
      return 0;
    }
    final resolvedIndex = itemIndex.clamp(0, items.length - 1).toInt();
    if (!showLevelHeaders) {
      return resolvedIndex * itemExtent;
    }

    var headerCount = 1;
    for (var index = 1; index <= resolvedIndex; index += 1) {
      if (items[index].level != items[index - 1].level) {
        headerCount += 1;
      }
    }
    return resolvedIndex * itemExtent + headerCount * levelHeaderExtent;
  }

  /// 根据列表内容偏移量查找当前可视角色
  ///
  /// [items] 当前列表角色条目
  /// [listOffset] 列表内容顶部相对视口的偏移量
  /// [showLevelHeaders] 是否包含等级分组标题
  static int? itemIndexAtListOffset(
    List<UserCharacterApiItem> items,
    double listOffset, {
    bool showLevelHeaders = false,
  }) {
    if (items.isEmpty) {
      return null;
    }
    final resolvedOffset = listOffset.clamp(0.0, double.infinity).toDouble();
    var headerCount = showLevelHeaders ? 1 : 0;
    for (var index = 0; index < items.length; index += 1) {
      if (showLevelHeaders &&
          index > 0 &&
          items[index].level != items[index - 1].level) {
        headerCount += 1;
      }
      final itemOffset = index * itemExtent +
          (showLevelHeaders ? headerCount * levelHeaderExtent : 0);
      if (resolvedOffset < itemOffset + itemExtent) {
        return index;
      }
    }
    return items.length - 1;
  }

  /// 计算目标角色所属等级分组的跳转位置
  ///
  /// [items] 当前分页窗口角色条目
  /// [itemIndex] 目标角色在分页窗口内的下标
  static double levelGroupOffsetForItem(
    List<UserCharacterApiItem> items,
    int itemIndex,
  ) {
    if (items.isEmpty) {
      return 0;
    }
    final resolvedIndex = itemIndex.clamp(0, items.length - 1);
    var groupStart = resolvedIndex;
    while (groupStart > 0 &&
        items[groupStart - 1].level == items[resolvedIndex].level) {
      groupStart -= 1;
    }
    if (groupStart == 0) {
      return 0;
    }
    var precedingHeaderCount = 1;
    for (var index = 1; index < groupStart; index += 1) {
      if (items[index].level != items[index - 1].level) {
        precedingHeaderCount += 1;
      }
    }
    return groupStart * itemExtent + precedingHeaderCount * levelHeaderExtent;
  }

  /// 构建用户角色资产条目
  ///
  /// [context] 当前组件树上下文
  /// [index] 角色条目下标
  Widget _buildCharacterItem(BuildContext context, int index) {
    final item = items[index];
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
    final avatarHeroTag = createCharacterDetailAvatarHeroTag(
      characterId: item.characterId,
      avatarUrl: avatarUrl,
      source: item,
    );

    onItemBuilt?.call(index);
    final contentTrailingInset =
        showLevelHeaders ? _levelContentTrailingInset : _contentTrailingInset;
    return _AssetListItem(
      fullWidth: true,
      showDivider: index < items.length - 1,
      dividerLeadingInset: _textLeadingInset,
      dividerTrailingInset: contentTrailingInset,
      child: UserCharacterAssetRow(
        item: item,
        avatarHeroTag: avatarHeroTag,
        sort: sort,
        contentPadding: AppSafeAreaInsets.fromLTRB(
          context,
          left: _contentLeadingInset,
          top: 0,
          right: contentTrailingInset,
          bottom: 0,
        ),
        tapBorderRadius: BorderRadius.zero,
        onTap: onCharacterTap == null
            ? null
            : () => onCharacterTap?.call(item, avatarHeroTag),
      ),
    );
  }
}

/// 用户角色等级分组标题
class _CharacterLevelHeader extends StatelessWidget {
  /// 创建用户角色等级分组标题
  ///
  /// [level] 角色等级
  const _CharacterLevelHeader({required this.level});

  /// 角色等级
  final int level;

  /// 构建用户角色等级分组标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: UserCharacterAssetSliverList.levelHeaderExtent,
      child: Padding(
        padding: AppSafeAreaInsets.fromLTRB(
          context,
          left: 20,
          top: 8,
          right: UserCharacterAssetSliverList._levelContentTrailingInset,
          bottom: 4,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Lv.$level',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
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
      itemExtent: _IcoAssetSliverListMetrics.itemExtent,
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
          return _AssetListItem(
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

/// 用户资产列表条目外层
class _AssetListItem extends StatelessWidget {
  /// 创建用户资产列表条目外层
  ///
  /// [child] 条目主体
  /// [fullWidth] 是否让条目覆盖列表完整宽度
  /// [showDivider] 是否显示条目分割线
  /// [dividerLeadingInset] 分割线左侧留白
  /// [dividerTrailingInset] 分割线右侧留白
  const _AssetListItem({
    required this.child,
    this.fullWidth = false,
    this.showDivider = false,
    this.dividerLeadingInset = 0,
    this.dividerTrailingInset = 0,
  });

  /// 条目主体
  final Widget child;

  /// 是否让条目覆盖列表完整宽度
  final bool fullWidth;

  /// 是否显示条目分割线
  final bool showDivider;

  /// 分割线左侧留白
  final double dividerLeadingInset;

  /// 分割线右侧留白
  final double dividerTrailingInset;

  /// 构建用户资产列表条目外层
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (!fullWidth) {
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
    final colorScheme = Theme.of(context).colorScheme;
    final mediaPadding = MediaQuery.paddingOf(context);
    return Stack(
      children: [
        Positioned.fill(child: child),
        if (showDivider)
          Positioned(
            left: dividerLeadingInset + mediaPadding.left,
            right: dividerTrailingInset + mediaPadding.right,
            bottom: 0,
            height: 1,
            child: ColoredBox(
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
      ],
    );
  }
}

/// 用户 ICO 资产 sliver 列表尺寸
final class _IcoAssetSliverListMetrics {
  /// 禁止创建用户 ICO 资产 sliver 列表尺寸实例
  const _IcoAssetSliverListMetrics._();

  /// 列表条目高度
  static const double itemExtent = 68;
}
