import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magrail_app/core/utils/image_saver.dart';

/// 验证图片保存平台异常不会越过保存结果边界
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('文件图片保存的平台通道异常返回失败结果', () async {
    const channel = MethodChannel('gal');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(
        code: 'TEST_GALLERY_FAILURE',
        message: 'test gallery failure',
      );
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(channel, null);
    });

    final result = await saveAssetImageToGallery(
      'assets/icons/app_icon_cropped.png',
    );

    expect(result.status, ImageSaveStatus.saveFailed);
    expect(result.message, '写入相册失败');
  });
}
