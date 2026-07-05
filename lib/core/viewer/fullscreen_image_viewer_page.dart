import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/extended_image_cache_maintenance.dart';
import 'package:magrail_app/core/utils/image_saver.dart';

/// 全屏图片查看页面
class FullscreenImageViewerPage extends StatefulWidget {
  /// 创建全屏图片查看页面
  ///
  /// [imageUrl] 图片地址
  /// [heroTag] Hero 动画标识
  const FullscreenImageViewerPage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  }) : assetName = null;

  /// 创建全屏资源图片查看页面
  ///
  /// [assetName] 资源图片路径
  /// [heroTag] Hero 动画标识
  const FullscreenImageViewerPage.asset({
    super.key,
    required this.assetName,
    required this.heroTag,
  }) : imageUrl = null;

  /// 图片地址
  final String? imageUrl;

  /// 资源图片路径
  final String? assetName;

  /// Hero 动画标识
  final String heroTag;

  /// 创建全屏图片查看页面状态
  @override
  State<FullscreenImageViewerPage> createState() =>
      _FullscreenImageViewerPageState();
}

/// 全屏图片查看页面状态
class _FullscreenImageViewerPageState extends State<FullscreenImageViewerPage> {
  /// 初始化全屏图片查看页面状态
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(maintainFullscreenImageCache);
  }

  /// 构建全屏图片查看页面
  ///
  /// [context] 当前组件上下文
  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: ExtendedImageSlidePage(
              slideAxis: SlideAxis.vertical,
              slideType: SlideType.wholePage,
              slidePageBackgroundHandler: _resolveSlideBackgroundColor,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: ExtendedImageSlidePageHandler(
                      child: SizedBox.expand(),
                    ),
                  ),
                  Positioned.fill(
                    child: Hero(
                      tag: widget.heroTag,
                      child: _buildImage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: safePadding.right + 16,
            bottom: safePadding.bottom + 16,
            child: Material(
              color: Colors.white.withValues(alpha: 0.12),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _saveImage(context),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建可缩放图片
  Widget _buildImage() {
    final assetName = widget.assetName;
    if (assetName != null) {
      return ExtendedImage.asset(
        assetName,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        enableSlideOutPage: true,
        initGestureConfigHandler: _createGestureConfig,
        onDoubleTap: _handleDoubleTap,
      );
    }

    return ExtendedImage.network(
      widget.imageUrl!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
      cache: true,
      cacheMaxAge: const Duration(days: 7),
      mode: ExtendedImageMode.gesture,
      enableSlideOutPage: true,
      initGestureConfigHandler: _createGestureConfig,
      onDoubleTap: _handleDoubleTap,
    );
  }

  /// 创建全屏图片手势配置
  ///
  /// [state] 当前图片状态
  GestureConfig _createGestureConfig(ExtendedImageState state) {
    return GestureConfig(
      minScale: 0.9,
      animationMinScale: 0.7,
      maxScale: 4.0,
      animationMaxScale: 4.5,
      speed: 1.0,
      inertialSpeed: 100.0,
      initialScale: 1.0,
      inPageView: false,
      initialAlignment: InitialAlignment.center,
    );
  }

  /// 处理双击缩放
  ///
  /// [state] 当前图片状态
  void _handleDoubleTap(ExtendedImageGestureState state) {
    final begin = state.gestureDetails?.totalScale ?? 1.0;
    final end = begin == 1.0 ? 2.5 : 1.0;
    state.handleDoubleTap(
      scale: end,
      doubleTapPosition: state.pointerDownPosition,
    );
  }

  /// 解析滑动关闭时的背景颜色
  ///
  /// [offset] 页面滑动位移
  /// [pageSize] 页面尺寸
  Color _resolveSlideBackgroundColor(Offset offset, Size pageSize) {
    final progress =
        (offset.dy.abs() / (pageSize.height * 0.45)).clamp(0.0, 1.0).toDouble();
    return const Color(0xFF09090B).withValues(alpha: 1 - progress);
  }

  /// 保存当前图片
  ///
  /// [context] 当前组件上下文
  Future<void> _saveImage(BuildContext context) async {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final assetName = widget.assetName;
    final result = assetName == null
        ? await saveImageToGallery(widget.imageUrl!)
        : await saveAssetImageToGallery(assetName);
    if (!rootNavigator.mounted) {
      return;
    }
    _showSaveToast(rootNavigator.context, result);
  }

  /// 显示保存结果提示
  ///
  /// [context] 当前组件上下文
  /// [result] 图片保存结果
  void _showSaveToast(BuildContext context, ImageSaveResult result) {
    final variant = switch (result.status) {
      ImageSaveStatus.success => AppToastVariant.info,
      ImageSaveStatus.unsupportedPlatform => AppToastVariant.error,
      ImageSaveStatus.permissionDenied => AppToastVariant.error,
      ImageSaveStatus.downloadFailed => AppToastVariant.error,
      ImageSaveStatus.saveFailed => AppToastVariant.error,
    };

    AppToast.show(
      context,
      text: result.message,
      variant: variant,
    );
  }
}
