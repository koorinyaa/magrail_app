import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/utils/formatters.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/core/widgets/temple_cover_image.dart';
import 'package:magrail_app/features/temple/model/temple_asset_card_data.dart';
import 'package:magrail_app/shared/widgets/app_bottom_sheet_header.dart';

/// 圣殿资产精炼标题
class TempleAssetRefineHeader extends StatelessWidget {
  /// 创建圣殿资产精炼标题
  ///
  /// [data] 圣殿资产卡片展示数据
  const TempleAssetRefineHeader({
    super.key,
    required this.data,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 构建圣殿资产精炼标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final characterName =
        data.characterName.trim().isEmpty ? '角色名称' : data.characterName.trim();
    return AppBottomSheetHeader(
      icon: LucideIcons.sparkles,
      title: '精炼',
      subtitle: '#${data.characterId} 「$characterName」',
    );
  }
}

/// 圣殿资产精炼固定资产进度
class TempleAssetRefineTransferPreview extends StatelessWidget {
  /// 创建圣殿资产精炼状态预览
  ///
  /// [data] 圣殿资产卡片展示数据
  /// [costText] 本次精炼 cc 消耗文案
  const TempleAssetRefineTransferPreview({
    super.key,
    required this.data,
    required this.costText,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 本次精炼 cc 消耗文案
  final String costText;

  /// 构建圣殿资产精炼状态预览
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _TempleAssetRefineTemplePreview(
                data: data,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 30,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: _TempleAssetRefineTemplePreview(
                data: data,
                assets: (data.assets - 1).clamp(0, data.assets),
                refine: data.refine + 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 38,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              '确定要消耗1股固定资产和${costText}cc进行精炼？',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.38,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 圣殿资产精炼单侧状态预览
class _TempleAssetRefineTemplePreview extends StatelessWidget {
  /// 创建圣殿资产精炼单侧状态预览
  ///
  /// [data] 圣殿资产卡片展示数据
  /// [assets] 固定资产覆盖值
  /// [refine] 精炼等级覆盖值
  const _TempleAssetRefineTemplePreview({
    required this.data,
    this.assets,
    this.refine,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 固定资产覆盖值
  final int? assets;

  /// 精炼等级覆盖值
  final int? refine;

  /// 构建圣殿资产精炼单侧状态预览
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final currentAssets = assets ?? data.assets;
    final progress = data.sacrifices <= 0
        ? 0.0
        : (currentAssets / data.sacrifices).clamp(0.0, 1.0).toDouble();
    final progressColor = _templeAssetRefineLevelColor(data.level);
    final trackColor = colorScheme.onSurfaceVariant.withValues(
      alpha: isDark ? 0.24 : 0.14,
    );
    final coverUrl = TinygrailAssetUrls.getSmallCover(data.cover);
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(data.avatar);

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 96,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 128,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.14 : 0.08,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      TempleCoverImage(
                        coverUrl: coverUrl,
                        avatarUrl: avatarUrl,
                        placeholderIconSize: 24,
                      ),
                      Positioned(
                        left: 6,
                        top: 6,
                        child: TempleAssetRefineLevelBadge(
                          data: data,
                          refine: refine,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${Formatters.groupedNumber(currentAssets)} / '
              '${Formatters.groupedNumber(data.sacrifices)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: trackColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor.withValues(alpha: isDark ? 0.92 : 0.86),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 圣殿资产精炼等级胶囊
class TempleAssetRefineLevelBadge extends StatelessWidget {
  /// 创建圣殿资产精炼等级胶囊
  ///
  /// [data] 圣殿资产卡片展示数据
  /// [refine] 精炼等级覆盖值
  const TempleAssetRefineLevelBadge({
    super.key,
    required this.data,
    this.refine,
  });

  /// 圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 精炼等级覆盖值
  final int? refine;

  /// 构建圣殿资产精炼等级胶囊
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      constraints: const BoxConstraints(minWidth: 26),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _templeAssetRefineLevelColor(data.level).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        _levelText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }

  /// 圣殿资产精炼等级文本
  String get _levelText {
    final refine = this.refine ?? data.refine;
    if (refine > 0) {
      return '+$refine';
    }

    return '${data.level}';
  }
}

/// 获取圣殿资产精炼等级颜色
///
/// [level] 圣殿等级
Color _templeAssetRefineLevelColor(int level) {
  return switch (level) {
    2 => const Color(0xFFEAB308),
    3 => const Color(0xFFA855F7),
    _ => const Color(0xFF9CA3AF),
  };
}
