import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/image_saver.dart';
import 'package:magrail_app/core/utils/tinygrail_asset_urls.dart';
import 'package:magrail_app/features/user/analysis/model/user_asset_analysis.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_character_packing_section.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_level_distribution_section.dart';
import 'package:magrail_app/features/user/analysis/widgets/user_asset_analysis_share_poster.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

part 'user_asset_analysis_share_overlay_preview.dart';
part 'user_asset_analysis_share_overlay_theme_switch.dart';

/// 显示用户资产分析分享预览
///
/// [context] 当前组件树上下文
/// [analysis] 用户资产分析缓存
/// [nickname] 用户昵称
/// [analysisAgeLabel] 分析更新时间文案
/// [assetMode] 资产占比统计模式
/// [levelMode] 等级分布统计模式
Future<void> showUserAssetAnalysisSharePreview(
  BuildContext context, {
  required UserAssetAnalysis analysis,
  required String nickname,
  required String analysisAgeLabel,
  required UserAssetAnalysisAssetProportionMode assetMode,
  required UserAssetAnalysisLevelDistributionMode levelMode,
}) {
  final initialBrightness = Theme.of(context).brightness;

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.78),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return UserAssetAnalysisShareOverlay(
        analysis: analysis,
        nickname: nickname,
        analysisAgeLabel: analysisAgeLabel,
        assetMode: assetMode,
        levelMode: levelMode,
        initialBrightness: initialBrightness,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// 用户资产分析全屏分享预览
class UserAssetAnalysisShareOverlay extends StatefulWidget {
  /// 创建用户资产分析全屏分享预览
  ///
  /// [key] Flutter 组件标识
  /// [analysis] 用户资产分析缓存
  /// [nickname] 用户昵称
  /// [analysisAgeLabel] 分析更新时间文案
  /// [assetMode] 资产占比统计模式
  /// [levelMode] 等级分布统计模式
  /// [initialBrightness] 初始长图主题亮度
  const UserAssetAnalysisShareOverlay({
    super.key,
    required this.analysis,
    required this.nickname,
    required this.analysisAgeLabel,
    required this.assetMode,
    required this.levelMode,
    required this.initialBrightness,
  });

  /// 用户资产分析缓存
  final UserAssetAnalysis analysis;

  /// 用户昵称
  final String nickname;

  /// 分析更新时间文案
  final String analysisAgeLabel;

  /// 资产占比统计模式
  final UserAssetAnalysisAssetProportionMode assetMode;

  /// 等级分布统计模式
  final UserAssetAnalysisLevelDistributionMode levelMode;

  /// 初始长图主题亮度
  final Brightness initialBrightness;

  /// 创建用户资产分析全屏分享预览状态
  @override
  State<UserAssetAnalysisShareOverlay> createState() {
    return _UserAssetAnalysisShareOverlayState();
  }
}

/// 用户资产分析全屏分享预览状态
class _UserAssetAnalysisShareOverlayState
    extends State<UserAssetAnalysisShareOverlay> {
  late final ScreenshotController _screenshotController;
  late final DateTime _generatedAt;
  late Brightness _brightness;
  final Map<Brightness, Uint8List> _imageCache = {};
  final GlobalKey _shareButtonKey = GlobalKey();
  bool _isGenerating = false;
  bool _isSaving = false;
  bool _isSharing = false;
  String? _generationError;

  /// 初始化用户资产分析全屏分享预览状态
  @override
  void initState() {
    super.initState();
    _screenshotController = ScreenshotController();
    _generatedAt = DateTime.now();
    _brightness = widget.initialBrightness;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_ensureImage(_brightness));
      }
    });
  }

  /// 构建用户资产分析全屏分享预览
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final imageBytes = _imageCache[_brightness];
    final isBusy = _isGenerating || _isSaving || _isSharing;

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            // 离屏长图绘制完成后重建预览子树，避免屏幕文字层延迟重绘
            KeyedSubtree(
              key: ValueKey('${_imageCache.length}-${_brightness.name}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: _SharePreviewThemeSwitch(
                      brightness: _brightness,
                      enabled: !isBusy,
                      onChanged: _selectBrightness,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildPreview(
                      context,
                      imageBytes: imageBytes,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.12,
                                  ),
                                  disabledForegroundColor: Colors.white38,
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.24),
                                  ),
                                  shape: const StadiumBorder(),
                                ),
                                onPressed: imageBytes == null || isBusy
                                    ? null
                                    : _saveImage,
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 17,
                                        height: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        LucideIcons.download,
                                        size: 18,
                                      ),
                                label: const Text('保存图片'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: FilledButton.icon(
                                key: _shareButtonKey,
                                style: FilledButton.styleFrom(
                                  shape: const StadiumBorder(),
                                ),
                                onPressed: imageBytes == null || isBusy
                                    ? null
                                    : _shareImage,
                                icon: _isSharing
                                    ? const SizedBox(
                                        width: 17,
                                        height: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        LucideIcons.share2,
                                        size: 18,
                                      ),
                                label: const Text('分享给'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 切换分享长图主题
  ///
  /// [brightness] 目标主题亮度
  void _selectBrightness(Brightness brightness) {
    if (_brightness == brightness || _isGenerating) {
      return;
    }

    setState(() {
      _brightness = brightness;
      _generationError = null;
    });
    unawaited(_ensureImage(brightness));
  }

  /// 确保当前主题分享长图已生成
  ///
  /// [brightness] 目标主题亮度
  Future<void> _ensureImage(Brightness brightness) async {
    if (_imageCache.containsKey(brightness)) {
      return;
    }

    setState(() {
      _isGenerating = true;
      _generationError = null;
    });

    try {
      await _precachePosterImages();
      if (!mounted) {
        return;
      }
      final bytes = await _screenshotController.captureFromLongWidget(
        UserAssetAnalysisSharePoster(
          analysis: widget.analysis,
          nickname: widget.nickname,
          analysisAgeLabel: widget.analysisAgeLabel,
          assetMode: widget.assetMode,
          levelMode: widget.levelMode,
          brightness: brightness,
          generatedAt: _generatedAt,
        ),
        context: context,
        pixelRatio: _posterPixelRatio,
        delay: _posterCaptureDelay,
        constraints: const BoxConstraints.tightFor(
          width: userAssetAnalysisSharePosterWidth,
        ),
      );
      if (!mounted) {
        return;
      }
      if (bytes.isEmpty) {
        throw StateError('empty poster image');
      }

      setState(() {
        _imageCache[brightness] = bytes;
        _isGenerating = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isGenerating = false;
        _generationError = '生成分享图片失败';
      });
    }
  }

  /// 预加载分享长图使用的图片
  Future<void> _precachePosterImages() async {
    await _precacheImageSafely(const AssetImage(_appIconAsset));
    final bubbles = selectUserAssetAnalysisCharacterBubbles(
      analysis: widget.analysis,
      mode: widget.assetMode,
    );
    final providers = <ImageProvider>[];
    for (final bubble in bubbles) {
      final avatarUrl = TinygrailAssetUrls.normalizeAvatar(bubble.avatarUrl);
      if (avatarUrl.isNotEmpty) {
        providers.add(CachedNetworkImageProvider(avatarUrl));
      }
    }

    // 限制头像预加载并发，避免分享操作瞬间创建过多图片请求
    final deadline = DateTime.now().add(_posterPrecacheBudget);
    for (var index = 0; index < providers.length; index += _precacheBatchSize) {
      final remaining = deadline.difference(DateTime.now());
      if (remaining.inMilliseconds <= 0) {
        return;
      }
      final end = (index + _precacheBatchSize).clamp(0, providers.length);
      try {
        await Future.wait(
          providers.sublist(index, end).map(_precacheImageSafely),
        ).timeout(remaining);
      } on TimeoutException {
        return;
      }
    }
  }

  /// 安全预加载单张分享图片
  ///
  /// [provider] 图片提供器
  Future<void> _precacheImageSafely(ImageProvider provider) async {
    try {
      await precacheImage(provider, context).timeout(_imagePrecacheTimeout);
    } catch (_) {
      // 图片加载失败时由现有角色头像占位图接管
    }
  }

  /// 保存当前分享长图到系统相册
  Future<void> _saveImage() async {
    final bytes = _imageCache[_brightness];
    if (bytes == null || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    try {
      final result = await saveImageBytesToGallery(
        bytes,
        imageName: _shareImageBaseName,
      );
      if (!mounted) {
        return;
      }
      if (result.isSuccess) {
        AppToast.info(context, text: result.message);
      } else {
        AppToast.error(context, text: result.message);
      }
    } catch (_) {
      if (mounted) {
        AppToast.error(context, text: '保存图片失败');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// 打开系统分享面板
  Future<void> _shareImage() async {
    final bytes = _imageCache[_brightness];
    if (bytes == null || _isSharing) {
      return;
    }

    final sharePositionOrigin = _resolveSharePositionOrigin();
    File? temporaryFile;
    setState(() {
      _isSharing = true;
    });
    try {
      final temporaryDirectory = await getTemporaryDirectory();
      temporaryFile = File(
        '${temporaryDirectory.path}${Platform.pathSeparator}'
        '$_shareImageBaseName.png',
      );
      await temporaryFile.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          title: 'MaGrail 资产分析',
          files: [XFile(temporaryFile.path, mimeType: 'image/png')],
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
    } catch (_) {
      if (mounted) {
        AppToast.error(context, text: '打开系统分享失败');
      }
    } finally {
      if (temporaryFile != null) {
        try {
          if (await temporaryFile.exists()) {
            await temporaryFile.delete();
          }
        } catch (_) {
          // 临时文件由系统临时目录继续管理
        }
      }
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  /// 计算系统分享面板锚点
  Rect _resolveSharePositionOrigin() {
    final buttonContext = _shareButtonKey.currentContext;
    final renderBox = buttonContext?.findRenderObject();
    if (renderBox is RenderBox && renderBox.hasSize) {
      return renderBox.localToGlobal(Offset.zero) & renderBox.size;
    }

    final size = MediaQuery.sizeOf(context);
    return Rect.fromLTWH(size.width / 2, size.height / 2, 1, 1);
  }

  /// 分享图片基础名称
  String get _shareImageBaseName {
    final safeUsername = widget.analysis.username
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final username = safeUsername.isEmpty ? 'user' : safeUsername;
    return 'magrail_asset_analysis_${username}_'
        '${_generatedAt.millisecondsSinceEpoch}';
  }
}

const _appIconAsset = 'assets/icons/app_icon_cropped.png';

// 分享长图以 2.5 倍像素密度导出为 900px 宽
const double _posterPixelRatio = 2.5;

// 头像预加载每批最多三个请求，避免分享时集中占用网络连接
const int _precacheBatchSize = 3;

// 单张头像超过八秒未加载时使用现有失败占位
const Duration _imagePrecacheTimeout = Duration(seconds: 8);

// 全部长图头像预加载最多等待十二秒，超时后继续生成可用图片
const Duration _posterPrecacheBudget = Duration(seconds: 12);

// 图片预加载完成后保留短暂绘制时间再捕获长图
const Duration _posterCaptureDelay = Duration(milliseconds: 500);
