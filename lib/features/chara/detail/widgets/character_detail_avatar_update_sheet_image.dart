part of 'character_detail_avatar_update_sheet.dart';

/// 已选择的头像图片
final class _PickedAvatarImage {
  /// 创建已选择的头像图片
  ///
  /// [bytes] 图片字节
  const _PickedAvatarImage({
    required this.bytes,
  });

  /// 图片字节
  final Uint8List bytes;
}

/// 头像裁剪请求
final class _AvatarCropRequest {
  /// 创建头像裁剪请求
  ///
  /// [bytes] 原图字节
  /// [left] 裁剪区域左侧位置
  /// [top] 裁剪区域顶部位置
  /// [width] 裁剪区域宽度
  /// [height] 裁剪区域高度
  const _AvatarCropRequest({
    required this.bytes,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// 原图字节
  final Uint8List bytes;

  /// 裁剪区域左侧位置
  final double left;

  /// 裁剪区域顶部位置
  final double top;

  /// 裁剪区域宽度
  final double width;

  /// 裁剪区域高度
  final double height;
}

/// 选择头像图片
///
/// [context] 当前组件树上下文
Future<_PickedAvatarImage?> _pickAvatarImage(BuildContext context) async {
  late final XFile? pickedFile;
  late final Uint8List bytes;
  try {
    pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return null;
    }

    bytes = await pickedFile.readAsBytes();
  } catch (_) {
    if (context.mounted) {
      AppToast.error(context, text: '读取图片失败');
    }
    return null;
  }

  if (!context.mounted) {
    return null;
  }

  if (bytes.isEmpty) {
    AppToast.error(context, text: '图片文件为空');
    return null;
  }

  final contentType = _resolveImageContentType(pickedFile, bytes);
  if (contentType == null || !contentType.startsWith('image/')) {
    AppToast.error(context, text: '请选择图片文件');
    return null;
  }

  return _PickedAvatarImage(bytes: bytes);
}

/// 解析图片 MIME 类型
///
/// [pickedFile] 选择的图片文件
/// [bytes] 图片字节
String? _resolveImageContentType(XFile pickedFile, List<int> bytes) {
  final pickedMimeType = pickedFile.mimeType?.trim();
  if (pickedMimeType != null && pickedMimeType.isNotEmpty) {
    return pickedMimeType;
  }

  final pathMimeType = lookupMimeType(
    pickedFile.path,
    headerBytes: bytes,
  )?.trim();
  if (pathMimeType != null && pathMimeType.isNotEmpty) {
    return pathMimeType;
  }

  return lookupMimeType(
    pickedFile.name,
    headerBytes: bytes,
  )?.trim();
}

/// 生成角色头像 JPEG 字节
///
/// [request] 头像裁剪请求
Uint8List _buildAvatarJpegBytes(_AvatarCropRequest request) {
  final decoded = image.decodeImage(request.bytes);
  if (decoded == null) {
    throw StateError('读取图片失败');
  }

  final source = image.bakeOrientation(decoded);
  final maxCropSize = math.min(source.width, source.height);
  final cropSize = math
      .min(request.width, request.height)
      .round()
      .clamp(1, maxCropSize)
      .toInt();
  final cropX = request.left
      .round()
      .clamp(0, math.max(0, source.width - cropSize))
      .toInt();
  final cropY = request.top
      .round()
      .clamp(0, math.max(0, source.height - cropSize))
      .toInt();

  final cropped = image.copyCrop(
    source,
    x: cropX,
    y: cropY,
    width: cropSize,
    height: cropSize,
  );
  final resized = image.copyResize(
    cropped,
    width: _avatarOutputSize,
    height: _avatarOutputSize,
    interpolation: image.Interpolation.average,
  );
  final encoded = image.encodeJpg(resized, quality: _avatarJpegQuality);
  return Uint8List.fromList(encoded);
}

/// 转换头像更换错误文案
///
/// [error] 头像更换异常
String _messageForAvatarUpdateError(Object error) {
  return resolveUserErrorMessage(error, fallback: '更换头像失败');
}
