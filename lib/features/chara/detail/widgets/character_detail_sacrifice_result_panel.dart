import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_sacrifice_result.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 角色资产重组结果面板
class CharacterDetailSacrificeResultPanel extends StatelessWidget {
  /// 创建角色资产重组结果面板
  ///
  /// [mode] 本次提交类型
  /// [result] 提交结果
  /// [onComplete] 完成回调
  const CharacterDetailSacrificeResultPanel({
    super.key,
    required this.mode,
    required this.result,
    required this.onComplete,
  });

  /// 本次提交类型
  final CharacterDetailSacrificeMode mode;

  /// 提交结果
  final CharacterDetailSacrificeResult result;

  /// 完成回调
  final VoidCallback onComplete;

  /// 构建角色资产重组结果面板
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final accentColor = _sacrificeResultAccentColor(mode);
    final items = result.items
        .where((item) => item.name.trim().isNotEmpty && item.count > 0)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SacrificeResultBanner(
          balance: result.balance,
          accentColor: accentColor,
        ),
        if (mode == CharacterDetailSacrificeMode.restructure ||
            items.isNotEmpty) ...[
          const SizedBox(height: 16),
          if (items.isEmpty)
            _SacrificeResultEmptyDrop(accentColor: accentColor)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SacrificeResultDropHeader(
                  count: items.length,
                  accentColor: accentColor,
                ),
                const SizedBox(height: 10),
                _SacrificeResultLootGrid(
                  items: items,
                  accentColor: accentColor,
                ),
              ],
            ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            onPressed: onComplete,
            child: const Text('完成'),
          ),
        ),
      ],
    );
  }
}

/// 资产重组结果顶部横幅
class _SacrificeResultBanner extends StatelessWidget {
  /// 创建资产重组结果顶部横幅
  ///
  /// [balance] 本次获得资金
  /// [accentColor] 强调色
  const _SacrificeResultBanner({
    required this.balance,
    required this.accentColor,
  });

  /// 本次获得资金
  final double balance;

  /// 强调色
  final Color accentColor;

  /// 构建资产重组结果顶部横幅
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Text(
            '获得资金',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              Formatters.tinygrailCurrency(balance),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: accentColor,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 资产重组掉落标题栏
class _SacrificeResultDropHeader extends StatelessWidget {
  /// 创建资产重组掉落标题栏
  ///
  /// [count] 掉落道具种类数量
  /// [accentColor] 强调色
  const _SacrificeResultDropHeader({
    required this.count,
    required this.accentColor,
  });

  /// 掉落道具种类数量
  final int count;

  /// 强调色
  final Color accentColor;

  /// 构建资产重组掉落标题栏
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Text(
            '获得道具',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.16 : 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            child: Text(
              '${Formatters.groupedNumber(count)} 种',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: accentColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 资产重组掉落格子组
class _SacrificeResultLootGrid extends StatelessWidget {
  /// 创建资产重组掉落格子组
  ///
  /// [items] 掉落道具列表
  /// [accentColor] 强调色
  const _SacrificeResultLootGrid({
    required this.items,
    required this.accentColor,
  });

  /// 掉落道具列表
  final List<CharacterDetailSacrificeItem> items;

  /// 强调色
  final Color accentColor;

  /// 构建资产重组掉落格子组
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 520 ? 4 : 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.76,
          ),
          itemBuilder: (context, index) {
            return _SacrificeResultLootSlot(
              item: items[index],
              accentColor: accentColor,
            );
          },
        );
      },
    );
  }
}

/// 资产重组掉落格子
class _SacrificeResultLootSlot extends StatelessWidget {
  /// 创建资产重组掉落格子
  ///
  /// [item] 掉落道具
  /// [accentColor] 强调色
  const _SacrificeResultLootSlot({
    required this.item,
    required this.accentColor,
  });

  /// 掉落道具
  final CharacterDetailSacrificeItem item;

  /// 强调色
  final Color accentColor;

  /// 构建资产重组掉落格子
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final itemColor = _sacrificeLootColor(item, accentColor);
    final surfaceColor = isDark ? const Color(0xFF18181B) : colorScheme.surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _SacrificeResultItemIcon(
                  item: item,
                  itemColor: itemColor,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            _SacrificeResultCountChip(
              count: item.count,
              itemColor: itemColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// 资产重组掉落图标
class _SacrificeResultItemIcon extends StatelessWidget {
  /// 创建资产重组掉落图标
  ///
  /// [item] 掉落道具
  /// [itemColor] 道具强调色
  const _SacrificeResultItemIcon({
    required this.item,
    required this.itemColor,
  });

  /// 掉落道具
  final CharacterDetailSacrificeItem item;

  /// 道具强调色
  final Color itemColor;

  /// 构建资产重组掉落图标
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final rawIcon = item.icon.trim();
    final icon =
        rawIcon.isEmpty ? '' : TinygrailAssetUrls.normalizeAvatar(rawIcon);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: itemColor.withValues(alpha: isDark ? 0.30 : 0.22),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox.square(
          dimension: 52,
          child: icon.isEmpty
              ? Center(
                  child: Icon(
                    LucideIcons.packageOpen,
                    color: colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: icon,
                  fit: BoxFit.cover,
                  width: 52,
                  height: 52,
                  placeholder: (context, url) {
                    return const Skeletonizer.zone(
                      child: Bone(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Center(
                      child: Icon(
                        LucideIcons.imageOff,
                        color: colorScheme.onSurfaceVariant,
                        size: 28,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

/// 资产重组道具数量标记
class _SacrificeResultCountChip extends StatelessWidget {
  /// 创建资产重组道具数量标记
  ///
  /// [count] 道具数量
  /// [itemColor] 道具强调色
  const _SacrificeResultCountChip({
    required this.count,
    required this.itemColor,
  });

  /// 道具数量
  final int count;

  /// 道具强调色
  final Color itemColor;

  /// 构建资产重组道具数量标记
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: itemColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          'x${Formatters.groupedNumber(count)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: itemColor,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// 资产重组无掉落状态
class _SacrificeResultEmptyDrop extends StatelessWidget {
  /// 创建资产重组无掉落状态
  ///
  /// [accentColor] 强调色
  const _SacrificeResultEmptyDrop({
    required this.accentColor,
  });

  /// 强调色
  final Color accentColor;

  /// 构建资产重组无掉落状态
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Icon(
              LucideIcons.packageOpen,
              size: 22,
              color: accentColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '未掉落道具',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 获取资产重组结果强调色
///
/// [mode] 本次提交类型
Color _sacrificeResultAccentColor(CharacterDetailSacrificeMode mode) {
  return mode == CharacterDetailSacrificeMode.financing
      ? const Color(0xFFF25C62)
      : const Color(0xFF17C964);
}

/// 获取掉落道具强调色
///
/// [item] 掉落道具
/// [fallback] 兜底颜色
Color _sacrificeLootColor(
  CharacterDetailSacrificeItem item,
  Color fallback,
) {
  if (item.count >= 6) {
    return const Color(0xFFF5A524);
  }

  if (item.count >= 3) {
    return const Color(0xFFA855F7);
  }

  return fallback;
}
