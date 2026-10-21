import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Satu-satunya pintu keluar-masuk token. Tidak ada kode lain yang boleh
/// menyentuh FlutterSecureStorage / SharedPreferences untuk token.
///
/// Access token dipakai untuk request API, refresh token hanya untuk menukar
/// access token baru. Keduanya tidak pernah ditulis ke log penuh.
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  // ponytail: build web demo tanpa WebCrypto/https bisa gagal baca secure
  // storage, jadi nilai terakhir disimpan juga di memori. Hapus fallback ini
  // saat aplikasi selalu berjalan di https/perangkat.
  final Map<String, String> _memory = {};

  Future<void> save({required String access, required String refresh}) async {
    _memory[_accessKey] = access;
    _memory[_refreshKey] = refresh;
    await _write(_accessKey, access);
    await _write(_refreshKey, refresh);
  }

  Future<String?> readAccess() => _read(_accessKey);

  Future<String?> readRefresh() => _read(_refreshKey);

  Future<void> clear() async {
    _memory.clear();
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('token clear gagal: $e');
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('token write gagal: $e');
    }
  }

  Future<String?> _read(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) return value;
    } catch (e) {
      debugPrint('token read gagal: $e');
    }
    return _memory[key];
  }
}
