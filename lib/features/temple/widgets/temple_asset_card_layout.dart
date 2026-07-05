part of 'temple_asset_card.dart';

/// 圣殿资产媒体卡片
class _TempleAssetMediaCard extends StatelessWidget {
  /// 创建圣殿资产媒体卡片
  ///
  /// [visual] 左侧圣殿视觉区
  /// [metrics] 右侧资产指标区
  /// [actions] 底部圣殿操作按钮行
  /// [watermarkText] 右上角水印文本
  /// [showActions] 是否显示底部圣殿操作区
  const _TempleAssetMediaCard({
    required this.visual,
    required this.metrics,
    required this.actions,
    required this.watermarkText,
    required this.showActions,
  });

  /// 左侧圣殿视觉区
  final Widget visual;

  /// 右侧资产指标区
  final Widget metrics;

  /// 底部圣殿操作按钮行
  final Widget actions;

  /// 右上角水印文本
  final String watermarkText;

  /// 是否显示底部圣殿操作区
  final bool showActions;

  /// 构建圣殿资产媒体卡片
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    return _TempleAssetPanel(
      padding: const EdgeInsets.all(10),
      watermarkText: watermarkText,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _templeAssetVisualHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: _templeAssetThumbnailWidth,
                  child: visual,
                ),
                const SizedBox(width: 14),
                Expanded(child: metrics),
              ],
            ),
          ),
          if (showActions) ...[
            const SizedBox(height: 10),
            actions,
          ],
        ],
      ),
    );
  }
}

/// 圣殿资产卡片面板
class _TempleAssetPanel extends StatelessWidget {
  /// 创建圣殿资产卡片面板
  ///
  /// [child] 面板内容
  /// [padding] 面板内边距
  /// [watermarkText] 右上角水印文本
  const _TempleAssetPanel({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 10),
    this.watermarkText,
  });

  /// 面板内容
  final Widget child;

  /// 面板内边距
  final EdgeInsetsGeometry padding;

  /// 右上角水印文本
  final String? watermarkText;

  /// 构建圣殿资产卡片面板
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final watermarkText = this.watermarkText?.trim() ?? '';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerLow : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Stack(
          children: [
            child,
            if (watermarkText.isNotEmpty)
              Positioned(
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _templeAssetWatermarkMaxWidth,
                    ),
                    child: Text(
                      watermarkText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: isDark ? 0.44 : 0.58,
                        ),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
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
