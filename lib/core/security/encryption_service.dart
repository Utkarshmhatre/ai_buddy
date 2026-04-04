import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as crypto;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for encrypting/decrypting sensitive data
/// Uses AES-256 encryption with secure key storage
class EncryptionService {
  static const String _keyStorageKey = 'encryption_key';
  static const String _ivStorageKey = 'encryption_iv';
  
  final FlutterSecureStorage _secureStorage;
  crypto.Key? _key;
  crypto.IV? _iv;
  crypto.Encrypter? _encrypter;

  EncryptionService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  /// Initialize encryption with stored or new keys
  Future<void> initialize() async {
    String? storedKey = await _secureStorage.read(key: _keyStorageKey);
    String? storedIv = await _secureStorage.read(key: _ivStorageKey);

    if (storedKey == null || storedIv == null) {
      // Generate new secure keys
      final keyBytes = _generateSecureBytes(32); // 256 bits
      final ivBytes = _generateSecureBytes(16); // 128 bits
      
      storedKey = base64Encode(keyBytes);
      storedIv = base64Encode(ivBytes);
      
      await _secureStorage.write(key: _keyStorageKey, value: storedKey);
      await _secureStorage.write(key: _ivStorageKey, value: storedIv);
    }

    _key = crypto.Key(Uint8List.fromList(base64Decode(storedKey)));
    _iv = crypto.IV(Uint8List.fromList(base64Decode(storedIv)));
    _encrypter = crypto.Encrypter(crypto.AES(_key!, mode: crypto.AESMode.cbc));
  }

  /// Generate cryptographically secure random bytes
  Uint8List _generateSecureBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  /// Encrypt a string
  String encrypt(String plainText) {
    if (_encrypter == null || _iv == null) {
      throw StateError('EncryptionService not initialized. Call initialize() first.');
    }
    final encrypted = _encrypter!.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypt a string
  String decrypt(String encryptedText) {
    if (_encrypter == null || _iv == null) {
      throw StateError('EncryptionService not initialized. Call initialize() first.');
    }
    final decrypted = _encrypter!.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }

  /// Encrypt a Map (converts to JSON first)
  String encryptMap(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    return encrypt(jsonString);
  }

  /// Decrypt to a Map
  Map<String, dynamic> decryptMap(String encryptedText) {
    final jsonString = decrypt(encryptedText);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Check if service is initialized
  bool get isInitialized => _encrypter != null;

  /// Clear all encryption keys (use for logout/account deletion)
  Future<void> clearKeys() async {
    await _secureStorage.delete(key: _keyStorageKey);
    await _secureStorage.delete(key: _ivStorageKey);
    _key = null;
    _iv = null;
    _encrypter = null;
  }

  /// Rotate encryption keys (re-encrypt all data with new keys)
  /// Returns new key for re-encryption process
  Future<void> rotateKeys({
    required Future<void> Function(String Function(String) reEncrypt) onReEncrypt,
  }) async {
    // Store old encrypter
    final oldEncrypter = _encrypter;
    final oldIv = _iv;
    
    // Generate new keys
    final newKeyBytes = _generateSecureBytes(32);
    final newIvBytes = _generateSecureBytes(16);
    
    final newKey = crypto.Key(newKeyBytes);
    final newIv = crypto.IV(newIvBytes);
    final newEncrypter = crypto.Encrypter(crypto.AES(newKey, mode: crypto.AESMode.cbc));

    // Re-encryption function
    String reEncrypt(String oldEncryptedText) {
      final plainText = oldEncrypter!.decrypt64(oldEncryptedText, iv: oldIv);
      return newEncrypter.encrypt(plainText, iv: newIv).base64;
    }

    // Callback to re-encrypt all data
    await onReEncrypt(reEncrypt);

    // Store new keys
    await _secureStorage.write(key: _keyStorageKey, value: base64Encode(newKeyBytes));
    await _secureStorage.write(key: _ivStorageKey, value: base64Encode(newIvBytes));

    // Update instance
    _key = newKey;
    _iv = newIv;
    _encrypter = newEncrypter;
  }
}
