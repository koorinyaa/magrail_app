import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

/// 图片保存状态
enum ImageSaveStatus {
  /// 保存成功
  success,

  /// 当前平台不支持
  unsupportedPlatform,

  /// 未授予相册权限
  permissionDenied,

  /// 图片下载失败
  downloadFailed,

  /// 写入系统相册失败
  saveFailed,
}

/// 图片保存结果
class ImageSaveResult {
  /// 创建图片保存结果
  ///
  /// [status] 保存状态
  /// [message] 提示文案
  const ImageSaveResult({
    required this.status,
    required this.message,
  });

  /// 保存状态
  final ImageSaveStatus status;

  /// 提示文案
  final String message;

  /// 是否保存成功
  bool get isSuccess => status == ImageSaveStatus.success;
}

/// 保存网络图片到系统相册
///
/// [imageUrl] 图片地址
Future<ImageSaveResult> saveImageToGallery(String imageUrl) async {
  return _saveImageFileToGallery(() => _downloadImageToTempFile(imageUrl));
}

/// 保存资源图片到系统相册
///
/// [assetName] 资源图片路径
Future<ImageSaveResult> saveAssetImageToGallery(String assetName) async {
  return _saveImageFileToGallery(() => _writeAssetImageToTempFile(assetName));
}

/// 保存图片字节到系统相册
///
/// [bytes] PNG 图片字节
/// [imageName] 不含扩展名的相册图片名称
Future<ImageSaveResult> saveImageBytesToGallery(
  Uint8List bytes, {
  required String imageName,
}) async {
  if (kIsWeb) {
    return const ImageSaveResult(
      status: ImageSaveStatus.unsupportedPlatform,
      message: '当前平台不支持保存图片',
    );
  }
  if (bytes.isEmpty) {
    return const ImageSaveResult(
      status: ImageSaveStatus.saveFailed,
      message: '图片数据为空',
    );
  }

  try {
    final hasAccess = await Gal.hasAccess(toAlbum: true);
    final granted = hasAccess || await Gal.requestAccess(toAlbum: true);
    if (!granted) {
      return const ImageSaveResult(
        status: ImageSaveStatus.permissionDenied,
        message: '未授予相册权限',
      );
    }

    await Gal.putImageBytes(
      bytes,
      album: 'magrail',
      name: imageName,
    );
    return const ImageSaveResult(
      status: ImageSaveStatus.success,
      message: '图片已保存',
    );
  } catch (_) {
    return const ImageSaveResult(
      status: ImageSaveStatus.saveFailed,
      message: '写入相册失败',
    );
  }
}

/// 保存临时图片文件到系统相册
///
/// [tempFileLoader] 临时图片文件加载器
Future<ImageSaveResult> _saveImageFileToGallery(
  Future<File?> Function() tempFileLoader,
) async {
  if (kIsWeb) {
    return const ImageSaveResult(
      status: ImageSaveStatus.unsupportedPlatform,
      message: '当前平台不支持保存图片',
    );
  }

  File? tempFile;
  try {
    final hasAccess = await Gal.hasAccess(toAlbum: true);
    final granted = hasAccess || await Gal.requestAccess(toAlbum: true);
    if (!granted) {
      return const ImageSaveResult(
        status: ImageSaveStatus.permissionDenied,
        message: '未授予相册权限',
      );
    }

    tempFile = await tempFileLoader();
    final file = tempFile;
    if (file == null || !await file.exists()) {
      return const ImageSaveResult(
        status: ImageSaveStatus.downloadFailed,
        message: '图片下载失败',
      );
    }

    await Gal.putImage(file.path, album: 'magrail');
    return const ImageSaveResult(
      status: ImageSaveStatus.success,
      message: '图片已保存',
    );
  } catch (_) {
    return const ImageSaveResult(
      status: ImageSaveStatus.saveFailed,
      message: '写入相册失败',
    );
  } finally {
    final file = tempFile;
    if (file != null) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // 临时文件清理失败不影响已经返回的相册保存结果
      }
    }
  }
}

/// 下载网络图片到临时文件
///
/// [imageUrl] 图片地址
Future<File?> _downloadImageToTempFile(String imageUrl) async {
  try {
    final temporaryDirectory = await getTemporaryDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File('${temporaryDirectory.path}/$fileName');
    // 图片保存是用户主动操作，连接和发送最多等待十五秒，响应最多等待三十秒
    final response = await Dio().get<List<int>>(
      imageUrl,
      options: Options(
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.bytes,
      ),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    await file.writeAsBytes(bytes, flush: true);
    return file;
  } catch (_) {
    return null;
  }
}

/// 写入资源图片到临时文件
///
/// [assetName] 资源图片路径
Future<File?> _writeAssetImageToTempFile(String assetName) async {
  try {
    final temporaryDirectory = await getTemporaryDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File('${temporaryDirectory.path}/$fileName');
    final bytes = await rootBundle.load(assetName);
    await file.writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      flush: true,
    );
    return file;
  } catch (_) {
    return null;
  }
}
