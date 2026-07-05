part of '../temple_asset_magic_action_sheet.dart';

class _TempleAssetMagicTemplePreview extends StatelessWidget {
  /// 创建魔法道具确认中的当前圣殿
  ///
  /// [data] 当前圣殿资产卡片展示数据
  const _TempleAssetMagicTemplePreview({
    required this.data,
  });

  /// 当前圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 构建魔法道具确认中的当前圣殿
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final coverUrl = TinygrailAssetUrls.getSmallCover(data.cover);
    final avatarUrl = TinygrailAssetUrls.normalizeAvatar(data.avatar);
    final progress = !data.hasTemple || data.sacrifices <= 0
        ? 0.0
        : (data.assets / data.sacrifices).clamp(0.0, 1.0).toDouble();
    final progressColor = switch (data.level) {
      2 => const Color(0xFFEAB308),
      3 => const Color(0xFFA855F7),
      _ => const Color(0xFF9CA3AF),
    };
    final trackColor = colorScheme.onSurfaceVariant.withValues(
      alpha: isDark ? 0.24 : 0.14,
    );
    final assetLabel = data.hasTemple
        ? '${Formatters.groupedNumber(data.assets)} / '
            '${Formatters.groupedNumber(data.sacrifices)}'
        : '-- / --';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
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
                          if (data.hasTemple)
                            Positioned(
                              left: 6,
                              top: 6,
                              child:
                                  _TempleAssetMagicTempleLevelBadge(data: data),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  assetLabel,
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
        ),
      ],
    );
  }
}

/// 魔法道具确认中的圣殿等级胶囊
class _TempleAssetMagicTempleLevelBadge extends StatelessWidget {
  /// 创建魔法道具确认中的圣殿等级胶囊
  ///
  /// [data] 当前圣殿资产卡片展示数据
  const _TempleAssetMagicTempleLevelBadge({
    required this.data,
  });

  /// 当前圣殿资产卡片展示数据
  final TempleAssetCardData data;

  /// 构建魔法道具确认中的圣殿等级胶囊
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final themeColor = switch (data.level) {
      2 => const Color(0xFFEAB308),
      3 => const Color(0xFFA855F7),
      _ => const Color(0xFF9CA3AF),
    };
    final text = data.refine > 0 ? '+${data.refine}' : '${data.level}';

    return Container(
      height: 20,
      constraints: const BoxConstraints(minWidth: 26),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.78),
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
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

/// 魔法道具确认中的目标角色
class _TempleAssetMagicTargetPreview extends StatelessWidget {
  /// 创建魔法道具确认中的目标角色
  ///
  /// [target] 已选择的目标角色
  /// [stockText] 目标角色胶囊文案
  const _TempleAssetMagicTargetPreview({
    required this.target,
    this.stockText,
  });

  /// 已选择的目标角色
  final CharacterDetailSearchItem target;

  /// 目标角色胶囊文案
  final String? stockText;

  /// 构建魔法道具确认中的目标角色
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stockText =
        this.stockText ?? '持股 ${Formatters.groupedNumber(target.userTotal)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.center,
          child: CharacterAvatar(
            imageUrl: TinygrailAssetUrls.normalizeAvatar(target.icon),
            size: 56,
            borderRadius: 18,
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.center,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: colorScheme.brightness == Brightness.dark ? 0.32 : 0.68,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              child: Text(
                stockText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
