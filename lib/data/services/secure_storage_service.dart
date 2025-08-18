// lib/data/services/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _nisnKey = 'user_nisn';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> saveNisn(String nisn) async {
    await _storage.write(key: _nisnKey, value: nisn);
  }

  Future<String?> readNisn() async {
    return await _storage.read(key: _nisnKey);
  }

  Future<void> deleteNisn() async {
    await _storage.delete(key: _nisnKey);
  }
}
