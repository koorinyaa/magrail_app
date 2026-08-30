import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/widgets/app_load_failed_state.dart';
import 'package:magrail_app/features/chara/auction/model/auction_api_item.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/model/character_full_list_sort.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_components.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_skeleton_sliver_list.dart';
import 'package:magrail_app/features/chara/widgets/character_level_grouped_sliver_list.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';

import 'character_pool_row.dart';

export 'character_pool_row.dart';

/// 角色池 sliver 列表
class CharacterPoolSliverList extends StatelessWidget {
  /// 创建角色池 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] 角色池条目
  /// [rowType] 角色池资产行类型
  /// [auctionMap] 当前用户竞拍映射
  /// [sort] 当前全量列表排序字段
  /// [showLevelHeaders] 是否显示等级标题
  /// [onItemBuilt] 条目构建回调
  /// [onCharacterTap] 角色条目点击回调
  /// [onAuctionPressed] 竞拍按钮点击回调
  const CharacterPoolSliverList({
    super.key,
    required this.items,
    required this.rowType,
    required this.auctionMap,
    this.sort,
    this.showLevelHeaders = false,
    this.onItemBuilt,
    this.onCharacterTap,
    this.onAuctionPressed,
  });

  /// 角色池条目
  final List<UserCharacterApiItem> items;

  /// 角色池资产行类型
  final CharacterPoolRowType rowType;

  /// 当前用户竞拍映射
  final Map<int, AuctionApiItem> auctionMap;

  /// 当前全量列表排序字段
  final CharacterFullListSort? sort;

  /// 是否显示等级标题
  final bool showLevelHeaders;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 角色条目点击回调
  final void Function(UserCharacterApiItem item, String? avatarHeroTag)?
  onCharacterTap;

  /// 竞拍按钮点击回调
  final ValueChanged<UserCharacterApiItem>? onAuctionPressed;

  /// 构建角色池 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    if (showLevelHeaders) {
      return CharacterLevelGroupedSliverList<UserCharacterApiItem>(
        items: items,
        levelOf: (item) => item.level,
        itemBuilder: (context, item, index) {
          return _buildItem(context, index, reserveLevelRail: true);
        },
      );
    }
    return SliverFixedExtentList(
      itemExtent: _CharacterPoolListMetrics.itemExtent,
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildItem(context, index),
        childCount: items.length,
      ),
    );
  }

  /// 构建角色池列表条目
  ///
  /// [context] 当前组件树上下文
  /// [index] 当前角色下标
  /// [reserveLevelRail] 是否为等级轨道预留右侧宽度
  Widget _buildItem(
    BuildContext context,
    int index, {
    bool reserveLevelRail = false,
  }) {
    final item = items[index];
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
    final avatarHeroTag = createCharacterDetailAvatarHeroTag(
      characterId: item.characterId,
      avatarUrl: avatarUrl,
      source: item,
    );

    onItemBuilt?.call(index);
    final contentTrailingInset = reserveLevelRail ? 38.0 : 18.0;
    return CharacterAssetListItemShell(
      showDivider: index < items.length - 1,
      dividerTrailingInset: contentTrailingInset,
      child: CharacterPoolRow(
        item: item,
        rowType: rowType,
        sort: sort,
        auction: auctionMap[item.characterId],
        avatarHeroTag: avatarHeroTag,
        onTap: onCharacterTap == null
            ? null
            : () => onCharacterTap?.call(item, avatarHeroTag),
        onAuctionPressed: onAuctionPressed == null
            ? null
            : () => onAuctionPressed?.call(item),
        contentPadding: AppSafeAreaInsets.fromLTRB(
          context,
          left: 18,
          top: 0,
          right: contentTrailingInset,
          bottom: 0,
        ),
        tapBorderRadius: BorderRadius.zero,
      ),
    );
  }
}

/// 角色池 sliver 骨架列表
class CharacterPoolSkeletonSliverList extends StatelessWidget {
  /// 创建角色池 sliver 骨架列表
  ///
  /// [key] Flutter 组件标识
  /// [rowType] 角色池资产行类型
  /// [itemCount] 骨架条目数量
  const CharacterPoolSkeletonSliverList({
    super.key,
    required this.rowType,
    this.itemCount = 24,
  });

  /// 角色池资产行类型
  final CharacterPoolRowType rowType;

  /// 骨架条目数量
  final int itemCount;

  /// 构建角色池 sliver 骨架列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final trailingSize = _trailingSkeletonSize(rowType);

    return CharacterAssetSkeletonSliverList(
      itemCount: itemCount,
      showTrailing: true,
      trailingWidth: trailingSize.width,
      trailingHeight: trailingSize.height,
    );
  }
}

/// 角色池预览提示状态
class CharacterPoolOverviewMessage extends StatelessWidget {
  /// 创建角色池预览提示状态
  ///
  /// [key] Flutter 组件标识
  /// [message] 提示文案
  /// [onRetry] 重试回调
  const CharacterPoolOverviewMessage({
    super.key,
    required this.message,
    this.onRetry,
  });

  /// 提示文案
  final String message;

  /// 重试回调
  final Future<void> Function()? onRetry;

  /// 构建角色池预览提示状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final onRetry = this.onRetry;
    if (onRetry != null) {
      return AppLoadFailedState(
        message: message,
        onActionPressed: () {
          onRetry();
        },
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(
          alpha: colorScheme.brightness == Brightness.dark ? 0.72 : 0.82,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 角色池列表尺寸
final class _CharacterPoolListMetrics {
  /// 禁止创建角色池列表尺寸实例
  const _CharacterPoolListMetrics._();

  /// 角色池列表条目高度
  static const double itemExtent = 68;
}

/// 读取角色池行尾骨架尺寸
///
/// [rowType] 角色池资产行类型
Size _trailingSkeletonSize(CharacterPoolRowType rowType) {
  return switch (rowType) {
    CharacterPoolRowType.valhalla => CharacterPoolRow.auctionButtonSize,
    CharacterPoolRowType.gensokyo => const Size(54, 18),
  };
}
