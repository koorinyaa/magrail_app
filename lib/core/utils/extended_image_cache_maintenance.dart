import 'package:extended_image/extended_image.dart';

/// 执行全屏看图缓存的静默清理
Future<void> maintainFullscreenImageCache() async {
  if (_isCleanupRunning) {
    return;
  }

  final now = DateTime.now();
  if (_lastCleanupAt != null &&
      now.difference(_lastCleanupAt!) < _cleanupThrottleDuration) {
    return;
  }

  _isCleanupRunning = true;
  try {
    await clearDiskCachedImages(duration: _cacheRetentionDuration);
    _lastCleanupAt = now;
  } catch (_) {
    // 静默清理失败时不打断正式看图流程
  } finally {
    _isCleanupRunning = false;
  }
}

const Duration _cacheRetentionDuration = Duration(days: 7);
const Duration _cleanupThrottleDuration = Duration(hours: 12);

DateTime? _lastCleanupAt;
bool _isCleanupRunning = false;
