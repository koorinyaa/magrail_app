import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magrail_app/core/feedback/app_toast.dart';
import 'package:magrail_app/core/utils/user_error_message.dart';
import 'package:magrail_app/core/widgets/app_loading_dialog.dart';
import 'package:magrail_app/features/temple/model/temple_asset_card_data.dart';
import 'package:mime/mime.dart';

/// 更新圣殿资产封面
///
/// [context] 当前组件树上下文
/// [data] 圣殿资产卡片展示数据
Future<void> updateTempleAssetCover(
  BuildContext context, {
  required TempleAssetCardData data,
}) async {
  final actionContext = data.actionContext;
  if (actionContext == null) {
    AppToast.error(context, text: '缺少操作上下文');
    return;
  }

  late final XFile? pickedFile;
  late final Uint8List bytes;
  try {
    pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) {
      return;
    }

    bytes = await pickedFile.readAsBytes();
  } catch (_) {
    if (context.mounted) {
      AppToast.error(context, text: '读取图片失败');
    }
    return;
  }

  if (!context.mounted) {
    return;
  }

  if (bytes.isEmpty) {
    AppToast.error(context, text: '图片文件为空');
    return;
  }

  final contentType = _resolveImageContentType(pickedFile, bytes);
  if (contentType == null || !contentType.startsWith('image/')) {
    AppToast.error(context, text: '请选择图片文件');
    return;
  }

  final rootNavigator = Navigator.of(context, rootNavigator: true);
  unawaited(showAppLoadingDialog(context, message: '正在更换封面'));
  var refreshFailed = false;

  try {
    final hash = actionContext.oosRepository.hashDataUrl(
      bytes: bytes,
      contentType: contentType,
    );
    final coverUrl = actionContext.oosRepository.buildUrl(
      path: 'cover',
      hash: hash,
    );
    final signature = await actionContext.oosRepository.fetchSignature(
      path: 'cover',
      hash: hash,
      contentType: contentType,
    );
    await actionContext.oosRepository.uploadBytes(
      url: coverUrl,
      bytes: bytes,
      contentType: contentType,
      signature: signature,
    );
    await actionContext.templeRepository.changeTempleCover(
      characterId: data.characterId,
      coverUrl: coverUrl,
    );
    try {
      await actionContext.onActionCompleted?.call();
    } catch (_) {
      refreshFailed = true;
    }
  } catch (error) {
    if (rootNavigator.mounted) {
      rootNavigator.pop();
    }
    if (context.mounted) {
      AppToast.error(context, text: _messageForCoverUpdateError(error));
    }
    return;
  }

  if (rootNavigator.mounted) {
    rootNavigator.pop();
  }
  if (context.mounted) {
    if (refreshFailed) {
      AppToast.error(context, text: '封面已更换，刷新圣殿数据失败');
    } else {
      AppToast.info(context, text: '更换封面成功');
    }
  }
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

/// 转换封面更新错误文案
///
/// [error] 封面更新异常
String _messageForCoverUpdateError(Object error) {
  return resolveUserErrorMessage(error, fallback: '更换封面失败');
}
