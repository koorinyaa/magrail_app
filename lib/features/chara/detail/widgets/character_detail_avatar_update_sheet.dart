import 'dart:async';
import 'dart:math' as math;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/app_safe_area_insets.dart';
import 'package:magrail_app/core/utils/tinygrail_formatters.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_bottom_sheet_drag_handle.dart';
import 'package:magrail_app/core/widgets/app_loading_dialog.dart';
import 'package:magrail_app/features/chara/detail/model/character_detail_trade_header.dart';
import 'package:magrail_app/features/chara/detail/repository/character_detail_repository.dart';
import 'package:magrail_app/features/oos/repository/tinygrail_oos_repository.dart';
import 'package:magrail_app/shared/widgets/app_bottom_sheet_header.dart';
import 'package:mime/mime.dart';

part 'character_detail_avatar_update_sheet_image.dart';

// 头像上传固定输出 JPEG
const String _avatarContentType = 'image/jpeg';
// 头像上传固定缩放到 256x256
const int _avatarOutputSize = 256;
// 头像 JPEG 编码质量
const int _avatarJpegQuality = 90;

/// 显示角色头像更换抽屉
///
/// [context] 当前组件树上下文
/// [header] 已上市角色头部资料
/// [repository] 角色详情仓库
/// [oosRepository] Tinygrail OOS 仓库
/// [onAvatarChanged] 头像更换成功后的刷新回调
Future<void> showCharacterAvatarUpdateSheet(
  BuildContext context, {
  required CharacterDetailTradeHeader header,
  required CharacterDetailRepository repository,
  required TinygrailOosRepository oosRepository,
  required Future<void> Function() onAvatarChanged,
}) async {
  final pickedImage = await _pickAvatarImage(context);
  if (pickedImage == null || !context.mounted) {
    return;
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    enableDrag: false,
    isDismissible: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: BoxConstraints.tightFor(
      width: MediaQuery.sizeOf(context).width,
    ),
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      const topGap = 32.0;
      final availableHeight =
          mediaQuery.size.height - mediaQuery.padding.top - topGap;
      final maxHeight =
          availableHeight.clamp(0.0, mediaQuery.size.height).toDouble();

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: _CharacterAvatarUpdateSheet(
          header: header,
          repository: repository,
          oosRepository: oosRepository,
          initialImageBytes: pickedImage.bytes,
          onAvatarChanged: onAvatarChanged,
        ),
      );
    },
  );
}

/// 角色头像更换抽屉
class _CharacterAvatarUpdateSheet extends StatefulWidget {
  /// 创建角色头像更换抽屉
  ///
  /// [header] 已上市角色头部资料
  /// [repository] 角色详情仓库
  /// [oosRepository] Tinygrail OOS 仓库
  /// [initialImageBytes] 初始图片字节
  /// [onAvatarChanged] 头像更换成功后的刷新回调
  const _CharacterAvatarUpdateSheet({
    required this.header,
    required this.repository,
    required this.oosRepository,
    required this.initialImageBytes,
    required this.onAvatarChanged,
  });

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 角色详情仓库
  final CharacterDetailRepository repository;

  /// Tinygrail OOS 仓库
  final TinygrailOosRepository oosRepository;

  /// 初始图片字节
  final Uint8List initialImageBytes;

  /// 头像更换成功后的刷新回调
  final Future<void> Function() onAvatarChanged;

  /// 创建角色头像更换抽屉状态
  @override
  State<_CharacterAvatarUpdateSheet> createState() =>
      _CharacterAvatarUpdateSheetState();
}

/// 角色头像更换抽屉状态
class _CharacterAvatarUpdateSheetState
    extends State<_CharacterAvatarUpdateSheet> {
  late ImageEditorController _editorController;
  late Uint8List _imageBytes;
  int _imageRevision = 0;
  bool _isSubmitting = false;
  // 横条拖拽只移动抽屉本身，避免图片编辑区的缩放和平移手势被抢占
  double _sheetDragOffset = 0;
  bool _isDraggingSheet = false;

  /// 初始化角色头像更换抽屉状态
  @override
  void initState() {
    super.initState();
    _editorController = ImageEditorController();
    _imageBytes = widget.initialImageBytes;
  }

  /// 释放角色头像更换抽屉状态资源
  @override
  void dispose() {
    _editorController.dispose();
    super.dispose();
  }

  /// 构建角色头像更换抽屉
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration:
          _isDraggingSheet ? Duration.zero : const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, _sheetDragOffset, 0),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerLow
                  : colorScheme.surfaceContainerLowest,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(
                    alpha: isDark ? 0.32 : 0.58,
                  ),
                ),
              ),
            ),
            child: SafeArea(
              left: false,
              right: false,
              top: false,
              child: SingleChildScrollView(
                child: Padding(
                  padding: AppSafeAreaInsets.fromLTRB(
                    context,
                    left: 20,
                    top: 10,
                    right: 20,
                    bottom: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragStart: (_) {
                          setState(() {
                            _isDraggingSheet = true;
                          });
                        },
                        onVerticalDragUpdate: (details) {
                          final delta = details.primaryDelta ?? 0;
                          if (delta == 0) {
                            return;
                          }

                          setState(() {
                            _sheetDragOffset =
                                math.max(0, _sheetDragOffset + delta);
                          });
                        },
                        onVerticalDragEnd: (details) {
                          final velocity = details.primaryVelocity ?? 0;
                          final shouldClose = _sheetDragOffset > 120 ||
                              (_sheetDragOffset > 56 && velocity > 1600);

                          if (shouldClose) {
                            setState(() {
                              _isDraggingSheet = false;
                            });
                            unawaited(Navigator.of(context).maybePop());
                            return;
                          }

                          setState(() {
                            _isDraggingSheet = false;
                            _sheetDragOffset = 0;
                          });
                        },
                        onVerticalDragCancel: () {
                          setState(() {
                            _isDraggingSheet = false;
                            _sheetDragOffset = 0;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AppBottomSheetDragHandle(),
                            const SizedBox(height: 14),
                            _CharacterAvatarUpdateHeader(
                              header: widget.header,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _CharacterAvatarEditor(
                        key: ValueKey<int>(_imageRevision),
                        imageBytes: _imageBytes,
                        controller: _editorController,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: isDark
                                    ? colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.5)
                                    : colorScheme.surfaceContainerHigh,
                                disabledBackgroundColor: colorScheme.onSurface
                                    .withValues(alpha: 0.08),
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                              onPressed: _isSubmitting ? null : _pickAgain,
                              child: const Text('重新选择'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                              onPressed: _isSubmitting ? null : _submit,
                              child: Text(_isSubmitting ? '更换中' : '更换头像'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 重新选择头像图片
  Future<void> _pickAgain() async {
    final pickedImage = await _pickAvatarImage(context);
    if (pickedImage == null || !mounted) {
      return;
    }

    setState(() {
      _editorController.dispose();
      _editorController = ImageEditorController();
      _imageBytes = pickedImage.bytes;
      _imageRevision += 1;
    });
  }

  /// 提交头像更换
  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final cropRect = _editorController.getCropRect();
    if (cropRect == null) {
      AppToast.error(context, text: '裁剪图片失败');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    unawaited(showAppLoadingDialog(context, message: '正在更换头像'));
    var refreshFailed = false;

    try {
      final avatarBytes = await compute(
        _buildAvatarJpegBytes,
        _AvatarCropRequest(
          bytes: _imageBytes,
          left: cropRect.left,
          top: cropRect.top,
          width: cropRect.width,
          height: cropRect.height,
        ),
      );
      final hash = widget.oosRepository.hashDataUrl(
        bytes: avatarBytes,
        contentType: _avatarContentType,
      );
      final avatarUrl = widget.oosRepository.buildUrl(
        path: 'avatar',
        hash: hash,
      );
      final signature = await widget.oosRepository.fetchSignature(
        path: 'avatar',
        hash: hash,
        contentType: _avatarContentType,
      );
      await widget.oosRepository.uploadBytes(
        url: avatarUrl,
        bytes: avatarBytes,
        contentType: _avatarContentType,
        signature: signature,
      );
      await widget.repository.changeCharacterAvatar(
        characterId: widget.header.characterId,
        avatarUrl: avatarUrl,
      );
      try {
        await widget.onAvatarChanged();
      } catch (_) {
        refreshFailed = true;
      }
    } catch (error) {
      if (rootNavigator.mounted) {
        rootNavigator.pop();
      }
      if (mounted) {
        AppToast.error(context, text: _messageForAvatarUpdateError(error));
        setState(() {
          _isSubmitting = false;
        });
      }
      return;
    }

    if (rootNavigator.mounted) {
      rootNavigator.pop();
    }
    if (!mounted) {
      return;
    }

    if (refreshFailed) {
      AppToast.error(context, text: '头像已更换，刷新角色数据失败');
    } else {
      AppToast.info(context, text: '更换头像成功');
    }
    Navigator.of(context).pop();
  }
}

/// 角色头像更换抽屉标题
class _CharacterAvatarUpdateHeader extends StatelessWidget {
  /// 创建角色头像更换抽屉标题
  ///
  /// [header] 已上市角色头部资料
  const _CharacterAvatarUpdateHeader({
    required this.header,
  });

  /// 已上市角色头部资料
  final CharacterDetailTradeHeader header;

  /// 构建角色头像更换抽屉标题
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final name = TinygrailFormatters.decodeHtmlEntities(header.name).trim();
    return AppBottomSheetHeader(
      icon: LucideIcons.imageUp,
      title: '更换头像',
      subtitle: name.isEmpty
          ? '#${header.characterId}'
          : '#${header.characterId} $name',
    );
  }
}

/// 角色头像裁剪编辑器
class _CharacterAvatarEditor extends StatelessWidget {
  /// 创建角色头像裁剪编辑器
  ///
  /// [key] Flutter 组件标识
  /// [imageBytes] 图片字节
  /// [controller] 图片裁剪控制器
  const _CharacterAvatarEditor({
    super.key,
    required this.imageBytes,
    required this.controller,
  });

  /// 图片字节
  final Uint8List imageBytes;

  /// 图片裁剪控制器
  final ImageEditorController controller;

  /// 构建角色头像裁剪编辑器
  ///
  /// [context] 当前组件树上下文
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHigh
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.34 : 0.48,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: ExtendedImage.memory(
            imageBytes,
            fit: BoxFit.contain,
            mode: ExtendedImageMode.editor,
            enableLoadState: true,
            cacheRawData: true,
            initEditorConfigHandler: (_) {
              return EditorConfig(
                maxScale: 4,
                cropRectPadding: const EdgeInsets.all(24),
                hitTestSize: 24,
                cropAspectRatio: CropAspectRatios.ratio1_1,
                initialCropAspectRatio: CropAspectRatios.ratio1_1,
                initCropRectType: InitCropRectType.imageRect,
                cornerColor: colorScheme.primary.withValues(alpha: 0.72),
                lineColor: colorScheme.outlineVariant.withValues(alpha: 0.52),
                controller: controller,
              );
            },
            loadStateChanged: (state) {
              if (state.extendedImageLoadState == LoadState.failed) {
                return Center(
                  child: Icon(
                    LucideIcons.imageOff,
                    size: 30,
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              }

              return null;
            },
          ),
        ),
      ),
    );
  }
}
