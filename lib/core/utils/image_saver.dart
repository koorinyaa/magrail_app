import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

  final ImageSaveStatus status;
  final String message;

  /// 是否保存成功
  bool get isSuccess => status == ImageSaveStatus.success;
}

/// 保存网络图片到系统相册
///
/// [imageUrl] 图片地址
Future<ImageSaveResult> saveImageToGallery(String imageUrl) async {
  if (kIsWeb) {
    return const ImageSaveResult(
      status: ImageSaveStatus.unsupportedPlatform,
      message: '当前平台不支持保存图片',
    );
  }

  final hasAccess = await Gal.hasAccess(toAlbum: true);
  final granted = hasAccess || await Gal.requestAccess(toAlbum: true);
  if (!granted) {
    return const ImageSaveResult(
      status: ImageSaveStatus.permissionDenied,
      message: '未授予相册权限',
    );
  }

  File? tempFile;
  try {
    tempFile = await _downloadImageToTempFile(imageUrl);
    if (tempFile == null || !tempFile.existsSync()) {
      return const ImageSaveResult(
        status: ImageSaveStatus.downloadFailed,
        message: '图片下载失败',
      );
    }

    await Gal.putImage(tempFile.path, album: 'magrail');
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
    if (tempFile != null && tempFile.existsSync()) {
      await tempFile.delete();
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
    final response = await Dio().get<List<int>>(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
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
