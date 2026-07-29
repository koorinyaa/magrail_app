import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/features/chara/auction/model/auction_api_item.dart';
import 'package:magrail_app/features/chara/model/character_full_list_sort.dart';
import 'package:magrail_app/features/chara/tower/widgets/tower_ranking_badges.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_chips.dart';
import 'package:magrail_app/features/chara/widgets/character_asset_row_components.dart';
import 'package:magrail_app/features/user/model/user_character_api_item.dart';

/// 角色池资产行类型
enum CharacterPoolRowType {
  /// 英灵殿角色行
  valhalla,

  /// 幻想乡角色行
  gensokyo,
}

/// 角色池资产行
class CharacterPoolRow extends StatelessWidget {
  /// 竞拍按钮固定尺寸
  static const Size auctionButtonSize = Size(46, 22);

  /// 创建角色池资产行
  ///
  /// [key] Flutter 组件标识
  /// [item] 角色池条目
  /// [rowType] 角色池资产行类型
  /// [sort] 当前全量列表排序字段
  /// [auction] 当前用户拍卖详情
  /// [avatarHeroTag] 头像转场标识
  /// [onTap] 条目点击回调
  /// [onAuctionPressed] 竞拍按钮点击回调
  const CharacterPoolRow({
    super.key,
    required this.item,
    required this.rowType,
    this.sort,
    this.auction,
    this.avatarHeroTag,
    this.onTap,
    this.onAuctionPressed,
  });

  /// 角色池条目
  final UserCharacterApiItem item;

  /// 角色池资产行类型
  final CharacterPoolRowType rowType;

  /// 当前全量列表排序字段
  final CharacterFullListSort? sort;

  /// 当前用户拍卖详情
  final AuctionApiItem? auction;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 条目点击回调
  final VoidCallback? onTap;

  /// 竞拍按钮点击回调
  final VoidCallback? onAuctionPressed;

  /// 构建角色池资产行
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
          label: '数量',
          value: _formatCount(item.state),
          isValueMuted: true,
        ),
        _buildSecondaryMetric(),
      ],
      trailing: _buildTrailing(),
      onTap: onTap,
    );
  }

  /// 构建角色池第三行数据
  CharacterAssetMetric _buildSecondaryMetric() {
    final selectedSort = sort;
    if (selectedSort != null && !_isSortDisplayed(selectedSort)) {
      return _buildSortMetric(selectedSort);
    }
    return _buildDefaultSecondaryMetric();
  }

  /// 判断排序字段是否已经由当前角色行展示
  ///
  /// [selectedSort] 当前排序字段
  bool _isSortDisplayed(CharacterFullListSort selectedSort) {
    return switch (selectedSort) {
      CharacterFullListSort.quantity => true,
      CharacterFullListSort.dividend =>
        rowType == CharacterPoolRowType.gensokyo,
      CharacterFullListSort.currentPrice =>
        rowType == CharacterPoolRowType.gensokyo,
      _ => false,
    };
  }

  /// 构建当前排序字段对应的第三行数据
  ///
  /// [selectedSort] 当前排序字段
  CharacterAssetMetric _buildSortMetric(CharacterFullListSort selectedSort) {
    return switch (selectedSort) {
      CharacterFullListSort.level ||
      CharacterFullListSort.circulation =>
        CharacterAssetMetric(
          label: '流通',
          value: _formatCount(item.total),
          isValueMuted: true,
        ),
      CharacterFullListSort.dividend => CharacterAssetMetric(
          label: '股息',
          value: '+${Formatters.tinygrailCurrency(item.singleDividend)}',
          isValueMuted: true,
        ),
      CharacterFullListSort.towerRank => CharacterAssetMetric(
          value: '通天塔 '
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
      CharacterFullListSort.currentPrice => CharacterAssetMetric(
          label: '当前价',
          value: Formatters.tinygrailCurrency(item.current),
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
      _ => _buildDefaultSecondaryMetric(),
    };
  }

  /// 构建角色池默认第三行数据
  CharacterAssetMetric _buildDefaultSecondaryMetric() {
    return switch (rowType) {
      CharacterPoolRowType.valhalla => CharacterAssetMetric(
          label: '底价',
          value: Formatters.tinygrailCurrency(item.price),
          isValueMuted: true,
        ),
      CharacterPoolRowType.gensokyo => CharacterAssetMetric(
          label: '股息',
          value: '+${Formatters.tinygrailCurrency(item.singleDividend)}',
          isValueMuted: true,
        ),
    };
  }

  /// 构建角色池行尾操作
  Widget _buildTrailing() {
    return switch (rowType) {
      CharacterPoolRowType.valhalla => _CharacterPoolAuctionButton(
          hasUserBid: auction != null,
          onPressed: onAuctionPressed,
        ),
      CharacterPoolRowType.gensokyo => CharacterAssetCurrentPriceChip(
          current: item.current,
          fluctuation: item.fluctuation,
        ),
    };
  }

  /// 格式化角色池数量
  ///
  /// [value] 原始数量
  String _formatCount(int value) {
    if (value <= 0) {
      return '0';
    }

    return Formatters.groupedNumber(value);
  }

  /// 格式化角色池涨跌幅
  ///
  /// [value] 原始涨跌幅
  String _formatFluctuation(double value) {
    final percent = Formatters.groupedNumber(value * 100);
    if (value > 0) {
      return '+$percent%';
    }
    return '$percent%';
  }

  /// 格式化角色池市值
  ///
  /// [value] 原始市值
  String _formatMarketValue(double value) {
    if (value.abs() >= 10000) {
      return Formatters.tinygrailCompactValue(
        value.truncate(),
        prefix: '₵',
      );
    }
    return Formatters.tinygrailCurrency(value);
  }
}

/// 角色池竞拍按钮
class _CharacterPoolAuctionButton extends StatelessWidget {
  /// 创建角色池竞拍按钮
  ///
  /// [hasUserBid] 当前用户是否已经出价
  /// [onPressed] 点击回调
  const _CharacterPoolAuctionButton({
    required this.hasUserBid,
    required this.onPressed,
  });

  final bool hasUserBid;
  final VoidCallback? onPressed;

  /// 构建角色池竞拍按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onPressed = this.onPressed;
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
      width: CharacterPoolRow.auctionButtonSize.width,
      height: CharacterPoolRow.auctionButtonSize.height,
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
