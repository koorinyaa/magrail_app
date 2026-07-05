import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 安全存储
class SecureStorage {
  /// 创建安全存储
  ///
  /// [_storage] 安全存储实例
  const SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  /// 读取安全存储值
  ///
  /// [key] 存储键
  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  /// 写入安全存储值
  ///
  /// [key] 存储键
  /// [value] 字符串值
  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  /// 删除安全存储值
  ///
  /// [key] 存储键
  Future<void> delete(String key) {
    return _storage.delete(key: key);
  }
}
