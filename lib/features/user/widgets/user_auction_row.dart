import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/features/user/model/user_auction_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_pill.dart';

/// 用户拍卖行
class UserAuctionRow extends StatelessWidget {
  /// 创建用户拍卖行
  ///
  /// [key] Flutter 组件标识
  /// [item] 用户拍卖条目
  /// [avatarHeroTag] 头像转场标识
  /// [onTap] 拍卖弹窗点击回调
  /// [onCharacterTap] 角色详情点击回调
  /// [onCancelAuction] 取消竞拍回调
  /// [hideCharacterInfo] 是否隐藏角色资料
  const UserAuctionRow({
    super.key,
    required this.item,
    this.avatarHeroTag,
    this.onTap,
    this.onCharacterTap,
    this.onCancelAuction,
    this.hideCharacterInfo = false,
  });

  /// 用户拍卖条目
  final UserAuctionApiItem item;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 拍卖弹窗点击回调
  final VoidCallback? onTap;

  /// 角色详情点击回调
  final void Function(UserAuctionApiItem item, String? avatarHeroTag)?
      onCharacterTap;

  /// 取消竞拍回调
  final ValueChanged<UserAuctionApiItem>? onCancelAuction;

  /// 是否隐藏角色资料
  final bool hideCharacterInfo;

  static const Color _auctioningColor = Color(0xFF45D216);
  static const Color _successColor = Color(0xFFFF5A91);
  static const Color _failedColor = Color(0xFF8A8F98);
  static const String _hiddenNameText = '******';
  static const String _hiddenValueText = '***';

  bool get _isAuctioning => item.state == 0;

  /// 构建用户拍卖行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final detail = item.auctionDetail;
    final handleCharacterTap = onCharacterTap == null
        ? null
        : () => onCharacterTap!(item, avatarHeroTag);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSafeAreaInsets.symmetricHorizontal(
            context,
            horizontal: 12,
            vertical: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AuctionCharacterAvatar(
                imageUrl: hideCharacterInfo
                    ? TinygrailAssetUrls.normalizeAvatar('')
                    : TinygrailAssetUrls.normalizeAvatar(item.icon),
                heroTag: avatarHeroTag,
                onTap: handleCharacterTap,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: InkWell(
                                  onTap: handleCharacterTap,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Text(
                                    _displayName,
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
                              ),
                              const SizedBox(width: 6),
                              UserAssetRecordPill(
                                text: _statusText,
                                accentColor: _statusColor,
                                isCompact: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          TinygrailFormatters.relativeTime(item.bid),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _AuctionBidSummary(
                                priceText: _resolvePrivacyText(
                                  Formatters.tinygrailCurrency(item.price),
                                ),
                                amountText: Formatters.groupedNumber(
                                  item.amount,
                                ),
                                valueColor:
                                    _isAuctioning ? _successColor : null,
                              ),
                              if (_isAuctioning) ...[
                                const SizedBox(height: 3),
                                _AuctionInlineIconMetricRow(
                                  metrics: [
                                    _AuctionIconMetricData(
                                      icon: Icons.group_rounded,
                                      value: _resolvePrivacyText(
                                        _formatOptionalCount(detail?.state),
                                      ),
                                      valueColor:
                                          _resolveInfoColor(colorScheme),
                                    ),
                                    _AuctionIconMetricData(
                                      icon: LucideIcons.gavel,
                                      value: _resolvePrivacyText(
                                        _formatOptionalCount(detail?.type),
                                      ),
                                      valueColor:
                                          _resolveInfoColor(colorScheme),
                                    ),
                                    _AuctionIconMetricData(
                                      icon: Icons.account_balance_rounded,
                                      value: _resolvePrivacyText(
                                        Formatters.groupedNumber(item.type),
                                      ),
                                      valueColor:
                                          _resolveInfoColor(colorScheme),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (_isAuctioning && onCancelAuction != null) ...[
                          const SizedBox(width: 8),
                          _CancelAuctionButton(
                            onPressed: () => onCancelAuction!(item),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 展示角色名称
  String get _displayName {
    if (hideCharacterInfo) {
      return _hiddenNameText;
    }

    final name = TinygrailFormatters.decodeHtmlEntities(item.name).trim();
    if (name.isEmpty) {
      return '#${item.characterId}';
    }

    return name;
  }

  /// 格式化可缺省数量
  ///
  /// [value] 原始数量
  String _formatOptionalCount(int? value) {
    if (value == null) {
      return '--';
    }

    return Formatters.groupedNumber(value);
  }

  /// 按隐私状态解析展示文本
  ///
  /// [value] 原始文本
  String _resolvePrivacyText(String value) {
    return hideCharacterInfo ? _hiddenValueText : value;
  }

  /// 拍卖状态文案
  String get _statusText {
    return switch (item.state) {
      0 => '竞拍中',
      1 => '竞拍成功',
      _ => '竞拍失败',
    };
  }

  /// 拍卖状态颜色
  Color get _statusColor {
    return switch (item.state) {
      0 => _auctioningColor,
      1 => _successColor,
      _ => _failedColor,
    };
  }

  /// 解析补充信息颜色
  ///
  /// [colorScheme] 当前主题色板
  Color _resolveInfoColor(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.dark
        ? const Color(0xFF7DD3FC)
        : const Color(0xFF0284C7);
  }
}

/// 用户拍卖角色头像点击区
class _AuctionCharacterAvatar extends StatelessWidget {
  /// 创建用户拍卖角色头像点击区
  ///
  /// [imageUrl] 角色头像地址
  /// [heroTag] 头像转场标识
  /// [onTap] 点击回调
  const _AuctionCharacterAvatar({
    required this.imageUrl,
    required this.heroTag,
    required this.onTap,
  });

  /// 角色头像地址
  final String imageUrl;

  /// 头像转场标识
  final String? heroTag;

  /// 点击回调
  final VoidCallback? onTap;

  /// 构建用户拍卖角色头像点击区
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (resolvedHeroTag == null || resolvedHeroTag.isEmpty)
              avatar
            else
              Hero(
                tag: resolvedHeroTag,
                transitionOnUserGestures: true,
                child: avatar,
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 用户拍卖取消按钮
class _CancelAuctionButton extends StatelessWidget {
  /// 创建用户拍卖取消按钮
  ///
  /// [onPressed] 点击回调
  const _CancelAuctionButton({
    required this.onPressed,
  });

  /// 点击回调
  final VoidCallback onPressed;

  /// 构建用户拍卖取消按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(
        alpha: isDark ? 0.42 : 0.58,
      ),
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Text(
            '撤销竞拍',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// 用户拍卖出价摘要
class _AuctionBidSummary extends StatelessWidget {
  /// 创建用户拍卖出价摘要
  ///
  /// [priceText] 出价文本
  /// [amountText] 数量文本
  /// [valueColor] 数值颜色
  const _AuctionBidSummary({
    required this.priceText,
    required this.amountText,
    this.valueColor,
  });

  /// 出价文本
  final String priceText;

  /// 数量文本
  final String amountText;

  /// 数值颜色
  final Color? valueColor;

  /// 构建用户拍卖出价摘要
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedValueColor = valueColor ?? colorScheme.onSurfaceVariant;
    final labelStyle = TextStyle(
      color: colorScheme.onSurfaceVariant,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.05,
    );
    final valueStyle = labelStyle.copyWith(
      color: resolvedValueColor,
      fontWeight: FontWeight.w800,
    );

    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: '价格 '),
          TextSpan(text: priceText, style: valueStyle),
          TextSpan(
            text: ' · ',
            style: labelStyle.copyWith(fontWeight: FontWeight.w800),
          ),
          const TextSpan(text: '数量 '),
          TextSpan(text: amountText, style: valueStyle),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: labelStyle,
    );
  }
}

/// 用户拍卖图标指标数据
final class _AuctionIconMetricData {
  /// 创建用户拍卖图标指标数据
  ///
  /// [icon] 指标图标
  /// [value] 指标数值
  /// [valueColor] 数值颜色
  const _AuctionIconMetricData({
    required this.icon,
    required this.value,
    this.valueColor,
  });

  /// 指标图标
  final IconData icon;

  /// 指标数值
  final String value;

  /// 数值颜色
  final Color? valueColor;
}

/// 用户拍卖左对齐图标指标行
class _AuctionInlineIconMetricRow extends StatelessWidget {
  /// 创建用户拍卖左对齐图标指标行
  ///
  /// [metrics] 指标数据
  const _AuctionInlineIconMetricRow({
    required this.metrics,
  });

  /// 指标数据
  final List<_AuctionIconMetricData> metrics;

  /// 构建用户拍卖左对齐图标指标行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = colorScheme.onSurfaceVariant;

    return Text.rich(
      TextSpan(
        children: [
          for (var index = 0; index < metrics.length; index++) ...[
            if (index > 0)
              const WidgetSpan(
                child: SizedBox(width: 9),
              ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Icon(
                  metrics[index].icon,
                  size: 14,
                  color: iconColor,
                ),
              ),
            ),
            TextSpan(
              text: metrics[index].value,
              style: TextStyle(
                color: metrics[index].valueColor ?? iconColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: iconColor,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        height: 1.05,
      ),
    );
  }
}
