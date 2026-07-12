import 'package:flutter/material.dart';
import 'package:magrail_app/core/widgets/character_avatar.dart';
import 'package:magrail_app/core/widgets/level_badge.dart';

/// 角色资产行数据项
class CharacterAssetMetric {
  /// 创建角色资产行数据项
  ///
  /// [label] 数据标签
  /// [value] 数据文本
  /// [isValueMuted] 是否使用浅色数字
  /// [valueColor] 数据文本颜色
  /// [valueWidget] 自定义数据展示组件
  const CharacterAssetMetric({
    required this.value,
    this.label,
    this.isValueMuted = false,
    this.valueColor,
    this.valueWidget,
  });

  /// 数据标签
  final String? label;

  /// 数据文本
  final String value;

  /// 是否使用浅色数字
  final bool isValueMuted;

  /// 数据文本颜色
  final Color? valueColor;

  /// 自定义数据展示组件
  final Widget? valueWidget;
}

/// 角色资产行
class CharacterAssetRowShell extends StatelessWidget {
  /// 创建角色资产行
  ///
  /// [key] Flutter 组件标识
  /// [name] 角色名称
  /// [avatarUrl] 角色头像地址
  /// [metrics] 底部数据项
  /// [level] 角色等级
  /// [zeroCount] ST 等级
  /// [trailing] 右侧附加组件
  /// [avatarHeroTag] 头像转场标识
  /// [onTap] 条目点击回调
  /// [contentPadding] 内容内边距
  /// [tapBorderRadius] 点击反馈圆角
  const CharacterAssetRowShell({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.metrics,
    this.level,
    this.zeroCount = 0,
    this.trailing,
    this.avatarHeroTag,
    this.onTap,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 6),
    this.tapBorderRadius,
  });

  /// 角色名称
  final String name;

  /// 角色头像地址
  final String avatarUrl;

  /// 底部数据项
  final List<CharacterAssetMetric> metrics;

  /// 角色等级
  final int? level;

  /// ST 等级
  final int zeroCount;

  /// 右侧附加组件
  final Widget? trailing;

  /// 头像转场标识
  final String? avatarHeroTag;

  /// 条目点击回调
  final VoidCallback? onTap;

  /// 内容内边距
  final EdgeInsetsGeometry contentPadding;

  /// 点击反馈圆角
  final BorderRadius? tapBorderRadius;

  /// 构建角色资产行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: tapBorderRadius ?? BorderRadius.circular(16),
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: contentPadding,
            child: Row(
              children: [
                _CharacterAssetAvatar(
                  imageUrl: avatarUrl,
                  heroTag: avatarHeroTag,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              name,
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
                          if (level != null) ...[
                            const SizedBox(width: 6),
                            LevelBadge(
                              level: level!,
                              zeroCount: zeroCount,
                              isCompact: true,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var index = 0;
                              index < metrics.length;
                              index++) ...[
                            _CharacterAssetMetricText(
                              metric: metrics[index],
                              isPrimary: index == 0,
                            ),
                            if (index != metrics.length - 1)
                              const SizedBox(height: 3),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 角色资产行头像
class _CharacterAssetAvatar extends StatelessWidget {
  /// 创建角色资产行头像
  ///
  /// [imageUrl] 头像地址
  /// [heroTag] 头像转场标识
  const _CharacterAssetAvatar({
    required this.imageUrl,
    required this.heroTag,
  });

  /// 头像地址
  final String imageUrl;

  /// 头像转场标识
  final String? heroTag;

  /// 构建角色资产行头像
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

/// 角色资产行数据文本
class _CharacterAssetMetricText extends StatelessWidget {
  /// 创建角色资产行数据文本
  ///
  /// [metric] 数据项
  /// [isPrimary] 是否使用主数据行样式
  const _CharacterAssetMetricText({
    required this.metric,
    required this.isPrimary,
  });

  /// 数据项
  final CharacterAssetMetric metric;

  /// 是否使用主数据行样式
  final bool isPrimary;

  /// 构建角色资产行数据文本
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = metric.label;
    final textColor = isPrimary
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.58);
    final valueColor = metric.valueColor ??
        (metric.isValueMuted ? textColor : colorScheme.onSurface);

    final valueWidget = metric.valueWidget;
    if (valueWidget != null) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(child: valueWidget),
        ],
      );
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(
          color: textColor,
          fontSize: isPrimary ? 11 : 10,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
        children: [
          if (label != null && label.isNotEmpty) TextSpan(text: '$label '),
          TextSpan(
            text: metric.value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
