import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/features/chara/detail/character_detail_hero.dart';
import 'package:magrail_app/features/chara/model/character_full_list_sort.dart';
import 'package:magrail_app/features/chara/tower/widgets/tower_ranking_badges.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_chips.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_components.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_skeleton_sliver_list.dart';
import 'package:magrail_app/features/ico/model/st_character_entry.dart';

/// ST 角色 sliver 列表
class StCharacterSliverList extends StatelessWidget {
  /// 创建 ST 角色 sliver 列表
  ///
  /// [key] Flutter 组件标识
  /// [items] ST 角色条目
  /// [sort] 当前全量列表排序字段
  /// [onItemBuilt] 条目构建回调
  /// [onCharacterTap] 角色条目点击回调
  const StCharacterSliverList({
    super.key,
    required this.items,
    this.sort,
    this.onItemBuilt,
    this.onCharacterTap,
  });

  /// ST 角色条目
  final List<StCharacterEntry> items;

  /// 当前全量列表排序字段
  final CharacterFullListSort? sort;

  /// 条目构建回调
  final ValueChanged<int>? onItemBuilt;

  /// 角色条目点击回调
  final void Function(StCharacterEntry item, String? avatarHeroTag)?
  onCharacterTap;

  /// 构建 ST 角色 sliver 列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList(
      itemExtent: _StCharacterListMetrics.itemExtent,
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = items[index];
        final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);
        final avatarHeroTag = createCharacterDetailAvatarHeroTag(
          characterId: item.characterId,
          avatarUrl: avatarUrl,
          source: item,
        );

        onItemBuilt?.call(index);
        return CharacterAssetListItemShell(
          showDivider: index < items.length - 1,
          child: StCharacterRow(
            item: item,
            sort: sort,
            avatarHeroTag: avatarHeroTag,
            onTap: onCharacterTap == null
                ? null
                : () => onCharacterTap?.call(item, avatarHeroTag),
            contentPadding: AppSafeAreaInsets.fromLTRB(
              context,
              left: 18,
              top: 0,
              right: 18,
              bottom: 0,
            ),
            tapBorderRadius: BorderRadius.zero,
          ),
        );
      }, childCount: items.length),
    );
  }
}

/// ST 角色 sliver 骨架列表
class StCharacterSkeletonSliverList extends StatelessWidget {
  /// 创建 ST 角色 sliver 骨架列表
  ///
  /// [key] Flutter 组件标识
  /// [itemCount] 骨架条目数量
  const StCharacterSkeletonSliverList({super.key, this.itemCount = 24});

  /// 骨架条目数量
  final int itemCount;

  /// 构建 ST 角色 sliver 骨架列表
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return CharacterAssetSkeletonSliverList(
      itemCount: itemCount,
      showTrailing: true,
    );
  }
}

/// ST 角色行
class StCharacterRow extends StatelessWidget {
  /// 创建 ST 角色行
  ///
  /// [key] Flutter 组件标识
  /// [item] ST 角色条目
  /// [sort] 当前全量列表排序字段
  /// [avatarHeroTag] 头像转场标识
  /// [onTap] 条目点击回调
  /// [contentPadding] 行内容内边距
  /// [tapBorderRadius] 点击反馈圆角
  const StCharacterRow({
    super.key,
    required this.item,
    this.sort,
    this.avatarHeroTag,
    this.onTap,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 6),
    this.tapBorderRadius,
  });

  /// ST 角色条目
  final StCharacterEntry item;

  /// 当前全量列表排序字段
  final CharacterFullListSort? sort;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 条目点击回调
  final VoidCallback? onTap;

  /// 行内容内边距
  final EdgeInsetsGeometry contentPadding;

  /// 点击反馈圆角
  final BorderRadius? tapBorderRadius;

  /// 构建 ST 角色行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);

    return CharacterAssetRowShell(
      name: TinygrailFormatters.decodeHtmlEntities(item.name),
      avatarUrl: avatarUrl,
      avatarHeroTag: avatarHeroTag,
      level: item.level,
      zeroCount: item.zeroCount,
      metrics: [
        CharacterAssetMetric(
          label: '流通',
          value: _formatCount(item.total),
          isValueMuted: true,
        ),
        _buildSecondaryMetric(),
      ],
      trailing: CharacterAssetCurrentPriceChip(
        current: item.current,
        fluctuation: item.fluctuation,
      ),
      onTap: onTap,
      contentPadding: contentPadding,
      tapBorderRadius: tapBorderRadius,
    );
  }

  /// 构建随排序字段变化的第三行数据
  CharacterAssetMetric _buildSecondaryMetric() {
    return switch (sort) {
      CharacterFullListSort.dividend => CharacterAssetMetric(
        label: '股息',
        value: '+${Formatters.tinygrailCurrency(item.singleDividend)}',
        isValueMuted: true,
      ),
      CharacterFullListSort.towerRank => CharacterAssetMetric(
        value:
            '通天塔 '
            '${item.rank <= 0 ? '--' : '${Formatters.groupedNumber(item.rank)}名'}'
            ' · 星之力 ${Formatters.groupedNumber(item.starForces)}',
        isValueMuted: true,
      ),
      CharacterFullListSort.stars => CharacterAssetMetric(
        value: '',
        valueWidget: TowerStarsRow(
          stars: item.stars,
          iconSize: 10,
          spacing: 1,
          runSpacing: 0,
        ),
        isValueMuted: true,
      ),
      CharacterFullListSort.fluctuation => CharacterAssetMetric(
        label: '涨跌',
        value: _formatFluctuation(item.fluctuation),
        isValueMuted: true,
        valueColor: CharacterAssetCurrentPriceChip.resolveCurrentPriceColor(
          item.fluctuation,
        ),
      ),
      CharacterFullListSort.marketValue => CharacterAssetMetric(
        label: '市值',
        value: _formatMarketValue(item.marketValue),
        isValueMuted: true,
      ),
      CharacterFullListSort.listedDate => CharacterAssetMetric(
        label: '上市日期',
        value: TinygrailFormatters.listedDate(item.listedDate),
        isValueMuted: true,
      ),
      _ => CharacterAssetMetric(
        label: '买卖',
        value: '${_formatCount(item.bids)} / ${_formatCount(item.asks)}',
        isValueMuted: true,
      ),
    };
  }

  /// 格式化 ST 角色数量
  ///
  /// [value] 原始数量
  String _formatCount(int value) {
    if (value <= 0) {
      return '0';
    }

    return Formatters.groupedNumber(value);
  }

  /// 格式化 ST 角色涨跌幅
  ///
  /// [value] 原始涨跌幅
  String _formatFluctuation(double value) {
    final percent = Formatters.groupedNumber(value * 100);
    if (value > 0) {
      return '+$percent%';
    }
    return '$percent%';
  }

  /// 格式化 ST 角色市值
  ///
  /// [value] 原始市值
  String _formatMarketValue(double value) {
    if (value.abs() >= 10000) {
      return Formatters.tinygrailCompactValue(value.truncate(), prefix: '₵');
    }
    return Formatters.tinygrailCurrency(value);
  }
}

/// ST 角色列表尺寸
final class _StCharacterListMetrics {
  /// 禁用创建 ST 角色列表尺寸实例
  const _StCharacterListMetrics._();

  static const double itemExtent = 68;
}
