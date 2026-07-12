import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_ico_time.dart';
import 'package:magrail_app/features/user/assets/model/user_character_snapshot_query.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';
import 'package:magrail_app/features/user/model/user_ico_api_item.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_chips.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_components.dart';
import 'package:magrail_app/features/chara/tower/widgets/tower_ranking_badges.dart';

/// 用户角色资产行
class UserCharacterAssetRow extends StatelessWidget {
  /// 创建用户角色资产行
  ///
  /// [key] Flutter 组件标识
  /// [item] 用户角色接口条目
  /// [avatarHeroTag] 头像转场标识
  /// [onTap] 条目点击回调
  /// [sort] 当前用户角色排序字段
  /// [contentPadding] 行内容内边距
  /// [tapBorderRadius] 点击反馈圆角
  const UserCharacterAssetRow({
    super.key,
    required this.item,
    this.avatarHeroTag,
    this.onTap,
    this.sort = UserCharacterSnapshotSort.holdings,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 6),
    this.tapBorderRadius,
  });

  /// 用户角色接口条目
  final UserCharacterApiItem item;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 条目点击回调
  final VoidCallback? onTap;

  /// 当前用户角色排序字段
  final UserCharacterSnapshotSort sort;

  /// 行内容内边距
  final EdgeInsetsGeometry contentPadding;

  /// 点击反馈圆角
  final BorderRadius? tapBorderRadius;

  /// 构建用户角色资产行
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
          label: '持股',
          value: _formatCount(item.userTotal),
          isValueMuted: true,
        ),
        _secondaryMetric(),
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

  /// 格式化角色资产数量
  ///
  /// [value] 原始数量
  String _formatCount(int value) {
    if (value <= 0) {
      return '--';
    }

    return Formatters.groupedNumber(value);
  }

  /// 创建随排序字段变化的第三行数据
  CharacterAssetMetric _secondaryMetric() {
    return switch (sort) {
      UserCharacterSnapshotSort.towerRank => CharacterAssetMetric(
          value: '通天塔 '
              '${item.rank <= 0 ? '--' : '${Formatters.groupedNumber(item.rank)}名'}'
              ' · 星之力 ${Formatters.groupedNumber(item.starForces)}',
          isValueMuted: true,
        ),
      UserCharacterSnapshotSort.stars => CharacterAssetMetric(
          value: '',
          valueWidget: TowerStarsRow(
            stars: item.stars,
            iconSize: 10,
            spacing: 1,
            runSpacing: 0,
          ),
          isValueMuted: true,
        ),
      UserCharacterSnapshotSort.singleDividend => CharacterAssetMetric(
          label: '股息',
          value: Formatters.tinygrailCurrency(item.singleDividend),
          isValueMuted: true,
        ),
      UserCharacterSnapshotSort.totalDividend => CharacterAssetMetric(
          label: '总息',
          value: Formatters.tinygrailCompactValue(
            item.totalDividend,
            prefix: '₵',
          ),
          isValueMuted: true,
        ),
      _ => CharacterAssetMetric(
          label: '固定资产',
          value: _formatCount(item.sacrifices),
          isValueMuted: true,
        ),
    };
  }
}

/// 用户 ICO 资产行
class UserIcoAssetRow extends StatelessWidget {
  /// 创建用户 ICO 资产行
  ///
  /// [key] Flutter 组件标识
  /// [item] 用户 ICO 接口条目
  /// [avatarHeroTag] 头像转场标识
  /// [onTap] 条目点击回调
  const UserIcoAssetRow({
    super.key,
    required this.item,
    this.avatarHeroTag,
    this.onTap,
  });

  /// 用户 ICO 接口条目
  final UserIcoApiItem item;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 条目点击回调
  final VoidCallback? onTap;

  /// 构建用户 ICO 资产行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final endTime = resolveTinygrailIcoRemainingTime(item.end);
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(item.icon);

    return CharacterAssetRowShell(
      name: TinygrailFormatters.decodeHtmlEntities(item.name),
      avatarUrl: avatarUrl,
      avatarHeroTag: avatarHeroTag,
      metrics: [
        CharacterAssetMetric(
          label: '已注资',
          value: _formatInvestment(item.state),
          isValueMuted: true,
        ),
        CharacterAssetMetric(
          label: '已筹集',
          value: Formatters.tinygrailCurrency(item.total),
          isValueMuted: true,
        ),
      ],
      trailing: CharacterAssetTrailingChip(
        text: endTime.text,
        accentColor: endTime.accentColor,
      ),
      onTap: onTap,
    );
  }

  /// 格式化 ICO 已注资金额
  ///
  /// [value] 已注资金额
  String _formatInvestment(num value) {
    if (value <= 0) {
      return '--';
    }

    return Formatters.tinygrailCurrency(value);
  }
}
