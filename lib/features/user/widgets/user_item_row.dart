import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/features/user/model/user_item_api_item.dart';
import 'package:magrail_app/features/user/widgets/user_asset_record_pill.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 用户道具行
class UserItemRow extends StatelessWidget {
  /// 创建用户道具行
  ///
  /// [key] Flutter 组件标识
  /// [item] 用户道具条目
  const UserItemRow({
    super.key,
    required this.item,
  });

  /// 用户道具条目
  final UserItemApiItem item;

  static const Color _amountColor = Color(0xFFFFB020);

  // 已接入使用流程的道具优先展示实际用途
  static const Map<int, String> _knownItemEffects = {
    1: '消耗指定角色活股，补充固定资产',
    2: '消耗100点固定资产，攻击指定角色星之力',
    5: '消耗10点固定资产，获得随机角色活股',
    6: '消耗100点固定资产，获得指定角色活股',
    9: '消耗100点固定资产，将指定角色从幻想乡移至英灵殿',
  };

  /// 构建用户道具行
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserItemIcon(imageUrl: _iconUrl),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
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
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  _descriptionText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: UserAssetRecordPill(
              text: '×${Formatters.groupedNumber(item.amount)}',
              accentColor: _amountColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 道具图标地址
  String get _iconUrl {
    final icon = item.icon.trim();
    if (icon.isEmpty) {
      return '';
    }

    return TinygrailAssetUrls.normalizeAvatar(icon);
  }

  /// 展示道具名称
  String get _displayName {
    final name = TinygrailFormatters.decodeHtmlEntities(item.name).trim();
    if (name.isEmpty) {
      return '#${item.id}';
    }

    return name;
  }

  /// 道具描述文案
  String get _descriptionText {
    final knownEffect = _knownItemEffects[item.id];
    if (knownEffect != null) {
      return knownEffect;
    }

    final description = TinygrailFormatters.decodeHtmlEntities(
      item.description ?? '',
    ).trim();
    if (description.isNotEmpty) {
      return description;
    }

    final line = TinygrailFormatters.decodeHtmlEntities(item.line).trim();
    if (line.isEmpty) {
      return '暂无描述';
    }

    return '「$line」';
  }
}

/// 用户道具图标
class _UserItemIcon extends StatelessWidget {
  /// 创建用户道具图标
  ///
  /// [imageUrl] 图标地址
  const _UserItemIcon({
    required this.imageUrl,
  });

  /// 图标地址
  final String imageUrl;

  /// 构建用户道具图标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: 48,
        height: 48,
        child: imageUrl.isEmpty
            ? const _UserItemIconFallback()
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                placeholder: (context, url) {
                  return const Skeletonizer.zone(
                    child: Bone(
                      width: 48,
                      height: 48,
                      borderRadius: BorderRadius.zero,
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return const _UserItemIconFallback();
                },
              ),
      ),
    );
  }
}

/// 用户道具图标占位
class _UserItemIconFallback extends StatelessWidget {
  /// 创建用户道具图标占位
  const _UserItemIconFallback();

  /// 构建用户道具图标占位
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        size: 22,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
