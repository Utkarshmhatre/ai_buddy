import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing and retrieving the Gemini API key
/// Uses platform-specific secure storage (Keychain on iOS, Keystore on Android)
class ApiKeyService {
  static const String _apiKeyStorageKey = 'gemini_api_key';

  static final ApiKeyService _instance = ApiKeyService._internal();
  factory ApiKeyService() => _instance;
  ApiKeyService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    webOptions: WebOptions(
      dbName: 'ai_buddy_secure',
      publicKey: 'ai_buddy_public_key',
    ),
    lOptions: LinuxOptions(),
  );

  String? _cachedApiKey;

  /// Get the stored API key
  /// Returns the key from cache if available, otherwise reads from secure storage
  /// Falls back to dart-define environment variable if no stored key exists
  Future<String?> getApiKey() async {
    if (_cachedApiKey != null && _cachedApiKey!.isNotEmpty) {
      return _cachedApiKey;
    }

    try {
      final storedKey = await _secureStorage.read(key: _apiKeyStorageKey);
      if (storedKey != null && storedKey.isNotEmpty) {
        _cachedApiKey = storedKey;
        return storedKey;
      }
    } catch (e) {
      debugPrint('ApiKeyService: Error reading API key: $e');
    }

    // Fall back to dart-define environment variable
    const envKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (envKey.isNotEmpty) {
      return envKey;
    }

    return null;
  }

  /// Save the API key securely
  Future<bool> saveApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: _apiKeyStorageKey, value: apiKey);
      _cachedApiKey = apiKey;
      debugPrint('ApiKeyService: API key saved successfully');
      return true;
    } catch (e) {
      debugPrint('ApiKeyService: Error saving API key: $e');
      return false;
    }
  }

  /// Delete the stored API key
  Future<bool> deleteApiKey() async {
    try {
      await _secureStorage.delete(key: _apiKeyStorageKey);
      _cachedApiKey = null;
      debugPrint('ApiKeyService: API key deleted');
      return true;
    } catch (e) {
      debugPrint('ApiKeyService: Error deleting API key: $e');
      return false;
    }
  }

  /// Check if an API key is stored
  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Validate an API key format (basic validation)
  bool isValidApiKeyFormat(String apiKey) {
    // Gemini API keys are typically 39 characters starting with 'AI'
    // But we'll be lenient and just check for minimum length
    return apiKey.isNotEmpty && apiKey.length >= 20;
  }

  /// Clear cached key (useful when reloading app)
  void clearCache() {
    _cachedApiKey = null;
  }
}
