import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 用户资料卡操作按钮组
class UserProfileCardActions extends StatelessWidget {
  /// 创建用户资料卡操作按钮组
  ///
  /// [key] Flutter 组件标识
  /// [isCurrentUser] 是否为当前登录用户
  /// [onRecordPressed] 红包记录按钮点击回调
  /// [onSendPressed] 发送红包按钮点击回调
  const UserProfileCardActions({
    super.key,
    required this.isCurrentUser,
    required this.onRecordPressed,
    required this.onSendPressed,
  });

  /// 是否为当前登录用户
  final bool isCurrentUser;

  /// 红包记录按钮点击回调
  final VoidCallback onRecordPressed;

  /// 发送红包按钮点击回调
  final VoidCallback onSendPressed;

  /// 构建用户资料卡操作按钮组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SmallPillButton(
          icon: Icons.receipt_long_rounded,
          label: '红包记录',
          foregroundColor: const Color(0xFFC85B68),
          backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
          onPressed: onRecordPressed,
        ),
        if (!isCurrentUser) ...[
          const SizedBox(width: 6),
          _SmallPillButton(
            icon: Icons.card_giftcard_rounded,
            label: '发送红包',
            foregroundColor: Colors.white,
            backgroundColor: colorScheme.primary,
            onPressed: onSendPressed,
          ),
        ],
      ],
    );
  }
}

/// 小圣杯封禁状态标签
class UserBannedLabel extends StatelessWidget {
  /// 创建小圣杯封禁状态标签
  ///
  /// [key] Flutter 组件标识
  const UserBannedLabel({super.key});

  /// 构建小圣杯封禁状态标签
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return const Text(
      '小圣杯封禁中',
      style: TextStyle(
        color: Color(0xFFEF4444),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
  }
}

/// 用户资料卡小按钮
class _SmallPillButton extends StatelessWidget {
  /// 创建用户资料卡小按钮
  ///
  /// [icon] 按钮图标
  /// [label] 按钮文案
  /// [foregroundColor] 前景颜色
  /// [backgroundColor] 背景颜色
  /// [onPressed] 按钮点击回调
  const _SmallPillButton({
    required this.icon,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.onPressed,
  });

  /// 按钮图标
  final IconData icon;

  /// 按钮文案
  final String label;

  /// 前景颜色
  final Color foregroundColor;

  /// 背景颜色
  final Color backgroundColor;

  /// 按钮点击回调
  final VoidCallback onPressed;

  /// 构建用户资料卡小按钮
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(9),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: 82,
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: foregroundColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 用户排名徽标
class UserProfileRankBadge extends StatelessWidget {
  /// 创建用户排名徽标
  ///
  /// [key] Flutter 组件标识
  /// [rank] 用户排名
  /// [isCompact] 是否使用紧凑尺寸
  const UserProfileRankBadge({
    super.key,
    required this.rank,
    this.isCompact = false,
  });

  /// 用户排名
  final int rank;

  /// 是否使用紧凑尺寸
  final bool isCompact;

  /// 构建用户排名徽标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = isCompact ? 14.0 : 16.0;
    final horizontalPadding = isCompact ? 5.0 : 7.0;
    final radius = isCompact ? 7.0 : 8.0;
    final fontSize = isCompact ? 9.0 : 10.0;

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF4A3515) : const Color(0xFFFFF2D8),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        '#$rank',
        style: TextStyle(
          color: isDark ? const Color(0xFFFFC568) : const Color(0xFFB87611),
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

/// 用户 ID 行
class UserProfileIdRow extends StatelessWidget {
  /// 创建用户 ID 行
  ///
  /// [key] Flutter 组件标识
  /// [tinygrailId] 小圣杯 ID
  /// [bangumiId] BGM ID
  /// [onTinygrailCopyPressed] 复制小圣杯 ID 点击回调
  /// [onBangumiCopyPressed] 复制 BGM ID 点击回调
  const UserProfileIdRow({
    super.key,
    required this.tinygrailId,
    required this.bangumiId,
    required this.onTinygrailCopyPressed,
    required this.onBangumiCopyPressed,
  });

  static const String _tinygrailLogoAsset =
      'assets/images/tinygrail/tinygrail_logo.jpg';
  static const String _bangumiLogoAsset = 'assets/icons/bangumi.svg';

  /// 小圣杯 ID
  final int tinygrailId;

  /// BGM ID
  final String bangumiId;

  /// 复制小圣杯 ID 点击回调
  final VoidCallback onTinygrailCopyPressed;

  /// 复制 BGM ID 点击回调
  final VoidCallback onBangumiCopyPressed;

  /// 构建用户 ID 行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final resolvedBangumiId = bangumiId.trim();

    return Row(
      children: [
        _UserProfileIdItem(
          leading: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => const RadialGradient(
              colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
            ).createShader(bounds),
            child: ClipOval(
              child: Image.asset(
                _tinygrailLogoAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
          value: '$tinygrailId',
          onPressed: onTinygrailCopyPressed,
        ),
        if (resolvedBangumiId.isNotEmpty) ...[
          const SizedBox(width: 12),
          Flexible(
            child: _UserProfileIdItem(
              leading: SvgPicture.asset(
                _bangumiLogoAsset,
                fit: BoxFit.contain,
              ),
              value: resolvedBangumiId,
              onPressed: onBangumiCopyPressed,
              hasFlexibleValue: true,
            ),
          ),
        ],
      ],
    );
  }
}

/// 用户资料卡单个 ID 项
class _UserProfileIdItem extends StatelessWidget {
  /// 创建用户资料卡单个 ID 项
  ///
  /// [leading] ID 来源图标
  /// [value] ID 文本
  /// [onPressed] 复制 ID 点击回调
  /// [hasFlexibleValue] ID 文本是否按剩余宽度省略
  const _UserProfileIdItem({
    required this.leading,
    required this.value,
    required this.onPressed,
    this.hasFlexibleValue = false,
  });

  /// ID 来源图标
  final Widget leading;

  /// ID 文本
  final String value;

  /// 复制 ID 点击回调
  final VoidCallback onPressed;

  /// ID 文本是否按剩余宽度省略
  final bool hasFlexibleValue;

  /// 构建用户资料卡单个 ID 项
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final valueText = Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(dimension: 14, child: leading),
            const SizedBox(width: 4),
            if (hasFlexibleValue)
              Flexible(child: valueText)
            else
              valueText,
            const SizedBox(width: 6),
            Icon(
              Icons.copy_rounded,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// 用户资产指标
class UserProfileMetric extends StatelessWidget {
  /// 创建用户资产指标
  ///
  /// [key] Flutter 组件标识
  /// [value] 指标数值
  /// [label] 指标标签
  const UserProfileMetric({
    super.key,
    required this.value,
    required this.label,
  });

  /// 指标数值
  final String value;

  /// 指标标签
  final String label;

  /// 构建用户资产指标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.72);
    final valueStyle = TextStyle(
      color: colorScheme.onSurface,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.15,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SizedBox(
            height: 18,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, maxLines: 1, style: valueStyle),
            ),
          ),
        ),
      ],
    );
  }
}
