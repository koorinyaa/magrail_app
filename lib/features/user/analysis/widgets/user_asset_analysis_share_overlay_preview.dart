part of 'user_asset_analysis_share_overlay.dart';

/// 用户资产分析分享预览内容
extension _UserAssetAnalysisShareOverlayPreview
    on _UserAssetAnalysisShareOverlayState {
  /// 构建分享图片预览区域
  ///
  /// [context] 当前组件树上下文
  /// [imageBytes] 当前主题长图字节
  Widget _buildPreview(
    BuildContext context, {
    required Uint8List? imageBytes,
  }) {
    return switch ((_isGenerating, _generationError, imageBytes)) {
      (true, _, _) => _buildLoadingPreview(context),
      (false, final String error, _) => _buildFailedPreview(context, error),
      (false, null, final Uint8List bytes) => Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                bytes,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
              ),
            ),
          ),
        ),
      _ => _buildLoadingPreview(context),
    };
  }

  /// 构建分享图片生成状态
  ///
  /// [context] 当前组件树上下文
  Widget _buildLoadingPreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
          const SizedBox(height: 14),
          Text(
            '正在生成分享图片',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分享图片失败状态
  ///
  /// [context] 当前组件树上下文
  /// [message] 失败文案
  Widget _buildFailedPreview(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.imageOff,
              size: 34,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => unawaited(_ensureImage(_brightness)),
              icon: const Icon(LucideIcons.refreshCw, size: 17),
              label: const Text('重新生成'),
            ),
          ],
        ),
      ),
    );
  }
}
