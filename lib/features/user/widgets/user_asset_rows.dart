import 'package:flutter/material.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
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

// 隐藏状态文本
const String _hiddenPrivateValue = '******';

/// 查询用户角色未公开持股
///
/// [item] 用户角色条目
typedef UserCharacterHoldingResolver = Future<int?> Function(
  UserCharacterApiItem item,
);

/// 用户角色资产行
class UserCharacterAssetRow extends StatelessWidget {
  /// 创建用户角色资产行
  ///
  /// [key] Flutter 组件标识
  /// [item] 用户角色接口条目
  /// [avatarHeroTag] 头像转场标识
  /// [onTap] 条目点击回调
  /// [onRevealHoldings] 未公开持股查询回调
  /// [sort] 当前用户角色排序字段
  /// [hideHoldings] 是否隐藏持股数量
  /// [contentPadding] 行内容内边距
  /// [tapBorderRadius] 点击反馈圆角
  const UserCharacterAssetRow({
    super.key,
    required this.item,
    this.avatarHeroTag,
    this.onTap,
    this.onRevealHoldings,
    this.sort = UserCharacterSnapshotSort.holdings,
    this.hideHoldings = false,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 6),
    this.tapBorderRadius,
  });

  /// 用户角色接口条目
  final UserCharacterApiItem item;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 条目点击回调
  final VoidCallback? onTap;

  /// 未公开持股查询回调
  final UserCharacterHoldingResolver? onRevealHoldings;

  /// 当前用户角色排序字段
  final UserCharacterSnapshotSort sort;

  /// 是否隐藏持股数量
  final bool hideHoldings;

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
          value: '',
          valueWidget: _UserCharacterHoldingPill(
            item: item,
            hideHoldings: hideHoldings,
            onRevealHoldings: onRevealHoldings,
          ),
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
      titleMetricSpacing: 4,
      metricSpacing: 4,
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

/// 用户角色持股胶囊
class _UserCharacterHoldingPill extends StatefulWidget {
  /// 创建用户角色持股胶囊
  ///
  /// [item] 用户角色条目
  /// [hideHoldings] 是否隐藏持股数量
  /// [onRevealHoldings] 未公开持股查询回调
  const _UserCharacterHoldingPill({
    required this.item,
    required this.hideHoldings,
    required this.onRevealHoldings,
  });

  /// 用户角色条目
  final UserCharacterApiItem item;

  /// 是否隐藏持股数量
  final bool hideHoldings;

  /// 未公开持股查询回调
  final UserCharacterHoldingResolver? onRevealHoldings;

  /// 创建用户角色持股胶囊状态
  @override
  State<_UserCharacterHoldingPill> createState() =>
      _UserCharacterHoldingPillState();
}

/// 用户角色持股胶囊状态
class _UserCharacterHoldingPillState extends State<_UserCharacterHoldingPill> {
  // 查询结果仅绑定当前行，不写回角色条目、快照或排序数据
  int? _revealedHoldings;
  bool _isRevealing = false;

  /// 处理用户角色条目变化
  ///
  /// [oldWidget] 更新前的持股胶囊
  @override
  void didUpdateWidget(covariant _UserCharacterHoldingPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.item, oldWidget.item) ||
        widget.onRevealHoldings == null && oldWidget.onRevealHoldings != null) {
      _revealedHoldings = null;
      _isRevealing = false;
    }
  }

  /// 构建用户角色持股胶囊
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _buildUserAmountPill(
      context,
      text: _displayText,
      onPressed: _canReveal ? _handleRevealPressed : null,
    );
  }

  /// 当前持股胶囊文案
  String get _displayText {
    if (widget.hideHoldings) {
      return '$_hiddenPrivateValue 股';
    }
    if (_isRevealing) {
      return '查询中';
    }

    final holdings = _revealedHoldings ?? widget.item.userTotal;
    if (holdings > 0) {
      return '${Formatters.groupedNumber(holdings)}股';
    }
    if (widget.onRevealHoldings != null) {
      return '点击查看';
    }
    return '-- 股';
  }

  /// 是否允许查询未公开持股
  bool get _canReveal {
    return !widget.hideHoldings &&
        widget.item.userTotal <= 0 &&
        _revealedHoldings == null &&
        !_isRevealing &&
        widget.onRevealHoldings != null;
  }

  /// 查询并在当前行显示未公开持股
  Future<void> _handleRevealPressed() async {
    final onRevealHoldings = widget.onRevealHoldings;
    if (onRevealHoldings == null || _isRevealing) {
      return;
    }

    final requestedItem = widget.item;
    setState(() {
      _isRevealing = true;
    });

    try {
      final holdings = await onRevealHoldings(requestedItem);
      if (!mounted || !identical(widget.item, requestedItem)) {
        return;
      }
      if (holdings == null || holdings <= 0) {
        AppToast.error(context, text: '获取用户持股失败，请稍后重试');
        return;
      }
      setState(() {
        _revealedHoldings = holdings;
      });
    } catch (_) {
      if (!mounted || !identical(widget.item, requestedItem)) {
        return;
      }
      AppToast.error(context, text: '获取用户持股失败，请稍后重试');
    } finally {
      if (mounted && identical(widget.item, requestedItem)) {
        setState(() {
          _isRevealing = false;
        });
      }
    }
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
  /// [hideInvestment] 是否隐藏已注资金额
  const UserIcoAssetRow({
    super.key,
    required this.item,
    this.avatarHeroTag,
    this.onTap,
    this.hideInvestment = false,
  });

  /// 用户 ICO 接口条目
  final UserIcoApiItem item;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 条目点击回调
  final VoidCallback? onTap;

  /// 是否隐藏已注资金额
  final bool hideInvestment;

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
          value: '',
          valueWidget: _buildUserAmountPill(
            context,
            text:
                '已注资 ${hideInvestment ? _hiddenPrivateValue : _formatInvestment(item.state)}',
          ),
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
      titleMetricSpacing: 4,
      metricSpacing: 4,
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

/// 构建用户私有资产数值胶囊
///
/// [context] 当前组件树上下文
/// [text] 展示文案
/// [onPressed] 点击回调
Widget _buildUserAmountPill(
  BuildContext context, {
  required String text,
  VoidCallback? onPressed,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final borderRadius = BorderRadius.circular(999);
  return Material(
    color: Colors.transparent,
    borderRadius: borderRadius,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onPressed,
      borderRadius: borderRadius,
      child: Ink(
        decoration: BoxDecoration(
          color: colorScheme.outlineVariant,
          borderRadius: borderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    ),
  );
}
